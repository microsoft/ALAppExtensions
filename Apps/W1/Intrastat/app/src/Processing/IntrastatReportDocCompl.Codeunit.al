// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
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
        CompanyInformation: Record "Company Information";
        MandatoryFieldErr: Label '%1 field cannot be empty.', Comment = '%1 - field name';
        MandatoryFieldsLineErr: Label '%1 field cannot be empty for the line %2.', Comment = '%1 - field name, %2 - Line No.';

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
        SalesLine: Record "Sales Line";
        CountryRegion: Record "Country/Region";
        Item: Record Item;
    begin
        if SalesHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        case IntrastatReportSetup."Shipments Based On" of
            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                if not CountryRegion.Get(SalesHeader."Bill-to Country/Region Code") then
                    exit;
            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                if not CountryRegion.Get(SalesHeader."Sell-to Country/Region Code") then
                    exit;
            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                if not CountryRegion.Get(SalesHeader."Ship-to Country/Region Code") then
                    exit;
        end;
        if CountryRegion."Intrastat Code" = '' then
            exit;

        if not CompanyInformation.Get() then
            exit;

        if CountryRegion.Code = CompanyInformation."Country/Region Code" then
            exit;

        if IntrastatReportSetup."Transaction Type Mandatory" then
            if SalesHeader."Transaction Type" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, SalesHeader.FieldCaption("Transaction Type")));

        if IntrastatReportSetup."Transaction Spec. Mandatory" then
            if SalesHeader."Transaction Specification" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, SalesHeader.FieldCaption("Transaction Specification")));

        if IntrastatReportSetup."Shipment Method Mandatory" then
            if SalesHeader."Shipment Method Code" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, SalesHeader.FieldCaption("Shipment Method Code")));

        if IntrastatReportSetup."Transport Method Mandatory" then
            if SalesHeader."Transport Method" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, SalesHeader.FieldCaption("Transport Method")));

        if TempErrorMessage.HasErrors(true) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterCheckPurchDoc, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnPurchaseDoc(var PurchHeader: Record "Purchase Header")
    var
        TempErrorMessage: Record "Error Message" temporary;
        PurchLine: Record "Purchase Line";
        CountryRegion: Record "Country/Region";
        Item: Record Item;
    begin
        if PurchHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not (PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order"]) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        case IntrastatReportSetup."Shipments Based On" of
            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                if not CountryRegion.Get(PurchHeader."Pay-to Country/Region Code") then
                    exit;
            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                if not CountryRegion.Get(PurchHeader."Buy-from Country/Region Code") then
                    exit;
            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                if not CountryRegion.Get(PurchHeader."Buy-from Country/Region Code") then
                    exit;
        end;
        if CountryRegion."Intrastat Code" = '' then
            exit;

        if not CompanyInformation.Get() then
            exit;

        if CountryRegion.Code = CompanyInformation."Country/Region Code" then
            exit;

        if IntrastatReportSetup."Transaction Type Mandatory" then
            if PurchHeader."Transaction Type" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, PurchHeader.FieldCaption("Transaction Type")));

        if IntrastatReportSetup."Transaction Spec. Mandatory" then
            if PurchHeader."Transaction Specification" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, PurchHeader.FieldCaption("Transaction Specification")));

        if IntrastatReportSetup."Shipment Method Mandatory" then
            if PurchHeader."Shipment Method Code" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, PurchHeader.FieldCaption("Shipment Method Code")));

        if IntrastatReportSetup."Transport Method Mandatory" then
            if PurchHeader."Transport Method" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, PurchHeader.FieldCaption("Transport Method")));

        if TempErrorMessage.HasErrors(true) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", OnCodeOnBeforePostTransferOrder, '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnTransferDoc(var TransHeader: Record "Transfer Header"; var Selection: Option)
    var
        TempErrorMessage: Record "Error Message" temporary;
        TransferLine: Record "Transfer Line";
        CountryRegion: Record "Country/Region";
        CountryRegion1: Record "Country/Region";
        Item: Record Item;
    begin
        if TransHeader.IsTemporary() or (not IntrastatReportSetup.ReadPermission) then
            exit;

        if not IntrastatReportSetup.Get() then
            exit;

        if TransHeader."Trsf.-from Country/Region Code" = TransHeader."Trsf.-to Country/Region Code" then
            exit;

        if (not CountryRegion.Get(TransHeader."Trsf.-from Country/Region Code") or (CountryRegion."Intrastat Code" = '')) and (not CountryRegion1.Get(TransHeader."Trsf.-to Country/Region Code") or (CountryRegion1."Intrastat Code" = '')) then
            exit;

        if IntrastatReportSetup."Transaction Type Mandatory" then
            if TransHeader."Transaction Type" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, TransHeader.FieldCaption("Transaction Type")));

        if IntrastatReportSetup."Transaction Spec. Mandatory" then
            if TransHeader."Transaction Specification" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, TransHeader.FieldCaption("Transaction Specification")));

        if IntrastatReportSetup."Shipment Method Mandatory" then
            if TransHeader."Shipment Method Code" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, TransHeader.FieldCaption("Shipment Method Code")));

        if IntrastatReportSetup."Transport Method Mandatory" then
            if TransHeader."Transport Method" = '' then
                TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, StrSubstNo(MandatoryFieldErr, TransHeader.FieldCaption("Transport Method")));

        if TempErrorMessage.HasErrors(true) then
            TempErrorMessage.ShowErrorMessages(true);
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