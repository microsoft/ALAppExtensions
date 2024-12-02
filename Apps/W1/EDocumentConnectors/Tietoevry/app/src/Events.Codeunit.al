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
using Microsoft.eServices.EDocument.Service.Participant;
codeunit 6395 Events
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
            Error(this.MissingCompInfVATRegNoErr, CompanyInformation.TableCaption());
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
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;

        IsHandled := true;
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) and
               Customer.Get(SalesHeader."Bill-to Customer No.")
            then
            if Customer."VAT Registration No." = '' then
                Error(this.MissingCustInfoErr, Customer.FieldCaption("VAT Registration No."), Customer."No.");

        if not ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.") then
            ServiceParticipant.Init();

        if ServiceParticipant."Participant Identifier" = '' then
            Error(this.MissingCustInfoErr, ServiceParticipant.FieldCaption("Participant Identifier"), Customer."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Participant", 'OnAfterValidateEvent', 'Participant Identifier', false, false)]
    local procedure OnAfterValidateServiceParticipant(var Rec: Record "Service Participant"; var xRec: Record "Service Participant"; CurrFieldNo: Integer)
    var
        EDocumentService: Record "E-Document Service";
    begin
        if not EDocumentService.Get(Rec.Service) then
            exit;
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::Tietoevry then
            exit;
        if Rec."Participant Identifier" <> '' then
            if not this.TietoevryProcessing.IsValidSchemeId(Rec."Participant Identifier") then
                Rec.FieldError(Rec."Participant Identifier");
    end;

    var
        TietoevryProcessing: Codeunit "Processing";
        MissingCompInfVATRegNoErr: Label 'You must specify VAT Registration No. in %1.', Comment = '%1=Company Information';
        MissingCustInfoErr: Label 'You must specify %1 for Customer %2.', Comment = '%1=Fieldcaption %2=Customer No.';
}
