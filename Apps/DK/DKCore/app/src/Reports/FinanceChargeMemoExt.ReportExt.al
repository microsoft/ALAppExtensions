reportextension 13604 FinanceChargeMemoExt extends "Finance Charge Memo"
{
    RDLCLayout = './src/Reports/FinanceChargeMemo.rdlc';
    dataset
    {
        add("Integer")
        {
            column(CompanyInfoBankBranchNo; CompanyInformationDK."Bank Branch No.") { }

            column(BankBranchNoCaption; BankBranchNoCaptionLbl) { }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformationDK.Get();
    end;

    var
        CompanyInformationDK: Record "Company Information";
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
}