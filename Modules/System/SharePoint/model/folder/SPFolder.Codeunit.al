codeunit 9105 "SP Folder"
{
    Access = Internal;
    procedure Parse(Payload: Text; var SPFolder: Record "SP Folder" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SPFolder);
    end;

    procedure Parse(Payload: JsonObject; var SPFolder: Record "SP Folder" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SPFolder := ParseSingle(JToken.AsObject());
                SPFolder.Insert();
            end;
    end;

    procedure ParseSingle(Payload: Text; var SPFolder: Record "SP Folder" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SPFolder := ParseSingle(JObject);
    end;

    local procedure ParseSingle(Payload: JsonObject) SPFolder: Record "SP Folder" temporary
    var
        JToken: JsonToken;
    begin
        SPFolder.Init();
        if Payload.Get('UniqueId', JToken) then
            SPFolder."Unique Id" := JToken.AsValue().AsText();

        if Payload.Get('Name', JToken) then
            SPFolder.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPFolder.Name));

        if Payload.Get('TimeCreated', JToken) then
            SPFolder.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Exists', JToken) then
            SPFolder.Exists := JToken.AsValue().AsBoolean();

        if Payload.Get('ItemCount', JToken) then
            SPFolder."Item Count" := JToken.AsValue().AsInteger();

        if Payload.Get('ServerRelativeUrl', JToken) then
            SPFolder."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPFolder."Server Relative Url"));

        if Payload.Get('odata.id', JToken) then
            SPFolder.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPFolder.OdataId));

        if Payload.Get('odata.type', JToken) then
            SPFolder.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPFolder.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            SPFolder.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPFolder.OdataEditLink));
    end;
}