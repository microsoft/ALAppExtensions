// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

codeunit 9103 "SharePoint List Item"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Parse(Payload: Text; var SharePointListItem: Record "SharePoint List Item" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointListItem);
    end;

    [NonDebuggable]
    procedure Parse(Payload: JsonObject; var SharePointListItem: Record "SharePoint List Item" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SharePointListItem := ParseSingle(JToken.AsObject());
                SharePointListItem.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingleReturnValue(Payload: Text; var SharePointListItem: Record "SharePoint List Item" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        //extract newly created list item data from the post response that created it.
        if JObject.ReadFrom(Payload) then
            if JObject.Get('d', JToken) then begin
                SharePointListItem := ParseSingle(JToken.AsObject());
                SharePointListItem.Insert();
            end;
    end;

    [NonDebuggable]
    local procedure ParseSingle(Payload: JsonObject) SharePointListItem: Record "SharePoint List Item" temporary
    var
        SharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        SharePointClient: Codeunit "SharePoint Client";
        JToken: JsonToken;
    begin
        SharePointListItem.Init();
        if Payload.Get('GUID', JToken) then
            SharePointListItem.Guid := JToken.AsValue().AsText();

        if Payload.Get('Id', JToken) then
            SharePointListItem.Id := JToken.AsValue().AsInteger();

        if Payload.Get('Title', JToken) then
            if not JToken.AsValue().IsNull() then
                SharePointListItem.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItem.Title));

        if Payload.Get('Created', JToken) then
            SharePointListItem.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Attachments', JToken) then
            if not JToken.AsValue().IsNull() then
                SharePointListItem.Attachments := JToken.AsValue().AsBoolean();

        if Payload.Get('ContentTypeId', JToken) then
            SharePointListItem."Content Type Id" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItem.Title));

        if Payload.Get('FileSystemObjectType', JToken) then
            SharePointListItem."File System Object Type" := JToken.AsValue().AsInteger();

        if Payload.Get('odata.editLink', JToken) then
            SharePointListItem.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItem.OdataEditLink));

        if Payload.Get('__metadata', JToken) then begin
            Payload := JToken.AsObject();

            if Payload.Get('uri', JToken) then
                SharePointListItem.OdataEditLink := CopyStr(JToken.AsValue().AsText(), JToken.AsValue().AsText().IndexOf('Web/Lists'), MaxStrLen(SharePointListItem.OdataEditLink));

            SharePointClient.ProcessSharePointListItemMetadata(JToken, SharePointListItem);
        end;

        if SharePointListItem.OdataEditLink <> '' then begin
            SharePointUriBuilder.SetPath(SharePointListItem.OdataEditLink);
            //guid'854d7f21-1c6a-43ab-a081-20404894b449' -> 854d7f21-1c6a-43ab-a081-20404894b449
            SharePointListItem."List Id" := SharePointUriBuilder.GetMethodParameter('Lists').Substring(6, 36);
        end;
    end;
}