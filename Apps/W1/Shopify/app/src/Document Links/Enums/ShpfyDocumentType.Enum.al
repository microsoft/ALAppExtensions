// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30143 "Shpfy Document Type" implements "Shpfy IOpenBCDocument"
{
    Extensible = true;
    DefaultImplementation = "Shpfy IOpenBCDocument" = "Shpfy OpenBCDoc NotSupported";

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Order")
    {
        Caption = 'Sales Order';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open SalesOrder";
    }
    value(2; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open SalesInvoice";
    }
    value(3; "Sales Return Order")
    {
        Caption = 'Sales Return Order';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open SalesReturnOrder";
    }
    value(4; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open SalesCrMemo";
    }
    value(5; "Posted Sales Shipment")
    {
        Caption = 'Posted Sales Shipment';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open SalesShipment";
    }
    value(6; "Posted Return Receipt")
    {
        Caption = 'Posted Return Receipt';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open PostedReturnReceipt";
    }
    value(7; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open PostedSalesInvoice";
    }
    value(8; "Posted Sales Credit Memo")
    {
        Caption = 'Posted Sales Credit Memo';
        Implementation = "Shpfy IOpenBCDocument" = "Shpfy Open PostedSalesCrMemo";
    }
}