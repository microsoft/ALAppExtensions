// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;

tableextension 31252 "Job Journal Line CZA" extends "Job Journal Line"
{
    procedure SetGPPGfromSKUCZA()
    var
        InventorySetup: Record "Inventory Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if Type <> Type::Item then
            exit;

        InventorySetup.Get();
        if not InventorySetup."Use GPPG from SKU CZA" then
            exit;

        TestField("No.");
        Item.Get("No.");
        if "Gen. Prod. Posting Group" <> Item."Gen. Prod. Posting Group" then
            Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        if StockkeepingUnit.Get("Location Code", "No.", "Variant Code") then
            if (StockkeepingUnit."Gen. Prod. Posting Group CZL" <> "Gen. Prod. Posting Group") and (StockkeepingUnit."Gen. Prod. Posting Group CZL" <> '') then
                Validate("Gen. Prod. Posting Group", StockkeepingUnit."Gen. Prod. Posting Group CZL");
        if "Gen. Bus. Posting Group" <> '' then
            GeneralPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
    end;
}
