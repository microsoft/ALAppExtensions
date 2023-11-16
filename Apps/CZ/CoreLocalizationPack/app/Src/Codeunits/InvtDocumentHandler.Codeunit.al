// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Document;

using Microsoft.Inventory.History;

codeunit 31369 "Invt. Document Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Invt. Document Header", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure CheckInvtTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Invt. Document Header"; var xRec: Record "Invt. Document Header"; CurrFieldNo: Integer)
    begin
        if (Rec."Gen. Bus. Posting Group" = xRec."Gen. Bus. Posting Group") or
           (Rec."Invt. Movement Template CZL" <> xRec."Invt. Movement Template CZL")
        then
            exit;

        Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Receipt", 'OnRunOnBeforeInvtRcptHeaderInsert', '', false, false)]
    local procedure CopyInvtDocumentToInvtReceiptOnRunOnBeforeInvtRcptHeaderInsert(var InvtRcptHeader: Record "Invt. Receipt Header"; InvtDocHeader: Record "Invt. Document Header")
    begin
        InvtRcptHeader."Invt. Movement Template CZL" := InvtDocHeader."Invt. Movement Template CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invt. Doc.-Post Shipment", 'OnRunOnBeforeInvtShptHeaderInsert', '', false, false)]
    local procedure CopyInvtDocumentToInvtShipmentOnRunOnBeforeInvtShptHeaderInsert(var InvtShptHeader: Record "Invt. Shipment Header"; InvtDocHeader: Record "Invt. Document Header")
    begin
        InvtShptHeader."Invt. Movement Template CZL" := InvtDocHeader."Invt. Movement Template CZL";
    end;
}
