codeunit 1451 "MS - Yodlee Import Bank Feed"
{
    TableNo = 274;

    trigger OnRun();
    var
        DataExch: Record 1220;
        ProcessDataExch: Codeunit 1201;
        RecRef: RecordRef;
    begin
        DataExch.GET("Data Exch. Entry No.");
        RecRef.GETTABLE(Rec);

        PreProcess(Rec);
        ProcessDataExch.ProcessAllLinesColumnMapping(DataExch, RecRef);
        PostProcess(Rec);
    end;

    var
        PrePostProcessXMLImport: Codeunit 1262;
        BankAccountIDPathTxt: Label '/root/root/transaction/accountId', Locked = true;
        BalanceAmountPathTxt: Label '/root/root/transaction/runningBalance/amount', Locked = true;
        BankAccCurrErr: Label 'The bank feed that you are importing contains transactions in currencies other than the %1 %2 of bank account %3.', Comment = '%1 %2 = Currency Code EUR; %3 = Bank Account No.';
        BankAccIDErr: Label 'The bank feed that you are importing contains transactions for a different bank account.';
        BankAccNotLinkedErr: Label 'This bank account is not linked to an online bank account.';
        BalanceCurrencyPathTxt: Label '/root/root/transaction/runningBalance/currency', Locked = true;
        TransactionCurrencyPathTxt: Label '/root/root/transaction/amount/currency', Locked = true;

    local procedure PreProcess(BankAccReconciliationLine: Record 274);
    var
        DataExch: Record 1220;
    begin
        DataExch.GET(BankAccReconciliationLine."Data Exch. Entry No.");

        CheckBankAccount(BankAccReconciliationLine, DataExch);
    end;

    local procedure PostProcess(BankAccReconciliationLine: Record 274);
    var
        DataExch: Record 1220;
        DataExchFieldDetails: Query 1232;
    begin
        DataExch.GET(BankAccReconciliationLine."Data Exch. Entry No.");

        IF PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BalanceAmountPathTxt) THEN
            SetClosingBalance(BankAccReconciliationLine, DataExchFieldDetails.FieldValue);
    end;

    local procedure CheckBankAccount(BankAccReconciliationLine: Record 274; DataExch: Record 1220);
    var
        BankAccount: Record 270;
        MSYodleeBankAccLink: Record 1451;
        GeneralLedgerSetup: Record 98;
        DataExchFieldDetails: Query 1232;
    begin
        GeneralLedgerSetup.GET();
        BankAccount.GET(BankAccReconciliationLine."Bank Account No.");

        // Check currency code match
        DataExchFieldDetails.SETFILTER(FieldValue, '<>%1&<>%2', '', GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"));
        IF PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", TransactionCurrencyPathTxt) THEN
            ERROR(BankAccCurrErr, BankAccount.FIELDCAPTION("Currency Code"),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");
        IF PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BalanceCurrencyPathTxt) THEN
            ERROR(BankAccCurrErr, BankAccount.FIELDCAPTION("Currency Code"),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");

        // check online bank account ID
        IF NOT MSYodleeBankAccLink.GET(BankAccount."No.") THEN
            ERROR(BankAccNotLinkedErr);
        DataExchFieldDetails.SETFILTER(FieldValue, '<>%1', MSYodleeBankAccLink."Online Bank Account ID");
        IF PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BankAccountIDPathTxt) THEN
            ERROR(BankAccIDErr);
    end;

    local procedure SetClosingBalance(BankAccReconciliationLine: Record 274; Value: Text);
    var
        BankAccReconciliation: Record 273;
        ConfigValidateManagement: Codeunit 8617;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        BankAccReconciliation.GET(
          BankAccReconciliationLine."Statement Type",
          BankAccReconciliationLine."Bank Account No.",
          BankAccReconciliationLine."Statement No.");
        RecRef.GETTABLE(BankAccReconciliation);
        FieldRef := RecRef.FIELD(BankAccReconciliation.FIELDNO("Statement Ending Balance"));
        ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, COPYSTR(Value, 1, 250), TRUE);
        RecRef.MODIFY(TRUE);
    end;
}

