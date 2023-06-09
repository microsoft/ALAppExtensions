codeunit 9112 "SharePoint Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    /// <summary>
    /// Process SharePointFile Metadata - Use to extract custom meta data into model record 
    /// </summary>
    /// <remarks>Extend the "SharePoint File" table to store any custom data.</remarks>
    /// <param name="Metadata">__metadata node of SharePointFile Json Object</param>
    /// <param name="SharePointFile">SharePointFile temporary record.</param>
    internal procedure ProcessSharePointFileMetadata(Metadata: JsonToken; var SharePointFile: Record "SharePoint File" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary>
    /// Process SharePointListItem Metadata - Use to extract custom mete data into model record 
    /// </summary>
    /// <remarks>Extend the "SharePoint List Item" table to store any custom data.</remarks>
    /// <param name="Metadata">__metadata node of SharePointListItem Json Object</param>
    /// <param name="SharePointListItem">SharePointListItem temporary record.</param>
    internal procedure ProcessSharePointListItemMetadata(Metadata: JsonToken; var SharePointListItem: Record "SharePoint List Item" temporary)
    begin
    end;
}