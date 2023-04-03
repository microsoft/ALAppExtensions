// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9102 "SharePoint List Item Atch."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Parse(Payload: Text; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointListItemAtch);
    end;

    [NonDebuggable]
    procedure Parse(Payload: JsonObject; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SharePointListItemAtch := ParseSingle(JToken.AsObject());
                SharePointListItemAtch.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingleReturnValue(Payload: Text; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        //extract newly created attachment data from the post response that created it.
        if JObject.ReadFrom(Payload) then
            if JObject.Get('d', JToken) then begin
                SharePointListItemAtch := ParseSingle(JToken.AsObject());
                SharePointListItemAtch.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingle(Payload: Text; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SharePointListItemAtch := ParseSingle(JObject);
    end;

    [NonDebuggable]
    local procedure ParseSingle(Payload: JsonObject) SharePointListItemAttachment: Record "SharePoint List Item Atch" temporary
    var
        SharePointUriBuilder: Codeunit "SharePoint Uri Builder";
        JToken: JsonToken;
    begin
        SharePointListItemAttachment.Init();

        if Payload.Get('odata.id', JToken) then
            SharePointListItemAttachment.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment.OdataId));

        if Payload.Get('odata.editLink', JToken) then
            SharePointListItemAttachment.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment.OdataEditLink));

        if Payload.Get('FileName', JToken) then
            SharePointListItemAttachment."File Name" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment."File Name"));

        if Payload.Get('ServerRelativeUrl', JToken) then
            SharePointListItemAttachment."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment."Server Relative Url"));

        if Payload.Get('odata.type', JToken) then
            SharePointListItemAttachment.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment.OdataType));

        if Payload.Get('__metadata', JToken) then begin
            Payload := JToken.AsObject();

            if Payload.Get('id', JToken) then
                SharePointListItemAttachment.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment.OdataId));

            if Payload.Get('uri', JToken) then
                SharePointListItemAttachment.OdataEditLink := CopyStr(JToken.AsValue().AsText(), JToken.AsValue().AsText().IndexOf('Web/Lists'), MaxStrLen(SharePointListItemAttachment.OdataEditLink));

            if Payload.Get('type', JToken) then
                SharePointListItemAttachment.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointListItemAttachment.OdataType));
        end;

        if SharePointListItemAttachment.OdataEditLink <> '' then begin
            SharePointUriBuilder.SetPath(SharePointListItemAttachment.OdataEditLink);
            //guid'854d7f21-1c6a-43ab-a081-20404894b449' -> 854d7f21-1c6a-43ab-a081-20404894b449
            SharePointListItemAttachment."List Id" := SharePointUriBuilder.GetMethodParameter('Lists').Substring(6, 36);
            Evaluate(SharePointListItemAttachment."List Item Id", SharePointUriBuilder.GetMethodParameter('Items'));
        end;
    end;
}