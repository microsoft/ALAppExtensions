namespace Microsoft.Finance.RoleCenters;

pageextension 1953 "LP - Overdue Customers Ext." extends "Account Receivables"
{
    layout
    {
        addafter("Overdue Customers")
        {
            part("LP - Invoices at Risk"; "LP - Invoices at Risk")
            {
                ApplicationArea = All;
            }
        }
    }
}