codeunit 4708 "VAT Group Settlement"
{
    TableNo = "VAT Report Header";

    var
        VATReportSetup: Record "VAT Report Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoDueBoxNoErr: Label 'The VAT Due Box No. is missing in VAT Report Setup.';
        NoVATSettlementAccountErr: Label 'The VAT Settlement Account is missing in VAT Report Setup.';
        NoGroupSettlementAccountErr: Label 'The Group Settlement Account is missing in VAT Report Setup.';
        NoGroupSettlementGenJnlTemplateErr: Label 'The Group Settlement General Journal Template is missing in VAT Report Setup.';
        NoGLAccountErr: Label 'The General Ledger Account %1 does not exist.', Comment = '%1 is a general ledger account no.';
        VATSettlementTxt: Label 'VAT Settlement for %1. %2 - %3', Comment = '%1 is the name of a VAT group member. %2 and %3 are dates';
        VATGroupSettlementTxt: Label 'VAT Due from %1. %2 - %3', Comment = '%1 is the name of a VAT group member. %2 and %3 are dates';

    trigger OnRun()
    begin
        CheckPrerequisites();
        Post(Rec."No.");
        Rec."VAT Group Settlement Posted" := true;
    end;

    local procedure Post(VATReportHeaderNo: Code[20])
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocNo: Code[20];
        VATAmount: Decimal;
    begin
        VATGroupSubmissionHeader.SetRange("VAT Group Return No.", VATReportHeaderNo);
        if VATGroupSubmissionHeader.FindSet() then begin
            DocNo := NoSeriesManagement.GetNextNo(GenJournalTemplate."No. Series", 0D, true);
            repeat
                VATAmount := FindVATAmount(VATGroupSubmissionHeader);

                if VATAmount <> 0 then begin
                    PrepareVATSettlementGenJnlLine(GenJournalLine, VATGroupSubmissionHeader, DocNo, GenJournalTemplate.Name, VATReportSetup."VAT Settlement Account", VATSettlementTxt, VATAmount);
                    PostGenJnlLine(GenJournalLine);
                    PrepareVATSettlementGenJnlLine(GenJournalLine, VATGroupSubmissionHeader, DocNo, GenJournalTemplate.Name, VATReportSetup."Group Settlement Account", VATGroupSettlementTxt, VATAmount * -1);
                    PostGenJnlLine(GenJournalLine);
                end
            until VATGroupSubmissionHeader.Next() = 0;
        end
    end;

    local procedure PrepareVATSettlementGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; VATGroupSubmissionHeader: Record "VAT Group Submission Header"; DocNo: Code[20]; JournalTemplateName: Code[10]; AccountNo: Code[20]; Description: Text[100]; VATAmount: Decimal)
    begin
        Clear(GenJournalLine);
        FillDefaultGeneralJournalLine(GenJournalLine, DocNo, JournalTemplateName);
        GenJournalLine.Validate("Account No.", AccountNo);
        VATGroupSubmissionHeader.CalcFields("Group Member Name");
        GenJournalLine.Description := StrSubstNo(Description, VATGroupSubmissionHeader."Group Member Name", VATGroupSubmissionHeader."Start Date", VATGroupSubmissionHeader."End Date");
        GenJournalLine.Amount := VATAmount;
    end;

    local procedure PostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Account No.");
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Bal. Account No.");
        GenJournalLine."Dimension Set ID" :=
          DimensionManagement.GetRecDefaultDimID(
            GenJournalLine, 0, DefaultDimSource, GenJournalLine."Source Code",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", 0, 0);
        GenJnlPostLine.Run(GenJournalLine);
    end;

    local procedure FillDefaultGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocNo: Code[20]; JournalTemplateName: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Posting Date" := WorkDate();
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."Document No." := DocNo;
        SourceCodeSetup.Get();
        GenJournalLine."Source Code" := SourceCodeSetup."VAT Settlement";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
    end;

    local procedure FindVATAmount(VATGroupSubmissionHeader: Record "VAT Group Submission Header"): Decimal
    var
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
    begin
        VATGroupSubmissionLine.SetRange("VAT Group Submission ID", VATGroupSubmissionHeader.ID);
        VATGroupSubmissionLine.SetRange("Box No.", VATReportSetup."VAT Due Box No.");
        if not VATGroupSubmissionLine.FindFirst() then
            exit(0);

        exit(VATGroupSubmissionLine.Amount);
    end;

    local procedure CheckPrerequisites()
    begin
        VATReportSetup.Get();

        if VATReportSetup."VAT Due Box No." = '' then
            Error(NoDueBoxNoErr);

        if VATReportSetup."VAT Settlement Account" = '' then
            Error(NoVATSettlementAccountErr);

        if VATReportSetup."Group Settlement Account" = '' then
            Error(NoGroupSettlementAccountErr);

        if VATReportSetup."Group Settle. Gen. Jnl. Templ." = '' then
            Error(NoGroupSettlementGenJnlTemplateErr);

        CheckGLAccount(VATReportSetup."VAT Settlement Account", false);
        CheckGLAccount(VATReportSetup."Group Settlement Account", true);

        GenJournalTemplate.Get(VATReportSetup."Group Settle. Gen. Jnl. Templ.");
        GenJournalTemplate.TestField("No. Series");
    end;

    local procedure CheckGLAccount(GLAccountNo: Code[20]; IsAsset: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(GLAccountNo) then
            Error(NoGLAccountErr, GLAccountNo);

        GLAccount.TestField("Gen. Posting Type", GLAccount."Gen. Posting Type"::" ");
        GLAccount.TestField("VAT Prod. Posting Group", '');
        if VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then
            VATPostingSetup.TestField("VAT %", 0);
        GLAccount.TestField("Gen. Bus. Posting Group", '');
        GLAccount.TestField("Gen. Prod. Posting Group", '');

        if IsAsset then
            GLAccount.TestField("Account Category", GLAccount."Account Category"::Assets)
        else
            GLAccount.TestField("Account Category", GLAccount."Account Category"::Liabilities);
    end;
}