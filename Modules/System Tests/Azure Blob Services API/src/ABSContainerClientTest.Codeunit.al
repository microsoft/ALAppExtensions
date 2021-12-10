// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132919 "ABS Container Client Test"
{
    Subtype = Test;

    [Test]
    procedure CreateContainerSharedKeyTest()
    var
        Response: Codeunit "ABS Operation Response";
        ContainerName: Text;
    begin
        // [Scenario] CreateContainer contains a container when using Shared Key authorization
        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ContainerName := ABSTestLibrary.GetContainerName();
        Response := ABSContainerClient.CreateContainer(ContainerName);

        Assert.IsTrue(Response.IsSuccessful(), 'Operation CreateContainer failed');

        // Clean-up
        Response := ABSContainerClient.DeleteContainer(ContainerName);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation DeleteContainer failed');
    end;

    [Test]
    procedure CreateContainerFailedTest()
    var
        Response: Codeunit "ABS Operation Response";
        ContainerName: Text;
    begin
        // [Scenario] Cannot create the same container twice
        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ContainerName := ABSTestLibrary.GetContainerName();
        Response := ABSContainerClient.CreateContainer(ContainerName);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation CreateContainer failed');

        Response := ABSContainerClient.CreateContainer(ContainerName);
        Assert.IsFalse(Response.IsSuccessful(), 'Operation CreateContainer should have failed');
        Assert.IsTrue(Response.GetError().Contains('Could not create container ' + ContainerName), 'Wrong error');

        // Clean-up
        Response := ABSContainerClient.DeleteContainer(ContainerName);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation DeleteContainer failed');
    end;

    [Test]
    procedure ListContainersTest()
    var
        Containers: Record "ABS Container";
        Response: Codeunit "ABS Operation Response";
        ContainerNames: List of [Text];
        ContainerName: Text;
    begin
        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ABSTestLibrary.GetListOfContainerNames(ContainerNames);

        foreach ContainerName in ContainerNames do begin
            Response := ABSContainerClient.CreateContainer(ContainerName);
            Assert.IsTrue(Response.IsSuccessful(), 'Operation CreateContainer failed');
        end;

        Response := ABSContainerClient.ListContainers(Containers);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation ListContainers failed');

        Assert.AreEqual(ContainerNames.Count(), Containers.Count(), 'Number of created containers mismatch');

        foreach ContainerName in ContainerNames do
            Assert.IsTrue(Containers.Get(ContainerName), 'Could not find container ' + ContainerName);

        // Clean up
        foreach ContainerName in ContainerNames do begin
            Response := ABSContainerClient.DeleteContainer(ContainerName);
            Assert.IsTrue(Response.IsSuccessful(), 'Operation DeleteContainer failed');
        end;
    end;

    [Test]
    procedure LeaseContainerTest()
    var
        Response: Codeunit "ABS Operation Response";
        ContainerName: Text;
        LeaseId: Guid;
        ProposedLeaseId: Guid;
    begin
        // [Scenarion] Given a storage account and a container name, CreateContainer creates a container and subsequent lease-operations
        // (1) create a lease, (2) renew a lease, [(3) change a lease], (4) break a lease and (5) release the lease        
        SharedKeyAuthorization := StorageServiceAuthorization.CreateSharedKey(AzuriteTestLibrary.GetAccessKey());

        ABSContainerClient.Initialize(AzuriteTestLibrary.GetStorageAccountName(), SharedKeyAuthorization);
        ABSContainerClient.SetBaseUrl(AzuriteTestLibrary.GetBlobStorageBaseUrl());

        ContainerName := ABSTestLibrary.GetContainerName();
        Response := ABSContainerClient.CreateContainer(ContainerName);

        Assert.IsTrue(Response.IsSuccessful(), 'Operation CreateContainer failed');

        // [1st] Acquire Lease on Container
        Response := ABSContainerClient.AcquireLease(ContainerName, 60, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseAcquire failed');
        Assert.IsFalse(IsNullGuid(LeaseId), 'Operation LeaseAcquire failed (no LeaseId returned)');

        // [2nd] Renew Lease on Container
        Response := ABSContainerClient.RenewLease(ContainerName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseRenew failed');

        // This part works when testing against a "real" Azure Storage and not Azurite
        if (AzuriteTestLibrary.GetStorageAccountName() <> 'devstoreaccount1') then begin // "devstoreaccount1" is the hardcoded name for Azurite test-account
            // [3rd] Change Lease on Container
            ProposedLeaseId := CreateGuid();
            Response := ABSContainerClient.ChangeLease(ContainerName, LeaseId, ProposedLeaseId);
            Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseChange failed');
            Assert.IsFalse(IsNullGuid(LeaseId), 'Operation LeaseChange failed (no LeaseId returned)');
        end;

        // [4th] Break Lease on Container
        Response := ABSContainerClient.BreakLease(ContainerName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseBreak failed');

        // [5th] Release Lease on Container
        Response := ABSContainerClient.ReleaseLease(ContainerName, LeaseId);
        Assert.IsTrue(Response.IsSuccessful(), 'Operation LeaseRelease failed');

        // Clean-up
        ABSContainerClient.DeleteContainer(ContainerName);
    end;

    var
        Assert: Codeunit "Library Assert";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSTestLibrary: Codeunit "ABS Test Library";
        AzuriteTestLibrary: Codeunit "Azurite Test Library";
        SharedKeyAuthorization: Interface "Storage Service Authorization";
}