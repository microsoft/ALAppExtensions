// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;

codeunit 4812 "Intrastat Report Doc. Compl."
{
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        MandatoryFieldErr: Label '%1 field cannot be empty.', Comment = '%1 - field name';

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterCheckSalesDoc, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnSalesDoc(var SalesHeader: Record "Sales Header")
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if SalesHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if not IsIntrastatTransaction(SalesHeader."VAT Country/Region Code") then
            exit;

        if SalesHeader.Ship or SalesHeader.Receive then begin
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Type Mandatory", SalesHeader."Transaction Type", SalesHeader.FieldCaption("Transaction Type"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Spec. Mandatory", SalesHeader."Transaction Specification", SalesHeader.FieldCaption("Transaction Specification"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Shipment Method Mandatory", SalesHeader."Shipment Method Code", SalesHeader.FieldCaption("Shipment Method Code"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transport Method Mandatory", SalesHeader."Transport Method", SalesHeader.FieldCaption("Transport Method"));

            if TempErrorMessage.HasErrors(true) then
                TempErrorMessage.ShowErrorMessages(true);
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterCheckPurchDoc, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnPurchaseDoc(var PurchHeader: Record "Purchase Header")
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if PurchHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if not IsIntrastatTransaction(PurchHeader."VAT Country/Region Code") then
            exit;

        if PurchHeader.Ship or PurchHeader.Receive then begin
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Type Mandatory", PurchHeader."Transaction Type", PurchHeader.FieldCaption("Transaction Type"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Spec. Mandatory", PurchHeader."Transaction Specification", PurchHeader.FieldCaption("Transaction Specification"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Shipment Method Mandatory", PurchHeader."Shipment Method Code", PurchHeader.FieldCaption("Shipment Method Code"));
            CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transport Method Mandatory", PurchHeader."Transport Method", PurchHeader.FieldCaption("Transport Method"));

            if TempErrorMessage.HasErrors(true) then
                TempErrorMessage.ShowErrorMessages(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnBeforeTransferOrderPostShipment, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnTransferShipment(var TransferHeader: Record "Transfer Header")
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if TransferHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if TransferHeader."Trsf.-from Country/Region Code" = TransferHeader."Trsf.-to Country/Region Code" then
            exit;

        if (not IsIntrastatTransaction(TransferHeader."Trsf.-to Country/Region Code")) and (not IsIntrastatTransaction(TransferHeader."Trsf.-from Country/Region Code")) then
            exit;

        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Type Mandatory", TransferHeader."Transaction Type", TransferHeader.FieldCaption("Transaction Type"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Spec. Mandatory", TransferHeader."Transaction Specification", TransferHeader.FieldCaption("Transaction Specification"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Shipment Method Mandatory", TransferHeader."Shipment Method Code", TransferHeader.FieldCaption("Shipment Method Code"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transport Method Mandatory", TransferHeader."Transport Method", TransferHeader.FieldCaption("Transport Method"));

        if TempErrorMessage.HasErrors(true) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforeTransferOrderPostReceipt, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnTransferReceipt(var TransferHeader: Record "Transfer Header")
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if TransferHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if TransferHeader."Trsf.-from Country/Region Code" = TransferHeader."Trsf.-to Country/Region Code" then
            exit;

        if (not IsIntrastatTransaction(TransferHeader."Trsf.-to Country/Region Code")) and (not IsIntrastatTransaction(TransferHeader."Trsf.-from Country/Region Code")) then
            exit;

        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Type Mandatory", TransferHeader."Transaction Type", TransferHeader.FieldCaption("Transaction Type"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transaction Spec. Mandatory", TransferHeader."Transaction Specification", TransferHeader.FieldCaption("Transaction Specification"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Shipment Method Mandatory", TransferHeader."Shipment Method Code", TransferHeader.FieldCaption("Shipment Method Code"));
        CheckIntrastatMandatoryFields(TempErrorMessage, IntrastatReportSetup."Transport Method Mandatory", TransferHeader."Transport Method", TransferHeader.FieldCaption("Transport Method"));

        if TempErrorMessage.HasErrors(true) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    local procedure IsIntrastatTransaction(CountryCode: Code[10]): Boolean
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        if not CountryRegion.Get(CountryCode) then
            exit(false);
        if CountryRegion."Intrastat Code" = '' then
            exit(false);
        CompanyInformation.Get();
        exit(CompanyInformation."Country/Region Code" <> CountryCode);
    end;

    local procedure CheckIntrastatMandatoryFields(var TempErrorMessage: Record "Error Message" temporary; ValueMandatory: Boolean; FieldValue: Code[20]; FieldCaption: Text)
    begin
        if ValueMandatory and (FieldValue = '') then
            TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, FieldCaption));
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