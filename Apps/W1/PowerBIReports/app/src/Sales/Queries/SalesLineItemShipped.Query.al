namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Sales.Document;

query 37006 "Sales Line - Item Shipped"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Shipped Not Invd. SO';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemShippedNotInvoicedSalesLine';
    EntitySetName = 'itemShippedNotInvoicedSalesLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableFilter = "Document Type" = const(Order);
            column(salesOrderNo; "No.")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(customerNo; "Bill-to Customer No.")
            {
            }
            column(orderDate; "Order Date")
            {
            }
            column(salespersonCode; "Salesperson Code")
            {
            }
            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document Type" = SalesHeader."Document Type", "Document No." = SalesHeader."No.";
                DataItemTableFilter = Type = const(Item), "Qty. Shipped Not Invd. (Base)" = filter(> 0);

                column(salesLineDocumentType; "Document Type")
                {
                }
                column(documentNo; "Document No.")
                {
                }
                column(lineNo; "Line No.")
                {
                }
                column(itemNo; "No.")
                {
                }
                column(locationCode; "Location Code")
                {
                }
                column(qtyShippedNotInvdBase; "Qty. Shipped Not Invd. (Base)")
                {
                }
                column(shippedNotInvoicedLCY; "Shipped Not Inv. (LCY) No VAT")
                {
                }
                column(unitCostLCY; "Unit Cost (LCY)")
                {
                }
                column(shippedNotInvoiced; "Shipped Not Invoiced")
                {
                }
                column(dimensionSetID; "Dimension Set ID")
                {
                }
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
            CurrQuery.SetFilter(orderDate, DateFilterText);
    end;
}