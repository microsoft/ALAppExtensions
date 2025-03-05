namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 37005 "Value Entries - Sales"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Value Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'salesValueEntry';
    EntitySetName = 'salesValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesValueEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Sale);
            column(itemLedgerEntryNo; "Entry No.") { }
            dataitem(Value_Entry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = SalesValueEntry."Entry No.";
                column(entryNo; "Entry No.") { }
                column(entryType; "Entry Type") { }
                column(documentNo; "Document No.") { }
                column(documentType; "Document Type") { }
                column(invoicedQuantity; "Invoiced Quantity") { }
                column(salesAmountActual; "Sales Amount (Actual)") { }
                column(costAmountActual; "Cost Amount (Actual)") { }
                column(costAmountNonInvtbl; "Cost Amount (Non-Invtbl.)") { }
                column(costPostedToGL; "Cost Posted to G/L") { }
                column(customerNo; "Source No.") { }
                column(postingDate; "Posting Date") { }
                column(documentDate; "Document Date") { }
                column(itemNo; "Item No.") { }
                column(locationCode; "Location Code") { }
                column(dimensionSetID; "Dimension Set ID") { }
                column(salespersonPurchaserCode; "Salespers./Purch. Code") { }
                column(returnReasonCode; "Return Reason Code") { }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Sales Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemSalesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}