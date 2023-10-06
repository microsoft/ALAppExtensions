// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

using System.Utilities;

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
    /// <raises>ProcessSharePointListItemMetadata</raises>    
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
    /// <raises>ProcessSharePointListItemMetadata</raises>    
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
    /// <raises>ProcessSharePointListItemMetadata</raises>    
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
    /// <raises>ProcessSharePointListItemMetadata</raises>    
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
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record).</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.GetFolderFilesByServerRelativeUrl(ServerRelativeUrl, SharePointFile, false));
    end;

    /// <summary>
    /// Lists all files in the given folder.
    /// </summary>
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record).</param>
    /// <param name="ListAllFields">Include metadata in results.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure GetFolderFilesByServerRelativeUrl(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    begin
        exit(SharePointClientImpl.GetFolderFilesByServerRelativeUrl(ServerRelativeUrl, SharePointFile, ListAllFields));
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
    /// Downloads a file to a TempBlob.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <param name="TempBlob">The TempBlob that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContent(OdataId: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContent(OdataId, TempBlob));
    end;

    /// <summary>
    /// Downloads a file to an InStream.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the file to Download.</param>
    /// <param name="FileInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; var FileInStream: InStream): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContentByServerRelativeUrl(ServerRelativeUrl, FileInStream));
    end;

    /// <summary>
    /// Downloads a file to the client.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the file to Download.</param>
    /// <param name="FileName">Name to be given to the file on the client side. Does not need to match the server side name.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; FileName: Text): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContentByServerRelativeUrl(ServerRelativeUrl, FileName));
    end;

    /// <summary>
    /// Downloads a file to a TempBlob.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the file to Download.</param>
    /// <param name="TempBlob">The TempBlob that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DownloadFileContentByServerRelativeUrl(ServerRelativeUrl: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        exit(SharePointClientImpl.DownloadFileContentByServerRelativeUrl(ServerRelativeUrl, TempBlob));
    end;

    /// <summary>
    /// Deletes a file.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the file entity.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DeleteFile(OdataId: Text): Boolean
    begin
        exit(SharePointClientImpl.DeleteFile(OdataId));
    end;

    /// <summary>
    /// Deletes a file.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the file to delete.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DeleteFileByServerRelativeUrl(ServerRelativeUrl: Text): Boolean
    begin
        exit(SharePointClientImpl.DeleteFileByServerRelativeUrl(ServerRelativeUrl));
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
    /// Deletes a folder.
    /// </summary>
    /// <param name="OdataId">The odata.id parameter of the folder entity.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DeleteFolder(OdataId: Text): Boolean
    begin
        exit(SharePointClientImpl.DeleteFolder(OdataId));
    end;

    /// <summary>
    /// Deletes a folder.
    /// </summary>
    /// <param name="ServerRelativeUrl">URL of the folder to delete.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure DeleteFolderByServerRelativeUrl(ServerRelativeUrl: Text): Boolean
    begin
        exit(SharePointClientImpl.DeleteFolderByServerRelativeUrl(ServerRelativeUrl));
    end;
    
    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, SharePointFile, false));
    end;

    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <remarks>Requires UI interaction to pick a file.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <param name="ListAllFields">Include metadata in results.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, SharePointFile, ListAllFields));
    end;

    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; FileName: Text; var FileInStream: InStream; var SharePointFile: Record "SharePoint File" temporary): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, FileName, FileInStream, SharePointFile, false));
    end;

    /// <summary>
    /// Adds a file to specific folder.
    /// </summary>
    /// <raises>ProcessSharePointFileMetadata</raises>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="ServerRelativeUrl">URL of the parent folder.</param>
    /// <param name="FileName">File name to use on SharePoint.</param>
    /// <param name="FileInStream">File stream to upload.</param>
    /// <param name="SharePointFile">Collection of the result (temporary record). Always one element.</param>
    /// <param name="ListAllFields">Include metadata in results.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure AddFileToFolder(ServerRelativeUrl: Text; FileName: Text; var FileInStream: InStream; var SharePointFile: Record "SharePoint File" temporary; ListAllFields: Boolean): Boolean
    begin
        exit(SharePointClientImpl.AddFileToFolder(ServerRelativeUrl, FileName, FileInStream, SharePointFile, ListAllFields));
    end;

    /// <summary>
    /// Updates metadata field for list item.
    /// </summary>
    /// <param name="ListTitle">The title of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="FieldName">The name of the metadata field.</param>
    /// <param name="FieldValue">Value.</param>    
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure UpdateListItemMetaDataField(ListTitle: Text; ItemId: Integer; ListItemEntityTypeFullName: Text; FieldName: Text; FieldValue: Text): Boolean
    begin
        exit(SharePointClientImpl.UpdateListItemMetaDataField(ListTitle, ItemId, ListItemEntityTypeFullName, FieldName, FieldValue));
    end;

    /// <summary>
    /// Updates metadata field for list item.
    /// </summary>
    /// <param name="ListTitle">The GUID of the list.</param>
    /// <param name="ListItemEntityTypeFullName">The Entity Type for the list. Parameter can be found on a list object (ListItemEntityType).</param>
    /// <param name="FieldName">The name of the metadata field.</param>
    /// <param name="FieldValue">Value.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure UpdateListItemMetaDataField(ListId: Guid; ItemId: Integer; ListItemEntityTypeFullName: Text; FieldName: Text; FieldValue: Text): Boolean
    begin
        exit(SharePointClientImpl.UpdateListItemMetaDataField(ListId, ItemId, ListItemEntityTypeFullName, FieldName, FieldValue));
    end;
    
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

    #endregion
}