// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;

codeunit 6443 "SignUp Connection"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = m;

    #region variables

    var
        SignUpAPIRequests: Codeunit "SignUp API Requests";
        SignUpHelpersImpl: Codeunit "SignUp Helpers";
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
        EnvironmentBlocksErr: Label 'The request to send documents has been blocked. To resolve the problem, enable outgoing HTTP requests for the E-Document apps on the Extension Management page.';
        NoValidSubscriptionErr: Label 'You do not have a valid subscription.';
        MetadataProfileLbl: Label 'metadataProfile', Locked = true;
        ProfileIdLbl: Label 'profileId', Locked = true;
        CommonNameLbl: Label 'commonName', Locked = true;
        ProcessIdentifierLbl: Label 'processIdentifier', Locked = true;
        SchemeLbl: Label 'scheme', Locked = true;
        ValueLbl: Label 'value', Locked = true;
        DocumentIdentifierLbl: Label 'documentIdentifier', Locked = true;


    #endregion

    #region public methods

    /// <summary>
    /// The methods sends a file to the API.
    /// </summary>
    /// <param name="TempBlob">Content</param>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True - if completed successfully</returns>
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.SignUpAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(this.CheckIfSuccessfulRequest(EDocument, HttpResponseMessage));
    end;

    /// <summary>
    /// The method checks the status of the document.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure CheckDocumentStatus(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.SignUpAPIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(this.CheckIfSuccessfulRequest(EDocument, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets received documents.
    /// </summary>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetReceivedDocuments(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        if not this.SignUpAPIRequests.GetReceivedDocumentsRequest(HttpRequestMessage, HttpResponseMessage) then
            exit;

        if not HttpResponseMessage.IsSuccessStatusCode() then
            if HttpResponseMessage.HttpStatusCode = 403 then
                Error(this.NoValidSubscriptionErr)
            else
                exit;

        exit(this.SignUpHelpersImpl.ParseJsonString(HttpResponseMessage.Content) <> '');
    end;

    /// <summary>
    /// The method gets the target document.
    /// </summary>
    /// <param name="DocumentId">DocumentId</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.SignUpAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequestMessage, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    /// <summary>
    /// The method removes the document from received.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure RemoveDocumentFromReceived(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.SignUpAPIRequests.PatchReceivedDocument(EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    /// <summary>
    /// Updates the Metadata Profile table.
    /// If the data is Fectched, the current Metadata Profile table will be deleted and the new data will be inserted.
    /// If any Metadata Profiles have been removed, references to them will be set to 0.
    /// </summary>
    /// <remarks>
    /// This procedure retrieves and updates the metadata profile information from an external service.
    /// </remarks>
    procedure UpdateMetadataProfile()
    var
        SignUpMetadataProfile: Record "SignUp Metadata Profile";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        MetadataProfileContent: Text;
    begin
        this.SignUpAPIRequests.FetchMetaDataProfiles(HttpRequestMessage, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            if HttpResponseMessage.HttpStatusCode = 403 then
                Message(this.NoValidSubscriptionErr)
            else
                Message(HttpResponseMessage.ReasonPhrase);
            exit;
        end;

        if not HttpResponseMessage.Content.ReadAs(MetadataProfileContent) then
            exit;

        SignUpMetadataProfile.Reset();
        SignUpMetadataProfile.DeleteAll();

        if this.MetadataProfileJsonToTable(MetadataProfileContent, SignUpMetadataProfile) then
            this.DeleteUnusedMetadataProfileReferenses(SignUpMetadataProfile);
    end;
    #endregion

    #region local methods
    local procedure CheckIfSuccessfulRequest(EDocument: Record "E-Document"; HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
    begin
        if HttpResponseMessage.IsSuccessStatusCode() then
            exit(true);

        if HttpResponseMessage.IsBlockedByEnvironment() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.EnvironmentBlocksErr)
        else
            if HttpResponseMessage.HttpStatusCode = 403 then
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.NoValidSubscriptionErr)
            else
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.UnsuccessfulResponseErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));
    end;

    local procedure MetadataProfileJsonToTable(JsonText: Text; var SignUpMetadataProfile: Record "SignUp Metadata Profile"): Boolean
    var
        JsonObject, ProfileJsonObject, ProcessIdentifierJsonObject, DocumentIdentifierJsonObject : JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(JsonText) then
            if JsonObject.Get(this.MetadataProfileLbl, JsonToken) then
                if JsonToken.IsArray() then begin
                    JsonArray := JsonToken.AsArray();
                    foreach JsonToken in JsonArray do
                        if JsonToken.IsObject() then begin
                            ProfileJsonObject := JsonToken.AsObject();
                            SignUpMetadataProfile.Init();

                            if ProfileJsonObject.SelectToken(this.ProfileIdLbl, JsonToken) then
                                SignUpMetadataProfile."Profile ID" := this.GetJsonValueAsInteger(JsonToken.AsValue());

                            if ProfileJsonObject.SelectToken(this.CommonNameLbl, JsonToken) then
                                SignUpMetadataProfile."Profile Name" := CopyStr(this.GetJsonValueAsText(JsonToken.AsValue()), 1, MaxStrLen(SignUpMetadataProfile."Profile Name"));

                            if ProfileJsonObject.SelectToken(this.ProcessIdentifierLbl, JsonToken) then begin
                                ProcessIdentifierJsonObject := JsonToken.AsObject();

                                if ProcessIdentifierJsonObject.SelectToken(this.SchemeLbl, JsonToken) then
                                    SignUpMetadataProfile."Process Identifier Scheme" := CopyStr(this.GetJsonValueAsText(JsonToken.AsValue()), 1, MaxStrLen(SignUpMetadataProfile."Process Identifier Scheme"));

                                if ProcessIdentifierJsonObject.SelectToken(this.ValueLbl, JsonToken) then
                                    SignUpMetadataProfile."Process Identifier Value" := CopyStr(this.GetJsonValueAsText(JsonToken.AsValue()), 1, MaxStrLen(SignUpMetadataProfile."Process Identifier Value"));
                            end;

                            if ProfileJsonObject.SelectToken(this.DocumentIdentifierLbl, JsonToken) then begin
                                DocumentIdentifierJsonObject := JsonToken.AsObject();

                                if DocumentIdentifierJsonObject.SelectToken(this.SchemeLbl, JsonToken) then
                                    SignUpMetadataProfile."Document Identifier Scheme" := CopyStr(this.GetJsonValueAsText(JsonToken.AsValue()), 1, MaxStrLen(SignUpMetadataProfile."Document Identifier Scheme"));

                                if DocumentIdentifierJsonObject.SelectToken(this.ValueLbl, JsonToken) then
                                    SignUpMetadataProfile."Document Identifier Value" := CopyStr(this.GetJsonValueAsText(JsonToken.AsValue()), 1, MaxStrLen(SignUpMetadataProfile."Document Identifier Value"));
                            end;

                            SignUpMetadataProfile.Insert();
                        end;
                end;
        exit(not SignUpMetadataProfile.IsEmpty());
    end;

    local procedure DeleteUnusedMetadataProfileReferenses(var SignUpMetadataProfile: Record "SignUp Metadata Profile")
    var
        EDocumentService: Record "E-Document Service";
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        EDocumentService.SetLoadFields("Service Integration V2");
        EDocumentService.Reset();
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::"ExFlow E-Invoicing");
        if EDocumentService.FindSet() then
            repeat
                EDocServiceSupportedType.Reset();
                EDocServiceSupportedType.SetRange("E-Document Service Code", EDocumentService.Code);
                if not EDocServiceSupportedType.FindSet() then
                    repeat
                        if EDocServiceSupportedType."Profile Id" <> 0 then
                            if not SignUpMetadataProfile.Get(EDocServiceSupportedType."Profile Id") then begin
                                EDocServiceSupportedType."Profile Id" := 0;
                                EDocServiceSupportedType.Modify();
                            end;
                    until EDocServiceSupportedType.Next() = 0;
            until EDocumentService.Next() = 0;
    end;

    local procedure GetJsonValueAsInteger(JValue: JsonValue): Integer
    begin
        if JValue.IsNull then
            exit(0);
        if JValue.IsUndefined then
            exit(0);
        exit(JValue.AsInteger());
    end;

    local procedure GetJsonValueAsText(JValue: JsonValue): Text
    begin
        if JValue.IsNull then
            exit('');
        if JValue.IsUndefined then
            exit('');
        exit(JValue.AsText());
    end;
    #endregion
}