/// <summary>
/// Provides functionality for interacting with SharePoint REST API
/// </summary>
codeunit 9100 "SharePoint Client"
{
    Access = Public;

    var
        SharePointClientImpl: Codeunit "SharePoint Client Impl.";

    /// <summary>
    /// Initialize SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Authorization: Interface "SharePoint Authorization")
    begin
        SharePointClientImpl.Initialize(BaseUrl, Authorization);
    end;

    /// <summary>
    /// Initialize SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>    
    /// <param name="Namespace">Namespace to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Namespace: Text; Authorization: Interface "SharePoint Authorization")
    begin
        SharePointClientImpl.Initialize(BaseUrl, Namespace, Authorization);
    end;

    #region Lists

    /// <summary>
    /// Get all lists on the given site.
    /// </summary>
    /// <param name="SharePointList">Collection of the result (temporary record).</param>
    procedure GetLists(var SharePointList: Record "SharePoint List")
    begin
        SharePointClientImpl.GetLists(SharePointList);
    end;

    /// <summary>
    /// Get all list items for the given list.
    /// </summary>
    /// <param name="ListTitle">The title of the list/</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    procedure GetListItems(ListTitle: Text; var SharePointListItem: Record "SharePoint List Item")
    begin
        SharePointClientImpl.GetListItems(ListTitle, SharePointListItem);
    end;

    /// <summary>
    /// Get all list items for the given list.
    /// </summary>
    /// <param name="ListId">The GUID of the list/</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    procedure GetListItems(ListId: Guid; var SharePointListItem: Record "SharePoint List Item")
    begin
        SharePointClientImpl.GetListItems(ListId, SharePointListItem);
    end;

    /// <summary>
    /// Get all attachments for the given list item.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record).</param>
    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.GetListItemAttachments(ListTitle, ListItemId, SharePointListItemAtch);
    end;

    /// <summary>
    /// Get all attachments for the given list item.
    /// </summary>
    /// <param name="ListId">The GUID of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record).</param>
    procedure GetListItemAttachments(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.GetListItemAttachments(ListId, ListItemId, SharePointListItemAtch);
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    procedure DownloadListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text)
    begin
        SharePointClientImpl.DownloadListItemAttachmentContent(ListTitle, ListItemId, FileName);
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <param name="ListId">The GUID of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    procedure DownloadListItemAttachmentContent(ListId: Guid; ListItemId: Integer; FileName: Text)
    begin
        SharePointClientImpl.DownloadListItemAttachmentContent(ListId, ListItemId, FileName);
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <remarks>The server side file name will be used.</remarks>
    /// <param name="OdataId">The odata.id parameter of the attachment entity.</param>
    procedure DownloadListItemAttachmentContent(OdataId: Text)
    begin
        SharePointClientImpl.DownloadListItemAttachmentContent(OdataId);
    end;

    /// <summary>
    /// Creates the list item attachment for given item.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.CreateListItemAttachment(ListTitle, ListItemId, SharePointListItemAtch);
    end;

    /// <summary>
    /// Creates the list item attachment for given item.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ListID">The GUID of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListID: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.CreateListItemAttachment(ListID, ListItemId, SharePointListItemAtch);
    end;

    /// <summary>
    /// Creates a list item attachment for specific list item.
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>    
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.CreateListItemAttachment(ListTitle, ListItemId, FileName, FileInStream, SharePointListItemAtch);
    end;

    /// <summary>
    /// Creates a list item attachment for specific list item.
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ListID">The GUID of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>    
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    procedure CreateListItemAttachment(ListID: Guid; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch")
    begin
        SharePointClientImpl.CreateListItemAttachment(ListID, ListItemId, FileName, FileInStream, SharePointListItemAtch);
    end;

    /// <summary>
    /// Creates a new list.
    /// </summary>
    /// <param name="ListTitle">Title for the new list.</param>
    /// <param name="ListDescription">Description for the new list.</param>
    procedure CreateList(ListTitle: Text; ListDescription: Text)
    begin
        SharePointClientImpl.CreateList(ListTitle, ListDescription);
    end;

    /// <summary>
    /// Creates a new list item in specific list.
    /// </summary>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="ListItemTitle">The title of the new list item.</param>
    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text)
    begin
        SharePointClientImpl.CreateListItem(ListTitle, ListItemEntityTypeFullName, ListItemTitle);
    end;

    /// <summary>
    /// Creates a new list item in specific list.
    /// </summary>
    /// <param name="ListId">The GUID of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="ListItemTitle">The title of the new list item.</param>
    procedure CreateListItem(ListId: Guid; ListItemEntityTypeFullName: Text; ListItemTitle: Text)
    begin
        SharePointClientImpl.CreateListItem(ListId, ListItemEntityTypeFullName, ListItemTitle);
    end;

    #endregion

    #region Folders

    /// <summary>
    /// List all subfolders in the given folder.
    /// </summary>
    /// <remarks>Only top level subfolders are included.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFolder">Collection of the result (temporary record).</param>
    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder")
    begin
        SharePointClientImpl.GetSubFoldersByServerRelativeUrl(ServerRelativeUrl, SharePointFolder);
    end;

    /// <summary>
    /// List all files in the given folder.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record).</param>
    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary)
    begin
        SharePointClientImpl.GetFolderFilesByServerRelativeUrl(ServerRelativeUrl, SharePointFile);
    end;

    /// <summary>
    /// Download a file to the client.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    procedure DownloadFileContent(OdataId: Text; FileName: Text)
    begin
        SharePointClientImpl.DownloadFileContent(OdataId, FileName);
    end;

    /// <summary>
    /// Get root folder for the list entity (Document Library).
    /// </summary>    
    /// <remarks>See "Is Catalog" parameter of the list.</remarks>
    /// <param name="OdataId">The odata.id parameter of the list entity.</param>
    /// <param name="SharePointFolder">Collection of the result (temporary record). Always one element.</param>
    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SharePointFolder: Record "SharePoint Folder")
    begin
        SharePointClientImpl.GetDocumentLibraryRootFolder(OdataID, SharePointFolder);
    end;

    /// <summary>
    /// Create a new folder.
    /// </summary>
    /// <remarks>Create subfolders by manipulating URL.</remarks>
    /// <param name="ServerRelativeUrl">URL of the new folder.</param>
    procedure CreateFolder(ServerRelativeUrl: Text)
    begin
        SharePointClientImpl.CreateFolder(ServerRelativeUrl);
    end;

    /// <summary>
    /// Add a file to specific folder.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    procedure AddFileToFolder(ServerRelativeUrl: Text)
    begin
        SharePointClientImpl.AddFileToFolder(ServerRelativeUrl);
    end;

    #endregion

}