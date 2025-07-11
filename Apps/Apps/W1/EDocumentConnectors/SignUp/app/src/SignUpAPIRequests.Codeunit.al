// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using Microsoft.EServices.EDocument.Service.Participant;
using Microsoft.Foundation.Company;
using System.Security.Authentication;
using System.Text;
using System.Utilities;
using System.Xml;
using System.Environment;

codeunit 6441 "SignUp API Requests"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region variables

    var
        CompanyId: Text[100];
        MissingSetupErr: Label 'Connection Setup is missing';
        MissingSetupMessageErr: Label 'You must set up service integration in the e-document service card.';
        MissingSetupNavigationActionErr: Label 'Show E-Document Services';
        MissingSetupCompanyIdErr: Label '%1 in %2 is missing', Comment = '%1 = Field Name, %2 = Table Name';
        MissingSetupCompanyIdMessageErr: Label 'You must set up %1 in %2.', Comment = '%1 = Field Name, %2 = Table Name';
        MissingSetupCompanyIdActionErr: Label 'Show %1', Comment = '%1 = Table Name';
        UnSupportedDocumentTypeTxt: Label 'Document %1 is not supported.', Comment = '%1 = EDocument Type';
        UnSupportedDocumentTypeProfileMissingTxt: Label 'Document %1 is not supported since %2 is missing in %3 %4', Comment = '%1 = EDocument Type; %2 = Profile Id; %3 = E-Document Service; %4 = Supported Document Types';
        SupportedDocumentTypesTxt: Label 'Supported Document Types';
        SenderReceiverPrefixTxt: Label 'iso6523-actorid-upis::', Locked = true;
        ContentTypeTxt: Label 'Content-Type', Locked = true;
        ApplicationJsonTxt: Label 'application/json', Locked = true;
        AuthorizationTxt: Label 'Authorization', Locked = true;
        AcceptTxt: Label 'Accept', Locked = true;
        AllTxt: Label '*/*', Locked = true;
        ApplicationResponseTxt: Label 'ApplicationResponse', Locked = true;
        InvoiceTxt: Label 'Invoice', Locked = true;
        CrMemoTxt: Label 'CreditNote', Locked = true;
        PaymentReminderTxt: Label 'PaymentReminder', Locked = true;
        DocumentTypeTxt: Label 'documentType', Locked = true;
        ReceiverTxt: Label 'receiver', Locked = true;
        SenderTxt: Label 'sender', Locked = true;
        SenderCountryCodeTxt: Label 'senderCountryCode', Locked = true;
        DocumentIdTxt: Label 'documentId', Locked = true;
        DocumentIdSchemeTxt: Label 'documentIdScheme', Locked = true;
        ProcessIdTxt: Label 'processId', Locked = true;
        ProcessIdSchemeTxt: Label 'processIdScheme', Locked = true;
        SendModeTxt: Label 'sendMode', Locked = true;
        DocumentTxt: Label 'document', Locked = true;


    #endregion

    #region public methods

    /// <summary>
    /// The method sends a file to the API.
    /// https://[BASEURL]/api/v2/Peppol/outbox/transactions
    /// </summary>
    /// <param name="TempBlob">TempBlob</param>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
        HttpContent: HttpContent;
        Payload: Text;
    begin
        Payload := this.XmlToTxt(TempBlob);
        if Payload = '' then
            exit;

        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Environment Type", "Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::POST, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/outbox/transactions');
        this.PrepareContent(HttpContent, Payload, EDocument, SignUpConnectionSetup);
        HttpRequestMessage.Content(HttpContent);
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method checks the status of the sent document.
    /// https://[BASE URL]/api/v2/Peppol/outbox/transactions/{transactionId}/status
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure GetSentDocumentStatus(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/outbox/transactions/' + EDocument."SignUp Document Id" + '/status');
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method modifies the document.
    /// https://[BASE URL]/api/v2/Peppol/outbox/transactions/{transactionId}/acknowledge
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure PatchDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::PATCH, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/outbox/transactions/' + EDocument."SignUp Document Id" + '/acknowledge');
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the received document request.
    /// https://[BASE URL]/api/v2/Peppol/inbox/transactions
    /// </summary>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>    
    /// <returns>True if successfully completed</returns>
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/inbox/transactions?partyId=' + this.SenderReceiverPrefixTxt + this.GetCompanyId());
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the target document request.
    /// https://[BASE URL]/api/v2/Peppol/inbox/transactions/{transactionId}
    /// </summary>
    /// <param name="DocumentId">Document ID</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/inbox/transactions/' + DocumentId);
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method modifies the received document.
    /// https://[BASE URL]/api/v2/Peppol/inbox/transactions/{transactionId}/acknowledge
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure PatchReceivedDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::PATCH, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/inbox/transactions/' + EDocument."SignUp Document Id" + '/acknowledge');
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method fetches metadata profiles.
    /// https://[BASE URL]/api/v2/Peppol/metadataprofile
    /// </summary>
    /// <param name="HttpRequestMessage">The HTTP request message to be sent.</param>
    /// <param name="HttpResponseMessage">The HTTP response message received.</param>
    /// <returns>Returns true if the metadata profiles were successfully fetched, otherwise false.</returns>
    procedure FetchMetaDataProfiles(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        SignUpConnectionSetup.SetLoadFields("Service URL");
        this.GetSetup(SignUpConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, SignUpConnectionSetup."Service URL" + '/api/v2/Peppol/metadataprofile');
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage, false));
    end;


    /// <summary>
    /// The method gets the marketplace credentials.
    /// </summary>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>   
    procedure GetMarketPlaceCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpAuthentication: Codeunit "SignUp Authentication";
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::POST, SignUpAuthentication.GetMarketplaceUrl() + '/api/Registration/init?EntraTenantId=' + SignUpAuthentication.GetBCInstanceIdentifier() + '&EnvironmentName=' + this.GetEnvironmentName());
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage, true));
    end;

    #endregion

    #region local methods
    local procedure GetEnvironmentName(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            exit(EnvironmentInformation.GetEnvironmentName())
        else
            exit(EnvironmentInformation.GetEnvironmentName()); //Change if OnPrem should be supported
    end;

    local procedure InitRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        Clear(HttpRequestMessage);
        Clear(HttpResponseMessage);
    end;

    local procedure GetSetup(var SignUpConnectionSetup: Record "SignUp Connection Setup")
    var
        MissingSetupErrorInfo: ErrorInfo;
    begin
        if not IsNullGuid(SignUpConnectionSetup.SystemId) then
            exit;

        if not SignUpConnectionSetup.Get() then begin
            MissingSetupErrorInfo.Title := this.MissingSetupErr;
            MissingSetupErrorInfo.Message := this.MissingSetupMessageErr;
            MissingSetupErrorInfo.PageNo := Page::"E-Document Services";
            MissingSetupErrorInfo.AddNavigationAction(this.MissingSetupNavigationActionErr);
            Error(MissingSetupErrorInfo);
        end;
    end;

    local procedure GetCompanyId(): Text[100]
    var
        CompanyInformation: Record "Company Information";
        MissingSetupErrorInfo: ErrorInfo;
    begin
        if this.CompanyId <> '' then
            exit(this.CompanyId);

        CompanyInformation.SetLoadFields("SignUp Service Participant Id");
        if not CompanyInformation.Get() or (CompanyInformation."SignUp Service Participant Id" = '') then begin
            MissingSetupErrorInfo.Title := StrSubstNo(this.MissingSetupCompanyIdErr, CompanyInformation.FieldName("SignUp Service Participant Id"), CompanyInformation.TableName);
            MissingSetupErrorInfo.Message := StrSubstNo(this.MissingSetupCompanyIdMessageErr, CompanyInformation.FieldName("SignUp Service Participant Id"), CompanyInformation.TableName);
            MissingSetupErrorInfo.PageNo := Page::"Company Information";
            MissingSetupErrorInfo.AddNavigationAction(StrSubstNo(this.MissingSetupCompanyIdActionErr, CompanyInformation.TableName));
            Error(MissingSetupErrorInfo);
        end;
        this.CompanyId := CompanyInformation."SignUp Service Participant Id";
        exit(this.CompanyId);
    end;

    local procedure PrepareContent(var HttpContent: HttpContent; Payload: Text; EDocument: Record "E-Document"; SignUpConnectionSetup: Record "SignUp Connection Setup")
    var
        ContentText: Text;
        HttpHeaders: HttpHeaders;
    begin
        Clear(HttpContent);
        ContentText := this.PrepareContentForSend(EDocument, this.GetCompanyId(), this.GetSenderCountryCode(), Payload, SignUpConnectionSetup."Environment Type");
        HttpContent.WriteFrom(ContentText);
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains(this.ContentTypeTxt) then
            HttpHeaders.Remove(this.ContentTypeTxt);
        HttpHeaders.Add(this.ContentTypeTxt, this.ApplicationJsonTxt);
    end;

    local procedure SendRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage, false));
    end;

    local procedure SendRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; MarketplaceRequest: Boolean): Boolean
    var
        SignUpAuthentication: Codeunit "SignUp Authentication";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if MarketplaceRequest then
            HttpHeaders.Add(this.AuthorizationTxt, SignUpAuthentication.GetMarketplaceBearerAuthToken())
        else
            HttpHeaders.Add(this.AuthorizationTxt, SignUpAuthentication.GetBearerAuthToken());
        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; Uri: Text) RequestMessage: HttpRequestMessage
    var
        HttpHeaders: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(Uri);
        RequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add(this.AcceptTxt, this.AllTxt);
    end;

    local procedure XmlToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        Content: Text;
    begin
        XMLDOMManagement.TryGetXMLAsText(TempBlob.CreateInStream(TextEncoding::UTF8), Content);
        exit(Content);
    end;

    local procedure GetDocumentType(EDocument: Record "E-Document"): Text
    begin
        if EDocument.Direction = EDocument.Direction::Incoming then
            exit(this.ApplicationResponseTxt);

        case EDocument."Document Type" of
            "E-Document Type"::"Sales Invoice":
                exit(this.InvoiceTxt);
            "E-Document Type"::"Sales Credit Memo":
                exit(this.CrMemoTxt);
            "E-Document Type"::"Issued Finance Charge Memo",
            "E-Document Type"::"Issued Reminder":
                exit(this.PaymentReminderTxt);
            else
                Error(this.UnSupportedDocumentTypeTxt, EDocument."Document Type");
        end;
    end;

    local procedure GetCustomerID(EDocument: Record "E-Document") Return: Text[50]
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.SetLoadFields("E-Document Service Code");
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindFirst();
        ServiceParticipant.SetLoadFields("Participant Identifier");
        ServiceParticipant.Get(EDocumentServiceStatus."E-Document Service Code", ServiceParticipant."Participant Type"::Customer, EDocument."Bill-to/Pay-to No.");
        Return := CopyStr(ServiceParticipant."Participant Identifier", 1, MaxStrLen(Return));
    end;

    local procedure GetSenderCountryCode(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.SetLoadFields("Country/Region Code");
        CompanyInformation.Get();
        CompanyInformation.TestField("Country/Region Code");
        exit(CompanyInformation."Country/Region Code");
    end;

    local procedure PrepareContentForSend(EDocument: Record "E-Document"; SendingCompanyID: Text; SenderCountryCode: Text; Payload: Text; SendMode: Enum "SignUp Environment Type"): Text
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
        SignUpMetadataProfile: Record "SignUp Metadata Profile";
        EDocumentHelper: Codeunit "E-Document Helper";
        Base64Convert: Codeunit "Base64 Convert";
        JsonObject: JsonObject;
        ContentText: Text;
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);

        if EDocumentService.Code = '' then begin
            EDocumentServiceStatus.SetRange("E-Document Entry No", Edocument."Entry No");
            if EDocumentServiceStatus.FindLast() then
                EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
        end;

        EDocServiceSupportedType.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocServiceSupportedType.SetRange("Source Document Type", EDocument."Document Type");
        if not EDocServiceSupportedType.FindFirst() then
            Error(this.UnSupportedDocumentTypeProfileMissingTxt, EDocument."Document Type", EDocServiceSupportedType.FieldCaption("Profile Id"), EDocumentService.TableCaption, this.SupportedDocumentTypesTxt);
        if (EDocServiceSupportedType."Profile Id" = 0) or (not SignUpMetadataProfile.Get(EDocServiceSupportedType."Profile Id")) then
            Error(this.UnSupportedDocumentTypeProfileMissingTxt, EDocument."Document Type", EDocServiceSupportedType.FieldCaption("Profile Id"), EDocumentService.TableCaption, this.SupportedDocumentTypesTxt);

        JsonObject.Add(this.DocumentTypeTxt, this.GetDocumentType(EDocument));
        JsonObject.Add(this.ReceiverTxt, this.SenderReceiverPrefixTxt + this.GetCustomerID(EDocument));
        JsonObject.Add(this.SenderTxt, this.SenderReceiverPrefixTxt + SendingCompanyID);
        JsonObject.Add(this.SenderCountryCodeTxt, SenderCountryCode);
        if EDocument.Direction = EDocument.Direction::Incoming then
            JsonObject.Add(this.DocumentIdTxt, this.ApplicationResponseTxt)
        else
            JsonObject.Add(this.DocumentIdTxt, SignUpMetadataProfile."Document Identifier Value");
        JsonObject.Add(this.DocumentIdSchemeTxt, SignUpMetadataProfile."Document Identifier Scheme");
        JsonObject.Add(this.ProcessIdTxt, SignUpMetadataProfile."Process Identifier Value");
        JsonObject.Add(this.ProcessIdSchemeTxt, SignUpMetadataProfile."Process Identifier Scheme");
        JsonObject.Add(this.SendModeTxt, Format(SendMode));
        JsonObject.Add(this.DocumentTxt, Base64Convert.ToBase64(Payload));
        JsonObject.WriteTo(ContentText);
        exit(ContentText);
    end;

    #endregion
}