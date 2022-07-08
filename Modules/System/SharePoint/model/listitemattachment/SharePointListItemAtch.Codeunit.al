codeunit 9102 "SharePoint List Item Atch."
{
    Access = Internal;
    procedure Parse(Payload: Text; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            Parse(JObject, SharePointListItemAtch);
    end;

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

    procedure ParseSingle(Payload: Text; var SharePointListItemAtch: Record "SharePoint List Item Atch" temporary)
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(Payload) then
            SharePointListItemAtch := ParseSingle(JObject);
    end;

    local procedure ParseSingle(Payload: JsonObject) ListItemAttachment: Record "SharePoint List Item Atch" temporary
    var
        SharePointUriBuilder: Codeunit "SharePoint Uri Builder";
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

        if ListItemAttachment.OdataEditLink <> '' then begin
            SharePointUriBuilder.SetPath(ListItemAttachment.OdataEditLink);
            ListItemAttachment."List Id" := SharePointUriBuilder.GetMethodParameter('Lists').Substring(6, 36);
            Evaluate(ListItemAttachment."List Item Id", SharePointUriBuilder.GetMethodParameter('Items'));
        end;

    end;
}