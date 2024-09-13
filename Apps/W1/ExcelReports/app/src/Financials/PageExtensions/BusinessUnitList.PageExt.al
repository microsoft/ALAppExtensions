namespace Microsoft.Finance.ExcelReports;
using Microsoft.Finance.Consolidation;

pageextension 4408 "Business Unit List" extends "Business Unit List"
{
    actions
    {
        addlast("&Reports")
        {
            action("Consolidation - Excel")
            {
                ApplicationArea = All;
                Caption = 'Consolidation reports (Excel)';
                Image = "Report";
                RunObject = report "EXR Consolidated Trial Balance";
                ToolTip = 'View and compare general ledger balances across the different business units.';
            }
        }
    }
}