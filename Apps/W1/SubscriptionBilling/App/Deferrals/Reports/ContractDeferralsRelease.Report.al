namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Sales.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

report 8051 "Contract Deferrals Release"
{
    ApplicationArea = All;
    Caption = 'Subscription Contract Deferrals Release';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDateReq; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date on which the release is posted.';
                    }
                    field(PostUntilDateReq; PostUntilDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post Until Date';
                        ToolTip = 'Specifies the date up to which contract deferrals are considered for release.';

                        trigger OnValidate()
                        begin
                            if PostUntilDate > PostingDate then
                                Error(PostUntilDateMustBeBeforePostingDateErr);
                        end;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        LineNo := 0;
        PostingDate := WorkDate();
        PostUntilDate := WorkDate();
        AllowGUI := true;
    end;

    trigger OnPreReport()
    begin
        TestDates();
        GetAndTestSourceCode();
        GetGeneralLedgerSetupAndCheckJournalTemplateAndBatch();

        FilterAndCountContractDeferrals();

        Window.Open(ContractDeferralsReleaseTxt + ContractProgressTxt);

        ReleaseAllCustomerContractDeferralsAndInsertTempGenJournalLines();
        PostTempGenJnlLineBufferForCustomerDeferrals();
        ReleaseAllVendorContractDeferralsAndInsertTempGenJournalLines();
        PostTempGenJnlLineBufferForVendorDeferrals();
    end;

    trigger OnPostReport()
    begin
        Window.Close();
    end;

    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        ServiceContractSetup: Record "Subscription Contract Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        GenPostingSetup: Record "General Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
        PurchaseSetup: Record "Purchases & Payables Setup";
        GlobalCustomerContractDeferral: Record "Cust. Sub. Contract Deferral";
        GlobalVendorContractDeferral: Record "Vend. Sub. Contract Deferral";
        CustomerDeferralsMngmt: Codeunit "Customer Deferrals Mngmt.";
        VendorDeferralsMngmt: Codeunit "Vendor Deferrals Mngmt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Window: Dialog;
        PostingDate: Date;
        PostUntilDate: Date;
        ContractDeferralIteration: Integer;
        TotalContractDeferralsCount: Integer;
        LineDiscountPosting: Boolean;
        PostingDateIsEmptyErr: Label 'You must fill in the Posting Date field.';
        PostUntilDateIsEmptyErr: Label 'You must fill in the Post Until Date field.';
        PostUntilDateMustBeBeforePostingDateErr: Label 'Posting until Date must be before then Posting Date.';
        ContractDeferralsReleaseTxt: Label 'Contract Deferrals Release...\';
        ContractProgressTxt: Label 'Contract: #1###############\\@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', Comment = '%1=Contract No., %2=Progress';
        ReleasingOfContractNoTxt: Label 'Release Contract Deferral of %1.', Comment = '%1 = Posting Date in format <Month Text> <Year4>';
        AllowGUI: Boolean;
        LineNo: Integer;

    local procedure TestDates()
    begin
        if PostUntilDate = 0D then
            Error(PostUntilDateIsEmptyErr);
        if PostingDate = 0D then
            Error(PostingDateIsEmptyErr);
        if PostUntilDate > PostingDate then
            Error(PostUntilDateMustBeBeforePostingDateErr);
    end;

    local procedure FilterAndCountContractDeferrals()
    begin
        ContractDeferralIteration := 0;

        GlobalCustomerContractDeferral.SetRange("Posting Date", 0D, PostUntilDate);
        GlobalCustomerContractDeferral.SetRange("Document Posting Date", 0D, PostUntilDate);
        GlobalCustomerContractDeferral.SetRange(Released, false);
        GlobalVendorContractDeferral.SetRange("Posting Date", 0D, PostUntilDate);
        GlobalVendorContractDeferral.SetRange("Document Posting Date", 0D, PostUntilDate);
        GlobalVendorContractDeferral.SetRange(Released, false);
        TotalContractDeferralsCount := GlobalVendorContractDeferral.Count + GlobalCustomerContractDeferral.Count;
    end;

    local procedure ReleaseAllCustomerContractDeferralsAndInsertTempGenJournalLines()
    begin
        if GlobalCustomerContractDeferral.FindSet() then begin
            GetLineDiscountPostingSetup(Enum::"Service Partner"::Customer);
            repeat
                ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(GlobalCustomerContractDeferral);
            until GlobalCustomerContractDeferral.Next() = 0;
        end;
    end;

    internal procedure ReleaseCustomerContractDeferralAndInsertTempGenJournalLine(var CustomerContractDeferral: Record "Cust. Sub. Contract Deferral")
    var
        GenBusPostingGroup: Code[20];
        GenProdPostingGroup: Code[20];
    begin
        if not CustomerContractDeferral.GetDocumentPostingGroups(GenBusPostingGroup, GenProdPostingGroup) then
            exit;
        CheckGenPostingSetup(GenBusPostingGroup, GenProdPostingGroup, Enum::"Service Partner"::Customer);
        ReleaseContractDeferral(Enum::"Service Partner"::Customer, CustomerContractDeferral."Entry No.");
        InsertTempGenJournalLine(
            CustomerContractDeferral."Document No.",
            CustomerContractDeferral."Subscription Contract No.",
            CustomerContractDeferral."Entry No.",
            CustomerContractDeferral."Dimension Set ID",
            GenPostingSetup."Cust. Sub. Contract Account",
            GenPostingSetup."Cust. Sub. Contr. Def Account",
            GenBusPostingGroup,
            GenProdPostingGroup,
            GetPostingAmount(CustomerContractDeferral.Amount, CustomerContractDeferral."Discount Amount"));
        if LineDiscountPosting and (CustomerContractDeferral."Discount Amount" <> 0) then
            InsertTempGenJournalLine(
                CustomerContractDeferral."Document No.",
                CustomerContractDeferral."Subscription Contract No.",
                CustomerContractDeferral."Entry No.",
                CustomerContractDeferral."Dimension Set ID",
                GenPostingSetup."Sales Line Disc. Account",
                GenPostingSetup."Cust. Sub. Contr. Def Account",
                GenBusPostingGroup,
                GenProdPostingGroup,
                -CustomerContractDeferral."Discount Amount");
    end;

    local procedure ReleaseAllVendorContractDeferralsAndInsertTempGenJournalLines()
    begin
        if GlobalVendorContractDeferral.FindSet() then begin
            GetLineDiscountPostingSetup(Enum::"Service Partner"::Vendor);
            repeat
                ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(GlobalVendorContractDeferral);
            until GlobalVendorContractDeferral.Next() = 0;
        end;
    end;

    internal procedure ReleaseVendorContractDeferralsAndInsertTempGenJournalLines(var VendorContractDeferral: Record "Vend. Sub. Contract Deferral")
    var
        GenBusPostingGroup: Code[20];
        GenProdPostingGroup: Code[20];
    begin
        if not VendorContractDeferral.GetDocumentPostingGroups(GenBusPostingGroup, GenProdPostingGroup) then
            exit;
        CheckGenPostingSetup(GenBusPostingGroup, GenProdPostingGroup, Enum::"Service Partner"::Vendor);
        ReleaseContractDeferral(Enum::"Service Partner"::Vendor, VendorContractDeferral."Entry No.");
        InsertTempGenJournalLine(
            VendorContractDeferral."Document No.",
            VendorContractDeferral."Subscription Contract No.",
            VendorContractDeferral."Entry No.",
            VendorContractDeferral."Dimension Set ID",
            GenPostingSetup."Vend. Sub. Contract Account",
            GenPostingSetup."Vend. Sub. Contr. Def. Account",
            GenBusPostingGroup,
            GenProdPostingGroup,
            GetPostingAmount(VendorContractDeferral.Amount, VendorContractDeferral."Discount Amount"));
        if LineDiscountPosting and (VendorContractDeferral."Discount Amount" <> 0) then
            InsertTempGenJournalLine(
                VendorContractDeferral."Document No.",
                VendorContractDeferral."Subscription Contract No.",
                VendorContractDeferral."Entry No.",
                VendorContractDeferral."Dimension Set ID",
                GenPostingSetup."Purch. Line Disc. Account",
                GenPostingSetup."Vend. Sub. Contr. Def. Account",
                GenBusPostingGroup,
                GenProdPostingGroup,
                -VendorContractDeferral."Discount Amount");
    end;

    local procedure GetLineDiscountPostingSetup(Partner: Enum "Service Partner")
    begin
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    SalesSetup.Get();
                    LineDiscountPosting := SalesSetup."Discount Posting" in
                       [SalesSetup."Discount Posting"::"Line Discounts", SalesSetup."Discount Posting"::"All Discounts"];
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    PurchaseSetup.Get();
                    LineDiscountPosting := PurchaseSetup."Discount Posting" in
                       [PurchaseSetup."Discount Posting"::"Line Discounts", PurchaseSetup."Discount Posting"::"All Discounts"];
                end;
        end;
    end;

    local procedure CheckGenPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; Partner: Enum "Service Partner")
    begin
        GenPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        case Partner of
            Enum::"Service Partner"::Customer:
                begin
                    GenPostingSetup.TestField("Cust. Sub. Contract Account");
                    if LineDiscountPosting then
                        GenPostingSetup.TestField("Sales Line Disc. Account");
                end;
            Enum::"Service Partner"::Vendor:
                begin
                    GenPostingSetup.TestField("Vend. Sub. Contract Account");
                    if LineDiscountPosting then
                        GenPostingSetup.TestField("Purch. Line Disc. Account");
                end;
        end;
    end;

    local procedure ReleaseContractDeferral(Partner: Enum "Service Partner"; DeferralEntryNo: Integer)
    var
        CustContractDeferralsToUpdate: Record "Cust. Sub. Contract Deferral";
        VendContractDeferralsToUpdate: Record "Vend. Sub. Contract Deferral";
    begin
        case Partner of
            Enum::"Service Partner"::Customer:
                if CustContractDeferralsToUpdate.Get(DeferralEntryNo) then begin
                    CustContractDeferralsToUpdate.Released := true;
                    CustContractDeferralsToUpdate."Release Posting Date" := PostingDate;
                    CustContractDeferralsToUpdate.Modify(false);
                end;
            Enum::"Service Partner"::Vendor:
                if VendContractDeferralsToUpdate.Get(DeferralEntryNo) then begin
                    VendContractDeferralsToUpdate.Released := true;
                    VendContractDeferralsToUpdate."Release Posting Date" := PostingDate;
                    VendContractDeferralsToUpdate.Modify(false);
                end;
        end;
    end;

    local procedure GetPostingAmount(Amount: Decimal; DiscountAmount: Decimal): Decimal
    begin
        if LineDiscountPosting then
            exit(Amount + DiscountAmount)
        else
            exit(Amount);
    end;

    local procedure InsertTempGenJournalLine(DocumentNo: Code[20]; ContractNo: Code[20]; DeferralEntryNo: Integer; DimSetID: Integer; AccountNo: Code[20]; BalAccountNo: Code[20]; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; PostingAmount: Decimal)
    begin
        UpdateWindow(ContractNo);
        InsertTempGenJournalLine(DocumentNo, ContractNo, DeferralEntryNo, DimSetID, AccountNo, BalAccountNo, PostingAmount, GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure InsertTempGenJournalLine(DocumentNo: Code[20]; ContractNo: Code[20]; DeferralEntryNo: Integer; DimSetID: Integer; AccountNo: Code[20]; BalAccountNo: Code[20]; PostingAmount: Decimal; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        LineNo += 1;
        TempGenJournalLine."Account No." := AccountNo;
        TempGenJournalLine."Bal. Account No." := BalAccountNo;
        TempGenJournalLine."Document No." := DocumentNo;
        TempGenJournalLine."Subscription Contract No." := ContractNo;
        TempGenJournalLine."Gen. Bus. Posting Group" := GenBusPostingGroup;
        TempGenJournalLine."Gen. Prod. Posting Group" := GenProdPostingGroup;
        TempGenJournalLine."Dimension Set ID" := DimSetID;
        TempGenJournalLine.Amount := PostingAmount;
        TempGenJournalLine."Line No." := LineNo;
        TempGenJournalLine."Deferral Line No." := DeferralEntryNo;
        TempGenJournalLine.Insert(false);
    end;

    internal procedure PostTempGenJnlLineBufferForCustomerDeferrals()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetCurrentKey("Document No.", "Subscription Contract No.", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
        if TempGenJournalLine.FindSet() then
            repeat
                CustomerDeferralsMngmt.SetDeferralNo(TempGenJournalLine."Deferral Line No.");
                PostGenJnlLine(TempGenJournalLine, PostingDate, SourceCodeSetup."Sub. Contr. Deferrals Release");
            until TempGenJournalLine.Next() = 0;
        ResetTempGenJournalLine();
        CustomerDeferralsMngmt.SetDeferralNo(0);
    end;

    internal procedure PostTempGenJnlLineBufferForVendorDeferrals()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetCurrentKey("Document No.", "Subscription Contract No.", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
        if TempGenJournalLine.FindSet() then
            repeat
                VendorDeferralsMngmt.SetDeferralNo(TempGenJournalLine."Deferral Line No.");
                PostGenJnlLine(TempGenJournalLine, PostingDate, SourceCodeSetup."Sub. Contr. Deferrals Release");
                VendorDeferralsMngmt.SetDeferralNo(0);
            until TempGenJournalLine.Next() = 0;
        ResetTempGenJournalLine();
    end;

    local procedure ResetTempGenJournalLine()
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.DeleteAll(false);
    end;

    local procedure UpdateWindow(ContractNo: Code[20])
    begin
        if not AllowGUI then
            exit;
        ContractDeferralIteration += 1;
        Window.Update(1, ContractNo);
        Window.Update(2, Round(ContractDeferralIteration / TotalContractDeferralsCount * 10000, 1));
    end;

    internal procedure GetAndTestSourceCode()
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Sub. Contr. Deferrals Release");
    end;

    internal procedure GetGeneralLedgerSetupAndCheckJournalTemplateAndBatch()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Journal Templ. Name Mandatory" then begin
            ServiceContractSetup.Get();
            ServiceContractSetup.TestField("Def. Rel. Jnl. Template Name");
            ServiceContractSetup.TestField("Def. Rel. Jnl. Batch Name");
        end;
    end;

    procedure PostGenJnlLine(var InputTempGenJournalLine: Record "Gen. Journal Line" temporary; InputPostingDate: Date; SourceCodeSetupContractDeferralsRelease: Code[10])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := ServiceContractSetup."Def. Rel. Jnl. Template Name";
        GenJnlLine."Journal Batch Name" := ServiceContractSetup."Def. Rel. Jnl. Batch Name";
        GenJnlLine."Document No." := InputTempGenJournalLine."Document No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
        GenJnlLine.Validate("Account No.", InputTempGenJournalLine."Account No.");
        GenJnlLine."Posting Date" := InputPostingDate;
        GenJnlLine.Description := StrSubstNo(ReleasingOfContractNoTxt, Format(GenJnlLine."Posting Date", 0, '<Month Text> <Year4>'));
        GenJnlLine."Subscription Contract No." := InputTempGenJournalLine."Subscription Contract No.";
        GenJnlLine.Validate(Amount, InputTempGenJournalLine.Amount);
        GenJnlLine.Validate("Dimension Set ID", InputTempGenJournalLine."Dimension Set ID");
        GenJnlLine."Source Code" := SourceCodeSetupContractDeferralsRelease;
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GenJnlLine.Validate("Account No.", InputTempGenJournalLine."Bal. Account No.");
        GenJnlLine.Validate("Dimension Set ID", InputTempGenJournalLine."Dimension Set ID");
        GenJnlLine.Validate(Amount, -InputTempGenJournalLine.Amount);
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine.Description := StrSubstNo(ReleasingOfContractNoTxt, Format(GenJnlLine."Posting Date", 0, '<Month Text> <Year4>'));
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    internal procedure SetRequestPageParameters(NewPostUntilDate: Date; NewPostingDate: Date)
    begin
        PostUntilDate := NewPostUntilDate;
        PostingDate := NewPostingDate;
    end;

    internal procedure SetAllowGUI(NewAllowGUI: Boolean)
    begin
        AllowGUI := NewAllowGUI;
    end;
}
