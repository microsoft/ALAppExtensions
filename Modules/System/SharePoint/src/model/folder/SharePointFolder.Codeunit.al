// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

codeunit 9105 "SharePoint Folder"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Parse(Payload: Text; var SharePointFolder: Record "SharePoint Folder" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointFolder);
    end;

    [NonDebuggable]
    procedure Parse(Payload: JsonObject; var SharePointFolder: Record "SharePoint Folder" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SharePointFolder := ParseSingle(JToken.AsObject());
                SharePointFolder.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingleReturnValue(Payload: Text; var SharePointFolder: Record "SharePoint Folder" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        //extract newly created folder data from the post response that created it.
        if JObject.ReadFrom(Payload) then
            if JObject.Get('d', JToken) then begin
                SharePointFolder := ParseSingle(JToken.AsObject());
                SharePointFolder.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingle(Payload: Text; var SharePointFolder: Record "SharePoint Folder" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then begin
            SharePointFolder := ParseSingle(JObject);
            SharePointFolder.Insert();
        end;
    end;

    [NonDebuggable]
    local procedure ParseSingle(Payload: JsonObject) SharePointFolder: Record "SharePoint Folder" temporary
    var
        JToken: JsonToken;
    begin
        SharePointFolder.Init();
        if Payload.Get('UniqueId', JToken) then
            SharePointFolder."Unique Id" := JToken.AsValue().AsText();

        if Payload.Get('Name', JToken) then
            SharePointFolder.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.Name));

        if Payload.Get('TimeCreated', JToken) then
            SharePointFolder.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Exists', JToken) then
            SharePointFolder.Exists := JToken.AsValue().AsBoolean();

        if Payload.Get('ItemCount', JToken) then
            SharePointFolder."Item Count" := JToken.AsValue().AsInteger();

        if Payload.Get('ServerRelativeUrl', JToken) then
            SharePointFolder."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder."Server Relative Url"));

        if Payload.Get('odata.id', JToken) then
            SharePointFolder.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.OdataId));

        if Payload.Get('odata.type', JToken) then
            SharePointFolder.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            SharePointFolder.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.OdataEditLink));

        if Payload.Get('__metadata', JToken) then begin
            Payload := JToken.AsObject();

            if Payload.Get('id', JToken) then
                SharePointFolder.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.OdataId));

            if Payload.Get('uri', JToken) then
                SharePointFolder.OdataEditLink := CopyStr(JToken.AsValue().AsText(), JToken.AsValue().AsText().IndexOf('/_api/Web/') + 6, MaxStrLen(SharePointFolder.OdataEditLink));

            if Payload.Get('type', JToken) then
                SharePointFolder.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFolder.OdataType));
        end;
    end;
}