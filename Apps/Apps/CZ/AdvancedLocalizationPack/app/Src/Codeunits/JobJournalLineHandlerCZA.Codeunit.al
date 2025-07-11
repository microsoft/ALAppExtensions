// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

codeunit 31254 "Job Journal Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure SetGPPGfromSKUOnAfterAssignItemValues(var JobJournalLine: Record "Job Journal Line")
    begin
        JobJournalLine.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateVariantCode(var Rec: Record "Job Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateEventLocationCode(var Rec: Record "Job Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;
}
