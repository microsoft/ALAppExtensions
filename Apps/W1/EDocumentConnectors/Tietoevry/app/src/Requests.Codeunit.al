// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.eServices.EDocument;
using System.Text;
using System.Reflection;
using Microsoft.eServices.EDocument.Service.Participant;


/// <summary>
/// Construct meta data object for Tietoevry request
/// </summary>
codeunit 6396 Requests
{

    Access = Internal;
    Permissions = tabledata "Connection Setup" = r;

    var
        TietoevryAuth: Codeunit "Authenticator";
        HttpRequestMessage: HttpRequestMessage;
        BaseUrl, AuthUrl, CompanyId : Text;
        AccessToken: SecretText;
        ServiceParticipantNotFoundErr: Label 'No Service Participant defined for Customer %1 and E-Document Service %2.', Comment = '%1 - The customer no., %2 - The e-document service code';

    /// <summary>
    /// Create request for /outbound API
    /// https://accesspoint.qa.dataplatfor.ms/swagger-ui/#/Outbound%20Resource/post_outbound
    /// </summary>
    /// <param name="Data">The data object is the details of the invoice.</param>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateSubmitDocumentRequest(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; Data: Text): Codeunit Requests
    var
        ServiceParticipant: Record "Service Participant";
        Base64Convert: Codeunit "Base64 Convert";
        HttpHeaders, HttpContentHeaders : HttpHeaders;
        Content: Text;
        ContentJson: JsonObject;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/outbound');
        this.HttpRequestMessage.Method := 'POST';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', this.AddBearer(this.AccessToken));

        EDocument.TestField("Bill-to/Pay-to No.");
        if not ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, EDocument."Bill-to/Pay-to No.") then
            Error(ServiceParticipantNotFoundErr, EDocument."Bill-to/Pay-to No.", EDocumentService.Code);

        ContentJson.Add('payload', Base64Convert.ToBase64(Data));
        ContentJson.Add('sender', CompanyId);
        ContentJson.Add('receiver', ServiceParticipant."Participant Identifier");
        ContentJson.Add('profileId', EDocument."Message Profile Id");
        ContentJson.Add('documentId', EDocument."Message Document Id");
        ContentJson.Add('channel', 'PEPPOL');
        ContentJson.Add('reference', Format(EDocument."Entry No"));
        ContentJson.WriteTo(Content);


        this.HttpRequestMessage.Content.WriteFrom(Content);

        this.HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.Contains('Content-Type') then
            HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'application/json');

        exit(this);
    end;

    /// <summary>
    /// Create request for /outbound/:id API
    /// https://accesspoint.qa.dataplatfor.ms/swagger-ui/#/Outbound%20Resource/get_outbound__id_
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateGetDocumentStatusRequest(Id: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/outbound/' + Id);
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', this.AddBearer(this.AccessToken));
        HttpHeaders.Add('Accept', 'application/json');

        exit(this);
    end;

    /// <summary>
    /// Create request for /inbound?receiver=$companyid
    /// Takes a path as query parameters are computed for each request. 
    /// https://accesspoint.qa.dataplatfor.ms/swagger-ui/#/Inbound%20Resource/get_inbound
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateReceiveDocumentsRequest(): Codeunit Requests
    var
        TypeHelper: Codeunit "Type Helper";
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/inbound?receiver=' + TypeHelper.UrlEncode(this.CompanyId));
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', this.AddBearer(this.AccessToken));
        HttpHeaders.Add('Accept', 'application/json');

        exit(this);
    end;

    /// <summary>
    /// Create request for /inbound/$id
    /// https://accesspoint.qa.dataplatfor.ms/swagger-ui/#/Inbound%20Resource/get_inbound__id___payload_type__document
    /// </summary>
    /// <param name="Id">Document Id</param>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateDownloadRequest(Id: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/inbound/' + Id + '/PAYLOAD/document');
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', this.AddBearer(this.AccessToken));
        HttpHeaders.Add('Accept', 'application/octet-stream');

        exit(this);
    end;

    /// <summary>
    /// Create request for /inbound/$id/read
    /// https://accesspoint.qa.dataplatfor.ms/swagger-ui/#/Inbound%20Resource/post_inbound__id__read
    /// </summary>
    /// <param name="Id">Document Id</param>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateAcknowledgeRequest(Id: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/inbound/' + Id + '/read');
        this.HttpRequestMessage.Method := 'POST';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', this.AddBearer(this.AccessToken));
        HttpHeaders.Add('Accept', 'application/json');

        exit(this);
    end;

    /// <summary>
    /// Create request to get access token for Tietoevry API
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    [NonDebuggable]
    procedure CreateAuthenticateRequest(ClientId: SecretText; ClientSecret: SecretText): Codeunit Requests;
    var
        HttpContentHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.AuthUrl + '/token');
        this.HttpRequestMessage.Method := 'POST';
        this.HttpRequestMessage.Content.WriteFrom('grant_type=client_credentials&client_id=' + ClientId.Unwrap() + '&client_secret=' + ClientSecret.Unwrap());

        this.HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.Contains('Content-Type') then
            HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        exit(this);
    end;

    procedure GetRequest(): HttpRequestMessage
    begin
        exit(this.HttpRequestMessage);
    end;

    procedure Init()
    begin
        this.TietoevryAuth.CreateConnectionSetupRecord();
        this.BaseUrl := this.GetBaseUrl();
        this.AuthUrl := this.GetAuthUrl();
        this.CompanyId := this.GetCompanyId();
    end;

    /// <summary>
    /// Set access token on request.
    /// </summary>
    procedure Authenticate(): Codeunit Requests
    begin
        this.AccessToken := this.TietoevryAuth.GetAccessToken();
        exit(this);
    end;

    [NonDebuggable]
    local procedure AddBearer(Token: SecretText): SecretText
    begin
        exit('Bearer ' + Token.Unwrap());
    end;

    procedure GetBaseUrl(): Text
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();

        case ConnectionSetup."Send Mode" of
            "Send Mode"::Production:
                exit(ConnectionSetup."API URL");
            "Send Mode"::Test:
                exit(ConnectionSetup."Sandbox API URL");
            else
                Error('Unsupported %1 in %2', ConnectionSetup.FieldCaption("Send Mode"), ConnectionSetup.TableCaption);
        end;
    end;

    local procedure GetAuthUrl(): Text
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();

        case ConnectionSetup."Send Mode" of
            "Send Mode"::Production:
                exit(ConnectionSetup."Authentication URL");
            "Send Mode"::Test:
                exit(ConnectionSetup."Sandbox Authentication URL");
            else
                Error('Unsupported %1 in %2', ConnectionSetup.FieldCaption("Send Mode"), ConnectionSetup.TableCaption);
        end;
    end;

    procedure GetCompanyId(): Text
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();
        exit(ConnectionSetup."Company Id");
    end;
}