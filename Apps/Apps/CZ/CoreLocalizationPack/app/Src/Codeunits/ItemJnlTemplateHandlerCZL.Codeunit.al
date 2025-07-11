// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Inventory.History;

codeunit 11789 "Item Jnl. Template Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Template", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure PostingReportIDOnAfterValidateEventType(var Rec: Record "Item Journal Template")
    begin
        if Rec.Type <> Rec.Type::Revaluation then
            Rec."Posting Report ID" := Report::"Posted Inventory Document CZL";
    end;
}
