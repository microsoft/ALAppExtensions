// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132919 "ABS Container Client Test"
{
    Subtype = Test;

    //[Test]
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

    //[Test]
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

    //[Test]
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

    var
        Assert: Codeunit "Library Assert";
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSTestLibrary: Codeunit "ABS Test Library";
        AzuriteTestLibrary: Codeunit "Azurite Test Library";
        SharedKeyAuthorization: Interface "Storage Service Authorization";
}