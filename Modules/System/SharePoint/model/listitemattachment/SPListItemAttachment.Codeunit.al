codeunit 9102 "SP List Item Attachment"
{
    Access = Internal;
    procedure Parse(Payload: Text; var SPListItemAttachment: Record "SP List Item Attachment" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SPListItemAttachment);
    end;

    procedure Parse(Payload: JsonObject; var SPListItemAttachment: Record "SP List Item Attachment" temporary)
    var
        JToken: JsonToken;
    begin
        if Payload.Get('value', JToken) then
            foreach JToken in JToken.AsArray() do begin
                SPListItemAttachment := ParseSingle(JToken.AsObject());
                SPListItemAttachment.Insert();
            end;
    end;

    procedure ParseSingle(Payload: Text; var SPListItemAttachment: Record "SP List Item Attachment" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SPListItemAttachment := ParseSingle(JObject);
    end;

    local procedure ParseSingle(Payload: JsonObject) ListItemAttachment: Record "SP List Item Attachment" temporary
    var
        JToken: JsonToken;
    begin
        ListItemAttachment.Init();
        if Payload.Get('odata.id', JToken) then
            ListItemAttachment.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItemAttachment.OdataId));

        if Payload.Get('odata.editLink', JToken) then
            ListItemAttachment.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItemAttachment.OdataEditLink));

        if Payload.Get('FileName', JToken) then
            ListItemAttachment."File Name" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItemAttachment."File Name"));

        if Payload.Get('ServerRelativeUrl', JToken) then
            ListItemAttachment."Server Relative Url" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItemAttachment."Server Relative Url"));

        if Payload.Get('odata.type', JToken) then
            ListItemAttachment.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItemAttachment.OdataType));

    end;
}