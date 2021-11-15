#if not CLEAN20
codeunit 20103 "AMC Bank Imp.-Pre-Mapping"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of AMC Bank Imp.-Pre-Process';
    ObsoleteTag = '20.0';

    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        AMCBankPrePostProcessXMLImport: Codeunit "AMC Bank Pre&Post Process";
    begin
        DataExch.Get("Data Exch. Entry No.");
        AMCBankPrePostProcessXMLImport.PreProcessFile(DataExch, StmtNoPathFilterTxt);
        AMCBankPrePostProcessXMLImport.PreProcessBankAccount(DataExch, "Bank Account No.", StmtBankAccNoPathFilterTxt, '', CurrCodePathFilterTxt);
    end;

    var
        StmtBankAccNoPathFilterTxt: Label '/reportExportResponse/return/finsta/statement/ownbankaccount/bankaccount', Locked = true;
        CurrCodePathFilterTxt: Label '=''/reportExportResponse/return/finsta/statement/ownbankaccount/currency''|=''/reportExportResponse/return/finsta/statement/finstatransus/amountdetails/currency''', Locked = true;
        StmtNoPathFilterTxt: Label '/reportExportResponse/return/finsta/statement/statementno', Locked = true;
}

#endif