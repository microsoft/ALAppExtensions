codeunit 9106 "SP File"
{
    Access = Internal;
    procedure Parse(Payload: Text; var SPFile: Record "SP File" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SPFile);
    end;

    procedure ParseSingle(Payload: Text; var SPFile: Record "SP File" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SPFile := ParseSingle(JObject);
    end;

    procedure Parse(Payload: JsonObject; var SPFile: Record "SP File" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SPFile := ParseSingle(JToken.AsObject());
                SPFile.Insert();
            end;
    end;

    local procedure ParseSingle(Payload: JsonObject) File: Record "SP File" temporary
    var
        JToken: JsonToken;
    begin
        File.Init();
        if Payload.Get('UniqueId', JToken) then
            File."Unique Id" := JToken.AsValue().AsText();

        if Payload.Get('Name', JToken) then
            File.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File.Name));

        if Payload.Get('Title', JToken) then
            if not JToken.AsValue().IsNull() then
                File.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File.Title));

        if Payload.Get('TimeCreated', JToken) then
            File.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Exists', JToken) then
            File.Exists := JToken.AsValue().AsBoolean();

        if Payload.Get('Length', JToken) then
            File."Length" := JToken.AsValue().AsInteger();

        if Payload.Get('ServerRelativeUrl', JToken) then
            File."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File."Server Relative Url"));

        if Payload.Get('odata.id', JToken) then
            File.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File.OdataId));

        if Payload.Get('odata.type', JToken) then
            File.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            File.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(File.OdataEditLink));
    end;
}