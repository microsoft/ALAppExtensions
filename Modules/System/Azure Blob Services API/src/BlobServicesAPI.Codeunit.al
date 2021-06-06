// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to use the Blob Services REST API for Azure Storage Accounts
/// </summary>
codeunit 9040 "Blob Services API"
{
    Access = Public;

    // #region List Containers
    /// <summary>
    /// List all Containers in specific Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="Container">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListContainers(var OperationObject: Codeunit "Blob API Operation Object"; var Container: Record "Container") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ListContainers(OperationObject, Container);
    end;
    // #endregion List Containers

    // #region Create Container
    /// <summary>
    /// Creates a new Container in the Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure CreateContainer(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.CreateContainer(OperationObject);
    end;
    // #endregion 

    // #region Delete Container
    /// <summary>
    /// Delete a Container in the Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure DeleteContainer(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.DeleteContainer(OperationObject);
    end;
    // #endregion Delete Container

    // #region Put Blob
    /// <summary>
    /// Uploads (PUT) a File as a BlockBlob (with File Selection Dialog)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">A Request Object containing the necessary para#meters for the request.</param>    
    procedure PutBlobBlockBlobUI(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlobBlockBlobUI(OperationObject);
    end;

    /// <summary>
    /// Uploads (PUT) the content of an InStream as a BlockBlob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceStream">The Content of the Blob as InStream.</param>
    procedure PutBlobBlockBlobStream(var OperationObject: Codeunit "Blob API Operation Object"; BlobName: Text; var SourceStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlobBlockBlobStream(OperationObject, BlobName, SourceStream);
    end;

    /// <summary>
    /// Uploads (PUT) the content of a Text-Variable as a BlockBlob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceText">The Content of the Blob as Text.</param>
    procedure PutBlobBlockBlobText(var OperationObject: Codeunit "Blob API Operation Object"; BlobName: Text; SourceText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlobBlockBlobText(OperationObject, BlobName, SourceText);
    end;

    /// <summary>
    /// Creates (PUT) a PageBlob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure PutBlobPageBlob(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlobPageBlob(OperationObject, ContentType);
    end;
    /// <summary>
    /// Creates (PUT) a PageBlob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure PutBlobPageBlob(var OperationObject: Codeunit "Blob API Operation Object"; BlobName: Text; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationObject.SetBlobName(BlobName);
        OperationResponse := PutBlobPageBlob(OperationObject, ContentType);
    end;
    // #endregion Put Blob

    // #region Append Block
    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure PutBlobAppendBlobStream(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := PutBlobAppendBlob(OperationObject, 'application/octet-stream');
    end;
    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// Uses 'text/plain; charset=UTF-8' as Content-Type
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure PutBlobAppendBlobText(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := PutBlobAppendBlob(OperationObject, 'text/plain; charset=UTF-8');
    end;
    /// <summary>
    /// The Put Blob operation creates a new append blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure PutBlobAppendBlob(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlobAppendBlob(OperationObject, ContentType);
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'text/plain; charset=UTF-8' as Content-Type
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    procedure AppendBlockText(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlockText(OperationObject, ContentAsText, 'text/plain; charset=UTF-8');
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure AppendBlockText(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsText: Text; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlock(OperationObject, ContentType, ContentAsText);
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    procedure AppendBlockStream(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlockStream(OperationObject, ContentAsStream, 'application/octet-stream');
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure AppendBlockStream(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsStream: InStream; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlock(OperationObject, ContentType, ContentAsStream);
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the Blob</param>
    procedure AppendBlock(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.AppendBlock(OperationObject, ContentType, SourceContent);
    end;

    /// <summary>
    /// The Append Block From URL operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block-from-url
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceUri">Specifies the name of the source blob.</param>
    procedure AppendBlockFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.AppendBlockFromURL(OperationObject, SourceUri);
    end;
    // #endregion Append Block

    // #region Get Blob Service Properties
    /// <summary>
    /// The Get Blob Service Properties operation gets the properties of a storage account’s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-properties
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="Properties">XmlDocument containing the current properties.</param>
    procedure GetBlobServiceProperties(var OperationObject: Codeunit "Blob API Operation Object"; var Properties: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobServiceProperties(OperationObject, Properties);
    end;
    // #endregion Get Blob Service Properties

    // #region Set Blob Service Properties
    /// <summary>
    /// The Set Blob Service Properties operation sets properties for a storage account’s Blob service endpoint, including properties for Storage Analytics, CORS (Cross-Origin Resource Sharing) rules and soft delete settings.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-service-properties
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="Document">The XmlDocument containing the Properties</param>
    procedure SetBlobServiceProperties(var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobServiceProperties(OperationObject, Document);
    end;
    // #endregion Set Blob Service Properties

    // #region Preflight Blob Request
    /// <summary>
    /// The Preflight Blob Request operation queries the Cross-Origin Resource Sharing (CORS) rules for the Blob service prior to sending the actual request.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/preflight-blob-request
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="Origin">Specifies the origin from which the actual request will be issued.</param>
    /// <param name="AccessControlRequestMethod">Specifies the method (or HTTP verb) for the actual request.</param>
    procedure PreflightBlobRequest(var OperationObject: Codeunit "Blob API Operation Object"; Origin: Text; AccessControlRequestMethod: Enum "Http Request Type") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := PreflightBlobRequest(OperationObject, Origin, AccessControlRequestMethod, '');
    end;

    /// <summary>
    /// The Preflight Blob Request operation queries the Cross-Origin Resource Sharing (CORS) rules for the Blob service prior to sending the actual request.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/preflight-blob-request
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="Origin">Specifies the origin from which the actual request will be issued.</param>
    /// <param name="AccessControlRequestMethod">Specifies the method (or HTTP verb) for the actual request.</param>
    /// <param name="AccessControlRequestHeaders">Optional. Specifies the headers for the actual request headers that will be sent</param>
    procedure PreflightBlobRequest(var OperationObject: Codeunit "Blob API Operation Object"; Origin: Text; AccessControlRequestMethod: Enum "Http Request Type"; AccessControlRequestHeaders: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PreflightBlobRequest(OperationObject, Origin, AccessControlRequestMethod, AccessControlRequestHeaders);
    end;
    // #endregion Preflight Blob Request

    // #region Get Blob Service Stats
    /// <summary>
    /// The Get Blob Service Stats operation retrieves statistics related to replication for the Blob service. It is only available on the secondary location endpoint when read-access geo-redundant replication is enabled for the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-stats
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>  
    /// <param name="ServiceStats">A XmlDocument containing the returned Services stats.</param>  
    procedure GetBlobServiceStats(var OperationObject: Codeunit "Blob API Operation Object"; var ServiceStats: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobServiceStats(OperationObject, ServiceStats);
    end;
    // #endregion Get Blob Service Stats

    // #region Get Account Information
    /// <summary>
    /// The Get Account Information operation returns the sku name and account kind for the specified account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-account-information
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="AccountInformationHeaders">HttpHeaders containing the current properties.</param>
    procedure GetAccountInformation(var OperationObject: Codeunit "Blob API Operation Object"; var AccountInformationHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetAccountInformation(OperationObject, AccountInformationHeaders);
    end;
    // #endregion Get Account Information

    // #region Get User Delegation Key
    /// <summary>
    /// The Get User Delegation Key operation gets a key that can be used to sign a user delegation SAS (shared access signature)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-user-delegation-key
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="ExpiryDateTime">The expiry time of user delegation SAS, in ISO Date format. It must be a valid date and time within 7 days of the current time.</param>
    /// <param name="UserDelegationKey">The returned User Delegation Key.</param>
    procedure GetUserDelegationKey(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryDateTime: DateTime; var UserDelegationKey: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := GetUserDelegationKey(OperationObject, ExpiryDateTime, 0DT, UserDelegationKey);
    end;
    /// <summary>
    /// The Get User Delegation Key operation gets a key that can be used to sign a user delegation SAS (shared access signature)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-user-delegation-key
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartDateTime">The start time for the user delegation SAS, in ISO Date format. It must be a valid date and time within 7 days of the current time</param>
    /// <param name="ExpiryDateTime">The expiry time of user delegation SAS, in ISO Date format. It must be a valid date and time within 7 days of the current time.</param>
    /// <param name="UserDelegationKey">The returned User Delegation Key.</param>
    procedure GetUserDelegationKey(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryDateTime: DateTime; StartDateTime: DateTime; var UserDelegationKey: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        // TODO: Think about adding a function with all details as return value (instead of only the key)
        OperationResponse := BlobServicesApiImpl.GetUserDelegationKey(OperationObject, ExpiryDateTime, StartDateTime, UserDelegationKey);
    end;
    // #endregion Get User Delegation Key

    // #region Get Container Properties
    /// <summary>
    /// The Get Container Properties operation returns all user-defined metadata and system properties for the specified container. The data returned does not include the container's list of blobs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="PropertyHeaders">HttpHeaders containing the current properties.</param>
    procedure GetContainerProperties(var OperationObject: Codeunit "Blob API Operation Object"; var PropertyHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetContainerProperties(OperationObject, PropertyHeaders);
    end;
    // #endregion Get Container Properties

    // #region Get Container Metadata
    /// <summary>
    /// The Get Container Metadata operation returns all user-defined metadata for the container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-metadata
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="MetadataHeaders">HttpHeaders containing the current metadata.</param>
    procedure GetContainerMetadata(var OperationObject: Codeunit "Blob API Operation Object"; var MetadataHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetContainerMetadata(OperationObject, MetadataHeaders);
    end;
    // #endregion Get Container Metadata

    // #region Set Container Metadata
    /// <summary>
    /// The Set Container Metadata operation sets one or more user-defined name-value pairs for the specified container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-container-metadata
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure SetContainerMetadata(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetContainerMetadata(OperationObject);
    end;
    // #endregion Set Container Metadata

    // #region Get Container ACL
    /// <summary>
    /// The Get Container ACL operation gets the permissions for the specified container. The permissions indicate whether container data may be accessed publicly.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-acl
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ContainerAcl">XmlDocument containing the current ACL.</param>
    procedure GetContainerACL(var OperationObject: Codeunit "Blob API Operation Object"; var ContainerAcl: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetContainerACL(OperationObject, ContainerAcl);
    end;
    // #endregion Get Container ACL

    // #region Set Container ACL
    /// <summary>
    /// The Set Container ACL operation sets the permissions for the specified container. The permissions indicate whether blobs in a container may be accessed publicly.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-container-acl
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="Document">The XmlDocument containing the ACL definition</param>
    procedure SetContainerACL(var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetContainerACL(OperationObject, Document);
    end;
    // #endregion Set Container ACL

    // #region Container Acquire Lease
    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure ContainerLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        OperationResponse := ContainerLeaseAcquire(OperationObject, -1, ProposedLeaseId, LeaseId); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure ContainerLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        OperationResponse := ContainerLeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, LeaseId); // Custom duration, new Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure ContainerLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; ProposedLeaseId: Guid; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := ContainerLeaseAcquire(OperationObject, -1, ProposedLeaseId, LeaseId); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure ContainerLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ContainerLeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, LeaseId);
    end;
    // #endregion Container Acquire Lease

    // #region Container Release Lease
    /// <summary>
    /// Releases a lock on a container if it is no longer needed so that another client may immediately acquire a lease against the container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be freed</param>
    procedure ContainerLeaseRelease(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ContainerLeaseRelease(OperationObject, LeaseId);
    end;
    // #endregion Container Release Lease

    // #region Container Renew Lease
    /// <summary>
    /// Renews a lock on a container to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    procedure ContainerLeaseRenew(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ContainerLeaseRenew(OperationObject, LeaseId);
    end;
    // #endregion Container Renew Lease

    // #region Container Break Lease
    /// <summary>
    /// Breaks a lock on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    procedure ContainerLeaseBreak(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ContainerLeaseBreak(OperationObject, LeaseId);
    end;
    // #endregion Container Break Lease

    // #region Container Change Lease
    /// <summary>
    /// Changes the lock ID for a lease on a container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    procedure ContainerLeaseChange(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; ProposedLeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ContainerLeaseChange(OperationObject, LeaseId, ProposedLeaseId);
    end;
    // #endregion Container Change Lease

    // #region Blob Acquire Lease
    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure BlobLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        OperationResponse := BlobLeaseAcquire(OperationObject, -1, ProposedLeaseId, LeaseId); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure BlobLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        OperationResponse := BlobLeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, LeaseId); // Custom duration, new Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure BlobLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; ProposedLeaseId: Guid; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobLeaseAcquire(OperationObject, -1, ProposedLeaseId, LeaseId); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">A GUID containing the LeaseId from the result.</param>
    procedure BlobLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.BlobLeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, LeaseId);
    end;
    // #endregion Blob Acquire Lease

    // #region Blob Release Lease
    /// <summary>
    /// Releases a lock on a Blob if it is no longer needed so that another client may immediately acquire a lease against the container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be freed</param>
    procedure BlobLeaseRelease(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.BlobLeaseRelease(OperationObject, LeaseId);
    end;
    // #endregion Blob Release Lease

    // #region Blob Renew Lease
    /// <summary>
    /// Renews a lock on a Blob to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    procedure BlobLeaseRenew(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.BlobLeaseRenew(OperationObject, LeaseId);
    end;
    // #endregion Blob Renew Lease

    // #region Blob Break Lease
    /// <summary>
    /// Breaks a lock on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    procedure BlobLeaseBreak(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.BlobLeaseBreak(OperationObject, LeaseId);
    end;
    // #endregion Blob Break Lease

    // #region Blob Change Lease
    /// <summary>
    /// Changes the lock ID for a lease on a Blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>    
    procedure BlobLeaseChange(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; ProposedLeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.BlobLeaseChange(OperationObject, LeaseId, ProposedLeaseId);
    end;
    // #endregion Blob Change Lease

    // #region List Blobs
    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ContainerContent">Collection of the result (temporary record).</param>
    procedure ListBlobs(var OperationObject: Codeunit "Blob API Operation Object"; var ContainerContent: Record "Container Content") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.ListBlobs(OperationObject, ContainerContent);
    end;
    // #endregion List Blobs

    // #region Get Blob
    /// <summary>
    /// Receives (GET) a Blob as a File from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure GetBlobAsFile(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobAsFile(OperationObject);
    end;

    /// <summary>
    /// Receives (GET) a Blob as a InStream from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="TargetStream">The result InStream containg the content of the Blob.</param>
    procedure GetBlobAsStream(var OperationObject: Codeunit "Blob API Operation Object"; var TargetStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobAsStream(OperationObject, TargetStream);
    end;

    /// <summary>
    /// Receives (GET) a Blob as Text from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="TargetText">The result Text containg the content of the Blob.</param>
    procedure GetBlobAsText(var OperationObject: Codeunit "Blob API Operation Object"; var TargetText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobAsText(OperationObject, TargetText);
    end;
    // #endregion Get Blob

    // #region Get Blob Properties
    /// <summary>
    /// The Get Blob Service Properties operation gets the properties of a storage account’s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure GetBlobProperties(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobProperties(OperationObject);
    end;
    // #endregion Get Blob Properties

    // #region Set Blob Properties
    /// <summary>
    /// The Set Blob Properties operation sets system properties on the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure SetBlobProperties(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobProperties(OperationObject);
    end;
    // #endregion Set Blob Properties

    // #region Set Blob Expiry
    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry time relative to the file creation time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from creation time.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    procedure SetBlobExpiryRelativeToCreation(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobExpiryRelativeToCreation(OperationObject, ExpiryTime);
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry relative to the current time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from now.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    procedure SetBlobExpiryRelativeToNow(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobExpiryRelativeToNow(OperationObject, ExpiryTime);
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry to an absolute DateTime
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Absolute DateTime for the expiration.</param>
    procedure SetBlobExpiryAbsolute(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: DateTime) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobExpiryAbsolute(OperationObject, ExpiryTime);
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the file to never expire or removes the current expiry time, x-ms-expiry-time must not to be specified.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure SetBlobExpiryNever(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobExpiryNever(OperationObject);
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryOption">The type of expiration that should be set.</param>
    /// <param name="ExpiryTime">Variant containing Nothing, number if miliseconds (Integer) or the absolute DateTime for the expiration.</param>
    /// <param name="OperationNotSuccessfulErr">The error message that should be thrown when the request fails.</param>
    procedure SetBlobExpiry(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryOption: Enum "Blob Expiry Option"; ExpiryTime: Variant; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobExpiry(OperationObject, ExpiryOption, ExpiryTime, OperationNotSuccessfulErr);
    end;
    // #endregion Set Blob Expiry

    // #region Get Blob Metadata
    /// <summary>
    /// The Get Blob Metadata operation returns all user-defined metadata for the specified blob or snapshot.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-metadata
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure GetBlobMetadata(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobMetadata(OperationObject);
    end;
    // #endregion Get Blob Metadata

    // #region Set Blob Metadata
    /// <summary>
    /// The Set Blob Metadata operation sets user-defined metadata for the specified blob as one or more name-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-metadata
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    procedure SetBlobMetadata(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobMetadata(OperationObject);
    end;
    // #endregion Set Blob Metadata

    // #region Get Blob Tags
    /// <summary>
    /// The Get Blob Tags operation returns all user-defined tags for the specified blob, version, or snapshot.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-tags
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="BlobTags">A XmlDocument which contains the Tags currently set on the Blob.</param>    
    procedure GetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"; var BlobTags: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlobTags(OperationObject, BlobTags);
    end;
    // #endregion Get Blob Tags

    // #region Set Blob Tags
    /// <summary>
    /// The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="Tags">A Dictionary of [Text, Text] which contains the Tags you want to set.</param>    
    procedure SetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"; Tags: Dictionary of [Text, Text]) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobTags(OperationObject, Tags);
    end;

    /// <summary>
    /// The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="Tags">A Dictionary of [Text, Text] which contains the Tags you want to set.</param>    
    procedure SetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"; Tags: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobTags(OperationObject, Tags);
    end;
    // #endregion Set Blob Tags

    // #region Find Blob by Tags
    /// <summary>
    /// The Find Blobs by Tags operation finds all blobs in the storage account whose tags match a given search expression.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/find-blobs-by-tags
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SearchTags">A Dictionary of [Text, Text] containing the necessary tags to search for.</param>
    /// <param name="FoundBlobs">XmlDocument containing the enumeration of found blobs</param>
    procedure FindBlobsByTags(var OperationObject: Codeunit "Blob API Operation Object"; SearchTags: Dictionary of [Text, Text]; var FoundBlobs: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.FindBlobsByTags(OperationObject, SearchTags, FoundBlobs);
    end;

    /// <summary>
    /// The Find Blobs by Tags operation finds all blobs in the storage account whose tags match a given search expression.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/find-blobs-by-tags
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SearchExpression">A search expression to find blobs by.</param>
    /// <param name="FoundBlobs">XmlDocument containing the enumeration of found blobs</param>
    procedure FindBlobsByTags(var OperationObject: Codeunit "Blob API Operation Object"; SearchExpression: Text; var FoundBlobs: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.FindBlobsByTags(OperationObject, SearchExpression, FoundBlobs);
    end;
    // #endregion Find Blob by Tags

    // #region Delete Blob
    /// <summary>
    /// The Delete Blob operation marks the specified blob or snapshot for deletion. The blob is later deleted during garbage collection.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure DeleteBlob(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.DeleteBlob(OperationObject);
    end;
    // #endregion Delete Blob

    // #region Undelete Blob
    /// <summary>
    /// The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure UndeleteBlob(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.UndeleteBlob(OperationObject);
    end;
    // #endregion Undelete Blob

    // #region Snapshot Blob
    /// <summary>
    /// The Snapshot Blob operation creates a read-only snapshot of a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/snapshot-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>        
    procedure SnapshotBlob(var OperationObject: Codeunit "Blob API Operation Object") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SnapshotBlob(OperationObject);
    end;
    // #endregion Snapshot Blob

    // #region Copy Blob
    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    procedure CopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; SourceName: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        LeaseId: Guid;
    begin
        OperationResponse := CopyBlob(OperationObject, SourceName, LeaseId);
    end;

    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    /// <param name="LeaseId">Required if the destination blob has an active lease. The lease ID specified must match the lease ID of the destination blob.</param>
    procedure CopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; SourceName: Text; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.CopyBlob(OperationObject, SourceName, LeaseId);
    end;
    // #endregion Copy Blob

    // #region Copy Blob from URL
    /// <summary>
    /// The Copy Blob From URL operation copies a blob to a destination within the storage account synchronously for source blob sizes up to 256 MiB
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob-from-url
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceUri">Specifies the URL of the source blob.</param>
    procedure CopyBlobFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.CopyBlobFromURL(OperationObject, SourceUri);
    end;
    // #endregion Copy Blob from URL

    // #region Abort Copy Blob
    /// <summary>
    /// The Abort Copy Blob operation aborts a pending Copy Blob operation, and leaves a destination blob with zero length and full metadata.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/abort-copy-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>    
    /// <param name="CopyId">Id with the copy identifier provided in the x-ms-copy-id header of the original Copy Blob operation.</param>
    procedure AbortCopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; CopyId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.AbortCopyBlob(OperationObject, CopyId);
    end;
    // #endregion Abort Copy Blob

    // #region Put Block
    /// <summary>
    /// The Put Block operation creates a new block to be committed as part of a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    procedure PutBlock(var OperationObject: Codeunit "Blob API Operation Object"; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlock(OperationObject, SourceContent);
    end;
    /// <summary>
    /// The Put Block operation creates a new block to be committed as part of a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    /// <param name="BlockId">A valid Base64 string value that identifies the block</param>
    procedure PutBlock(var OperationObject: Codeunit "Blob API Operation Object"; SourceContent: Variant; BlockId: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlock(OperationObject, SourceContent, BlockId);
    end;
    // #endregion Put Block

    // #region Get Block List
    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlockListType">Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together.</param>
    /// <param name="CommitedBlocks">Dictionary of [Text, Integer] containing the list of commited blocks (BLockId and Size)</param>
    /// <param name="UncommitedBlocks">Dictionary of [Text, Integer] containing the list of uncommited blocks (BLockId and Size)</param>
    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockListType: Enum "Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlockList(OperationObject, BlockListType, CommitedBlocks, UncommitedBlocks);
    end;

    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlockList">XmlDocument containing the Block List.</param>
    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"; var BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        BlockListType: Enum "Block List Type";
    begin
        OperationResponse := GetBlockList(OperationObject, BlockListType::committed, BlockList); // default API value is "committed"
    end;

    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlockListType">Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together.</param>
    /// <param name="BlockList">XmlDocument containing the Block List.</param>
    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockListType: Enum "Block List Type"; var BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetBlockList(OperationObject, BlockListType, BlockList);
    end;
    // #endregion Get Block List

    // #region Put Block List
    /// <summary>
    /// The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="CommitedBlocks">Dictionary of [Text, Integer] containing the list of commited blocks that should be put to the Blob</param>
    /// <param name="UncommitedBlocks">Dictionary of [Text, Integer] containing the list of uncommited blocks that should be put to the Blob</param>
    procedure PutBlockList(var OperationObject: Codeunit "Blob API Operation Object"; CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlockList(OperationObject, CommitedBlocks, UncommitedBlocks);
    end;
    /// <summary>
    /// The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    procedure PutBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlockList(OperationObject, BlockList);
    end;
    // #endregion Put Block List

    // #region Put Block From URL
    /// <summary>
    /// The Put Block From URL operation creates a new block to be committed as part of a blob where the contents are read from a URL.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-from-url
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceUri">Specifies the name of the source block blob.</param>
    /// <param name="BlockId">Specifies the BlockId that should be put.</param>
    procedure PutBlockFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text; BlockId: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutBlockFromURL(OperationObject, SourceUri, BlockId);
    end;
    // #endregion Put Block From URL

    // #region Query Blob Contents
    /// <summary>
    /// The Query Blob Contents API applies a simple Structured Query Language (SQL) statement on a blob's contents and returns only the queried subset of the data.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/query-blob-contents
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="QueryExpression">A SQL-like expression to query content (see: https://docs.microsoft.com/en-us/azure/storage/blobs/query-acceleration-sql-reference)</param>
    /// <param name="Result">An InStream-object containing the Blob contents.</param>
    procedure QueryBlobContents(var OperationObject: Codeunit "Blob API Operation Object"; QueryExpression: Text; var Result: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.QueryBlobContents(OperationObject, QueryExpression, Result);
    end;
    /// <summary>
    /// The Query Blob Contents API applies a simple Structured Query Language (SQL) statement on a blob's contents and returns only the queried subset of the data.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/query-blob-contents
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="QueryDocument">The XML containing the QueryRequest</param>
    /// <param name="Result">An InStream-object containing the Blob contents.</param>
    procedure QueryBlobContents(var OperationObject: Codeunit "Blob API Operation Object"; QueryDocument: XmlDocument; var Result: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.QueryBlobContents(OperationObject, QueryDocument, Result);
    end;
    // #endregion Query Blob Contents

    // #region Set Blob Tier
    /// <summary>
    /// The Set Blob Tier operation sets the access tier on a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tier
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="BlobAccessTier">The Access Tier the blob should be set to.</param>
    procedure SetBlobTier(var OperationObject: Codeunit "Blob API Operation Object"; BlobAccessTier: Enum "Blob Access Tier") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.SetBlobTier(OperationObject, BlobAccessTier);
    end;
    // #endregion Set Blob Tier

    // #region Put Page
    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// 'Update' will add the specified content to the defined range
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be written as a page</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    procedure PutPageUpdate(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        OperationResponse := PutPage(OperationObject, StartRange, EndRange, SourceContent, PageWriteOption::Update);
    end;

    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// 'Clear' will empty the defined range
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be cleared</param>    
    procedure PutPageClear(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        OperationResponse := PutPage(OperationObject, StartRange, EndRange, '', PageWriteOption::Clear);
    end;

    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be written as a page</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    /// <param name="PageWriteOption">Either 'update' or 'clear'; defines if content is added to or cleared from a page</param>
    procedure PutPage(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant; PageWriteOption: Enum "PageBlob Write Option") OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutPage(OperationObject, StartRange, EndRange, SourceContent, PageWriteOption);
    end;
    // #endregion Put Page

    // #region Put Page from URL
    /// <summary>
    /// The Put Page From URL operation writes a range of pages to a page blob where the contents are read from a URL.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page-from-url
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes of the source page blob to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes of the source page blob to be written as a page</param>        
    /// <param name="SourceUri">Specifies the URL of the source blob.</param>
    procedure PutPageFromURL(var OperationObject: Codeunit "Blob API Operation Object"; StartRangeSource: Integer; EndRangeSource: Integer; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := PutPageFromURL(OperationObject, StartRangeSource, EndRangeSource, StartRangeSource, EndRangeSource, SourceUri); // uses the same ranges for source and destination
    end;

    /// <summary>
    /// The Put Page From URL operation writes a range of pages to a page blob where the contents are read from a URL.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page-from-url
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes of the source page blob to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes of the source page blob to be written as a page</param>    
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be written as a page</param>    
    /// <param name="SourceUri">Specifies the URL of the source blob.</param>
    procedure PutPageFromURL(var OperationObject: Codeunit "Blob API Operation Object"; StartRangeSource: Integer; EndRangeSource: Integer; StartRange: Integer; EndRange: Integer; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.PutPageFromURL(OperationObject, StartRangeSource, EndRangeSource, StartRange, EndRange, SourceUri);
    end;
    // #endregion Put Page from URL

    // #region Get Page Ranges
    /// <summary>
    /// The Get Page Ranges operation returns the list of valid page ranges for a page blob or snapshot of a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-page-ranges
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="PageRanges">A Dictionairy containing the result in structured form.</param>
    procedure GetPageRanges(var OperationObject: Codeunit "Blob API Operation Object"; var PageRanges: Dictionary of [Integer, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetPageRanges(OperationObject, PageRanges);
    end;

    /// <summary>
    /// The Get Page Ranges operation returns the list of valid page ranges for a page blob or snapshot of a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-page-ranges
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="PageRanges">XmlDocument containing the Page ranges.</param>
    procedure GetPageRanges(var OperationObject: Codeunit "Blob API Operation Object"; var PageRanges: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.GetPageRanges(OperationObject, PageRanges);
    end;
    // #endregion Get Page Ranges

    // #region Incremental Copy Blob
    /// <summary>
    /// The Incremental Copy Blob operation copies a snapshot of the source page blob to a destination page blob. 
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/incremental-copy-blob
    /// </summary>
    /// <param name="OperationObject">An object containing the necessary parameters for the request.</param>
    /// <param name="SourceUri">Specifies the name of the source page blob snapshot.</param>
    procedure IncrementalCopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := BlobServicesApiImpl.IncrementalCopyBlob(OperationObject, SourceUri);
    end;
    // #endregion Incremental Copy Blob

    var
        BlobServicesApiImpl: Codeunit "Blob Services API Impl.";
}