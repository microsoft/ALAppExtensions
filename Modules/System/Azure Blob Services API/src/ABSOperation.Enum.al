// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 9048 "ABS Operation"
{
    Access = Internal;
    Extensible = false;

    value(0; ListContainers)
    {
        Caption = 'List Containers', Locked = true;
    }

    value(1; SetBlobServiceProperties)
    {
        Caption = 'Set Blob Service Properties', Locked = true;
    }

    value(2; GetBlobServiceProperties)
    {
        Caption = 'Get Blob Service Properties', Locked = true;
    }

    value(3; PreflightBlobRequest)
    {
        Caption = 'Preflight Blob Request', Locked = true;
    }

    value(4; GetBlobServiceStats)
    {
        Caption = 'Get Blob Service Stats', Locked = true;
    }

    value(5; GetAccountInformation)
    {
        Caption = 'Get Account Information', Locked = true;
    }

    value(6; GetUserDelegationKey)
    {
        Caption = 'Get User Delegation Key', Locked = true;
    }

    value(20; CreateContainer)
    {
        Caption = 'Create Container', Locked = true;
    }

    value(21; GetContainerProperties)
    {
        Caption = 'Get Container Properties', Locked = true;
    }

    value(22; GetContainerMetadata)
    {
        Caption = 'Get Container Metadata', Locked = true;
    }

    value(23; SetContainerMetadata)
    {
        Caption = 'Set Container Metadata', Locked = true;
    }

    value(24; GetContainerAcl)
    {
        Caption = 'Get Container ACL', Locked = true;
    }

    value(25; SetContainerAcl)
    {
        Caption = 'Set Container ACL', Locked = true;
    }

    value(26; DeleteContainer)
    {
        Caption = 'Delete Container', Locked = true;
    }

    value(27; LeaseContainer)
    {
        Caption = 'Lease Container', Locked = true;
    }

    value(29; ListBlobs)
    {
        Caption = 'List Blobs', Locked = true;
    }

    value(40; PutBlob)
    {
        Caption = 'Upload Blob', Locked = true;
    }

    value(41; PutBlobFromURL)
    {
        Caption = 'Upload Blob', Locked = true;
    }

    value(42; GetBlob)
    {
        Caption = 'Get Blob', Locked = true;
    }

    value(43; GetBlobProperties)
    {
        Caption = 'Get Blob Properties', Locked = true;
    }

    value(44; SetBlobProperties)
    {
        Caption = 'Set Blob Properties', Locked = true;
    }

    value(45; GetBlobMetadata)
    {
        Caption = 'Get Blob Metadata', Locked = true;
    }

    value(46; SetBlobMetadata)
    {
        Caption = 'Set Blob Metadata', Locked = true;
    }

    value(47; GetBlobTags)
    {
        Caption = 'Get Blob Tags', Locked = true;
    }

    value(48; SetBlobTags)
    {
        Caption = 'Set Blob Tags', Locked = true;
    }

    value(49; FindBlobByTags)
    {
        Caption = 'Find Blobs by Tags', Locked = true;
    }

    value(50; LeaseBlob)
    {
        Caption = 'Lease Blob', Locked = true;
    }
    value(51; SnapshotBlob)
    {
        Caption = 'Snapshot Blob', Locked = true;
    }

    value(52; CopyBlob)
    {
        Caption = 'Copy Blob', Locked = true;
    }

    value(53; CopyBlobFromUrl)
    {
        Caption = 'Copy Blob from URL', Locked = true;
    }

    value(54; AbortCopyBlob)
    {
        Caption = 'Abort Copy Blob', Locked = true;
    }

    value(55; DeleteBlob)
    {
        Caption = 'Delete Blob', Locked = true;
    }
    value(56; UndeleteBlob)
    {
        Caption = 'Undelete Blob', Locked = true;
    }

    value(57; SetBlobTier)
    {
        Caption = 'Set Blob Tier', Locked = true;
    }

    value(70; PutBlock)
    {
        Caption = 'Put Block', Locked = true;
    }

    value(71; PutBlockFromURL)
    {
        Caption = 'Put Block from URL', Locked = true;
    }

    value(72; PutBlockList)
    {
        Caption = 'Put Block List', Locked = true;
    }

    value(73; GetBlockList)
    {
        Caption = 'Get Block List', Locked = true;
    }
    value(74; QueryBlobContents)
    {
        Caption = 'Query Blob Contents', Locked = true;
    }

    value(80; PutPage)
    {
        Caption = 'Put Page', Locked = true;
    }

    value(81; PutPageFromURL)
    {
        Caption = 'Put Page from URL', Locked = true;
    }

    value(82; GetPageRanges)
    {
        Caption = 'Get Page Ranges', Locked = true;
    }

    value(83; IncrementalCopyBlob)
    {
        Caption = 'Incremental Copy Blob', Locked = true;
    }

    value(100; AppendBlock)
    {
        Caption = 'Append Block', Locked = true;
    }
    value(101; AppendBlockFromURL)
    {
        Caption = 'Append Block from URL', Locked = true;
    }

    value(120; SetBlobExpiry)
    {
        Caption = 'Set Blob Expiry', Locked = true;
    }
}