// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides common authorization functionality for using Azurite in tests for Azure Storage Services.
/// See: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite
/// </summary>
codeunit 132923 "Azurite Test Library"
{
    Access = Internal;

    var
        BlobStorageBaseUrlTxt: Label 'http://127.0.0.1:10000/devstoreaccount1';
        StorageAccountNameTxt: Label 'devstoreaccount1', Locked = true; // Azurite account name
        AccessKeyTxt: Label 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==', Locked = true; // Azurite account key

    /// <summary>
    /// Clears the storage account by removing all containers.
    /// </summary>
    procedure ClearStorageAccount()
    var
        Container: Record "ABS Container";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
    begin
        Authorization := StorageServiceAuthorization.CreateSharedKey(GetAccessKey());

        ABSContainerClient.Initialize(GetStorageAccountName(), Authorization);
        ABSContainerClient.ListContainers(Container);

        if not Container.Find('-') then
            exit;

        repeat
            ABSContainerClient.DeleteContainer(Container.Name);
        until Container.Next() = 0;
    end;

    /// <summary>
    /// Gets Azurite storage account name.
    /// See: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio#well-known-storage-account-and-key
    /// </summary>
    /// <returns>Azurite storage account name</returns>
    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountNameTxt);
    end;

    /// <summary>
    /// Gets Azurite base storage URL for blob storage.
    /// </summary>
    /// <returns>Azurite base storage URL.</returns>
    procedure GetBlobStorageBaseUrl(): Text
    begin
        exit(BlobStorageBaseUrlTxt);
    end;

    /// <summary>
    /// Gets Azurite storage account key.
    /// See: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio#well-known-storage-account-and-key
    /// </summary>
    /// <returns>Azurite storage account key</returns>
    procedure GetAccessKey(): Text;
    begin
        exit(AccessKeyTxt);
    end;
}