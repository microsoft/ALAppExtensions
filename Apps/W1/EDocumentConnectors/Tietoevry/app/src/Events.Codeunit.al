// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.Sales.Peppol;
using Microsoft.Sales.Document;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using System.Automation;
using Microsoft.Foundation.Reporting;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Service.Participant;
codeunit 6395 Events
{
    SingleInstance = true;
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo, '', false, false)]
    local procedure "PEPPOL Validation_OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo"(SalesHeader: Record "Sales Header"; CompanyInformation: Record "Company Information"; var IsHandled: Boolean)
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        if not ConnectionSetup.Get() then
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
        ConnectionSetup: Record "Connection Setup";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        if not ConnectionSetup.Get() then
            exit;

        DocumentSendingProfile.GetDefaultForCustomer(Customer."No.", DocumentSendingProfile);
        if DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow" then
            exit;

        if not this.GetServicesInWorkflow(EDocumentService, DocumentSendingProfile."Electronic Service Flow") then
            exit;

        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::Tietoevry);
        if not EDocumentService.FindSet() then
            exit;
        IsHandled := true;
        repeat
            if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) and Customer.Get(SalesHeader."Bill-to Customer No.") then
                if Customer."VAT Registration No." = '' then
                    Error(this.MissingCustInfoErr, Customer.FieldCaption("VAT Registration No."), Customer."No.");

            if not ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.") then
                ServiceParticipant.Init();

            if ServiceParticipant."Participant Identifier" = '' then
                Error(this.MissingCustInfoErr, ServiceParticipant.FieldCaption("Participant Identifier"), Customer."No.");
        until EDocumentService.Next() = 0;
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

    internal procedure GetServicesInWorkflow(var EDocServices: Record "E-Document Service"; WorkFlowCode: Code[20]): Boolean
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStep: Record "Workflow Step";
        Workflow: Record Workflow;
        Filter: Text;
    begin
        Workflow.Get(WorkFlowCode);
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        WorkflowStep.SetRange(Type, WorkflowStep.Type::Response);
        if WorkflowStep.FindSet() then
            repeat
                WorkflowStepArgument.Get(WorkflowStep.Argument);
                this.AddFilter(Filter, WorkflowStepArgument."E-Document Service");
            until WorkflowStep.Next() = 0;

        if Filter = '' then
            exit(false);

        EDocServices.SetFilter(Code, Filter);
        exit(true);
    end;

    internal procedure AddFilter(var Filter: Text; Value: Text)
    begin
        if Value = '' then
            exit;

        if Filter = '' then
            Filter := Value
        else
            Filter += '|' + Value;
    end;

    var
        TietoevryProcessing: Codeunit "Processing";
        MissingCompInfVATRegNoErr: Label 'You must specify VAT Registration No. in %1.', Comment = '%1=Company Information';
        MissingCustInfoErr: Label 'You must specify %1 for Customer %2.', Comment = '%1=Fieldcaption %2=Customer No.';
}
