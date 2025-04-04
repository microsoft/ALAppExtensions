namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.RoleCenters;

pageextension 4420 "EXR Purchasing Manager RC" extends "Purchasing Manager Role Center"
{
    actions
    {
        addafter("Vendor - Detail Trial Balance")
        {
            action(EXRVendorTopListExcel)
            {
                ApplicationArea = Suite;
                Caption = 'Vendor - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Vendor Top List";
                ToolTip = 'View a list of the vendors from whom you purchase the most or to whom you owe the most.';
            }
        }
    }
}