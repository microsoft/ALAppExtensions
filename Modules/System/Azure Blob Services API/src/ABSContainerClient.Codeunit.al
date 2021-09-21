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

    var
        BlobServicesApiImpl: Codeunit "ABS Client Impl.";
}