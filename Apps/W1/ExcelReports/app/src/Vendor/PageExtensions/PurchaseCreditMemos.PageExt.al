namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Document;

pageextension 4419 "Purchase Credit Memos" extends "Purchase Credit Memos"
{
    actions
    {
        addfirst(Sales)
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