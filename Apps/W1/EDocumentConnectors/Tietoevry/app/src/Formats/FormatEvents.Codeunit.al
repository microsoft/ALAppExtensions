// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.Sales.Peppol;
using Microsoft.Sales.Document;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;

codeunit 6398 "Format Events"
{

    SingleInstance = true;
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyInfoByFormat"(var SupplierEndpointID: Text; var SupplierSchemeID: Text; var SupplierName: Text; IsBISBilling: Boolean)
    var
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;

        this.SplitId(EDocExtConnectionSetup."Company Id", SupplierSchemeID, SupplierEndpointID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyLegalEntityByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyLegalEntityByFormat"(var PartyLegalEntityRegName: Text; var PartyLegalEntityCompanyID: Text; var PartyLegalEntitySchemeID: Text; var SupplierRegAddrCityName: Text; var SupplierRegAddrCountryIdCode: Text; var SupplRegAddrCountryIdListId: Text; IsBISBilling: Boolean)
    var
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;

        this.SplitId(EDocExtConnectionSetup."Company Id", PartyLegalEntitySchemeID, PartyLegalEntityCompanyID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingCustomerPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingCustomerPartyInfoByFormat"(SalesHeader: Record "Sales Header"; var CustomerEndpointID: Text; var CustomerSchemeID: Text; var CustomerPartyIdentificationID: Text; var CustomerPartyIDSchemeID: Text; var CustomerName: Text; IsBISBilling: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;
        ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.");
        this.SplitId(ServiceParticipant."Participant Identifier", CustomerSchemeID, CustomerEndpointID);
        this.SplitId(ServiceParticipant."Participant Identifier", CustomerPartyIDSchemeID, CustomerPartyIdentificationID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingCustomerPartyLegalEntityByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingCustomerPartyLegalEntityByFormat"(SalesHeader: Record "Sales Header"; var CustPartyLegalEntityRegName: Text; var CustPartyLegalEntityCompanyID: Text; var CustPartyLegalEntityIDSchemeID: Text; IsBISBilling: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;

        ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.");
        this.SplitId(ServiceParticipant."Participant Identifier", CustPartyLegalEntityIDSchemeID, CustPartyLegalEntityCompanyID);
    end;


    local procedure SplitId(Input: Text; var SchemeId: Text; var EndpointId: Text)
    var
        Parts: List of [Text];
    begin
        Parts := Input.Split(':');
        SchemeId := Parts.Get(1);
        EndpointId := Parts.Get(2);
    end;
}
