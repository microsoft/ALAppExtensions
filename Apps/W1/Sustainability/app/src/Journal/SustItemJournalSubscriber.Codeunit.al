// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Journal;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Sustainability.Setup;

codeunit 6282 "Sust. Item Journal Subscriber"
{

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnBeforeValidateUnitOfMeasureCode', '', false, false)]
    local procedure OnValidateItemNoOnBeforeValidateUnitOfMeasureCode(var Item: Record Item; var ItemJournalLine: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if (ItemJournalLine.IsSourceItemJournal() or (ItemJournalLine.IsSourceItemReclassJournal())) and
           (SustainabilitySetup.IsValueChainTrackingEnabled())
        then
            ItemJournalLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
}