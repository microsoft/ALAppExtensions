namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.Customer;

pageextension 4410 "Customer List" extends "Customer List"
{
    actions
    {
        addfirst(SalesReports)
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
        addafter("Customer Register")
        {
            action(EXRCustomerTopListExcel1)
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