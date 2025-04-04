namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.RoleCenters;

pageextension 4412 "EXR Order Processor RC" extends "Order Processor Role Center"
{
    actions
    {
        addafter("Customer - &Order Summary")
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