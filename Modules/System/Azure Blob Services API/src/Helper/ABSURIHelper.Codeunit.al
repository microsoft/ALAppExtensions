// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9046 "ABS URI Helper"
{
    Access = Internal;

    var
        [NonDebuggable]
        OptionalUriParameters: Dictionary of [Text, Text];
        BlobStorageBaseUrlLbl: Label 'https://%1.blob.core.windows.net', Comment = '%1 = Storage Account Name', Locked = true;

    [NonDebuggable]
    procedure SetOptionalUriParameter(NewOptionalUriParameters: Dictionary of [Text, Text])
    begin
        OptionalUriParameters := NewOptionalUriParameters;
    end;

    [NonDebuggable]
    procedure ConstructUri(StorageBaseUrl: Text; StorageAccountName: Text; ContainerName: Text; BlobName: Text; Operation: Enum "ABS Operation"): Text
    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        ConstructedUrl: Text;
    begin
        TestConstructUrlParameter(StorageAccountName, ContainerName, BlobName, Operation);

        // e.g. https://<StorageAccountName>-secondary.blob.core.windows.net/?restype=service&comp=stats
        if Operation = Operation::GetBlobServiceStats then
            StorageAccountName := StorageAccountName + '-secondary';

        if StorageBaseUrl = '' then
            StorageBaseUrl := BlobStorageBaseUrlLbl;

        ConstructedUrl := StrSubstNo(StorageBaseUrl, StorageAccountName);

        AppendContainerIfNecessary(ConstructedUrl, ContainerName, Operation);
        AppendBlobIfNecessary(ConstructedUrl, BlobName, Operation);
        AppendRestTypeIfNecessary(ConstructedUrl, Operation);
        AppendCompValueIfNecessary(ConstructedUrl, Operation);

        // e.g. https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>?comp=copy&coppyid=<Id>
        if Operation = Operation::AbortCopyBlob then
            ABSFormatHelper.AppendToUri(ConstructedUrl, 'copyid', RetrieveFromOptionalUriParameters('copyid'));

        if Operation in [Operation::Putblock, Operation::PutBlockFromURL] then
            ABSFormatHelper.AppendToUri(ConstructedUrl, 'blockid', RetrieveFromOptionalUriParameters('blockid'));

        AddOptionalUriParameters(ConstructedUrl);

        exit(ConstructedUrl);
    end;

    [NonDebuggable]
    local procedure AppendContainerIfNecessary(var ConstructedUrl: Text; ContainerName: Text; Operation: Enum "ABS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<ContainerName>?restype=container
        if not (Operation in [Operation::DeleteContainer, Operation::ListBlobs, Operation::CreateContainer,
                              Operation::GetContainerProperties, Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob,
                              Operation::CopyBlob, Operation::CopyBlobFromUrl, Operation::LeaseContainer, Operation::LeaseBlob, Operation::AbortCopyBlob,
                              Operation::GetBlobProperties, Operation::SetBlobProperties, Operation::GetContainerMetadata, Operation::SetContainerMetadata,
                              Operation::GetBlobMetadata, Operation::SetBlobMetadata, Operation::GetContainerAcl, Operation::SetContainerAcl,
                              Operation::GetBlobTags, Operation::SetBlobTags, Operation::SetBlobExpiry, Operation::SnapshotBlob,
                              Operation::UndeleteBlob, Operation::AppendBlock, Operation::AppendBlockFromURL, Operation::SetBlobTier, Operation::PutPage, Operation::PutPageFromURL, Operation::GetPageRanges, Operation::IncrementalCopyBlob,
                              Operation::PutBlock, Operation::PutBlockFromURL, Operation::PutBlockList, Operation::GetBlockList, Operation::PreflightBlobRequest, Operation::QueryBlobContents]) then
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += ContainerName;
    end;

    [NonDebuggable]
    local procedure AppendBlobIfNecessary(var ConstructedUrl: Text; BlobName: Text; Operation: Enum "ABS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>
        if not (Operation in [Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob, Operation::CopyBlob, Operation::CopyBlobFromUrl, Operation::LeaseBlob,
                              Operation::AbortCopyBlob, Operation::GetBlobProperties, Operation::SetBlobProperties, Operation::GetBlobMetadata,
                              Operation::SetBlobMetadata, Operation::GetBlobTags, Operation::SetBlobTags, Operation::SetBlobExpiry, Operation::SnapshotBlob,
                              Operation::UndeleteBlob, Operation::AppendBlock, Operation::AppendBlockFromURL, Operation::SetBlobTier, Operation::PutPage, Operation::PutPageFromURL, Operation::GetPageRanges, Operation::IncrementalCopyBlob,
                              Operation::PutBlock, Operation::PutBlockFromURL, Operation::PutBlockList, Operation::GetBlockList, Operation::PreflightBlobRequest, Operation::QueryBlobContents]) then
            exit;
        if (Operation = Operation::PreflightBlobRequest) and (BlobName = '') then // Blob is not mandatory for Operation::PreflightBlobRequest, so only proceed if given
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += BlobName;
    end;

    [NonDebuggable]
    local procedure AppendRestTypeIfNecessary(var ConstructedUrl: Text; Operation: Enum "ABS Operation")
    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        RestType: Text;
        RestTypeLbl: Label 'restype';
        ContainerRestTypeLbl: Label 'container', Locked = true;
        ServiceRestTypeLbl: Label 'service', Locked = true;
        AccountRestTypeLbl: Label 'account', Locked = true;
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/?restype=account&comp=properties
        case Operation of
            Operation::LeaseContainer, Operation::CreateContainer, Operation::GetContainerProperties, Operation::ListBlobs,
            Operation::DeleteContainer, Operation::ListContainers, Operation::GetContainerMetadata, Operation::SetContainerMetadata,
            Operation::GetContainerAcl, Operation::SetContainerAcl:
                RestType := ContainerRestTypeLbl;
            Operation::GetAccountInformation:
                RestType := AccountRestTypeLbl;
            Operation::GetBlobServiceProperties, Operation::SetBlobServiceProperties, Operation::GetBlobServiceStats:
                RestType := ServiceRestTypeLbl;
            Operation::GetUserDelegationKey:
                RestType := ServiceRestTypeLbl;
        end;
        if RestType = '' then
            exit;
        ABSFormatHelper.AppendToUri(ConstructedUrl, RestTypeLbl, RestType);
    end;

    [NonDebuggable]
    local procedure AppendCompValueIfNecessary(var ConstructedUrl: Text; Operation: Enum "ABS Operation")
    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        CompValue: Text;
        CompIdentifierLbl: Label 'comp', Locked = true;
        ListExtensionLbl: Label 'list', Locked = true;
        LeaseExtensionLbl: Label 'lease', Locked = true;
        CopyExtensionLbl: Label 'copy', Locked = true;
        PropertiesExtensionLbl: Label 'properties', Locked = true;
        MetadataExtensionLbl: Label 'metadata', Locked = true;
        AclExtensionLbl: Label 'acl', Locked = true;
        StatsExtensionLbl: Label 'stats', Locked = true;
        TagsExtensionLbl: Label 'tags', Locked = true;
        BlobsExtensionLbl: Label 'blobs', Locked = true;
        ExpiryExtensionLbl: Label 'expiry', Locked = true;
        SnapshotExtensionLbl: Label 'snapshot', Locked = true;
        UndeleteExtensionLbl: Label 'undelete', Locked = true;
        AppendBlockExtensionLbl: Label 'appendblock', Locked = true;
        TierExtensionLbl: Label 'tier', Locked = true;
        PageExtensionLbl: Label 'page', Locked = true;
        PageListExtensionLbl: Label 'pagelist', Locked = true;
        IncrementalCopyExtensionLbl: Label 'incrementalcopy', Locked = true;
        BlockExtensionLbl: Label 'block', Locked = true;
        BlockListExtensionLbl: Label 'blocklist', Locked = true;
        UserDelegationKeyExtensionLbl: Label 'userdelegationkey', Locked = true;
        QueryExtensionLbl: Label 'query', Locked = true;
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/?restype=account&comp=properties
        case Operation of
            Operation::ListContainers, Operation::ListBlobs:
                CompValue := ListExtensionLbl;
            Operation::LeaseContainer, Operation::LeaseBlob:
                CompValue := LeaseExtensionLbl;
            Operation::AbortCopyBlob:
                CompValue := CopyExtensionLbl;
            Operation::GetAccountInformation, Operation::GetBlobServiceProperties, Operation::SetBlobServiceProperties, Operation::SetBlobProperties:
                CompValue := PropertiesExtensionLbl;
            Operation::GetContainerMetadata, Operation::SetContainerMetadata, Operation::GetBlobMetadata, Operation::SetBlobMetadata:
                CompValue := MetadataExtensionLbl;
            Operation::GetContainerAcl, Operation::SetContainerAcl:
                CompValue := AclExtensionLbl;
            Operation::GetBlobServiceStats:
                CompValue := StatsExtensionLbl;
            Operation::GetBlobTags, Operation::SetBlobTags:
                CompValue := TagsExtensionLbl;
            Operation::FindBlobByTags:
                CompValue := BlobsExtensionLbl;
            Operation::SetBlobExpiry:
                CompValue := ExpiryExtensionLbl;
            Operation::SnapshotBlob:
                CompValue := SnapshotExtensionLbl;
            Operation::UndeleteBlob:
                CompValue := UndeleteExtensionLbl;
            Operation::AppendBlock:
                CompValue := AppendBlockExtensionLbl;
            Operation::SetBlobTier:
                CompValue := TierExtensionLbl;
            Operation::PutPage, Operation::PutPageFromURL:
                CompValue := PageExtensionLbl;
            Operation::GetPageRanges:
                CompValue := PageListExtensionLbl;
            Operation::IncrementalCopyBlob:
                CompValue := IncrementalCopyExtensionLbl;
            Operation::PutBlock, Operation::PutBlockFromURL:
                CompValue := BlockExtensionLbl;
            Operation::GetBlockList, Operation::PutBlockList:
                CompValue := BlockListExtensionLbl;
            Operation::GetUserDelegationKey:
                CompValue := UserDelegationKeyExtensionLbl;
            Operation::AppendBlockFromURL:
                CompValue := AppendBlockExtensionLbl;
            Operation::QueryBlobContents:
                CompValue := QueryExtensionLbl;
        end;
        if CompValue = '' then
            exit;
        ABSFormatHelper.AppendToUri(ConstructedUrl, CompIdentifierLbl, CompValue);
    end;

    [NonDebuggable]
    local procedure RetrieveFromOptionalUriParameters(Identifier: Text): Text
    var
        ReturnValue: Text;
    begin
        if not OptionalUriParameters.ContainsKey(Identifier) then
            exit;

        OptionalUriParameters.Get(Identifier, ReturnValue);
        exit(ReturnValue);
    end;

    [NonDebuggable]
    local procedure AddOptionalUriParameters(var Uri: Text)
    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        ParameterIdentifier: Text;
        ParameterValue: Text;
    begin
        if OptionalUriParameters.Count = 0 then
            exit;

        foreach ParameterIdentifier in OptionalUriParameters.Keys do
            if not (ParameterIdentifier in ['copyid', 'blockid']) then begin
                OptionalUriParameters.Get(ParameterIdentifier, ParameterValue);
                ABSFormatHelper.AppendToUri(Uri, ParameterIdentifier, ParameterValue);
            end;
    end;

    [NonDebuggable]
    local procedure TestConstructUrlParameter(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Operation: Enum "ABS Operation")
    var
        ValueCanNotBeEmptyErr: Label '%1 can not be empty', Comment = '%1 = Variable Name';
        StorageAccountNameLbl: Label 'Storage Account Name';
        ContainerNameLbl: Label 'Container Name';
        BlobNameLbl: Label 'Blob Name';
    begin
        if StorageAccountName = '' then
            Error(ValueCanNotBeEmptyErr, StorageAccountNameLbl);

        case true of
            Operation in [Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob]:
                begin
                    if ContainerName = '' then
                        Error(ValueCanNotBeEmptyErr, ContainerNameLbl);
                    if BlobName = '' then
                        Error(ValueCanNotBeEmptyErr, BlobNameLbl);
                end;
        end;
    end;
    // #endregion Uri generation
}