// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 31251 "Item Journal Line CZA" extends "Item Journal Line"
{
    fields
    {
        field(31002; "Delivery-to Source No. CZA"; Code[20])
        {
            Caption = 'Delivery-to Source No.';
            TableRelation = if ("Source Type" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("Source No.")) else
            if ("Source Type" = const(Vendor)) "Order Address".Code where("Vendor No." = field("Source No."));
            DataClassification = CustomerContent;
        }
        field(31006; "Currency Code CZA"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(31007; "Currency Factor CZA"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            DataClassification = CustomerContent;
        }
    }

    procedure SetGPPGfromSKUCZA()
    var
        InventorySetup: Record "Inventory Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        StockkeepingUnit: Record "Stockkeeping Unit";
        Item: Record Item;
    begin
        if not ((("Entry Type" = "Entry Type"::Output) and ("Work Center No." = '')) or
                  ("Entry Type" <> "Entry Type"::Output) or
                  ("Value Entry Type" = "Value Entry Type"::Revaluation)) then
            exit;

        InventorySetup.Get();
        if not InventorySetup."Use GPPG from SKU CZA" then
            exit;

        TestField("Item No.");
        Item.Get("Item No.");
        if "Gen. Prod. Posting Group" <> Item."Gen. Prod. Posting Group" then
            Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        if StockkeepingUnit.Get("Location Code", "Item No.", "Variant Code") then
            if (StockkeepingUnit."Gen. Prod. Posting Group CZL" <> "Gen. Prod. Posting Group") and
               (StockkeepingUnit."Gen. Prod. Posting Group CZL" <> '')
            then
                Validate("Gen. Prod. Posting Group", StockkeepingUnit."Gen. Prod. Posting Group CZL");
        if "Gen. Bus. Posting Group" <> '' then
            GeneralPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
    end;

    procedure CheckInventoryPostingGroupCZA()
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        OnBeforeCheckInventoryPostingGroupCZA(Rec, IsHandled);
        if IsHandled then
            exit;

        if ("Item No." = '') or ("Inventory Posting Group" = '') then
            exit;

        Item.Get("Item No.");
        if Item.Type = Item.Type::Inventory then
            TestField("Inventory Posting Group", Item."Inventory Posting Group");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckInventoryPostingGroupCZA(ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;
}
