namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Vendor;

pageextension 4418 "Vendor List" extends "Vendor List"
{
    actions
    {
        addafter("Vendor - Labels")
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