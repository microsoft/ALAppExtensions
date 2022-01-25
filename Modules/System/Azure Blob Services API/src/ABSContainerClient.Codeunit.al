// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to use operations on containers in Azure BLOB Services.
/// </summary>
codeunit 9052 "ABS Container Client"
{
    Access = Public;

    /// <summary>
    /// Initializes the Azure BLOB Storage container client.
    /// </summary>
    /// <param name="StorageAccount">The name of Storage Account to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    [NonDebuggable]
    procedure Initialize(StorageAccount: Text; Authorization: Interface "Storage Service Authorization")
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        BlobServicesApiImpl.Initialize(StorageAccount, '', '', Authorization, StorageServiceAuthorization.GetDefaultAPIVersion());
    end;

    /// <summary>
    /// Initializes the Azure BLOB Storage container client.
    /// </summary>
    /// <param name="StorageAccount">The Storage Account to use.</param>
    /// <param name="ApiVersion">The API version to use.</param>
    [NonDebuggable]
    procedure Initialize(StorageAccount: Text; Authorization: Interface "Storage Service Authorization"; ApiVersion: Enum "Storage Service API Version")
    begin
        BlobServicesApiImpl.Initialize(StorageAccount, '', '', Authorization, ApiVersion);
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
    /// List all containers in specific Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="Container">Collection of the result (temporary record).</param>
    /// <returns>An operation reponse object</returns>
    procedure ListContainers(var Containers: Record "ABS Container"): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ListContainers(Containers, OptionalParameters));
    end;

    /// <summary>
    /// List all containers in specific Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="Container">Collection of the result (temporary record).</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ListContainers(var Containers: Record "ABS Container"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ListContainers(Containers, OptionalParameters));
    end;

    /// <summary>
    /// Creates a new container in the Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <returns>An operation reponse object</returns>
    procedure CreateContainer(ContainerName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.CreateContainer(ContainerName, OptionalParameters));
    end;

    /// <summary>
    /// Creates a new container in the Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
    /// </summary>
    /// <param name="ContainerName">The name of the container to create.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure CreateContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.CreateContainer(ContainerName, OptionalParameters));
    end;

    /// <summary>
    /// Deletes a container from the Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <returns>An operation reponse object</returns>
    procedure DeleteContainer(ContainerName: Text): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.DeleteContainer(ContainerName, OptionalParameters));
    end;

    /// <summary>
    /// Deletes a container from the Storage Account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
    /// </summary>
    /// <param name="ContainerName">The name of the container to delete.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure DeleteContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.DeleteContainer(ContainerName, OptionalParameters));
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>    
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; DurationSeconds: Integer; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId)); // Custom duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>    
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; DurationSeconds: Integer; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        ProposedLeaseId: Guid;
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId)); // Custom duration, null Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, -1, ProposedLeaseId, LeaseId)); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Requests a new lease. If the container does not have an active lease, the blob service creates a lease on the container. The lease duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>     
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseId">Guid containing the response value from x-ms-lease-id HttpHeader</param>
    /// <returns>An operation reponse object</returns>
    procedure AcquireLease(ContainerName: Text; DurationSeconds: Integer; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerAcquireLease(ContainerName, OptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId));
    end;

    /// <summary>
    /// Releases a lease on a container if it is no longer needed so that another client may immediately acquire a lease against the blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(ContainerName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerReleaseLease(ContainerName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Releases a lease on a container if it is no longer needed so that another client may immediately acquire a lease against the blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be released</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ReleaseLease(ContainerName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerReleaseLease(ContainerName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Renews a lease on a container to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    /// <returns>An operation reponse object</returns>
    procedure RenewLease(ContainerName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerRenewLease(ContainerName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Renews a lease on a container to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure RenewLease(ContainerName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerRenewLease(ContainerName, OptionalParameters, LeaseId));
    end;

    /// <summary>
    /// Breaks a lease on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(ContainerName: Text; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerBreakLease(ContainerName, OptionalParameters, LeaseId, 0));
    end;

    /// <summary>
    /// Breaks a lease on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="LeaseBreakPeriod">The proposed duration the lease should continue before it is broken, in seconds, between 0 and 60.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(ContainerName: Text; LeaseId: Guid; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerBreakLease(ContainerName, OptionalParameters, LeaseId, LeaseBreakPeriod));
    end;

    /// <summary>
    /// Breaks a lease on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(ContainerName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerBreakLease(ContainerName, OptionalParameters, LeaseId, 0));
    end;

    /// <summary>
    /// Breaks a lease on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <param name="LeaseBreakPeriod">The proposed duration the lease should continue before it is broken, in seconds, between 0 and 60.</param>
    /// <returns>An operation reponse object</returns>
    procedure BreakLease(ContainerName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerBreakLease(ContainerName, OptionalParameters, LeaseId, LeaseBreakPeriod));
    end;

    /// <summary>
    /// Changes the lease ID of an active lease
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed. Will contain the updated Guid after successful operation.</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    /// <returns>An operation reponse object</returns>
    procedure ChangeLease(ContainerName: Text; var LeaseId: Guid; ProposedLeaseId: Guid): Codeunit "ABS Operation Response"
    var
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        exit(BlobServicesApiImpl.ContainerChangeLease(ContainerName, OptionalParameters, LeaseId, ProposedLeaseId));
    end;

    /// <summary>
    /// Changes the lease ID of an active lease
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="ContainerName">The name of the container.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    /// <param name="OptionalParameters">Optional parameters to pass.</param>
    /// <returns>An operation reponse object</returns>
    procedure ChangeLease(ContainerName: Text; LeaseId: Guid; ProposedLeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    begin
        exit(BlobServicesApiImpl.ContainerChangeLease(ContainerName, OptionalParameters, LeaseId, ProposedLeaseId));
    end;

    var
        BlobServicesApiImpl: Codeunit "ABS Client Impl.";
}