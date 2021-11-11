#if not CLEAN20
codeunit 20102 "AMC Bank Pre&Post Process"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of Pre & Post process.';
    ObsoleteTag = '20.0';
    trigger OnRun()
    begin
    end;

    var
        DiffCurrQst: Label 'The bank statement that you are importing contains transactions in %1 %2. This conflicts with the %3 %4.\\Do you want to continue?', Comment = '%1 %2 = Currency Code EUR; %3 %4 = LCY Code DKK.';
        MissingStmtDateInDataMsg: Label 'The statement date was not found in the data to be imported.';
        MissingClosingBalInDataMsg: Label 'The closing balance was not found in the data to be imported.';
        MissingBankAccNoQst: Label 'Bank account %1 does not have a bank account number.\\Do you want to continue?', comment = '%1 = Bank Account Code';
        BankAccCurrErr: Label 'The bank statement that you are importing contains transactions in currencies other than the %1 %2 of bank account %3.', Comment = '%1 %2 = Currency Code EUR; %3 = Bank Account No.';
        MultipleStmtErr: Label 'The file that you are trying to import contains more than one bank statement.';
        MissingBankAccNoInDataErr: Label 'The bank account number was not found in the data to be imported.';
        BankAccMismatchQst: Label 'Bank account %1 does not have the bank account number %2, as specified in the bank statement file.\\Do you want to continue?', Comment = '%1=Value; %2 = Bank account no.';

    procedure PostProcessStatementDate(DataExch: Record "Data Exch."; var RecRef: RecordRef; FieldNo: Integer; StmtDatePathFilter: Text)
    var
        DataExchFieldDetails: Query "Data Exch. Field Details";
    begin
        SetValueFromDataExchField(DataExchFieldDetails, DataExch, StmtDatePathFilter, MissingStmtDateInDataMsg, RecRef, FieldNo);
    end;

    procedure PostProcessStatementEndingBalance(DataExch: Record "Data Exch."; var RecRef: RecordRef; FieldNo: Integer; BalAmtPathFilter: Text)
    var
        DataExchFieldDetails: Query "Data Exch. Field Details";
    begin
        SetValueFromDataExchField(DataExchFieldDetails, DataExch, BalAmtPathFilter, MissingClosingBalInDataMsg, RecRef, FieldNo);
    end;

    procedure PreProcessBankAccount(DataExch: Record "Data Exch."; BankAccNo: Code[20]; IBANPathFilter: Text; BankAccIDPathFilter: Text; CurrCodePathFilter: Text)
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(BankAccNo);
        CheckBankAccNo(DataExch, BankAccount, IBANPathFilter, BankAccIDPathFilter);
        CheckBankAccCurrency(DataExch, BankAccount, CurrCodePathFilter);
    end;

    procedure PreProcessGLAccount(DataExch: Record "Data Exch."; var GenJournalLineTemplate: Record "Gen. Journal Line"; CurrencyCodePathFilter: Text)
    var
        GLSetup: Record "General Ledger Setup";
        DataExchFieldDetails: Query "Data Exch. Field Details";
        StatementCurrencyCode: Code[10];
    begin
        GLSetup.Get();

        DataExchFieldDetails.SetFilter(FieldValue, '<>%1&<>%2', '', GLSetup."LCY Code");
        if HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", CurrencyCodePathFilter) then
            if not Confirm(StrSubstNo(DiffCurrQst, GenJournalLineTemplate.FieldCaption("Currency Code"),
                   DataExchFieldDetails.FieldValue, GLSetup.FieldCaption("LCY Code"), GLSetup."LCY Code"))
            then
                Error('');

        DataExchFieldDetails.SetRange(FieldValue);
        if HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", CurrencyCodePathFilter) then begin
            StatementCurrencyCode := Format(DataExchFieldDetails.FieldValue, -MaxStrLen(GenJournalLineTemplate."Currency Code"));
            GenJournalLineTemplate.Validate("Currency Code", GLSetup.GetCurrencyCode(StatementCurrencyCode));
        end;
    end;

    procedure PreProcessFile(DataExch: Record "Data Exch."; StatementIdPathFilter: Text)
    begin
        CheckMultipleStatements(DataExch, StatementIdPathFilter);
    end;

    local procedure CheckBankAccNo(DataExch: Record "Data Exch."; BankAccount: Record "Bank Account"; IBANPathFilter: Text; BankAccIDPathFilter: Text)
    var
        DataExchFieldDetails: Query "Data Exch. Field Details";
        FileHasIBAN: Boolean;
        FileHasBankAccID: Boolean;
    begin
        if BankAccount.GetBankAccountNo() = '' then begin
            if not Confirm(StrSubstNo(MissingBankAccNoQst, BankAccount."No.")) then
                Error('');
            exit;
        end;

        FileHasIBAN := HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", IBANPathFilter);
        if not FileHasIBAN and (BankAccIDPathFilter <> '') then
            FileHasBankAccID := HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BankAccIDPathFilter);

        if not FileHasIBAN and not FileHasBankAccID then
            Error(MissingBankAccNoInDataErr);

        if (DelChr(DataExchFieldDetails.FieldValue, '=', '- ') <> DelChr(BankAccount."Bank Account No.", '=', '- ')) and
           (DelChr(DataExchFieldDetails.FieldValue, '=', '- ') <> DelChr(BankAccount.IBAN, '=', '- '))
        then
            if not Confirm(StrSubstNo(BankAccMismatchQst, BankAccount."No.", DataExchFieldDetails.FieldValue)) then
                Error('');
    end;

    local procedure CheckBankAccCurrency(DataExch: Record "Data Exch."; BankAccount: Record "Bank Account"; CurrCodePathFilter: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExchFieldDetails: Query "Data Exch. Field Details";
    begin
        GeneralLedgerSetup.Get();

        DataExchFieldDetails.SetFilter(FieldValue, '<>%1&<>%2', '', GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"));
        if HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", CurrCodePathFilter) then
            Error(BankAccCurrErr, BankAccount.FieldCaption("Currency Code"),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");
    end;

    local procedure CheckMultipleStatements(DataExch: Record "Data Exch."; StatementIdPathFilter: Text)
    var
        DataExchFieldDetails: Query "Data Exch. Field Details";
        StmtCount: Integer;
    begin
        if HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", StatementIdPathFilter) then begin
            StmtCount := 1;
            while DataExchFieldDetails.Read() do
                StmtCount += 1;
        end;

        if StmtCount > 1 then
            Error(MultipleStmtErr);
    end;

    procedure HasDataExchFieldValue(var DataExchFieldDetails: Query "Data Exch. Field Details"; DataExchEntryNo: Integer; PathFilter: Text): Boolean
    begin
        DataExchFieldDetails.SetRange(Data_Exch_No, DataExchEntryNo);
        DataExchFieldDetails.SetFilter(Path, PathFilter);
        DataExchFieldDetails.Open();
        exit(DataExchFieldDetails.Read());
    end;

    local procedure SetValueFromDataExchField(var DataExchFieldDetails: Query "Data Exch. Field Details"; DataExch: Record "Data Exch."; PathFilter: Text; NotFoundMessage: Text; RecRef: RecordRef; FieldNo: Integer): Boolean
    var
        DataExchField: Record "Data Exch. Field";
        TempFieldIdsToNegate: Record "Integer" temporary;
        DummyDataExchFieldMapping: Record "Data Exch. Field Mapping";
        ProcessDataExch: Codeunit "Process Data Exch.";
    begin
        if not HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", PathFilter) then begin
            Message(NotFoundMessage);
            exit(false);
        end;

        DataExchField.Get(
          DataExchFieldDetails.Data_Exch_No,
          DataExchFieldDetails.Line_No,
          DataExchFieldDetails.Column_No,
          DataExchFieldDetails.Node_ID);

        DummyDataExchFieldMapping."Data Exch. Def Code" := DataExch."Data Exch. Def Code";
        DummyDataExchFieldMapping."Data Exch. Line Def Code" := DataExch."Data Exch. Line Def Code";
        DummyDataExchFieldMapping."Column No." := DataExchFieldDetails.Column_No;
        DummyDataExchFieldMapping."Field ID" := FieldNo;
        DummyDataExchFieldMapping."Table ID" := RecRef.Number();

        ProcessDataExch.SetField(RecRef, DummyDataExchFieldMapping, DataExchField, TempFieldIdsToNegate);
        ProcessDataExch.NegateAmounts(RecRef, TempFieldIdsToNegate);

        RecRef.Modify(true);
        exit(true);
    end;
}

#endif