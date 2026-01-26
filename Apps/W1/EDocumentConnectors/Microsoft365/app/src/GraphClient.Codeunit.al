// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System;
using System.Environment;
using System.Integration;
using System.Utilities;

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 6384 "Graph Client"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;

    internal procedure InitializeWebRequest(Url: Text; Method: Text; ReturnType: Text; var HttpWebRequestMgt: Codeunit "Http Web Request Mgt.")
    var
        GraphAuthentication: Codeunit "Graph Authentication";
        Token: SecretText;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            Error(AvailableOnlyOnSaaSErr);

        GraphAuthentication.GetAccessToken(Token);

        if Token.IsEmpty() then begin
            Session.LogMessage('0000OB4', EmptyTokenTelemetryMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
            Error(SignInAgainErr);
        end;

        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI();
        HttpWebRequestMgt.SetMethod(Method);
        HttpWebRequestMgt.SetReturnType(ReturnType);
        HttpWebRequestMgt.AddHeader('Authorization', SecretStrSubstNo('Bearer %1', Token));
    end;

    [TryFunction]
    [NonDebuggable]
    procedure GetDriveFolderInfo(FolderUrl: Text; var FolderJson: JsonObject)
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseBody: Text;
        ErrorMessage: Text;
        ErrorDetails: Text;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
    begin
        InitializeWebRequest(FolderUrl, 'GET', 'application/json', HttpWebRequestMgt);

        if not HttpWebRequestMgt.SendRequestAndReadTextResponse(ResponseBody, ErrorMessage, ErrorDetails, HttpStatusCode, ResponseHeaders) then begin
            Session.LogMessage('0000OB5', StrSubstNo(GraphStatusCodeTelemetryMsg, HttpStatusCode), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);

            CheckNoAccessError(HttpStatusCode, ErrorDetails);
            Error(UnexpectedStatusCodeErr, HttpStatusCode);
        end;

        if not FolderJson.ReadFrom(ResponseBody) then
            Error(InvalidJsonErr, ResponseBody);
    end;

    [TryFunction]
    [NonDebuggable]
    procedure GetFileContent(SiteId: Text; var TempDocumentSharing: Record "Document Sharing" temporary)
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Codeunit "Temp Blob";
        ErrorMessage: Text;
        ErrorDetails: Text;
        FileUrl: Text;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
        InStream: InStream;
        OutStream: OutStream;
    begin
        FileUrl := GetGraphItemByIdUrl(SiteId, TempDocumentSharing."Item Id") + '/content';

        InitializeWebRequest(FileUrl, 'GET', '', HttpWebRequestMgt);

        if not HttpWebRequestMgt.SendRequestAndReadResponse(TempBlob, ErrorMessage, ErrorDetails, HttpStatusCode, ResponseHeaders) then begin
            Session.LogMessage('0000OB6', StrSubstNo(GraphStatusCodeTelemetryMsg, HttpStatusCode), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);

            CheckNoAccessError(HttpStatusCode, ErrorDetails);
            Error(UnexpectedStatusCodeErr, HttpStatusCode);
        end;

        if TempBlob.Length() = 0 then
            Session.LogMessage('0000OB7', GraphEmptyFileTelemetryMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl)
        else begin
            Session.LogMessage('0000OB8', StrSubstNo(GraphFileTelemetryMsg, TempBlob.Length()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
            TempDocumentSharing.Data.CreateOutStream(OutStream);
            TempBlob.CreateInStream(InStream);
            CopyStream(OutStream, InStream);
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    procedure MoveDriveItem(SiteId: Text; ItemId: Text; NewFolderId: Text)
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseBody: Text;
        ErrorMessage: Text;
        ErrorDetails: Text;
        ItemUrl: Text;
        BodyTxt: Text;
        HttpStatusCode: DotNet HttpStatusCode;
        ResponseHeaders: DotNet NameValueCollection;
    begin
        ItemUrl := GetGraphItemByIdUrl(SiteId, ItemId);
        BodyTxt := '{ "parentReference": { "id": "' + NewFolderId + '" } }';
        InitializeWebRequest(ItemUrl, 'PATCH', '', HttpWebRequestMgt);
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.AddBodyAsText(BodyTxt);
        if not HttpWebRequestMgt.SendRequestAndReadTextResponse(ResponseBody, ErrorMessage, ErrorDetails, HttpStatusCode, ResponseHeaders) then begin
            Session.LogMessage('0000N7U', StrSubstNo(GraphStatusCodeTelemetryMsg, HttpStatusCode), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);

            CheckNoAccessError(HttpStatusCode, ErrorDetails);
            Error(UnexpectedStatusCodeErr, HttpStatusCode);
        end;
    end;

    local procedure GetGraphItemByIdUrl(SiteId: Text; ItemId: Text): Text
    begin
        exit(StrSubstNo(GraphItemUrlTxt, SiteId, ItemId));
    end;

    local procedure CheckNoAccessError(HttpStatusCode: Integer; HttpErrorDetails: Text)
    var
        ErrorTxt: Text;
    begin
        if HttpStatusCode in [401, 403, 404] then begin
            ErrorTxt := DocumentFolderNotAccessibleErr + '\\' + HttpErrorDetails;
            Error(ErrorTxt);
        end;
    end;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        GraphItemUrlTxt: Label 'https://graph.microsoft.com/v1.0/sites/%1/drive/items/%2', Locked = true;
        EmptyTokenTelemetryMsg: Label 'No Microsoft 365 access token received', Locked = true;
        AvailableOnlyOnSaaSErr: Label 'This functionality is available only when running on Business Central Online environment.';
        SignInAgainErr: Label 'No access token is available. You must sign in to the target resource with the correct credentials. If the problem persists, open a Business Central support request.';
        DocumentFolderNotAccessibleErr: Label 'Unable to access the folder specified on the setup page. Verify that the shared link points to an existing folder and that you have access to it.';
        GraphStatusCodeTelemetryMsg: Label 'Microsoft 365 returned an error code: %1.', Locked = true;
        UnexpectedStatusCodeErr: Label 'Remote service returned an unexpected error code: %1.', Comment = '%1 = An error code from OneDrive or Sharepoint, for example 503';
        InvalidJsonErr: Label 'Remote service returned an invalid response. Details: %1.', Comment = '%1 = The response details from OneDrive or Sharepoint (e.g. "Your Drive is not available")';
        CategoryLbl: Label 'EDoc Connector M365', Locked = true;
        GraphEmptyFileTelemetryMsg: Label 'Microsoft 365 returned an empty file.', Locked = true;
        GraphFileTelemetryMsg: Label 'Microsoft 365 file size: %1', Locked = true;

}