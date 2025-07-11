namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Purchases.Document;

query 36973 "Purchase Lines - Outstanding"
{
    Access = Internal;
    Caption = 'Power BI Purchase Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'outstandingPurchaseLine';
    EntitySetName = 'outstandingPurchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(purchaseLines; "Purchase Line")
        {
            DataItemTableFilter = Type = const(Item), "Outstanding Qty. (Base)" = filter(> 0), "Document Type" = filter('Order|Return Order');
            column(itemNo; "No.")
            {
            }
            column(outstandingQtyBase; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }
            column(expectedReceiptDate; "Expected Receipt Date")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(buyFromVendorNo; "Buy-from Vendor No.")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure")
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
        }
    }
}