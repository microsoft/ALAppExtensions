// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.EServices.EDocumentConnector.Avalara.Models;
using System.Reflection;


/// <summary>
/// Construct meta data object for Avalara request
/// </summary>
codeunit 6376 Requests
{

    Access = Internal;
    Permissions = tabledata "Connection Setup" = r;

    var
        AvalaraAuth: Codeunit "Authenticator";
        HttpRequestMessage: HttpRequestMessage;
        BaseUrl, AuthUrl, DataBoundary, ApiVersion, AvalaraClient : Text;
        AccessToken: SecretText;

    /// <summary>
    /// Create request for /einvoicing/documents API
    /// https://developer.avalara.com/api-reference/e-invoicing/einvoice/methods/Documents/SubmitDocument/
    /// </summary>
    /// <param name="Metadata">The metadata instructs the Avalara E-Invoicing service how to process the data (invoice) provided.</param>
    /// <param name="Data">The data object is the details of the invoice in the dataFormat and dataFormatVersion schema provided as part of the metadata object.</param>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateSubmitDocumentRequest(var Metadata: Codeunit Metadata; Data: Text): Codeunit Requests
    var
        HttpHeaders, HttpContentHeaders : HttpHeaders;
        MultiPartContent: TextBuilder;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/einvoicing/documents');
        this.HttpRequestMessage.Method := 'POST';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        MultiPartContent.AppendLine('--' + this.DataBoundary);
        MultiPartContent.AppendLine('Content-Disposition: form-data; name="metadata"');
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(Metadata.ToString());
        MultiPartContent.AppendLine('--' + this.DataBoundary);
        MultiPartContent.AppendLine('Content-Disposition: form-data; name="data"');
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(Data);
        MultiPartContent.AppendLine('--' + this.DataBoundary + '--');

        this.HttpRequestMessage.Content.WriteFrom(MultiPartContent.ToText());

        this.HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.Contains('Content-Type') then
            HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'multipart/form-data; boundary=' + this.DataBoundary);

        exit(this);
    end;

    /// <summary>
    /// Create request for /einvoicing/documents/:id/status API
    /// https://developer.avalara.com/api-reference/e-invoicing/einvoice/methods/Documents/GetDocumentStatus/
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateGetDocumentStatusRequest(Id: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/einvoicing/documents/' + Id + '/status');
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        exit(this);
    end;

    /// <summary>
    /// Create request for /scs/companies
    /// https://developer.avalara.com/api-reference/sharedservice/sharedCompanyService/methods/Companies/QueryCompanies/
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateGetCompaniesRequest(): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/scs/companies');
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        exit(this);
    end;

    /// <summary>
    /// Create request for /einvoicing/documents
    /// Takes a path as query parameters are computed for each request. 
    /// https://developer.avalara.com/api-reference/e-invoicing/einvoice/methods/Documents/GetDocumentList/
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateReceiveDocumentsRequest(Path: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + Path);
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        exit(this);
    end;

    /// <summary>
    /// Create request for /einvoicing/documents/$id/$download
    /// https://developer.avalara.com/api-reference/e-invoicing/einvoice/methods/Documents/DownloadDocument/
    /// </summary>
    /// <param name="Id">Document Id</param>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateDownloadRequest(Id: Text): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/einvoicing/documents/' + Id + '/$download');
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('Accept', 'application/vnd.oasis.ubl+xml');
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        exit(this);
    end;

    /// <summary>
    /// Create request for /einvoicing/mandates
    /// https://developer.avalara.com/api-reference/e-invoicing/einvoice/methods/Mandates/GetMandates/
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateGetMandates(): Codeunit Requests
    var
        HttpHeaders: HttpHeaders;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.BaseUrl + '/einvoicing/mandates');
        this.HttpRequestMessage.Method := 'GET';

        this.HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', AddBearer(this.AccessToken));
        HttpHeaders.Add('avalara-version', this.ApiVersion);
        HttpHeaders.Add('X-Avalara-Client', this.AvalaraClient);

        exit(this);

    end;

    /// <summary>
    /// Create request to get access token for Avalara API
    /// </summary>
    /// <returns>A request object that can be used for the endpoint.</returns>
    procedure CreateAuthenticateRequest(ClientId: SecretText; ClientSecret: SecretText): Codeunit Requests;
    var
        TypeHelper: Codeunit "Type Helper";
        HttpContentHeaders: HttpHeaders;
        ContentDataTxt: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2', Locked = true;
    begin
        Clear(this.HttpRequestMessage);
        this.HttpRequestMessage.SetRequestUri(this.AuthUrl + '/connect/token');
        this.HttpRequestMessage.Method := 'POST';
        ClientId := TypeHelper.UrlEncode(ClientId);
        ClientSecret := TypeHelper.UrlEncode(ClientSecret);

        this.HttpRequestMessage.Content.WriteFrom(SecretStrSubstNo(ContentDataTxt, ClientId, ClientSecret));
        this.HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.ContainsSecret('Content-Type') then
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
        this.AvalaraAuth.CreateConnectionSetupRecord();
        this.BaseUrl := GetBaseUrl();
        this.AuthUrl := GetAuthUrl();
        this.DataBoundary := CreateGuid();
        this.DataBoundary := DelChr(this.DataBoundary, '<>=', '{}&[]*()!@#$%^+=;:"''<>,.?/|\\~`');

        this.ApiVersion := '1.0';
        this.AvalaraClient := 'a0nUz00000MVekTIAT';
    end;

    /// <summary>
    /// Set access token on request.
    /// </summary>
    procedure Authenticate(): Codeunit Requests
    begin
        this.AccessToken := this.AvalaraAuth.GetAccessToken();
        exit(this);
    end;

    [NonDebuggable]
    local procedure AddBearer(Token: SecretText): SecretText
    var
        AuthorizationHeaderValueTxt: Label 'Bearer %1', Locked = true;
    begin
        exit(SecretStrSubstNo(AuthorizationHeaderValueTxt, Token));
    end;

    procedure GetBaseUrl(): Text
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();

        case ConnectionSetup."Avalara Send Mode" of
            "Avalara Send Mode"::Production:
                exit(ConnectionSetup."API URL");
            "Avalara Send Mode"::Test:
                exit(ConnectionSetup."Sandbox API URL");
            else
                Error('Unsupported %1 in %2', ConnectionSetup.FieldCaption("Avalara Send Mode"), ConnectionSetup.TableCaption);
        end;
    end;

    local procedure GetAuthUrl(): Text
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();

        case ConnectionSetup."Avalara Send Mode" of
            "Avalara Send Mode"::Production:
                exit(ConnectionSetup."Authentication URL");
            "Avalara Send Mode"::Test:
                exit(ConnectionSetup."Sandbox Authentication URL");
            else
                Error('Unsupported %1 in %2', ConnectionSetup.FieldCaption("Avalara Send Mode"), ConnectionSetup.TableCaption);
        end;
    end;

}