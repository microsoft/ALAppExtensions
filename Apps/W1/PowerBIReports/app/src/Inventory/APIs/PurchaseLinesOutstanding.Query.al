// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Purchases.Document;

query 36973 "Purchase Lines - Outstanding"
{
    Access = Internal;
    Caption = 'Power BI Purchase Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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