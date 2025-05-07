// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Reports;

codeunit 14139 "Create Item Journal TemplateMX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Item Journal Template")
    var
        CreateItemJournalTemplate: Codeunit "Create Item Journal Template";
    begin
        case Rec.Name of
            CreateItemJournalTemplate.ItemJournalTemplate():
                ValidateRecordFields(Rec, Report::"Item Register");
        end;
    end;

    local procedure ValidateRecordFields(var ItemJournalTemplate: Record "Item Journal Template"; PostingReportID: Integer)
    begin
        ItemJournalTemplate.Validate("Posting Report ID", PostingReportID);
    end;
}
