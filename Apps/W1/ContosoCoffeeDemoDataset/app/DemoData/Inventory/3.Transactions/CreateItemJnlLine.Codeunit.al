// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;

codeunit 5538 "Create Item Jnl Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        CreateItem: Codeunit "Create Item";
        ContosoItem: Codeunit "Contoso Item";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateItemJournalTemplate: Codeunit "Create Item Journal Template";
        TemplateName, BatchName : Code[10];
    begin
        ItemJournalTemplate.Get(CreateItemJournalTemplate.ItemJournalTemplate());
        ItemJournalBatch.Get(ItemJournalTemplate.Name, ContosoUtilities.GetDefaultBatchNameLbl());

        BatchName := ItemJournalBatch.Name;
        TemplateName := ItemJournalTemplate.Name;

        // Create 500 units for each item
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.AthensDesk(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.ParisGuestChairBlack(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.AthensMobilePedestal(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.LondonSwivelChairBlue(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.AntwerpConferenceTable(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.ConferenceBundle16(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.AmsterdamLamp(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.ConferenceBundle18(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.BerlingGuestChairYellow(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.GuestSection1(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.RomeGuestChairGreen(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.TokyoGuestChairBlue(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.ConferenceBundle28(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.MexicoSwivelChairBlack(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.ConferencePackage1(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.MunichSwivelChairYellow(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.MoscowSwivelChairRed(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.SeoulGuestChairRed(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.AtlantaWhiteboardBase(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));
        ContosoItem.InsertItemJournalLine(TemplateName, BatchName, CreateItem.SydneySwivelChairGreen(), '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 500, '', ContosoUtilities.AdjustDate(19020601D));

        // Post the journal lines
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindFirst() then
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;
}
