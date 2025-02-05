// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;

codeunit 4812 "Intrastat Report Doc. Compl."
{
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure DefaultSalesDocuments(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (not RunTrigger) or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if Rec."Document Type" in [Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order"] then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Return";

        if Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Order] then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Purchase";

        OnAfterDefaultSalesDocuments(Rec, IntrastatReportSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure DefaultPurchaseDocuments(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (not RunTrigger) or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if Rec."Document Type" in [Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order"] then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Return";

        if Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Order] then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Purchase";

        OnAfterDefaultPurchaseDocuments(Rec, IntrastatReportSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure DefaultServiceDocuments(var Rec: Record "Service Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (not RunTrigger) or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Return";

        if Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Order] then
            if Rec."Transaction Type" = '' then
                Rec."Transaction Type" := IntrastatReportSetup."Default Trans. - Purchase";

        OnAfterDefaultServiceDocuments(Rec, IntrastatReportSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDefaultPurchaseDocuments(var PurchaseHeader: Record "Purchase Header"; IntrastatReportSetup: Record "Intrastat Report Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDefaultSalesDocuments(var SalesHeader: Record "Sales Header"; IntrastatReportSetup: Record "Intrastat Report Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDefaultServiceDocuments(var ServiceHeader: Record "Service Header"; IntrastatReportSetup: Record "Intrastat Report Setup")
    begin
    end;
}