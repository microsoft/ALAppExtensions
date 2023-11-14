// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

codeunit 31255 "Purchase Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure SetGPPGfromSKUOnAfterAssignItemValues(var PurchLine: Record "Purchase Line")
    begin
        PurchLine.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateVariantCodeOnAfterValidationChecks', '', false, false)]
    local procedure SetGPPGfromSKUOnValidateVariantCodeOnAfterValidationChecks(var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateEventLocationCode(var Rec: Record "Purchase Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;
}
