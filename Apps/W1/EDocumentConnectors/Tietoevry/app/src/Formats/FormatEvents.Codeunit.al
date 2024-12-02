// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.Sales.Peppol;
using Microsoft.Sales.Document;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;
using System.IO;
using Microsoft.eServices.EDocument.IO.Peppol;
using System.Utilities;

codeunit 6398 "Format Events"
{

    SingleInstance = true;
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EDoc PEPPOL BIS 3.0", OnAfterCreatePEPPOLXMLDocument, '', false, false)]
    local procedure OnAfterCreatePEPPOLXMLDocument(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob");
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        DocInStream: InStream;
        MessageDocumentId: Text;
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::Tietoevry then
            exit;

        TempBlob.CreateInStream(DocInStream);
        TempXMLBuffer.LoadFromStream(DocInStream);
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name, 'ProfileID');
        if TempXMLBuffer.FindFirst() then
            EDocument."Message Profile Id" := TempXMLBuffer.Value;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Attribute);
        TempXMLBuffer.SetRange(Name, 'xmlns');
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId := TempXMLBuffer.Value;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name);
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId += '::' + TempXMLBuffer.Name;

        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Name, 'CustomizationID');
        if TempXMLBuffer.FindFirst() then
            MessageDocumentId += '##' + TempXMLBuffer.Value + '::2.1';

        EDocument."Message Document Id" := MessageDocumentId;
        EDocument.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyInfoByFormat"(var SupplierEndpointID: Text; var SupplierSchemeID: Text; var SupplierName: Text; IsBISBilling: Boolean)
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not ConnectionSetup.Get() then
            exit;

        this.SplitId(ConnectionSetup."Company Id", SupplierSchemeID, SupplierEndpointID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyLegalEntityByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyLegalEntityByFormat"(var PartyLegalEntityRegName: Text; var PartyLegalEntityCompanyID: Text; var PartyLegalEntitySchemeID: Text; var SupplierRegAddrCityName: Text; var SupplierRegAddrCountryIdCode: Text; var SupplRegAddrCountryIdListId: Text; IsBISBilling: Boolean)
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not ConnectionSetup.Get() then
            exit;

        this.SplitId(ConnectionSetup."Company Id", PartyLegalEntitySchemeID, PartyLegalEntityCompanyID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingCustomerPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingCustomerPartyInfoByFormat"(SalesHeader: Record "Sales Header"; var CustomerEndpointID: Text; var CustomerSchemeID: Text; var CustomerPartyIdentificationID: Text; var CustomerPartyIDSchemeID: Text; var CustomerName: Text; IsBISBilling: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        ConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not ConnectionSetup.Get() then
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
        ConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not ConnectionSetup.Get() then
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