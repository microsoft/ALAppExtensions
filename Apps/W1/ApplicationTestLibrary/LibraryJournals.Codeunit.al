/// <summary>
/// Provides utility functions for creating and managing various journal types in test scenarios, including general journals, item journals, and resource journals.
/// </summary>
codeunit 131306 "Library - Journals"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";

    procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
        RecRef: RecordRef;
    begin
        // Find a balanced template/batch pair.
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);

        // Create a General Journal Entry.
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(GenJournalLine);
        GenJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, GenJournalLine.FieldNo("Line No.")));
        GenJournalLine.Insert(true);
        GenJournalLine.Validate("Posting Date", WorkDate());  // Defaults to work date.
        GenJournalLine.Validate("VAT Reporting Date", WorkDate());
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Account Type", AccountType);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Amount, Amount);
        if NoSeries.Get(GenJournalBatch."No. Series") then
            GenJournalLine.Validate("Document No.", NoSeriesCodeunit.PeekNextNo(GenJournalBatch."No. Series")) // Unused but required field for posting.
        else
            GenJournalLine.Validate(
              "Document No.", LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Document No."), DATABASE::"Gen. Journal Line"));
        GenJournalLine.Validate("External Document No.", GenJournalLine."Document No.");  // Unused but required for vendor posting.
        GenJournalLine.Validate("Source Code", LibraryERM.FindGeneralJournalSourceCode());  // Unused but required for AU, NZ builds
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        OnBeforeModifyGenJnlLineWhenCreate(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLine2(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        LastGenJnlLine: Record "Gen. Journal Line";
        RecRef: RecordRef;
        Balance: Decimal;
    begin
        // This function should replace the one above, but it requires a lot of changes to existing tests so I'm keeping both for now and will refactor when time permits

        // Find a balanced template/batch pair.
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);

        // get the last Gen Jnl Line as template or insert a new doc no (to avoid CODEUNIT.RUN in WRITE transaction error)
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if not GetLastGenJnlLineAndBalance(GenJournalLine, LastGenJnlLine, Balance, JournalTemplateName, JournalBatchName) then
            SetLastGenJnlLineFields(LastGenJnlLine, GenJournalBatch);

        // Create a General Journal Entry.
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(GenJournalLine);
        GenJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, GenJournalLine.FieldNo("Line No.")));
        GenJournalLine.Insert(true);

        // Initialize the new line
        GenJournalLine.SetUpNewLine(LastGenJnlLine, Balance, true);

        // fill in additional fields
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Account Type", AccountType);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("External Document No.", GenJournalLine."Document No.");  // Unused but required for vendor posting.
        GenJournalLine.Validate("Source Code", LibraryERM.FindGeneralJournalSourceCode());  // Unused but required for AU, NZ builds
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        OnBeforeModifyGenJnlLineWhenCreate(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithBatch(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; LineAmount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        CreateGenJournalBatch(GenJournalBatch);
        LibraryERM.CreateGLAccount(GLAccount);
        CreateGenJournalLine(
          GenJournalLine,
          GenJournalBatch."Journal Template Name",
          GenJournalBatch.Name,
          DocumentType,
          AccountType,
          AccountNo,
          GenJournalLine."Bal. Account Type"::"G/L Account",
          GLAccount."No.",
          LineAmount);
    end;

    procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    procedure CreateGenJournalBatchWithType(var GenJournalBatch: Record "Gen. Journal Batch"; TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, TemplateType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    procedure SelectGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; GenJournalTemplateCode: Code[10])
    var
        GLAccount: Record "G/L Account";
    begin
        // Select General Journal Batch Name for General Journal Line.
        GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplateCode);
        GenJournalBatch.SetRange("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
        LibraryERM.CreateGLAccount(GLAccount);

        if not GenJournalBatch.FindFirst() then begin
            // Create New General Journal Batch.
            LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplateCode);
            GenJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
            GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
        end;

        GenJournalBatch.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalBatch.Modify(true);
    end;

    procedure SelectGenJournalTemplate(Type: Enum "Gen. Journal Template Type"; PageID: Integer): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, Type);
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange("Page ID", PageID);

        if not GenJournalTemplate.FindFirst() then begin
            GenJournalTemplate.Init();
            GenJournalTemplate.Validate(
              Name, LibraryUtility.GenerateRandomCode(GenJournalTemplate.FieldNo(Name), DATABASE::"Gen. Journal Template"));
            GenJournalTemplate.Validate(Type, Type);
            GenJournalTemplate.Validate("Page ID", PageID);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Insert(true);
        end;

        exit(GenJournalTemplate.Name);
    end;

    local procedure GetLastGenJnlLineAndBalance(var GenJournalLine: Record "Gen. Journal Line"; var LastGenJnlLine: Record "Gen. Journal Line"; var Balance: Decimal; JournalTemplateName: Code[20]; JournalBatchName: Code[20]) LineExists: Boolean
    var
        GenJnlManagement: Codeunit GenJnlManagement;
        TotalBalance: Decimal;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
    begin
        LastGenJnlLine.SetRange("Journal Template Name", JournalTemplateName);
        LastGenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        LineExists := LastGenJnlLine.FindLast();
        GenJnlManagement.CalcBalance(GenJournalLine, LastGenJnlLine, Balance, TotalBalance, ShowBalance, ShowTotalBalance);
        exit(LineExists);
    end;

    local procedure SetLastGenJnlLineFields(var LastGenJnlLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch")
    var
        NoSeries: Codeunit "No. Series";
    begin
        if GenJournalBatch."No. Series" <> '' then
            LastGenJnlLine."Document No." := NoSeries.PeekNextNo(GenJournalBatch."No. Series")
        else
            LastGenJnlLine."Document No." :=
              LibraryUtility.GenerateRandomCode(LastGenJnlLine.FieldNo("Document No."), DATABASE::"Gen. Journal Line");
        LastGenJnlLine."Posting Date" := WorkDate();
        LastGenJnlLine."VAT Reporting Date" := WorkDate();
    end;

    procedure SetPostWithJobQueue(PostWithJobQueue: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Post with Job Queue", PostWithJobQueue);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetPostAndPrintWithJobQueue(PostAndPrintWithJobQueue: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Post & Print with Job Queue", PostAndPrintWithJobQueue);
        GeneralLedgerSetup.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyGenJnlLineWhenCreate(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}