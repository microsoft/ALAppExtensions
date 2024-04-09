// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Item.Catalog;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Setup;

codeunit 31260 "Nonstock Item Handler CZA"
{
    ObsoleteReason = 'Replaced by standard "Item No. Series"';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    var
        NonstockItemSetup: Record "Nonstock Item Setup";

    [EventSubscriber(ObjectType::Table, Database::"Nonstock Item", 'OnModifyOnNoFormatElseCase', '', false, false)]
    local procedure ItemFromItemSeriesOnModifyOnNoFormatElseCase(NonstockItem: Record "Nonstock Item"; var ItemNo: Code[20])
    begin
        NonstockItemSetup.Get();
        case NonStockItemSetup."No. Format" of
            NonStockItemSetup."No. Format"::"Item No. Series CZA":
                ItemNo := NonstockItem."Item No.";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Catalog Item Management", 'OnAfterDetermineItemNoAndItemNoSeries', '', false, false)]
    local procedure ItemNoFromItemSeriesOnAfterDetermineItemNoAndItemNoSeries(var NonstockItem: Record "Nonstock Item")
    begin
        NonstockItemSetup.Get();
        case NonStockItemSetup."No. Format" of
            NonStockItemSetup."No. Format"::"Item No. Series CZA":
                GetItemNoFromNoSeries(NonstockItem);
        end;
    end;

    local procedure GetItemNoFromNoSeries(var NonstockItem: Record "Nonstock Item")
    var
        InvtSetup: Record "Inventory Setup";
        ItemTempl: Record "Item Templ.";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ItemTempl.SetLoadFields("No. Series");
        ItemTempl.Get(NonstockItem."Item Templ. Code");
        NonstockItem."Item No. Series" := ItemTempl."No. Series";

        if NonstockItem."Item No. Series" = '' then begin
            InvtSetup.Get();
            InvtSetup.TestField("Item Nos.");
            NonstockItem."Item No. Series" := InvtSetup."Item Nos.";
        end;

        NoSeriesMgt.InitSeries(NonstockItem."Item No. Series", '', 0D, NonstockItem."Item No.", NonstockItem."Item No. Series");
    end;
}
#endif
