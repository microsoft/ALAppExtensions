namespace Mirosoft.Integration.CompanyHub;

using Microsoft.Finance.RoleCenters;

pageextension 1151 "COHUB Bookkeeper Role Center" extends "Bookkeeper Role Center"
{
    layout
    {
        addbefore("User Tasks Activities")
        {
            part(COHUBShortSummary; "COHUB Company Short Summary")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}