codeunit 50108 "AFS URI Helper"
{
    Access = Internal;

    var
        // [NonDebuggable]
        OptionalUriParameters: Dictionary of [Text, Text];
        FileShareBaseUrlLbl: Label 'https://%1.file.core.windows.net', Comment = '%1 = Storage Account Name', Locked = true;

    // [NonDebuggable]
    procedure SetOptionalUriParameter(NewOptionalUriParameters: Dictionary of [Text, Text])
    begin
        OptionalUriParameters := NewOptionalUriParameters;
    end;

    // [NonDebuggable]
    procedure ConstructUri(StorageBaseUrl: Text; StorageAccountName: Text; FileShareName: Text; FilePath: Text; Operation: Enum "AFS Operation"): Text
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        ConstructedUrl: Text;
    begin
        TestConstructUrlParameter(StorageAccountName, FileShareName, FilePath, Operation);

        if StorageBaseUrl = '' then
            StorageBaseUrl := FileShareBaseUrlLbl;

        ConstructedUrl := StrSubstNo(StorageBaseUrl, StorageAccountName);

        AppendFileShareIfNecessary(ConstructedUrl, FileShareName, Operation);
        AppendPathIfNecessary(ConstructedUrl, FilePath, Operation);
        AppendRestTypeIfNecessary(ConstructedUrl, Operation);
        AppendCompValueIfNecessary(ConstructedUrl, Operation);

        AddOptionalUriParameters(ConstructedUrl);

        exit(ConstructedUrl);
    end;

    // [NonDebuggable]
    // procedure ConstructDirectoryUri(StorageBaseUrl: Text; StorageAccountName: Text; FileShareName: Text; FilePath: Text): Text
    // var
    //     AFSFormatHelper: Codeunit "AFS Format Helper";
    //     ConstructedUrl: Text;
    // begin
    //     TestConstructUrlParameter(StorageAccountName, FileShareName);

    //     if StorageBaseUrl = '' then
    //         StorageBaseUrl := FileShareBaseUrlLbl;

    //     ConstructedUrl := StrSubstNo(StorageBaseUrl, StorageAccountName);

    //     AppendFileShare(ConstructedUrl, FileShareName);
    //     AppendPath(ConstructedUrl, FilePath);

    //     exit(ConstructedUrl);
    // end;

    // [NonDebuggable]
    local procedure AppendFileShareIfNecessary(var ConstructedUrl: Text; FileShare: Text; Operation: Enum "AFS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>?restype=container
        if not (Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::GetFile, Operation::ListDirectory, Operation::CreateDirectory, Operation::DeleteDirectory, Operation::CopyFile, Operation::AbortCopyFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::RenameFile, Operation::LeaseFile]) then
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += FileShare;
    end;

    // [NonDebuggable]
    local procedure AppendFileShare(var ConstructedUrl: Text; FileShare: Text)
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>?restype=container
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += FileShare;
    end;

    // [NonDebuggable]
    local procedure AppendPathIfNecessary(var ConstructedUrl: Text; Path: Text; Operation: Enum "AFS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>/<Path>
        if not (Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::GetFile, Operation::ListDirectory, Operation::CreateDirectory, Operation::DeleteDirectory, Operation::CopyFile, Operation::AbortCopyFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::RenameFile, Operation::LeaseFile]) then
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += Path;
    end;

    // [NonDebuggable]
    local procedure AppendPath(var ConstructedUrl: Text; Path: Text)
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>/<Path>
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += Path;
    end;

    // [NonDebuggable]
    local procedure AppendRestTypeIfNecessary(var ConstructedUrl: Text; Operation: Enum "AFS Operation")
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        RestType: Text;
        RestTypeLbl: Label 'restype', Locked = true;
        DirectoryRestTypeLbl: Label 'directory', Locked = true;
        ServiceRestTypeLbl: Label 'service', Locked = true;
        AccountRestTypeLbl: Label 'account', Locked = true;
        ShareRestTypeLbl: Label 'share', Locked = true;
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/?restype=account&comp=properties
        case Operation of
            Operation::CreateDirectory, Operation::ListDirectory, Operation::DeleteDirectory:
                RestType := DirectoryRestTypeLbl;
        // Operation::GetAccountInformation:
        //     RestType := AccountRestTypeLbl;
        // Operation::GetBlobServiceProperties, Operation::SetBlobServiceProperties, Operation::GetBlobServiceStats:
        //     RestType := ServiceRestTypeLbl;
        // Operation::GetUserDelegationKey:
        //     RestType := ServiceRestTypeLbl;
        end;
        if RestType = '' then
            exit;
        AFSFormatHelper.AppendToUri(ConstructedUrl, RestTypeLbl, RestType);
    end;

    // [NonDebuggable]
    local procedure AppendCompValueIfNecessary(var ConstructedUrl: Text; Operation: Enum "AFS Operation")
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        CompValue: Text;
        CompIdentifierLbl: Label 'comp', Locked = true;
        ListExtensionLbl: Label 'list', Locked = true;
        ListHandlesExtensionLbl: Label 'listhandles', Locked = true;
        RenameExtensionLbl: Label 'rename', Locked = true;
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
        RangeExtensionLbl: Label 'range', Locked = true;
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/?restype=account&comp=properties
        case Operation of
            Operation::PutRange, Operation::PutRangefromURL:
                CompValue := RangeExtensionLbl;
            Operation::ListDirectory:
                CompValue := ListExtensionLbl;
            Operation::AbortCopyFile:
                CompValue := CopyExtensionLbl;
            Operation::ListFileHandles, Operation::ListDirectoryHandles:
                CompValue := ListHandlesExtensionLbl;
            Operation::RenameFile:
                CompValue := RenameExtensionLbl;
            Operation::LeaseFile:
                CompValue := LeaseExtensionLbl;
        // Operation::ListContainers, Operation::ListBlobs:
        //     CompValue := ListExtensionLbl;
        // Operation::LeaseContainer, Operation::LeaseBlob:
        //     CompValue := LeaseExtensionLbl;
        // Operation::AbortCopyBlob:
        //     CompValue := CopyExtensionLbl;
        // Operation::GetAccountInformation, Operation::GetBlobServiceProperties, Operation::SetBlobServiceProperties, Operation::SetBlobProperties:
        //     CompValue := PropertiesExtensionLbl;
        // Operation::GetContainerMetadata, Operation::SetContainerMetadata, Operation::GetBlobMetadata, Operation::SetBlobMetadata:
        //     CompValue := MetadataExtensionLbl;
        // Operation::GetContainerAcl, Operation::SetContainerAcl:
        //     CompValue := AclExtensionLbl;
        // Operation::GetBlobServiceStats:
        //     CompValue := StatsExtensionLbl;
        // Operation::GetBlobTags, Operation::SetBlobTags:
        //     CompValue := TagsExtensionLbl;
        // Operation::FindBlobByTags:
        //     CompValue := BlobsExtensionLbl;
        // Operation::SetBlobExpiry:
        //     CompValue := ExpiryExtensionLbl;
        // Operation::SnapshotBlob:
        //     CompValue := SnapshotExtensionLbl;
        // Operation::UndeleteBlob:
        //     CompValue := UndeleteExtensionLbl;
        // Operation::AppendBlock:
        //     CompValue := AppendBlockExtensionLbl;
        // Operation::SetBlobTier:
        //     CompValue := TierExtensionLbl;
        // Operation::PutPage, Operation::PutPageFromURL:
        //     CompValue := PageExtensionLbl;
        // Operation::GetPageRanges:
        //     CompValue := PageListExtensionLbl;
        // Operation::IncrementalCopyBlob:
        //     CompValue := IncrementalCopyExtensionLbl;
        // Operation::PutBlock, Operation::PutBlockFromURL:
        //     CompValue := BlockExtensionLbl;
        // Operation::GetBlockList, Operation::PutBlockList:
        //     CompValue := BlockListExtensionLbl;
        // Operation::GetUserDelegationKey:
        //     CompValue := UserDelegationKeyExtensionLbl;
        // Operation::AppendBlockFromURL:
        //     CompValue := AppendBlockExtensionLbl;
        // Operation::QueryBlobContents:
        //     CompValue := QueryExtensionLbl;
        end;
        if CompValue = '' then
            exit;
        AFSFormatHelper.AppendToUri(ConstructedUrl, CompIdentifierLbl, CompValue);
    end;

    // [NonDebuggable]
    local procedure RetrieveFromOptionalUriParameters(Identifier: Text): Text
    var
        ReturnValue: Text;
    begin
        if not OptionalUriParameters.ContainsKey(Identifier) then
            exit;

        OptionalUriParameters.Get(Identifier, ReturnValue);
        exit(ReturnValue);
    end;

    // [NonDebuggable]
    local procedure AddOptionalUriParameters(var Uri: Text)
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        ParameterIdentifier: Text;
        ParameterValue: Text;
    begin
        if OptionalUriParameters.Count = 0 then
            exit;

        foreach ParameterIdentifier in OptionalUriParameters.Keys do
            if not (ParameterIdentifier in ['copyid', 'blockid']) then begin
                OptionalUriParameters.Get(ParameterIdentifier, ParameterValue);
                AFSFormatHelper.AppendToUri(Uri, ParameterIdentifier, ParameterValue);
            end;
    end;

    // [NonDebuggable]
    local procedure TestConstructUrlParameter(StorageAccountName: Text; FileShareName: Text; Path: Text; Operation: Enum "AFS Operation")
    var
        ValueCanNotBeEmptyErr: Label '%1 can not be empty', Comment = '%1 = Variable Name';
        StorageAccountNameLbl: Label 'Storage Account Name';
        FileShareLbl: Label 'File Share Name';
        PathLbl: Label 'Path';
    begin
        if StorageAccountName = '' then
            Error(ValueCanNotBeEmptyErr, StorageAccountNameLbl);

        case true of
            Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::CreateDirectory, Operation::CopyFile, Operation::RenameFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::LeaseFile]:
                begin
                    if FileShareName = '' then
                        Error(ValueCanNotBeEmptyErr, FileShareLbl);
                    if Path = '' then
                        Error(ValueCanNotBeEmptyErr, PathLbl);
                end;
            Operation in [Operation::ListDirectory]:
                begin
                    if FileShareName = '' then
                        Error(ValueCanNotBeEmptyErr, FileShareLbl);
                end;
        end;
    end;

    // [NonDebuggable]
    local procedure TestConstructUrlParameter(StorageAccountName: Text; FileShareName: Text)
    var
        ValueCanNotBeEmptyErr: Label '%1 can not be empty', Comment = '%1 = Variable Name';
        StorageAccountNameLbl: Label 'Storage Account Name';
        FileShareLbl: Label 'File Share Name';
    begin
        if StorageAccountName = '' then
            Error(ValueCanNotBeEmptyErr, StorageAccountNameLbl);

        if FileShareName = '' then
            Error(ValueCanNotBeEmptyErr, FileShareLbl);
    end;
    // #endregion Uri generation
}