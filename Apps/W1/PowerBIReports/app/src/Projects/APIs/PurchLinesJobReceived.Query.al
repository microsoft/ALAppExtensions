// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Purchases.Document;

query 36997 "Purch. Lines - Job Received"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Received Not Invoiced PO Line';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'jobReceivedNotInvoicedPurchaseLine';
    EntitySetName = 'jobReceivedNotInvoicedPurchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(receivedNotInvoicedPOLine; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = const(Order),
                                    "Job No." = filter(<> ''),
                                    "Qty. Rcd. Not Invoiced (Base)" = filter(> 0);
            column(documentType; "Document Type")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(no; "No.")
            {
            }
            column(lineNo; "Line No.")
            {
            }
            column(type; Type)
            {
            }
            column(qtyRcdNotInvoicedBase; "Qty. Rcd. Not Invoiced (Base)")
            {
            }
            column(amtRcdNotInvoicedLCY; "Amt. Rcd. Not Invoiced (LCY)")
            {
            }
            column(jobNo; "Job No.")
            {
            }
            column(jobTaskNo; "Job Task No.")
            {
            }
            column(expectedReceiptDate; "Expected Receipt Date")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(description; Description)
            {
            }
        }
    }
}
