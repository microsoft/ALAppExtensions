codeunit 9103 "SP List Item"
{
    Access = Internal;

    procedure Parse(Payload: Text; var SPListItem: Record "SP List Item" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SPListItem);
    end;

    procedure Parse(Payload: JsonObject; var SPListItem: Record "SP List Item" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SPListItem := ParseSingle(JToken.AsObject());
                SPListItem.Insert();
            end;
    end;

    local procedure ParseSingle(Payload: JsonObject) SPListItem: Record "SP List Item" temporary
    var
        JToken: JsonToken;
    begin
        SPListItem.Init();
        if Payload.Get('GUID', JToken) then
            SPListItem.Guid := JToken.AsValue().AsText();

        if Payload.Get('Id', JToken) then
            SPListItem.Id := JToken.AsValue().AsInteger();

        if Payload.Get('Title', JToken) then
            if not JToken.AsValue().IsNull() then
                SPListItem.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPListItem.Title));

        if Payload.Get('Created', JToken) then
            SPListItem.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Attachments', JToken) then
            if not JToken.AsValue().IsNull() then
                SPListItem.Attachments := JToken.AsValue().AsBoolean();


        if Payload.Get('ContentTypeId', JToken) then
            SPListItem."Content Type Id" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(SPListItem.Title));

        if Payload.Get('FileSystemObjectType', JToken) then
            SPListItem."File System Object Type" := JToken.AsValue().AsInteger();

    end;
}