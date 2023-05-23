// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9104 "SharePoint List"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Parse(Payload: Text; var SharePointList: Record "SharePoint List" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointList);
    end;

    [NonDebuggable]
    procedure Parse(Payload: JsonObject; var SharePointList: Record "SharePoint List" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SharePointList := ParseSingle(JToken.AsObject());
                SharePointList.Insert();
            end;
    end;

    [NonDebuggable]
    procedure ParseSingleReturnValue(Payload: Text; var SharePointList: Record "SharePoint List" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        //extract newly created list data from the post response that created it.
        if JObject.ReadFrom(Payload) then
            if JObject.Get('d', JToken) then begin
                SharePointList := ParseSingle(JToken.AsObject());
                SharePointList.Insert();
            end;
    end;

    [NonDebuggable]
    local procedure ParseSingle(Payload: JsonObject) SharePointList: Record "SharePoint List" temporary
    var
        JToken: JsonToken;
    begin
        SharePointList.Init();
        if Payload.Get('Id', JToken) then
            SharePointList.Id := JToken.AsValue().AsText();

        if Payload.Get('Title', JToken) then
            SharePointList.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.Title));

        if Payload.Get('Created', JToken) then
            SharePointList.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Description', JToken) then
            SharePointList.Description := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.Description));

        if Payload.Get('BaseTemplate', JToken) then
            SharePointList."Base Template" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList."Base Template"));

        if Payload.Get('BaseType', JToken) then
            SharePointList."Base Type" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList."Base Type"));

        if Payload.Get('IsCatalog', JToken) then
            SharePointList."Is Catalog" := JToken.AsValue().AsBoolean();

        if Payload.Get('ListItemEntityTypeFullName', JToken) then
            if not JToken.AsValue().IsNull() then
                SharePointList."List Item Entity Type" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList."List Item Entity Type"));

        if Payload.Get('odata.id', JToken) then
            SharePointList.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.OdataId));

        if Payload.Get('odata.type', JToken) then
            SharePointList.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            SharePointList.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.OdataEditLink));

        if Payload.Get('__metadata', JToken) then begin
            Payload := JToken.AsObject();

            if Payload.Get('id', JToken) then
                SharePointList.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.OdataId));

            if Payload.Get('uri', JToken) then
                SharePointList.OdataEditLink := CopyStr(JToken.AsValue().AsText(), JToken.AsValue().AsText().IndexOf('Web/Lists'), MaxStrLen(SharePointList.OdataEditLink));

            if Payload.Get('type', JToken) then
                SharePointList.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointList.OdataType));
        end;
    end;
}