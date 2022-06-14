/// <summary>
/// Provides functionality for interacting with SharePoint REST API
/// </summary>
codeunit 9100 "SP Client"
{

    var
        SPClientImpl: Codeunit "SP Client Impl.";


    /// <summary>
    /// Initialize SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Authorization: Interface "SP IAuthorization")
    begin
        SPClientImpl.Initialize(BaseUrl, Authorization);
    end;

    /// <summary>
    /// Initialize SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>    
    /// <param name="Namespace">Namespace to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Namespace: Text; Authorization: Interface "SP IAuthorization")
    begin
        SPClientImpl.Initialize(BaseUrl, Namespace, Authorization);
    end;



    #region Lists


    /// <summary>
    /// Get all lists on the given site.
    /// </summary>
    /// <param name="SPList">Collection of the result (temporary record).</param>
    procedure GetLists(var SPList: Record "SP List")
    begin
        SPClientImpl.GetLists(SPList);
    end;

    /// <summary>
    /// Get all list items for the given list.
    /// </summary>
    /// <param name="ListTitle">The title of the list/</param>
    /// <param name="SPListItem">Collection of the result (temporary record).</param>
    procedure GetListItems(ListTitle: Text; var SPListItem: Record "SP List Item")
    begin
        SPClientImpl.GetListItems(ListTitle, SPListItem);
    end;


    /// <summary>
    /// Get all attachments for the given list item.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SPListItemAttachment">Collection of the result (temporary record).</param>
    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    begin
        SPClientImpl.GetListItemAttachments(ListTitle, ListItemId, SPListItemAttachment);
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    procedure GetListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text)
    begin
        SPClientImpl.GetListItemAttachmentContent(ListTitle, ListItemId, FileName);
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <remarks>The server side file name will be used.</remarks>
    /// <param name="OdataId">The odata.id parameter of the attachment entity.</param>
    procedure GetListItemAttachmentContent(OdataId: Text)
    begin
        SPClientImpl.GetListItemAttachmentContent(OdataId);
    end;

    /// <summary>
    /// Creates the list item attachment for given item.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SPListItemAttachment">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SPListItemAttachment: Record "SP List Item Attachment")
    begin
        SPClientImpl.CreateListItemAttachment(ListTitle, ListItemId, SPListItemAttachment);
    end;

    /// <summary>
    /// Creates a list item attachment for specific list item.
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>    
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SPListItemAttachment">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SPListItemAttachment: Record "SP List Item Attachment")
    begin
        SPClientImpl.CreateListItemAttachment(ListTitle, ListItemId, FileName, FileInStream, SPListItemAttachment);
    end;

    /// <summary>
    /// Creates a new list.
    /// </summary>
    /// <param name="ListTitle">Title for the new list.</param>
    /// <param name="ListDescription">Description for the new list.</param>
    procedure CreateList(ListTitle: Text; ListDescription: Text)
    begin
        SPClientImpl.CreateList(ListTitle, ListDescription);
    end;


    /// <summary>
    /// Creates a new list item in specific list.
    /// </summary>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="ListItemTitle">The title of the new list item.</param>
    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text)
    begin
        SPClientImpl.CreateListItem(ListTitle, ListItemEntityTypeFullName, ListItemTitle);
    end;
    #endregion

    #region Folders


    /// <summary>
    /// List all subfolders in the given folder.
    /// </summary>
    /// <remarks>Only top level subfolders are included.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SPFolder">Collection of the result (temporary record).</param>
    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SPFolder: Record "SP Folder")
    begin
        SPClientImpl.GetSubFoldersByServerRelativeUrl(ServerRelativeUrl, SPFolder);
    end;

    /// <summary>
    /// List all files in the given folder.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SPFile">Collection of the result (temporary record).</param>
    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SPFile: Record "SP File" temporary)
    begin
        SPClientImpl.GetFolderFilesByServerRelativeUrl(ServerRelativeUrl, SPFile);
    end;

    /// <summary>
    /// Download a file to the client.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    procedure GetFileContent(OdataId: Text; FileName: Text)
    begin
        SPClientImpl.GetFileContent(OdataId, FileName);
    end;

    /// <summary>
    /// Get root folder for the list entity (Document Library).
    /// </summary>    
    /// <remarks>See "Is Catalog" parameter of the list.</remarks>
    /// <param name="OdataId">The odata.id parameter of the list entity.</param>
    /// <param name="SPFolder">Collection of the result (temporary record). Always one element.</param>
    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SPFolder: Record "SP Folder")
    begin
        SPClientImpl.GetDocumentLibraryRootFolder(OdataID, SPFolder);
    end;

    /// <summary>
    /// Create a new folder.
    /// </summary>
    /// <remarks>Create subfolders by manipulating URL.</remarks>
    /// <param name="ServerRelativeUrl">URL of the new folder.</param>
    procedure CreateFolder(ServerRelativeUrl: Text)
    begin
        SPClientImpl.CreateFolder(ServerRelativeUrl);
    end;

    /// <summary>
    /// Add a file to specific folder.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    procedure AddFileToFolder(ServerRelativeUrl: Text)
    begin
        SPClientImpl.AddFileToFolder(ServerRelativeUrl);
    end;

    #endregion

}