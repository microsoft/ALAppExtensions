codeunit 9112 "Sharepoint Events"
{
    [IntegrationEvent(false, false)]
    procedure OnAfterApplySharepointFolderMetadata(JToken: JsonToken; var SharePointFolder: Record "SharePoint Folder" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterApplySharepointListMetadata(JToken: JsonToken; var SharePointList: Record "SharePoint List" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterApplySharepointListItemMetadata(JToken: JsonToken; var SharePointListItem: Record "SharePoint List Item" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterApplySharePointListItemAttachmentMetadata(JToken: JsonToken; var SharePointListItemAttachment: Record "SharePoint List Item Atch" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAddListItemMetaData(var Metadata: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAddListMetaData(var Metadata: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAddFolderMetaData(var Metadata: JsonObject)
    begin
    end;
}