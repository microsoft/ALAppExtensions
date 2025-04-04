namespace Microsoft.Sales.ExcelReports;
using Microsoft.Sales.Document;

pageextension 4414 "Sales Invoice List" extends "Sales Invoice List"
{
    actions
    {
        addfirst(SalesReports)
        {
            action("Customer Top List - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Customer Top List";
                ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
            }
        }
    }
}