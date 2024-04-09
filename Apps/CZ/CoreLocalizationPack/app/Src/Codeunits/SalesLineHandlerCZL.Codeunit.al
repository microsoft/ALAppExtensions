// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

codeunit 11783 "Sales Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
#if not CLEAN22
    var
        SalesHeader: Record "Sales Header";
#endif
    begin
        SalesLine."Tariff No. CZL" := Item."Tariff No.";
#if not CLEAN22
#pragma warning disable AL0432
        SalesLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
        SalesLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            SalesLine."Physical Transfer CZL" := SalesHeader."Physical Transfer CZL";
#pragma warning restore AL0432
#endif
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        SalesLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveVATCorrectionOnBeforeDeleteEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        RemoveVATCorrection(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure RemoveVATCorrectionOnBeforeInsertEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        RemoveVATCorrection(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure RemoveVATCorrectionOnBeforeModifyEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        RemoveVATCorrection(Rec);
    end;

    local procedure RemoveVATCorrection(var SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
    begin
        // remove vat correction on current line
        if (SalesLine."VAT Difference" <> 0) and (SalesLine.Quantity <> 0) then begin
            SalesLine."VAT Difference" := 0;
            SalesLine.UpdateAmounts();
        end;

        // remove vat correction on another lines except the current line
        SalesLine2.Reset();
        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
        SalesLine2.SetFilter("VAT Difference", '<>0');
        if SalesLine2.FindSet() then
            repeat
                SalesLine2."VAT Difference" := 0;
                SalesLine2.UpdateAmounts();
                SalesLine2.Modify();
            until SalesLine2.Next() = 0;
    end;
}
