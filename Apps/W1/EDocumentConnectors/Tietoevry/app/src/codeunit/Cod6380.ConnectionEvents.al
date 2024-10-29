// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.Sales.Peppol;
using Microsoft.Sales.Document;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Service;

codeunit 6380 "Connection Events"
{
    SingleInstance = true;
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo, '', false, false)]
    local procedure "PEPPOL Validation_OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo"(SalesHeader: Record "Sales Header"; CompanyInformation: Record "Company Information"; var IsHandled: Boolean)
    var
        ExternalConnectionSetup: Record "Connection Setup";
    begin
        if not ExternalConnectionSetup.Get() then
            exit;

        IsHandled := true;
        if CompanyInformation."VAT Registration No." = '' then
            Error(MissingCompInfVATRegNoErr, CompanyInformation.TableCaption());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", OnCheckSalesDocumentOnBeforeCheckCustomerVATRegNo, '', false, false)]
    local procedure "PEPPOL Validation_OnCheckSalesDocumentOnBeforeCheckCustomerVATRegNo"(SalesHeader: Record "Sales Header"; Customer: Record Customer; var IsHandled: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not EDocExtConnectionSetup.Get() then
            exit;
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;

        IsHandled := true;
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) and
               Customer.Get(SalesHeader."Bill-to Customer No.")
            then
            if Customer."VAT Registration No." = '' then
                Error(MissingCustInfoErr, Customer.FieldCaption("VAT Registration No."), Customer."No.");

        if not ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.") then
            ServiceParticipant.Init();

        if ServiceParticipant."Participant Identifier" = '' then
            Error(MissingCustInfoErr, ServiceParticipant.FieldCaption("Participant Identifier"), Customer."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnAfterInsertImportedEdocument', '', false, false)]
    local procedure OnAfterInsertEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
        DocumentOutStream: OutStream;
        ContentData, MessageId : Text;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Tietoevry then
            exit;

        HttpResponse.Content.ReadAs(ContentData);
        if not TietoevryProcessing.ParseReceivedDocument(ContentData, EDocument."Index In Batch", MessageId) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;

        TietoevryConnection.HandleGetTargetDocumentRequest(MessageId, LocalHttpRequest, LocalHttpResponse, false);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);

        LocalHttpResponse.Content.ReadAs(ContentData);
        if ContentData = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(CouldNotRetrieveDocumentErr, MessageId));

        Clear(TempBlob);
        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        DocumentOutStream.WriteText(ContentData);

        TietoevryProcessing.AcknowledgeEDocument(EDocument, EDocumentService, MessageId);

        EDocument."Message Id" := CopyStr(MessageId, 1, MaxStrLen(EDocument."Message Id"));

        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Service", 'OnAfterValidateEvent', 'Document Format', false, false)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service"; var xRec: Record "E-Document Service"; CurrFieldNo: Integer)
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        if Rec."Document Format" <> Rec."Document Format"::"TE PEPPOL BIS 3.0" then
            exit;

        EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
        if EDocServiceSupportedType.IsEmpty() then begin
            EDocServiceSupportedType.Init();
            EDocServiceSupportedType."E-Document Service Code" := Rec.Code;
            EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
            EDocServiceSupportedType.Insert();

            EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
            EDocServiceSupportedType.Insert();

            EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
            EDocServiceSupportedType.Insert();

            EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
            EDocServiceSupportedType.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Participant", 'OnAfterValidateEvent', 'Participant Identifier', false, false)]
    local procedure OnAfterValidateServiceParticipant(var Rec: Record "Service Participant"; var xRec: Record "Service Participant"; CurrFieldNo: Integer)
    var
        EDocumentService: Record "E-Document Service";
    begin
        if not EDocumentService.Get(Rec.Service) then
            exit;
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Tietoevry then
            exit;
        if Rec."Participant Identifier" <> '' then
            if not TietoevryProcessing.IsValidSchemeId(Rec."Participant Identifier") then
                Rec.FieldError(Rec."Participant Identifier");
    end;

    var
        TietoevryConnection: Codeunit "Connection";
        TietoevryProcessing: Codeunit "Processing";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
#pragma warning disable AA0470
        MissingCompInfVATRegNoErr: Label 'You must specify VAT Registration No. in %1.', Comment = '%1=Company Information';
#pragma warning restore AA0470
#pragma warning disable AA0470
        MissingCustInfoErr: Label 'You must specify %1 for Customer %2.', Comment = '%1=Fieldcaption %2=Customer No.';
#pragma warning restore AA0470
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
}
