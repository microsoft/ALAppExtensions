namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Purchases.Document;

query 37001 "Purch. Lines - Item Received"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Received Not Invd. PO';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemReceivedNotInvoicedPurchaseLine';
    EntitySetName = 'itemReceivedNotInvoicedPurchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(purchaseHeader; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = const(Order);
            column(purchaseOrderNo; "No.")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(vendorNo; "Pay-to Vendor No.")
            {
            }
            column(orderDate; "Order Date")
            {
            }
            column(purchaserCode; "Purchaser Code")
            {
            }
            dataitem(purchaseLine; "Purchase Line")
            {
                DataItemLink = "Document Type" = purchaseHeader."Document Type", "Document No." = purchaseHeader."No.";
                DataItemTableFilter = Type = const(Item), "Qty. Rcd. Not Invoiced (Base)" = filter(> 0);
                column(purchaseLineDocumentType; "Document Type")
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
                column(qtyRcdNotInvoicedBase; "Qty. Rcd. Not Invoiced (Base)")
                {
                }
                column(amtRcdNotInvoicedLCY; "A. Rcd. Not Inv. Ex. VAT (LCY)")
                {
                }
                column(dimensionSetID; "Dimension Set ID")
                {
                }
            }
        }
    }
}