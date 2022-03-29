// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132920 "ABS Blob Client Test"
{
    Subtype = Test;

    [Test]
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

    [Test]
    procedure LeaseBlobTest()
    var
        Response: Codeunit "ABS Operation Response";
        ContainerName, BlobName, BlobContent : Text;
        LeaseId: Guid;
        ProposedLeaseId: Guid;
    begin
        // [Scenarion] Given a storage account and a container, PutBlobBlockBlob operation succeeds and subsequent lease-operations
        // (1) create a lease, (2) renew a lease, [(3) change a lease], (4) break a lease and (5) release the lease

        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ContainerName := ABSTestLibrary.GetContainerName();
        BlobName := ABSTestLibrary.GetBlobName();
        BlobContent := ABSTestLibrary.GetSampleTextBlobContent();

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ABSContainerClient.CreateContainer(ContainerName);

        ABSBlobClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), ContainerName, SharedKeyAuthorization);
        ABSBlobClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        // Create blob for this test
        Response := ABSBlobClient.PutBlobBlockBlobText(BlobName, BlobContent);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation PutBlobBlockBlob failed');

        // [1st] Acquire Lease on Blob
        Response := ABSBlobClient.AcquireLease(BlobName, 60, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseAcquire failed');
        Assert.IsFalse(IsNullGuid(LeaseId), 'Operation LeaseAcquire failed (no LeaseId returned)');

        // [2nd] Renew Lease on Blob
        Response := ABSBlobClient.RenewLease(BlobName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseRenew failed');

        // This part works when testing against a "real" Azure Storage and not Azurite
        if (AzuriteTestLibrary.GetStorageAccountName() <> 'devstoreaccount1') then begin // "devstoreaccount1" is the hardcoded name for Azurite test-account
            // [3rd] Change Lease on Blob
            ProposedLeaseId := CreateGuid();
            Response := ABSBlobClient.ChangeLease(BlobName, LeaseId, ProposedLeaseId);
            Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseChange failed');
            Assert.IsFalse(IsNullGuid(LeaseId), 'Operation LeaseChange failed (no LeaseId returned)');
        end;

        // [4th] Break Lease on Blob
        Response := ABSBlobClient.BreakLease(BlobName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseBreak failed');

        // [5th] Release Lease on Blob
        Response := ABSBlobClient.ReleaseLease(BlobName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseRelease failed');

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