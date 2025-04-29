// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.Sales.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Inventory.Setup;
using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 5128 "Create Common No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Sales & Receivables Setup" = r,
        tabledata "Purchases & Payables Setup" = r,
        tabledata "Inventory Setup" = r;

    trigger OnRun()
    var
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        InventorySetup: Record "Inventory Setup";
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        SalesReceivablesSetup.Get();

        if SalesReceivablesSetup."Customer Nos." = '' then
            ContosoNoSeries.InsertNoSeries(Customer(), CustomerLbl, 'C10', 'C99990', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);

        if SalesReceivablesSetup."Order Nos." = '' then
            ContosoNoSeries.InsertNoSeries(SalesOrder(), SalesOrderLbl, '101001', '102999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        if SalesReceivablesSetup."Invoice Nos." = '' then
            ContosoNoSeries.InsertNoSeries(SalesInvoice(), SalesInvoiceLbl, '101001', '102999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        if SalesReceivablesSetup."Posted Invoice Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PostedSalesInvoice(), PostedSalesInvoiceLbl, '101001', '102999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        InventorySetup.Get();
        if InventorySetup."Item Nos." = '' then
            ContosoNoSeries.InsertNoSeries(Item(), ItemsLbl, '1000', '9999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);

        PurchasePayablesSetup.Get();

        if PurchasePayablesSetup."Vendor Nos." = '' then
            ContosoNoSeries.InsertNoSeries(Vendor(), VendorLbl, 'V10', 'V99990', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);

        if PurchasePayablesSetup."Order Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PurchaseOrder(), PurchaseOrderLbl, '106001', '107999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        if PurchasePayablesSetup."Invoice Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PurchaseInvoice(), PurchaseInvoiceLbl, '106001', '107999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        if PurchasePayablesSetup."Posted Invoice Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PostedPurchaseInvoice(), PostedPurchaseInvoiceLbl, '106001', '107999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

        if PurchasePayablesSetup."Posted Receipt Nos." = '' then
            ContosoNoSeries.InsertNoSeries(PostedReceipt(), PostedReceiptLbl, '106001', '107999', '', '', 1, Enum::"No. Series Implementation"::Normal, false);

    end;

    var
        CustomerTok: Label 'CUST', MaxLength = 20;
        CustomerLbl: Label 'Customer', MaxLength = 100;
        VendorTok: Label 'VEND', MaxLength = 20;
        VendorLbl: Label 'Vendor', MaxLength = 100;
        ItemTok: Label 'ITEM', MaxLength = 20;
        ItemsLbl: Label 'Items', MaxLength = 100;
        SalesOrderTok: Label 'S-ORD', MaxLength = 20;
        SalesOrderLbl: Label 'Sales Order', MaxLength = 100;
        SalesInvoiceTok: Label 'S-INV', MaxLength = 20;
        SalesInvoiceLbl: Label 'Sales Invoice', MaxLength = 20;
        PostedSalesInvoiceTok: Label 'PS-INV', MaxLength = 20;
        PostedSalesInvoiceLbl: Label 'Posted Sales Invoice', MaxLength = 20;
        PurchaseOrderTok: Label 'P-ORD', MaxLength = 20;
        PurchaseOrderLbl: Label 'Purchase Order', MaxLength = 100;
        PurchaseInvoiceTok: Label 'P-INV', MaxLength = 20;
        PurchaseInvoiceLbl: Label 'Purchase Invoice', MaxLength = 100;
        PostedPurchaseInvoiceTok: Label 'PP-INV', MaxLength = 20;
        PostedPurchaseInvoiceLbl: Label 'Posted Purchase Invoice', MaxLength = 100;
        PostedReceiptTok: Label 'P-RPT', MaxLength = 20;
        PostedReceiptLbl: Label 'Posted Receipt', MaxLength = 20;


    procedure Customer(): Code[20]
    begin
        exit(CustomerTok);
    end;

    procedure Vendor(): Code[20]
    begin
        exit(VendorTok);
    end;

    procedure Item(): Code[20]
    begin
        exit(ItemTok);
    end;

    procedure SalesOrder(): Code[20]
    begin
        exit(SalesOrderTok);
    end;

    procedure SalesInvoice(): Code[20]
    begin
        exit(SalesInvoiceTok);
    end;

    procedure PostedSalesInvoice(): Code[20]
    begin
        exit(PostedSalesInvoiceTok);
    end;

    procedure PurchaseOrder(): Code[20]
    begin
        exit(PurchaseOrderTok);
    end;

    procedure PurchaseInvoice(): Code[20]
    begin
        exit(PurchaseInvoiceTok);
    end;

    procedure PostedPurchaseInvoice(): Code[20]
    begin
        exit(PostedPurchaseInvoiceTok);
    end;

    procedure PostedReceipt(): Code[20]
    begin
        exit(PostedReceiptTok);
    end;
}
