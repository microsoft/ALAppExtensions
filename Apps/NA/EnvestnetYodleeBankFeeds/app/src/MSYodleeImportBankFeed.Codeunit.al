namespace Microsoft.Bank.StatementImport.Yodlee;

using System.IO;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 1451 "MS - Yodlee Import Bank Feed"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun();
    var
        DataExch: Record "Data Exch.";
        ProcessDataExch: Codeunit "Process Data Exch.";
        AuxRecordRef: RecordRef;
    begin
        DataExch.GET("Data Exch. Entry No.");
        AuxRecordRef.GETTABLE(Rec);

        PreProcess(Rec);
        ProcessDataExch.ProcessAllLinesColumnMapping(DataExch, AuxRecordRef);
        PostProcess(Rec);
    end;

    var
        PrePostProcessXMLImport: Codeunit "Pre & Post Process XML Import";
        BankAccountIDPathTxt: Label '/root/root/transaction/accountId', Locked = true;
        BalanceAmountPathTxt: Label '/root/root/transaction/runningBalance/amount', Locked = true;
        BankAccCurrErr: Label 'The bank feed that you are importing contains transactions in currencies other than the %1 %2 of bank account %3.', Comment = '%1 %2 = Currency Code EUR; %3 = Bank Account No.';
        BankAccIDErr: Label 'The bank feed that you are importing contains transactions for a different bank account.';
        BankAccNotLinkedErr: Label 'This bank account is not linked to an online bank account.';
        BalanceCurrencyPathTxt: Label '/root/root/transaction/runningBalance/currency', Locked = true;
        TransactionCurrencyPathTxt: Label '/root/root/transaction/amount/currency', Locked = true;

    local procedure PreProcess(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    var
        DataExch: Record "Data Exch.";
    begin
        DataExch.GET(BankAccReconciliationLine."Data Exch. Entry No.");

        CheckBankAccount(BankAccReconciliationLine, DataExch);
    end;

    local procedure PostProcess(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    var
        DataExch: Record "Data Exch.";
        DataExchFieldDetails: Query "Data Exch. Field Details";
    begin
        DataExch.GET(BankAccReconciliationLine."Data Exch. Entry No.");

        if PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BalanceAmountPathTxt) then
            SetClosingBalance(BankAccReconciliationLine, DataExchFieldDetails.FieldValue);
    end;

    local procedure CheckBankAccount(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; DataExch: Record "Data Exch.");
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExchFieldDetails: Query "Data Exch. Field Details";
    begin
        GeneralLedgerSetup.GET();
        BankAccount.GET(BankAccReconciliationLine."Bank Account No.");

        // Check currency code match
        DataExchFieldDetails.SETFILTER(FieldValue, '<>%1&<>%2&<>%3', '', GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."Currency Code");
        if PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", TransactionCurrencyPathTxt) then
            ERROR(BankAccCurrErr, BankAccount.FIELDCAPTION("Currency Code"),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");
        if PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BalanceCurrencyPathTxt) then
            ERROR(BankAccCurrErr, BankAccount.FIELDCAPTION("Currency Code"),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), BankAccount."No.");

        // check online bank account ID
        if not MSYodleeBankAccLink.GET(BankAccount."No.") then
            ERROR(BankAccNotLinkedErr);
        DataExchFieldDetails.SETFILTER(FieldValue, '<>%1', MSYodleeBankAccLink."Online Bank Account ID");
        if PrePostProcessXMLImport.HasDataExchFieldValue(DataExchFieldDetails, DataExch."Entry No.", BankAccountIDPathTxt) then
            ERROR(BankAccIDErr);
    end;

    local procedure SetClosingBalance(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Value: Text);
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        AuxRecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        BankAccReconciliation.GET(
          BankAccReconciliationLine."Statement Type",
          BankAccReconciliationLine."Bank Account No.",
          BankAccReconciliationLine."Statement No.");
        AuxRecordRef.GETTABLE(BankAccReconciliation);
        FieldRef := AuxRecordRef.FIELD(BankAccReconciliation.FIELDNO("Statement Ending Balance"));
        ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, COPYSTR(Value, 1, 250), true);
        AuxRecordRef.MODIFY(true);
    end;
}

