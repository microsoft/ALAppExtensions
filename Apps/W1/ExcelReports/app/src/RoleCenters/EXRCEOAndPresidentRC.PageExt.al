namespace Microsoft.Sales.ExcelReports;
using Microsoft.RoleCenters;

pageextension 4409 "EXR CEO and President RC" extends "CEO and President Role Center"
{
    actions
    {
        addafter("Customer - &Balance")
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