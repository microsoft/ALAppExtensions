// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132920 "ABS Blob Client Test"
{
    Subtype = Test;

    //[Test]
    procedure PutBlobBlockBlobStreamTest()
    var
        Response: Codeunit "ABS Operation Response";
        ContainerName, BlobName, BlobContent, NewBlobContent : Text;
    begin
        // [Scenarion] Given a storage account and a container, PutBlobBlockBlob operation succeeds and GetBlobAsText returns the content 

        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ContainerName := ABSTestLibrary.GetContainerName();
        BlobName := ABSTestLibrary.GetBlobName();
        BlobContent := ABSTestLibrary.GetSampleTextBlobContent();

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ABSContainerClient.CreateContainer(ContainerName);

        ABSBlobClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), ContainerName, SharedKeyAuthorization);
        ABSBlobClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        Response := ABSBlobClient.PutBlobBlockBlobText(BlobName, BlobContent);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation PutBlobBlockBlob failed');

        Response := ABSBlobClient.GetBlobAsText(BlobName, NewBlobContent);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation GetBlobAsText failed');

        Assert.AreEqual(BlobContent, NewBlobContent, 'Blob content mismatch');

        // Clean-up
        ABSContainerClient.DeleteContainer(ContainerName);
    end;

    var
        Assert: Codeunit "Library Assert";
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSTestLibrary: Codeunit "ABS Test Library";
        AzuriteTestLibrary: Codeunit "Azurite Test Library";
        SharedKeyAuthorization: Interface "Storage Service Authorization";
}