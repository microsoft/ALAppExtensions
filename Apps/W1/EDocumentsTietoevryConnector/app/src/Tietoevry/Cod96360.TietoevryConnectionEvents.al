namespace TietoevryConnector.TietoevryConnector;

using Microsoft.Sales.Peppol;
using Microsoft.Sales.Document;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.EServices.EDocumentConnector;
using Microsoft.eServices.EDocument;
using System.Utilities;

codeunit 96360 "Tietoevry Connection Events"
{
    SingleInstance = true;
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo, '', false, false)]
    local procedure "PEPPOL Validation_OnCheckSalesDocumentOnBeforeCheckCompanyVATRegNo"(SalesHeader: Record "Sales Header"; CompanyInformation: Record "Company Information"; var IsHandled: Boolean)
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
    begin
        if not ExternalConnectionSetup.Get() then
            Error(MissingSetupErr);
        IsHandled := true;
        if CompanyInformation."VAT Registration No." = '' then
            Error(MissingCompInfVATRegNoErr, CompanyInformation.TableCaption());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", OnCheckSalesDocumentOnBeforeCheckCustomerVATRegNo, '', false, false)]
    local procedure "PEPPOL Validation_OnCheckSalesDocumentOnBeforeCheckCustomerVATRegNo"(SalesHeader: Record "Sales Header"; Customer: Record Customer; var IsHandled: Boolean)
    begin
        IsHandled := true;
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) and
               Customer.Get(SalesHeader."Bill-to Customer No.")
            then
            if Customer."VAT Registration No." = '' then
                Error(MissingCustInfoErr, Customer.FieldCaption("VAT Registration No."), Customer."No.");
        if Customer."Service Participant Id" = '' then
            Error(MissingCustInfoErr, Customer.FieldCaption("Service Participant Id"), Customer."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnAfterInsertImportedEdocument', '', false, false)]
    local procedure OnAfterInsertEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
        DocumentOutStream: OutStream;
        ContentData, MessageId : Text;
    begin
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
        if Rec."Document Format" = Rec."Document Format"::"TE PEPPOL BIS 3.0" then begin
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
    end;

    var
        TietoevryConnection: Codeunit "Tietoevry Connection";
        TietoevryProcessing: Codeunit "Tietoevry Processing";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";

        MissingSetupErr: Label 'You must set up service integration in the E-Document service card.';
#pragma warning disable AA0470
        MissingCompInfVATRegNoErr: Label 'You must specify VAT Registration No. in %1.', Comment = '%1=Company Information';
#pragma warning restore AA0470
#pragma warning disable AA0470
        MissingCustInfoErr: Label 'You must specify %1 for Customer %2.', Comment = '%1=Fieldcaption %2=Customer No.';
#pragma warning restore AA0470
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
}
