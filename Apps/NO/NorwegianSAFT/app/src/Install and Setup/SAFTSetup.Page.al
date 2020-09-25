page 10690 "SAF-T Setup"
{
    PageType = Card;
    SourceTable = "SAF-T Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Caption = 'SAF-T Setup';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group("Data Quality")
            {
                field(CheckCompanyInformation; "Check Company Information")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for SAF-T in the Company Information page.';
                }
                field(CheckCustomer; "Check Customer")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for SAF-T for specific customers.';
                }
                field(CheckVendor; "Check Vendor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for SAF-T for specific vendors';
                }
                field(CheckBankAccount; "Check Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be notified about fields that have not been set up correctly for SAF-T on specific bank accounts.';
                }
            }
        }
    }

    actions
    {
    }

    var
        OpenWizardQst: Label 'Something is not set up correctly for SAF-T. Do you want to open the SAF-T assisted setup guide?';
        InitializationFailedErr: Label 'You must continue the SAF-T assisted setup guide first.';

    trigger OnOpenPage()
    var

    begin
        if not Get() then begin
            if Confirm(OpenWizardQst) then
                Page.RunModal(Page::"SAF-T Setup Wizard")
            else
                CurrPage.Close();
            if not Get() then
                error(InitializationFailedErr);
        end;
    end;

}
