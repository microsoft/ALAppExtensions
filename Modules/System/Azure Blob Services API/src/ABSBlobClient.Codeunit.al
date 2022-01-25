// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for using operations on blobs in Azure Blob storage.
/// </summary>
codeunit 9053 "ABS Blob Client"
{
    Access = Public;

    /// <summary>
    /// Initializes the Azure Blob storage client.
    /// </summary>
    /// <param name="StorageAccount">The name of Storage Account to use.</param>
    /// <param name="Container">The name of the container to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    [NonDebuggable]
    procedure Initialize(StorageAccount: Text; Container: Text; Authorization: Interface "Storage Service Authorization")
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        BlobServicesApiImpl.Initialize(StorageAccount, Container, '', Authorization, StorageServiceAuthorization.GetDefaultAPIVersion());
    end;

    /// <summary>
    /// Initializes the Azure BLOB Storage BLOB client.
    /// </summary>
    /// <param name="StorageAccount">The name of Storage Account to use.</param>
    /// <param name="Container">The name of the container to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    /// <param name="APIVersion">The used API version to use.</param>
    [NonDebuggable]
    procedure Initialize(StorageAccount: Text; Container: Text; Authorization: Interface "Storage Service Authorization"; APIVersion: Enum "Storage Service API Version")
    begin
        BlobServicesApiImpl.Initialize(StorageAccount, Container, '', Authorization, APIVersion);
    end;

    /// <summary>
    /// The base URL to use when constructing the final URI.
    /// If not set, the base URL is https://%1.blob.core.windows.net where %1 is the storage account name. 
    /// </summary>
    /// <remarks>Use %1 as a placeholder for the storage account name.</remarks>
    /// <param name="BaseUrl">A valid URL string</param>
    procedure SetBaseUrl(BaseUrl: Text)
    begin
        BlobServicesApiImpl.SetBaseUrl(BaseUrl);
    end;

    /// <summary>
    /// Lists the blobs in a specific container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>    
    /// <param name="ContainerContent">Collection of the result (temporary record).</param>
    /// <returns>An operation reponse object</returns>
    procedure ListBlobs(var ContainerContent: Record "ABS Container Content"): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ListBlobs(ContainerContent, OptionalParameters));
    end;

    /// <summary>
    /// Lists the blobs in a specific container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>    
    /// <param name="ContainerContent">Collection of the result (temporary record).</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ListBlobs(var ContainerContent: Record "ABS Container Content"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ListBlobs(ContainerContent, OptionalParameters));
    end;

    /// <summary>
    /// Uploads a file as a BlockBlob (with File Selection Dialog).
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobUI(): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobUI(OptionalParameters));
    end;

    /// <summary>
    /// Uploads a file as a BlockBlob (with File Selection Dialog).
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobUI(OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobUI(OptionalParameters));
    end;

    /// <summary>
    /// Uploads the content of an InStream as a BlockBlob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceStream">The Content of the Blob as InStream.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobStream(BlobName: Text; var SourceStream: InStream): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobStream(BlobName, SourceStream, OptionalParameters));
    end;

    /// <summary>
    /// Uploads the content of an InStream as a BlockBlob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceStream">The Content of the Blob as InStream.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobStream(BlobName: Text; var SourceStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobStream(BlobName, SourceStream, OptionalParameters));
    end;

    /// <summary>
    /// Uploads text as a BlockBlob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceText">The Content of the Blob as Text.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobText(BlobName, SourceText, OptionalParameters));
    end;

    /// <summary>
    /// Uploads text as a BlockBlob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceText">The Content of the Blob as Text.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlobBlockBlobText(BlobName, SourceText, OptionalParameters));
    end;

    /// <summary>
    /// Creates a PageBlob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobPageBlob(BlobName: Text; ContentType: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.PutBlobPageBlob(BlobName, ContentType, OptionalParameters));
    end;

    /// <summary>
    /// Creates a PageBlob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobPageBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlobPageBlob(BlobName, ContentType, OptionalParameters));
    end;

    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobAppendBlobStream(BlobName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(PutBlobAppendBlob(BlobName, 'application/octet-stream', OptionalParameters));
    end;

    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobAppendBlobStream(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(PutBlobAppendBlob(BlobName, 'application/octet-stream', OptionalParameters));
    end;

    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// Uses 'text/plain; charset=UTF-8' as Content-Type
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobAppendBlobText(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(PutBlobAppendBlob(BlobName, 'text/plain; charset=UTF-8', OptionalParameters));
    end;
    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlobAppendBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlobAppendBlob(BlobName, ContentType, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'text/plain; charset=UTF-8' as Content-Type
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockText(BlobName: Text; ContentAsText: Text): Codeunit "ABS Operation Response"
    begin
        exit(AppendBlockText(BlobName, ContentAsText, 'text/plain; charset=UTF-8'));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(AppendBlock(BlobName, ContentType, ContentAsText, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(AppendBlock(BlobName, ContentType, ContentAsText, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(AppendBlockStream(BlobName, ContentAsStream, 'application/octet-stream', OptionalParameters));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(AppendBlock(BlobName, ContentType, ContentAsStream, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the Blob</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlock(BlobName: Text; ContentType: Text; SourceContent: Variant; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.AppendBlock(BlobName, ContentType, SourceContent, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block From URL operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block-from-url
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceUri">Specifies the name of the source blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.AppendBlockFromURL(BlobName, SourceUri, OptionalParameters));
    end;

    /// <summary>
    /// The Append Block From URL operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block-from-url
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceUri">Specifies the name of the source blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.AppendBlockFromURL(BlobName, SourceUri, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as a File from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsFile(BlobName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.GetBlobAsFile(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as a File from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsFile(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.GetBlobAsFile(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as a InStream from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="TargetStream">The result InStream containg the content of the Blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsStream(BlobName: Text; var TargetStream: InStream): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.GetBlobAsStream(BlobName, TargetStream, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as a InStream from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="TargetStream">The result InStream containg the content of the Blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsStream(BlobName: Text; var TargetStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.GetBlobAsStream(BlobName, TargetStream, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as Text from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="TargetText">The result Text containg the content of the Blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsText(BlobName: Text; var TargetText: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.GetBlobAsText(BlobName, TargetText, OptionalParameters));
    end;

    /// <summary>
    /// Receives a Blob as Text from a Container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="TargetText">The result Text containg the content of the Blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure GetBlobAsText(BlobName: Text; var TargetText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.GetBlobAsText(BlobName, TargetText, OptionalParameters));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry time relative to the file creation time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from creation time.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>    
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    /// <returns>An operation reponse object</returns>
    procedure SetBlobExpiryRelativeToCreation(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.SetBlobExpiryRelativeToCreation(BlobName, ExpiryTime));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry relative to the current time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from now.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>    
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    /// <returns>An operation reponse object</returns>
    procedure SetBlobExpiryRelativeToNow(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.SetBlobExpiryRelativeToNow(BlobName, ExpiryTime));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry to an absolute DateTime
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>    
    /// <param name="ExpiryTime">Absolute DateTime for the expiration.</param>
    /// <returns>An operation reponse object</returns>
    procedure SetBlobExpiryAbsolute(BlobName: Text; ExpiryTime: DateTime): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.SetBlobExpiryAbsolute(BlobName, ExpiryTime));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the file to never expire or removes the current expiry time, x-ms-expiry-time must not to be specified.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>    
    procedure SetBlobExpiryNever(BlobName: Text): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.SetBlobExpiryNever(BlobName));
    end;

    /// <summary>
    /// The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
    /// </summary> 
    /// <param name="BlobName">The name of the blob.</param>   
    /// <param name="Tags">A Dictionary of [Text, Text] which contains the Tags you want to set.</param>    
    /// <returns>An operation reponse object</returns>
    procedure SetBlobTags(BlobName: Text; Tags: Dictionary of [Text, Text]): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.SetBlobTags(BlobName, Tags));
    end;

    /// <summary>
    /// The Delete Blob operation marks the specified blob or snapshot for deletion. The blob is later deleted during garbage collection.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure DeleteBlob(BlobName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.DeleteBlob(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// The Delete Blob operation marks the specified blob or snapshot for deletion. The blob is later deleted during garbage collection.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure DeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.DeleteBlob(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <returns>An operation reponse object</returns>
    procedure UndeleteBlob(BlobName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.UndeleteBlob(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure UndeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.UndeleteBlob(BlobName, OptionalParameters));
    end;

    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    /// <returns>An operation reponse object</returns>
    procedure CopyBlob(BlobName: Text; SourceName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
        LeaseId: Guid;
    begin
        exit(CopyBlob(BlobName, SourceName, LeaseId, OptionalParameters));
    end;

    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    /// <param name="LeaseId">Required if the destination blob has an active lease. The lease ID specified must match the lease ID of the destination blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure CopyBlob(BlobName: Text; SourceName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.CopyBlob(BlobName, SourceName, LeaseId, OptionalParameters));
    end;

    /// <summary>
    /// The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
    /// </summary>
    /// <param name="CommitedBlocks">Dictionary of [Text, Integer] containing the list of commited blocks that should be put to the Blob</param>
    /// <param name="UncommitedBlocks">Dictionary of [Text, Integer] containing the list of uncommited blocks that should be put to the Blob</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlockList(CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlockList(CommitedBlocks, UncommitedBlocks));
    end;

    /// <summary>
    /// The Put Block From URL operation creates a new block to be committed as part of a blob where the contents are read from a URL.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-from-url
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceUri">Specifies the name of the source block blob.</param>
    /// <param name="BlockId">Specifies the BlockId that should be put.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.PutBlockFromURL(BlobName, SourceUri, BlockId, OptionalParameters));
    end;

    /// <summary>
    /// The Put Block From URL operation creates a new block to be committed as part of a blob where the contents are read from a URL.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-from-url
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="SourceUri">Specifies the name of the source block blob.</param>
    /// <param name="BlockId">Specifies the BlockId that should be put.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.PutBlockFromURL(BlobName, SourceUri, BlockId, OptionalParameters));
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>    
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; DurationSeconds: Integer; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId)); // Custom duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>    
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; DurationSeconds: Integer; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId)); // Custom duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Requests a new lease. If the blob does not have an active lease, the Blob service creates a lease on the blob. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>  
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(BlobName: Text; DurationSeconds: Integer; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobAcquireLease(BlobName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId));
    end;

    /// <summary>
    /// Releases a lease on a Blob if it is no longer needed so that another client may immediately acquire a lease against the blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(BlobName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobReleaseLease(BlobName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Releases a lease on a Blob if it is no longer needed so that another client may immediately acquire a lease against the blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(BlobName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobReleaseLease(BlobName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Renews a lease on a Blob to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    /// <returns>An operation reponse object</returns>
    procedure RenewLease(BlobName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobRenewLease(BlobName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Renews a lease on a Blob to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure RenewLease(BlobName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobRenewLease(BlobName, OptionalParameters, LeaseId));
    end;


    /// <summary>
    /// Breaks a lease on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(BlobName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobBreakLease(BlobName, OptionalParameters, LeaseId, 0));
    end;

    /// <summary>
    /// Breaks a lease on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="LeaseBreakPeriod">The proposed duration the lease should continue before it is broken, in seconds, between 0 and 60.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(BlobName: Text; LeaseId: Guid; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobBreakLease(BlobName, OptionalParameters, LeaseId, LeaseBreakPeriod));
    end;

    /// <summary>
    /// Breaks a lease on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(BlobName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobBreakLease(BlobName, OptionalParameters, LeaseId, 0));
    end;

    /// <summary>
    /// Breaks a lease on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseBreakPeriod">The proposed duration the lease should continue before it is broken, in seconds, between 0 and 60.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(BlobName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobBreakLease(BlobName, OptionalParameters, LeaseId, LeaseBreakPeriod));
    end;

    /// <summary>
    /// Changes the lease ID of an active lease
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be changed. Will contain the updated Guid after successful operation.</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    /// <returns>An operation reponse object</returns>
    procedure ChangeLease(BlobName: Text; var LeaseId: Guid; ProposedLeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.BlobChangeLease(BlobName, OptionalParameters, LeaseId, ProposedLeaseId));
    end;

    /// <summary>
    /// Changes the lease ID of an active lease
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="BlobName">The name of the blob.</param>  
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ChangeLease(BlobName: Text; LeaseId: Guid; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.BlobChangeLease(BlobName, OptionalParameters, LeaseId, ProposedLeaseId));
    end;

    var
        BlobServicesApiImpl: Codeunit "ABS Client Impl.";
}