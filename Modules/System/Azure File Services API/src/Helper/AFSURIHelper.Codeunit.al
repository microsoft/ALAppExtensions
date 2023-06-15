// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8957 "AFS URI Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        OptionalUriParameters: Dictionary of [Text, Text];
        FileShareBaseUrlLbl: Label 'https://%1.file.core.windows.net', Comment = '%1 = Storage Account Name', Locked = true;

    [NonDebuggable]
    procedure SetOptionalUriParameter(NewOptionalUriParameters: Dictionary of [Text, Text])
    begin
        OptionalUriParameters := NewOptionalUriParameters;
    end;

    [NonDebuggable]
    procedure ConstructUri(StorageBaseUrl: Text; StorageAccountName: Text; FileShareName: Text; FilePath: Text; Operation: Enum "AFS Operation"): Text
    var
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

    [NonDebuggable]
    local procedure AppendFileShareIfNecessary(var ConstructedUrl: Text; FileShare: Text; Operation: Enum "AFS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>?restype=container
        if not (Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::GetFile, Operation::ListDirectory, Operation::CreateDirectory, Operation::DeleteDirectory, Operation::CopyFile, Operation::AbortCopyFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::RenameFile, Operation::LeaseFile, Operation::GetFileMetadata, Operation::SetFileMetadata]) then
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += FileShare;
    end;

    [NonDebuggable]
    local procedure AppendPathIfNecessary(var ConstructedUrl: Text; Path: Text; Operation: Enum "AFS Operation")
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/<FileShare>/<Path>
        if not (Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::GetFile, Operation::ListDirectory, Operation::CreateDirectory, Operation::DeleteDirectory, Operation::CopyFile, Operation::AbortCopyFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::RenameFile, Operation::LeaseFile, Operation::GetFileMetadata, Operation::SetFileMetadata]) then
            exit;
        if not ConstructedUrl.EndsWith('/') then
            ConstructedUrl += '/';
        ConstructedUrl += Path;
    end;

    [NonDebuggable]
    local procedure AppendRestTypeIfNecessary(var ConstructedUrl: Text; Operation: Enum "AFS Operation")
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        RestType: Text;
        RestTypeLbl: Label 'restype', Locked = true;
        DirectoryRestTypeLbl: Label 'directory', Locked = true;
    begin
        // e.g. https://<StorageAccountName>.blob.core.windows.net/?restype=account&comp=properties
        case Operation of
            Operation::CreateDirectory, Operation::ListDirectory, Operation::DeleteDirectory:
                RestType := DirectoryRestTypeLbl;
        end;
        if RestType = '' then
            exit;
        AFSFormatHelper.AppendToUri(ConstructedUrl, RestTypeLbl, RestType);
    end;

    [NonDebuggable]
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
        RangeExtensionLbl: Label 'range', Locked = true;
        MetadataExtensionLbl: Label 'metadata', Locked = true;
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
            Operation::GetFileMetadata, Operation::SetFileMetadata:
                CompValue := MetadataExtensionLbl;
        end;
        if CompValue = '' then
            exit;
        AFSFormatHelper.AppendToUri(ConstructedUrl, CompIdentifierLbl, CompValue);
    end;

    [NonDebuggable]
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

    [NonDebuggable]
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
            Operation in [Operation::CreateFile, Operation::PutRange, Operation::DeleteFile, Operation::CreateDirectory, Operation::CopyFile, Operation::RenameFile, Operation::ListFileHandles, Operation::ListDirectoryHandles, Operation::LeaseFile, Operation::GetFileMetadata, Operation::SetFileMetadata]:
                begin
                    if FileShareName = '' then
                        Error(ValueCanNotBeEmptyErr, FileShareLbl);
                    if Path = '' then
                        Error(ValueCanNotBeEmptyErr, PathLbl);
                end;
            Operation in [Operation::ListDirectory]:
                if FileShareName = '' then
                    Error(ValueCanNotBeEmptyErr, FileShareLbl);
        end;
    end;
}