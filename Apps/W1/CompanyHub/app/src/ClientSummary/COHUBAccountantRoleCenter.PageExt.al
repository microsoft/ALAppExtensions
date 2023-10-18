namespace Mirosoft.Integration.CompanyHub;

using Microsoft.Finance.RoleCenters;

pageextension 1150 "COHUB Accountant Role Center" extends "Accountant Role Center"
{
    layout
    {
        addafter(Control1907692008)
        {
            part(COHUBShortSummary; "COHUB Company Short Summary")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}