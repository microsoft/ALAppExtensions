codeunit 9104 "SharePoint List"
{
    Access = Internal;
    procedure Parse(Payload: Text; var SharePointList: Record "SharePoint List" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointList);
    end;

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

    local procedure ParseSingle(Payload: JsonObject) ListItem: Record "SharePoint List" temporary
    var
        JToken: JsonToken;
    begin
        ListItem.Init();
        if Payload.Get('Id', JToken) then
            ListItem.Id := JToken.AsValue().AsText();

        if Payload.Get('Title', JToken) then
            ListItem.Title := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.Title));

        if Payload.Get('Created', JToken) then
            ListItem.Created := JToken.AsValue().AsDateTime();

        if Payload.Get('Description', JToken) then
            ListItem.Description := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.Description));

        if Payload.Get('BaseTemplate', JToken) then
            ListItem."Base Template" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem."Base Template"));

        if Payload.Get('BaseType', JToken) then
            ListItem."Base Type" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem."Base Type"));

        if Payload.Get('IsCatalog', JToken) then
            ListItem."Is Catalog" := JToken.AsValue().AsBoolean();

        if Payload.Get('ListItemEntityTypeFullName', JToken) then
            if not JToken.AsValue().IsNull() then
                ListItem."List Item Entity Type" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem."List Item Entity Type"));

        if Payload.Get('odata.id', JToken) then
            ListItem.OdataId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.OdataId));

        if Payload.Get('odata.type', JToken) then
            ListItem.OdataType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.OdataType));

        if Payload.Get('odata.editLink', JToken) then
            ListItem.OdataEditLink := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ListItem.OdataEditLink));
    end;
}