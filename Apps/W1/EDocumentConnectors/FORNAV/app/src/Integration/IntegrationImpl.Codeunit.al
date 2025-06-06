namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Privacy;

codeunit 6418 "ForNAV Integration Impl." implements IDocumentSender, IDocumentResponseHandler, IDocumentReceiver, ISentDocumentActions, IConsentManager
{
    Access = Internal;

    var
        ForNAVProcessing: Codeunit "ForNAV Processing";

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        ForNAVProcessing.SendDocument(EDocument, SendContext);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    begin
        SendContext.Http().GetHttpRequestMessage().SetRequestUri('https://GetResponse');
        exit(ForNAVProcessing.GetResponse(EDocument, SendContext));
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        ForNAVProcessing.ReceiveDocuments(ReceiveContext, DocumentsMetadata);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        ForNAVProcessing.GetDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        ConnectionSetupCard: Page "ForNAV Peppol Setup";
    begin
        if not EDocumentService.ForNAVIsServiceIntegration() then
            exit;
        ConnectionSetupCard.RunModal();
        IsServiceIntegrationSetupRun := true;
    end;

    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        ActionContext.Http().GetHttpRequestMessage().SetRequestUri('https://GetApprovalStatus');
        exit(ForNAVProcessing.GetDocumentApproval(EDocument) = "ForNAV Incoming E-Doc Status"::Approved);
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        ActionContext.Http().GetHttpRequestMessage().SetRequestUri('https://GetCancellationStatus');
        exit(ForNAVProcessing.GetDocumentApproval(EDocument) = "ForNAV Incoming E-Doc Status"::Rejected);
    end;

    procedure ObtainPrivacyConsent(): Boolean
    var
        CustConsentMgt: Codeunit "Customer Consent Mgt.";
        CustomConsentMessageLbl: Label 'Please agree to the ForNAV EULA: https://www.fornav.com/documents/EULA.pdf', Locked = true;
    begin
        exit(CustConsentMgt.ConfirmCustomConsent(CustomConsentMessageLbl));
    end;
}
