reportextension 13606 ReminderExt extends Reminder
{
    RDLCLayout = './src/Reports/Reminder.rdlc';
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