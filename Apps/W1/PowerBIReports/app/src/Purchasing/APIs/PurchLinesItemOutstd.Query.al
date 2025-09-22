// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Purchases.Document;

query 36998 "Purch. Lines - Item Outstd."
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Outstanding PO';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'itemOutstandingPurchaseLine';
    EntitySetName = 'itemOutstandingPurchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(purchaseHeader; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = const(Order);
            column(purchOrderNo; "No.")
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
                DataItemTableFilter = Type = const(Item), "Outstanding Qty. (Base)" = filter(> 0);

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
                column(outstandingQtyBase; "Outstanding Qty. (Base)")
                {
                }
                column(outstandingAmountLCY; "Outstanding Amt. Ex. VAT (LCY)")
                {
                }
                column(dimensionSetID; "Dimension Set ID")
                {
                }
            }
        }
    }
}