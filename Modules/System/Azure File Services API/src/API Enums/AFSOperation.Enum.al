// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines possible operations to the azure file share API.
/// Operations are divided into operations on:
/// - file (https://learn.microsoft.com/en-us/rest/api/storageservices/operations-on-files)
/// - directory (https://learn.microsoft.com/en-us/rest/api/storageservices/operations-on-directories)
/// - file share (https://learn.microsoft.com/en-us/rest/api/storageservices/operations-on-shares--file-service-)
/// - file service (https://learn.microsoft.com/en-us/rest/api/storageservices/operations-on-the-account--file-service-)
/// </summary>
enum 8950 "AFS Operation"
{
    Access = Internal;
    Extensible = false;

    value(0; GetFileServiceProperties)
    {
        Caption = 'Get File Service Properties', Locked = true;
    }
    value(1; SetFileServiceProperties)
    {
        Caption = 'Set File Service Properties', Locked = true;
    }
    value(2; PreflightFileRequest)
    {
        Caption = 'Preflight File Request', Locked = true;
    }
    value(20; ListShares)
    {
        Caption = 'List Shares', Locked = true;
    }
    value(21; CreateShare)
    {
        Caption = 'Create Share', Locked = true;
    }
    value(22; SnapshotShare)
    {
        Caption = 'Snapshot Share', Locked = true;
    }
    value(23; GetShareProperties)
    {
        Caption = 'Get Share Properties', Locked = true;
    }
    value(24; SetShareProperties)
    {
        Caption = 'Set Share Properties', Locked = true;
    }
    value(25; GetShareMetadata)
    {
        Caption = 'Get Share Metadata', Locked = true;
    }
    value(26; SetShareMetadata)
    {
        Caption = 'Set Share Metadata', Locked = true;
    }
    value(27; DeleteShare)
    {
        Caption = 'Delete Share', Locked = true;
    }
    value(28; RestoreShare)
    {
        Caption = 'Restore Share', Locked = true;
    }
    value(29; GetShareACL)
    {
        Caption = 'Get Share ACL', Locked = true;
    }
    value(30; SetShareACL)
    {
        Caption = 'Set Share ACL', Locked = true;
    }
    value(31; GetShareStats)
    {
        Caption = 'Get Share Stats', Locked = true;
    }
    value(32; CreatePermission)
    {
        Caption = 'Create Permission', Locked = true;
    }
    value(33; GetPermission)
    {
        Caption = 'Get Permission', Locked = true;
    }
    value(34; LeaseShare)
    {
        Caption = 'Lease Share', Locked = true;
    }
    value(40; ListDirectory)
    {
        Caption = 'List Directory', Locked = true;
    }
    value(41; CreateDirectory)
    {
        Caption = 'Create Directory', Locked = true;
    }
    value(42; GetDirectoryProperties)
    {
        Caption = 'Get Directory Properties', Locked = true;
    }
    value(43; SetDirectoryProperties)
    {
        Caption = 'Set Directory Properties', Locked = true;
    }
    value(44; DeleteDirectory)
    {
        Caption = 'Delete Directory', Locked = true;
    }
    value(45; GetDirectoryMetadata)
    {
        Caption = 'Get Directory Metadata', Locked = true;
    }
    value(46; SetDirectoryMetadata)
    {
        Caption = 'Set Directory Metadata', Locked = true;
    }
    value(47; ListDirectoryHandles)
    {
        Caption = 'List Directory Handles', Locked = true;
    }
    value(48; ForceCloseDirectoryHandles)
    {
        Caption = 'Force Close Directory Handles', Locked = true;
    }
    value(49; RenameDirectory)
    {
        Caption = 'Rename Directory', Locked = true;
    }
    value(60; CreateFile)
    {
        Caption = 'Create File', Locked = true;
    }
    value(61; GetFile)
    {
        Caption = 'Get File', Locked = true;
    }
    value(62; GetFileProperties)
    {
        Caption = 'Get File Properties', Locked = true;
    }
    value(63; SetFileProperties)
    {
        Caption = 'Set File Properties', Locked = true;
    }
    value(64; PutRange)
    {
        Caption = 'Put Range', Locked = true;
    }
    value(65; PutRangefromURL)
    {
        Caption = 'Put Rangefrom URL', Locked = true;
    }
    value(66; ListRanges)
    {
        Caption = 'List Ranges', Locked = true;
    }
    value(67; GetFileMetadata)
    {
        Caption = 'Get File Metadata', Locked = true;
    }
    value(68; SetFileMetadata)
    {
        Caption = 'Set File Metadata', Locked = true;
    }
    value(69; DeleteFile)
    {
        Caption = 'Delete File', Locked = true;
    }
    value(71; CopyFile)
    {
        Caption = 'Copy File', Locked = true;
    }
    value(72; AbortCopyFile)
    {
        Caption = 'Abort Copy File', Locked = true;
    }
    value(73; ListFileHandles)
    {
        Caption = 'List File Handles', Locked = true;
    }
    value(74; ForceCloseFileHandles)
    {
        Caption = 'Force Close File Handles', Locked = true;
    }
    value(75; LeaseFile)
    {
        Caption = 'Lease File', Locked = true;
    }
    value(76; RenameFile)
    {
        Caption = 'Rename File', Locked = true;
    }
}