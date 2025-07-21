// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Reports;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Reports;
using Microsoft.Service.Document;
using Microsoft.Service.Posting;
using Microsoft.Service.Reports;


codeunit 4812 "Intrastat Report Doc. Compl."
{
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        MustBeSpecifiedLbl: Label '%1 must be specified.', Comment = '%1 = FieldCaption';

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

    [EventSubscriber(ObjectType::Report, Report::"Sales Document - Test", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocSalesDocumentTest(SalesHeader: Record "Sales Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if SalesHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not (SalesHeader.Ship or SalesHeader.Receive) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if SalesHeader.IsIntrastatTransaction() and SalesHeader.ShipOrReceiveInventoriableTypeItems() then begin
            if IntrastatReportSetup."Transaction Type Mandatory" then
                if SalesHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transaction Spec. Mandatory" then
                if SalesHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transport Method Mandatory" then
                if SalesHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Shipment Method Mandatory" then
                if SalesHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Service Document - Test", 'OnAfterCheckServiceDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckServiceDocServiceDocumentTest(ServiceHeader: Record "Service Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if ServiceHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if ServiceHeader.IsIntrastatTransaction() and ServiceHeader.ShipOrReceiveInventoriableTypeItems() then begin
            if IntrastatReportSetup."Transaction Type Mandatory" then
                if ServiceHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, ServiceHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transaction Spec. Mandatory" then
                if ServiceHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, ServiceHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transport Method Mandatory" then
                if ServiceHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, ServiceHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Shipment Method Mandatory" then
                if ServiceHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, ServiceHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", 'OnAfterCheckPurchaseDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckPurchaseDocPurchaseDocumentTest(PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if PurchaseHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not (PurchaseHeader.Ship or PurchaseHeader.Receive) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if PurchaseHeader.IsIntrastatTransaction() and PurchaseHeader.ShipOrReceiveInventoriableTypeItems() then begin
            if IntrastatReportSetup."Transaction Type Mandatory" then
                if PurchaseHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transaction Spec. Mandatory" then
                if PurchaseHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Transport Method Mandatory" then
                if PurchaseHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if IntrastatReportSetup."Shipment Method Mandatory" then
                if PurchaseHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterCheckBeforePost', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")
    begin
        TransferHeader.CheckIntrastatMandatoryFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocSalesPost(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CheckIntrastatMandatoryFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnInitializeOnAfterCheckAndSetPostingConstants', '', false, false)]
    local procedure OnInitializeOnAfterCheckAndSetPostingConstants(var PassedServiceHeader: Record "Service Header"; var PassedServiceLine: Record "Service Line"; var PassedShip: Boolean; var PassedConsume: Boolean; var PassedInvoice: Boolean; PreviewMode: Boolean)
    begin
        if PassedShip then
            PassedServiceHeader.CheckIntrastatMandatoryFields();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDocPurchPost(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.CheckIntrastatMandatoryFields();
    end;

    local procedure AddError(Text: Text[250]; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
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