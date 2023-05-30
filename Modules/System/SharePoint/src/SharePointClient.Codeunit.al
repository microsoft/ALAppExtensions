// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for interacting with SharePoint REST API
/// </summary>
codeunit 9100 "SharePoint Client"
{
    Access = Public;

    var
        SharePointClientImpl: Codeunit "SharePoint Client Impl.";

    /// <summary>
    /// Initializes SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Authorization: Interface "SharePoint Authorization")
    begin
        SharePointClientImpl.Initialize(BaseUrl, Authorization);
    end;

    /// <summary>
    /// Initializes SharePoint client.
    /// </summary>
    /// <param name="BaseUrl">SharePoint URL to use.</param>    
    /// <param name="Namespace">Namespace to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(BaseUrl: Text; Namespace: Text; Authorization: Interface "SharePoint Authorization")
    begin
        SharePointClientImpl.Initialize(BaseUrl, Namespace, Authorization);
    end;

    /// <summary>
    /// Returns detailed information on last API call.
    /// </summary>
    /// <returns>Codeunit holding http resonse status, reason phrase, headers and possible error information for tha last API call</returns>
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(SharePointClientImpl.GetDiagnostics());
    end;

    #region Lists

    /// <summary>
    /// Gets all lists on the given site.
    /// </summary>
    /// <param name="SharePointList">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetLists(var SharePointList: Record "SharePoint List"): Boolean
    begin
        exit(SharePointClientImpl.GetLists(SharePointList));
    end;

    /// <summary>
    /// Gets all list items for the given list.
    /// </summary>
    /// <param name="ListTitle">The title of the list/</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetListItems(ListTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    begin
        exit(SharePointClientImpl.GetListItems(ListTitle, SharePointListItem));
    end;

    /// <summary>
    /// Gets all list items for the given list.
    /// </summary>
    /// <param name="ListId">The GUID of the list/</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetListItems(ListId: Guid; var SharePointListItem: Record "SharePoint List Item"): Boolean
    begin
        exit(SharePointClientImpl.GetListItems(ListId, SharePointListItem));
    end;

    /// <summary>
    /// Gets all attachments for the given list item.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetListItemAttachments(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.GetListItemAttachments(ListTitle, ListItemId, SharePointListItemAtch));
    end;

    /// <summary>
    /// Gets all attachments for the given list item.
    /// </summary>
    /// <param name="ListId">The GUID of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetListItemAttachments(ListId: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.GetListItemAttachments(ListId, ListItemId, SharePointListItemAtch));
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <param name="ListTitle">The title of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadListItemAttachmentContent(ListTitle: Text; ListItemId: Integer; FileName: Text): Boolean
    begin
        exit(SharePointClientImpl.DownloadListItemAttachmentContent(ListTitle, ListItemId, FileName));
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <param name="ListId">The GUID of the list</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadListItemAttachmentContent(ListId: Guid; ListItemId: Integer; FileName: Text): Boolean
    begin
        exit(SharePointClientImpl.DownloadListItemAttachmentContent(ListId, ListItemId, FileName));
    end;

    /// <summary>
    /// Downloads the specified attachment file to the client.
    /// </summary>
    /// <remarks>The server side file name will be used.</remarks>
    /// <param name="OdataId">The odata.id parameter of the attachment entity.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadListItemAttachmentContent(OdataId: Text): Boolean
    begin
        exit(SharePointClientImpl.DownloadListItemAttachmentContent(OdataId));
    end;

    /// <summary>
    /// Creates the list item attachment for given item.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    /// 
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItemAttachment(ListTitle, ListItemId, SharePointListItemAtch));
    end;

    /// <summary>
    /// Creates the list item attachment for given item.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ListID">The GUID of the list.</param>
    /// <param name="ListItemId">Unique id of the item within the list. </param>
    /// <param name="SharePointListItemAtch">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateListItemAttachment(ListID: Guid; ListItemId: Integer; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItemAttachment(ListID, ListItemId, SharePointListItemAtch));
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
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateListItemAttachment(ListTitle: Text; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItemAttachment(ListTitle, ListItemId, FileName, FileInStream, SharePointListItemAtch));
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
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateListItemAttachment(ListID: Guid; ListItemId: Integer; FileName: Text; var FileInStream: InStream; var SharePointListItemAtch: Record "SharePoint List Item Atch"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItemAttachment(ListID, ListItemId, FileName, FileInStream, SharePointListItemAtch));
    end;

    /// <summary>
    /// Creates a new list.
    /// </summary>
    /// <param name="ListTitle">Title for the new list.</param>
    /// <param name="ListDescription">Description for the new list.</param>
    /// <param name="SharePointList">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateList(ListTitle: Text; ListDescription: Text; var SharePointList: Record "SharePoint List"): Boolean
    begin
        exit(SharePointClientImpl.CreateList(ListTitle, ListDescription, SharePointList));
    end;

    /// <summary>
    /// Creates a new list item in specific list.
    /// </summary>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="ListItemTitle">The title of the new list item.</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateListItem(ListTitle: Text; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItem(ListTitle, ListItemEntityTypeFullName, ListItemTitle, SharePointListItem));
    end;

    /// <summary>
    /// Creates a new list item in specific list.
    /// </summary>
    /// <param name="ListId">The GUID of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="ListItemTitle">The title of the new list item.</param>
    /// <param name="SharePointListItem">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateListItem(ListId: Guid; ListItemEntityTypeFullName: Text; ListItemTitle: Text; var SharePointListItem: Record "SharePoint List Item"): Boolean
    begin
        exit(SharePointClientImpl.CreateListItem(ListId, ListItemEntityTypeFullName, ListItemTitle, SharePointListItem));
    end;

    #endregion

    #region Folders

    /// <summary>
    /// Lists all subfolders in the given folder.
    /// </summary>
    /// <remarks>Only top level subfolders are included.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFolder">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetSubFoldersByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    begin
        exit(SharePointClientImpl.GetSubFoldersByServerRelativeUrl(ServerRelativeUrl, SharePointFolder));
    end;

    /// <summary>
    /// Lists all files in the given folder.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.GetFolderFilesByServerRelativeUrl(ServerRelativeUrl, SharePointFile));
    end;

    /// <summary>
    /// Downloads a file to an InStream.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <param name="FileInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContent(OdataId: Text; var FileInStream: InStream): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContent(OdataId, FileInStream));
    end;

    /// <summary>
    /// Downloads a file to the client.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContent(OdataId: Text; FileName: Text): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContent(OdataId, FileName));
    end;

    /// <summary>
    /// Gets root folder for the list entity (Document Library).
    /// </summary>    
    /// <remarks>See "Is Catalog" parameter of the list.</remarks>
    /// <param name="OdataId">The odata.id parameter of the list entity.</param>
    /// <param name="SharePointFolder">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetDocumentLibraryRootFolder(OdataID: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    begin
        exit(SharePointClientImpl.GetDocumentLibraryRootFolder(OdataID, SharePointFolder));
    end;

    /// <summary>
    /// Creates a new folder.
    /// </summary>
    /// <remarks>Create subfolders by manipulating URL.</remarks>
    /// <param name="ServerRelativeUrl">URL of the new folder.</param>
    /// <param name="SharePointFolder">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure CreateFolder(ServerRelativeUrl: Text; var SharePointFolder: Record "SharePoint Folder"): Boolean
    begin
        exit(SharePointClientImpl.CreateFolder(ServerRelativeUrl, SharePointFolder));
    end;

    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, SharePointFile));
    end;

    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; FileName: Text; var FileInStream: InStream; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, FileName, FileInStream, SharePointFile));
    end;

    #endregion
}