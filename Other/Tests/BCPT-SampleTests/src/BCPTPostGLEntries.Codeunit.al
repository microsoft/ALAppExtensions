codeunit 149121 "BCPT Post G/L Entries"
{
    SingleInstance = true;

    trigger OnRun();
    var
    begin
        PostGeneralJournal();
    end;

    procedure PostGeneralJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BCPTTestContext: Codeunit "BCPT Test Context";
    begin
        // Setup: Create General Journal
        BCPTTestContext.StartScenario('Create General Journal Lines');
        CreateGeneralJournalLine(GenJournalLine);
        BCPTTestContext.EndScenario('Create General Journal Lines');

        // Exercise: Post General Journal.
        BCPTTestContext.StartScenario('Post General Journal Lines');
        PostGeneralJournalLine(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        BCPTTestContext.EndScenario('Post General Journal Lines');
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        SelectGeneralJournal(GenJournalBatch);

        CreateGeneralJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name",
          GenJournalBatch.Name);
    end;

    procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if not GenJournalBatch.Get(JournalTemplateName, JournalBatchName) then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Validate(Name, JournalBatchName);
            GenJournalBatch.Validate(Description, JournalBatchName + ' journal');
            GenJournalBatch.Insert(true);
        end;
        CreateGeneralJnlLine(GenJournalLine, GenJournalBatch, JournalTemplateName, JournalBatchName);
    end;

    procedure CreateGeneralJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocumentNo: Code[20];
    begin
        Clear(GenJournalLine);
        GenJournalLine.DeleteAll();
        //Debit amount
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        GenJournalLine.Validate("Line No.", 10000);
        GenJournalLine.Insert(true);
        GenJournalLine.Validate("Posting Date", WorkDate());
        if NoSeries.Get(GenJournalBatch."No. Series") then
            DocumentNo := NoSeriesManagement.GetNextNo(GenJournalBatch."No. Series", GenJournalLine."Posting Date", false);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Account No.", SelectRandomGLAccount());
        GenJournalLine.Validate("Debit Amount", 1000);
        GenJournalLine.Modify(true);

        //Credit amount
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        GenJournalLine.Validate("Line No.", 20000);
        GenJournalLine.Insert(true);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Account No.", SelectRandomGLAccount());
        GenJournalLine.Validate("Credit Amount", 1000);
        GenJournalLine.Modify(true);
    end;

    local procedure SelectGeneralJournal(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        SelectGeneralJournalTemplateName(GenJournalTemplate, GenJournalTemplate.Type::General);
        SelectGeneralJournalBatchName(GenJournalBatch, GenJournalTemplate.Type::General, GenJournalTemplate.Name);
    end;

    local procedure PostGeneralJournalLine(JournalTemplateName: Text[10]; JournalBatchName: Text[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
    end;

    local procedure SelectGeneralJournalTemplateName(var GenJournalTemplate: Record "Gen. Journal Template"; GenJournalTemplateType: Enum "Gen. Journal Template Type")
    begin
        // Find General Journal Template for the given Template Type.
        GenJournalTemplate.SetRange(Type, GenJournalTemplateType);
        GenJournalTemplate.SetRange(Recurring, false);
        if GenJournalTemplate.FindFirst() then;
    end;

    local procedure SelectGeneralJournalBatchName(var GenJournalBatch: Record "Gen. Journal Batch"; GenJournalTemplateType: Enum "Gen. Journal Template Type"; GenJournalTemplateName: Code[10])
    begin
        // Find Name for Batch Name.
        GenJournalBatch.SetRange("Template Type", GenJournalTemplateType);
        GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplateName);
        if GenJournalBatch.FindFirst() then;
    end;

    local procedure SelectRandomGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GLAccount.Next(SessionId() MOD GLAccount.Count());
        exit(GLAccount."No.");
    end;
}