// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides common authorization functionality for using Azure storage accounts in tests for Azure Storage Services.
/// </summary>
codeunit 132516 "Azure Test Library"
{
    Access = Internal;

    var
        AFSTestLibrary: Codeunit "AFS Test Library";
        FileShareNameTxt: Label 'filesharename', Locked = true;
        StorageAccountNameTxt: Label 'storageaccountname', Locked = true;
        AccessKeyTxt: Label 'base64accountkey', Locked = true;

    procedure ClearFileShare(): Text
    var
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSFileClient: Codeunit "AFS File Client";
        Visited: List of [Text];
    begin
        AFSFileClient.Initialize(GetStorageAccountName(), GetFileShareName(), AFSTestLibrary.GetDefaultAccountSAS());
        AFSFileClient.ListDirectory('', AFSDirectoryContent);
        if not AFSDirectoryContent.FindSet() then
            exit;
        DeleteDirectoryRecursive(AFSFileClient, AFSDirectoryContent, Visited);
    end;

    local procedure DeleteDirectoryRecursive(var AFSFileClient: Codeunit "AFS File Client"; var AFSDirectoryContent: Record "AFS Directory Content"; var Visited: List of [Text])
    var
        AFSDirectoryContentLocal: Record "AFS Directory Content";
    begin
        if not AFSDirectoryContent.FindSet() then
            exit;
        repeat
            if not Visited.Contains(AFSDirectoryContent."Full Name") then
                if AFSDirectoryContent."Resource Type" = AFSDirectoryContent."Resource Type"::File then
                    AFSFileClient.DeleteFile(AFSDirectoryContent."Full Name")
                else begin
                    AFSFileClient.ListDirectory(AFSDirectoryContent."Full Name", AFSDirectoryContentLocal);
                    Visited.Add(AFSDirectoryContent."Full Name");
                    DeleteDirectoryRecursive(AFSFileClient, AFSDirectoryContentLocal, Visited);
                    AFSFileClient.DeleteDirectory(AFSDirectoryContent."Full Name");
                    Visited.Remove(AFSDirectoryContent."Full Name");
                end;
        until AFSDirectoryContent.Next() = 0;
    end;

    /// <summary>
    /// Gets storage account name.
    /// </summary>
    /// <returns>Storage account name</returns>
    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountNameTxt);
    end;

    /// <summary>
    /// Gets file share name.
    /// </summary>
    /// <returns>File share name</returns>
    procedure GetFileShareName(): Text
    begin
        exit(FileShareNameTxt);
    end;

    /// <summary>
    /// Gets storage account key.
    /// </summary>
    /// <returns>Storage account key</returns>
    procedure GetAccessKey(): Text;
    begin
        exit(AccessKeyTxt);
    end;
}