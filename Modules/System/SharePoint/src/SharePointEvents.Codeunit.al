codeunit 9112 "SharePoint Events"
{
    [IntegrationEvent(false, false)]
    procedure ProcessSharePointFileMetadata(Metadata: JsonToken; SharePointFile: Record "SharePoint File" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure ProcessSharePointListItemMetadata(Metadata: JsonToken; SharePointListItem: Record "SharePoint List Item" temporary)
    begin
    end;
}