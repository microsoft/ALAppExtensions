namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

reportextension 8009 "Contract Blanket Sales Order" extends "Blanket Sales Order"
{
    dataset
    {
        modify(RoundLoop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                SalesReportPrintoutMgmt.ExcludeItemFromTotals("Sales Line", TotalSalesLineAmount, TotalSalesInvDiscAmount, VATBaseAmount, VATAmount, TotalAmountInclVAT);
            end;
        }
    }
    var
        SalesReportPrintoutMgmt: Codeunit "Sales Report Printout Mgmt.";
}
