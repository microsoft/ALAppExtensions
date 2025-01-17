namespace Microsoft.PowerBIReports;

using Microsoft.RoleCenters;

pageextension 36950 "Administrator Main Role Center" extends "Administrator Main Role Center"
{
    actions
    {
        addlast(Group2)
        {
            action("Power BI Connector Setup")
            {
                ApplicationArea = All;
                Caption = 'Power BI Connector Setup';
                ToolTip = 'View and edit Power BI Connector settings.';
                RunObject = page "PowerBI Reports Setup";
            }
        }
    }
}