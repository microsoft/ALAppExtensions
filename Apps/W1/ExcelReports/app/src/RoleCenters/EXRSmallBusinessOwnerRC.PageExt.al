namespace Microsoft.Sales.ExcelReports;

using Microsoft.RoleCenters;

pageextension 4411 "EXR Small Business Owner RC" extends "Small Business Owner RC"
{
    actions
    {
        addafter("Customer - Order Su&mmary")
        {
            action(EXRCustomerTopListExcel)
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