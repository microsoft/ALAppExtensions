codeunit 9103 "SP List Item"
{
    Access = Internal;

    procedure Parse(Payload: Text; var ListItem: Record "SP List Item" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, ListItem);
    end;

    procedure Parse(Payload: JsonObject; var ListItem: Record "SP List Item" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                ListItem := ParseSingle(JToken.AsObject());
                ListItem.Insert();
            end;
    end;

    local procedure ParseSingle(Payload: JsonObject) ListItem: Record "SP List Item" temporary
    var
        JToken: JsonToken;
    begin
        ListItem.Init();
        if Payload.Get('GUID', JToken) then
            ListItem.Guid := JToken.AsValue().AsText();

        if Payload.Get('Id', JToken) then
            ListItem.Id := JToken.AsValue().AsInteger();

        if Payload.Get('Title', JToken) then
            if not JToken.AsValue().IsNull() then
                ListItem.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.Title));

        if Payload.Get('Created', JToken) then
            ListItem.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Attachments', JToken) then
            if not JToken.AsValue().IsNull() then
                ListItem.Attachments := JToken.AsValue().AsBoolean();


        if Payload.Get('ContentTypeId', JToken) then
            ListItem."Content Type Id" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.Title));

        if Payload.Get('FileSystemObjectType', JToken) then
            ListItem."File System Object Type" := JToken.AsValue().AsInteger();

    end;
}