// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

enum 7279 "Document Lookup Types" implements DocumentLookupSubType
{
    Access = Internal;
    Extensible = false;

    value(0; "Sales Order")
    {
        Implementation = DocumentLookupSubType = SalesOrderLookup;
    }
    value(1; "Posted Sales Invoice")
    {
        Implementation = DocumentLookupSubType = SalesInvoiceLookup;
    }
    value(2; "Posted Sales Shipment")
    {
        Implementation = DocumentLookupSubType = SalesShipmentLookup;
    }
    value(3; "Sales Quote")
    {
        Implementation = DocumentLookupSubType = SalesQuoteLookup;
    }
    value(4; "Blanket Sales Order")
    {
        Implementation = DocumentLookupSubType = BlanketSalesOrderLookup;
    }
}