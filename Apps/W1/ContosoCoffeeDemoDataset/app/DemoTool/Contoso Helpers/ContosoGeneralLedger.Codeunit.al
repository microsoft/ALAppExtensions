codeunit 5112 "Contoso General Ledger"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Gen. Journal Template" = rim,
        tabledata "General Ledger Setup" = rim,
        tabledata "Gen. Journal Batch" = rim,
        tabledata "Gen. Journal Line" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; Recurring: Boolean; NoSeries: Code[20]; SourceCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Exists: Boolean;
    begin
        if GenJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalTemplate.Validate(Name, Name);
        GenJournalTemplate.Validate(Description, Description);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate(Recurring, Recurring);
        GenJournalTemplate.Validate("No. Series", NoSeries);

        if Exists then
            GenJournalTemplate.Modify(true)
        else
            GenJournalTemplate.Insert(true);

        if SourceCode <> '' then begin
            GenJournalTemplate.Validate("Source Code", SourceCode);
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; PageID: Integer; NoSeries: Code[20]; CopytoPostedJnlLines: Boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Exists: Boolean;
    begin
        if GenJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalTemplate.Validate(Name, Name);
        GenJournalTemplate.Validate(Description, Description);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate("Page ID", PageID);
        GenJournalTemplate.Validate("No. Series", NoSeries);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", CopytoPostedJnlLines);

        if Exists then
            GenJournalTemplate.Modify(true)
        else
            GenJournalTemplate.Insert(true);
    end;

    procedure InsertGeneralJournalBatch(TemplateName: Code[10]; Name: Code[10]; Description: Text[100])
    begin
        InsertGeneralJournalBatch(TemplateName, Name, Description, Enum::"Gen. Journal Account Type"::"G/L Account", '', '', false);
    end;

    procedure InsertGeneralJournalBatch(TemplateName: Code[10]; Name: Code[10]; Description: Text[100]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; NoSeries: Code[20]; AllowPaymentExport: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        Exists: Boolean;
    begin
        if GenJournalBatch.Get(TemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalBatch.Validate("Journal Template Name", TemplateName);
        GenJournalBatch.SetupNewBatch();
        GenJournalBatch.Validate(Name, Name);
        GenJournalBatch.Validate(Description, Description);
        GenJournalBatch.Validate("Bal. Account Type", BalAccountType);
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJournalBatch.Validate("No. Series", NoSeries);

        if Exists then
            GenJournalBatch.Modify(true)
        else
            GenJournalBatch.Insert(true);

        GenJournalBatch.Validate("Allow Payment Export", AllowPaymentExport);
        GenJournalBatch.Modify(true);
    end;

    procedure InsertGeneralLedgerSetup(LocalContAddrFormat: Option)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Exists: Boolean;
    begin
        if GeneralLedgerSetup.Get() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GeneralLedgerSetup.Validate("Allow Posting From", 0D);
        GeneralLedgerSetup.Validate("Allow Posting To", 0D);
        GeneralLedgerSetup.Validate("Adjust for Payment Disc.", false);
        GeneralLedgerSetup.Validate("Local Cont. Addr. Format", LocalContAddrFormat);
        GeneralLedgerSetup.Validate("Local Address Format", LocalContAddrFormat);

        if Exists then
            GeneralLedgerSetup.Modify(true)
        else
            GeneralLedgerSetup.Insert(true);
    end;

    procedure InsertGenJournalLine(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LineNo: Integer; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; Description: Text[100]; BalAccountNo: Code[20]; Amount: Decimal; SystemCreatedEntry: Boolean; BalAccountType: Enum "Gen. Journal Account Type"; AppliesToDocumentType: Enum "Gen. Journal Document Type"; AppliesToDocumentNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        Exists: Boolean;
    begin
        if GenJournalLine.Get(JournalTemplateName, JournalBatchName, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        GenJournalLine.Validate("Line No.", LineNo);
        GenJournalLine.Validate("Account Type", AccountType);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Validate("Applies-to Doc. Type", AppliesToDocumentType);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocumentNo);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("System-Created Entry", SystemCreatedEntry);

        if Exists then
            GenJournalLine.Modify(true)
        else
            GenJournalLine.Insert(true);
    end;
}