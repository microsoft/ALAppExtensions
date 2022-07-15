codeunit 9106 "SharePoint File"
{
    Access = Internal;
    procedure Parse(Payload: Text; var SharePointFile: Record "SharePoint File" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointFile);
    end;

    procedure ParseSingleReturnValue(Payload: Text; var SharePointFile: Record "SharePoint File" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(Payload) then
            if JObject.Get('d', JToken) then begin
                SharePointFile := ParseSingle(JToken.AsObject());
                SharePointFile.Insert();
            end;
    end;

    procedure ParseSingle(Payload: Text; var SharePointFile: Record "SharePoint File" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SharePointFile := ParseSingle(JObject);
    end;

    procedure Parse(Payload: JsonObject; var SharePointFile: Record "SharePoint File" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SharePointFile := ParseSingle(JToken.AsObject());
                SharePointFile.Insert();
            end;
    end;

    local procedure ParseSingle(Payload: JsonObject) SharePointFile: Record "SharePoint File" temporary
    var
        JToken: JsonToken;
    begin
        SharePointFile.Init();
        if Payload.Get('UniqueId', JToken) then
            SharePointFile."Unique Id" := JToken.AsValue().AsText();

        if Payload.Get('Name', JToken) then
            SharePointFile.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.Name));

        if Payload.Get('Title', JToken) then
            if not JToken.AsValue().IsNull() then
                SharePointFile.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.Title));

        if Payload.Get('TimeCreated', JToken) then
            SharePointFile.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Exists', JToken) then
            SharePointFile.Exists := JToken.AsValue().AsBoolean();

        if Payload.Get('Length', JToken) then
            SharePointFile."Length" := JToken.AsValue().AsInteger();

        if Payload.Get('ServerRelativeUrl', JToken) then
            SharePointFile."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile."Server Relative Url"));

        if Payload.Get('odata.id', JToken) then
            SharePointFile.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.OdataId));

        if Payload.Get('odata.type', JToken) then
            SharePointFile.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            SharePointFile.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.OdataEditLink));

        if Payload.Get('__metadata', JToken) then begin
            Payload := JToken.AsObject();

            if Payload.Get('id', JToken) then
                SharePointFile.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.OdataId));

            if Payload.Get('uri', JToken) then
                SharePointFile.OdataEditLink := CopyStr(JToken.AsValue().AsText(), JToken.AsValue().AsText().IndexOf('/_api/Web/') + 6, MaxStrLen(SharePointFile.OdataEditLink));

            if Payload.Get('type', JToken) then
                SharePointFile.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SharePointFile.OdataType));
        end;
    end;
}