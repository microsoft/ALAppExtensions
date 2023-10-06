// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8951 "AFS File Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AFSOperationPayload: Codeunit "AFS Operation Payload";
        AFSHttpContentHelper: Codeunit "AFS HttpContent Helper";
        AFSWebRequestHelper: Codeunit "AFS Web Request Helper";
        AFSFormatHelper: Codeunit "AFS Format Helper";
        CreateFileOperationNotSuccessfulErr: Label 'Could not create file %1 in %2.', Comment = '%1 = File Name; %2 = File Share Name';
        PutFileOperationNotSuccessfulErr: Label 'Could not put file %1 ranges in %2.', Comment = '%1 = File Name; %2 = File Share Name';
        CreateDirectoryOperationNotSuccessfulErr: Label 'Could not create directory %1 in %2.', Comment = '%1 = Directory Name; %2 = File Share Name';
        GetFileOperationNotSuccessfulErr: Label 'Could not get File %1.', Comment = '%1 = File Path';
        GetFileMetadataOperationNotSuccessfulErr: Label 'Could not get File %1 metadata.', Comment = '%1 = File Path';
        SetFileMetadataOperationNotSuccessfulErr: Label 'Could not set File %1 metadata.', Comment = '%1 = File Path';
        CopyFileOperationNotSuccessfulErr: Label 'Could not copy File %1.', Comment = '%1 = File Path';
        DeleteFileOperationNotSuccessfulErr: Label 'Could not %3 File %1 in file share %2.', Comment = '%1 = File Name; %2 = File Share Name, %3 = Delete/Undelete';
        DeleteDirectoryOperationNotSuccessfulErr: Label 'Could not delete directory %1 in file share %2.', Comment = '%1 = File Name; %2 = File Share Name';
        AbortCopyFileOperationNotSuccessfulErr: Label 'Could not abort copy of File %1.', Comment = '%1 = File Path';
        LeaseOperationNotSuccessfulErr: Label 'Could not %1 lease for %2 %3.', Comment = '%1 = Lease Action, %2 = Type (File or Share), %3 = Name';
        ListDirectoryOperationNotSuccessfulErr: Label 'Could not list directory %1 in file share %2.', Comment = '%1 = Directory Name; %2 = File Share Name';
        ListHandlesOperationNotSuccessfulErr: Label 'Could not list handles of %1 in file share %2.', Comment = '%1 = Path; %2 = File Share Name';
        RenameFileOperationNotSuccessfulErr: Label 'Could not rename file %1 to %2 on file share %3.', Comment = '%1 = Source Path; %2 = Destination Path; %3 = File Share Name';
        ParameterMissingErr: Label 'You need to specify %1 (%2)', Comment = '%1 = Parameter Name, %2 = Header Identifer';
        LeaseAcquireLbl: Label 'acquire';
        LeaseBreakLbl: Label 'break';
        LeaseChangeLbl: Label 'change';
        LeaseReleaseLbl: Label 'release';
        FileLbl: Label 'File';

    [NonDebuggable]
    procedure Initialize(StorageAccountName: Text; FileShare: Text; Path: Text; Authorization: Interface "Storage Service Authorization"; ApiVersion: Enum "Storage Service API Version")
    begin
        AFSOperationPayload.Initialize(StorageAccountName, FileShare, Path, Authorization, ApiVersion);
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        AFSOperationPayload.SetBaseUrl(BaseUrl);
    end;

    procedure CreateDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::CreateDirectory);
        AFSOperationPayload.SetPath(DirectoryPath);
        AFSOperationPayload.AddRequestHeader('x-ms-file-attributes', 'Directory');
        AFSOperationPayload.AddRequestHeader('x-ms-file-creation-time', 'now');
        AFSOperationPayload.AddRequestHeader('x-ms-file-last-write-time', 'now');
        AFSOperationPayload.AddRequestHeader('x-ms-file-permission', 'inherit');
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(CreateDirectoryOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));
        exit(AFSOperationResponse);
    end;

    procedure DeleteDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::DeleteDirectory);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(DirectoryPath);

        AFSOperationResponse := AFSWebRequestHelper.DeleteOperation(AFSOperationPayload, StrSubstNo(DeleteDirectoryOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));

        exit(AFSOperationResponse);
    end;

    procedure ListDirectory(DirectoryPath: Text[2048]; var AFSDirectoryContent: Record "AFS Directory Content"; PreserveDirectoryContent: Boolean; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSHelperLibrary: Codeunit "AFS Helper Library";
        AFSOperation: Enum "AFS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
        DirectoryURI: Text;
    begin
        AFSOperationPayload.SetOperation(AFSOperation::ListDirectory);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(DirectoryPath);

        AFSOperationResponse := AFSWebRequestHelper.GetOperationAsText(AFSOperationPayload, ResponseText, StrSubstNo(ListDirectoryOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));

        NodeList := AFSHelperLibrary.CreateDirectoryContentNodeListFromResponse(ResponseText);
        DirectoryURI := AFSHelperLibrary.GetDirectoryPathFromResponse(ResponseText);

        AFSHelperLibrary.DirectoryContentNodeListToTempRecord(DirectoryURI, DirectoryPath, NodeList, PreserveDirectoryContent, AFSDirectoryContent);

        exit(AFSOperationResponse);
    end;

    procedure ListFileHandles(Path: Text; var AFSHandle: Record "AFS Handle"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSHelperLibrary: Codeunit "AFS Helper Library";
        AFSOperation: Enum "AFS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        AFSOperationPayload.SetOperation(AFSOperation::ListFileHandles);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(Path);

        AFSOperationResponse := AFSWebRequestHelper.GetOperationAsText(AFSOperationPayload, ResponseText, StrSubstNo(ListHandlesOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));

        NodeList := AFSHelperLibrary.CreateHandleNodeListFromResponse(ResponseText);
        AFSHelperLibrary.HandleNodeListToTempRecord(NodeList, AFSHandle);
        AFSHandle."Next Marker" := CopyStr(AFSHelperLibrary.GetNextMarkerFromResponse(ResponseText), 1, MaxStrLen(AFSHandle."Next Marker"));
        AFSHandle.Modify();

        exit(AFSOperationResponse);
    end;

    procedure RenameFile(SourceFilePath: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::RenameFile);
        AFSOperationPayload.AddRequestHeader('x-ms-file-rename-source', SourceFilePath);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(DestinationFilePath);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(RenameFileOperationNotSuccessfulErr, SourceFilePath, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));
        exit(AFSOperationResponse);
    end;

    procedure CreateFile(FilePath: Text; InStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(CreateFile(FilePath, AFSHttpContentHelper.GetContentLength(InStream), AFSOptionalParameters));
    end;

    procedure CreateFile(FilePath: Text; FileSize: Integer; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::CreateFile);
        AFSOperationPayload.SetPath(FilePath);
        AFSOperationPayload.AddRequestHeader('x-ms-type', 'file');
        AFSOperationPayload.AddRequestHeader('x-ms-file-attributes', 'None');
        AFSOperationPayload.AddRequestHeader('x-ms-file-creation-time', 'now');
        AFSOperationPayload.AddRequestHeader('x-ms-file-last-write-time', 'now');
        AFSOperationPayload.AddRequestHeader('x-ms-file-permission', 'inherit');
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSHttpContentHelper.AddFilePutContentHeaders(AFSOperationPayload, FileSize, '', 0, 0);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(CreateFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));
        exit(AFSOperationResponse);
    end;

    procedure GetFileAsFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        TargetInStream: InStream;
    begin
        AFSOperationResponse := GetFileAsStream(FilePath, TargetInStream, AFSOptionalParameters);

        if AFSOperationResponse.IsSuccessful() then begin
            FilePath := AFSOperationPayload.GetPath();
            DownloadFromStream(TargetInStream, '', '', '', FilePath);
        end;
        exit(AFSOperationResponse);
    end;

    procedure GetFileAsStream(FilePath: Text; var TargetInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::GetFile);
        AFSOperationPayload.SetPath(FilePath);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.GetOperationAsStream(AFSOperationPayload, TargetInStream, StrSubstNo(GetFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        exit(AFSOperationResponse);
    end;

    procedure GetFileAsText(FilePath: Text; var TargetText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::GetFile);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(FilePath);

        AFSOperationResponse := AFSWebRequestHelper.GetOperationAsText(AFSOperationPayload, TargetText, StrSubstNo(GetFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        exit(AFSOperationResponse);
    end;

    procedure GetFileMetadata(FilePath: Text; var TargetMetadata: Dictionary of [Text, Text]; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSHttpHeaderHelper: Codeunit "AFS HttpHeader Helper";
        AFSOperation: Enum "AFS Operation";
        TargetText: Text;
    begin
        AFSOperationPayload.SetOperation(AFSOperation::GetFileMetadata);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(FilePath);

        AFSOperationResponse := AFSWebRequestHelper.GetOperationAsText(AFSOperationPayload, TargetText, StrSubstNo(GetFileMetadataOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        TargetMetadata := AFSHttpHeaderHelper.GetMetadataHeaders(AFSOperationResponse.GetHeaders());
        exit(AFSOperationResponse);
    end;

    procedure SetFileMetadata(FilePath: Text; Metadata: Dictionary of [Text, Text]; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
        MetadataKey: Text;
        MetadataValue: Text;
    begin
        AFSOperationPayload.SetOperation(AFSOperation::SetFileMetadata);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(FilePath);

        foreach MetadataKey in Metadata.Keys() do begin
            MetadataValue := Metadata.Get(MetadataKey);
            if not MetadataKey.StartsWith('x-ms-meta-') then
                MetadataKey := 'x-ms-meta-' + MetadataKey;
            AFSOperationPayload.AddRequestHeader(MetadataKey, MetadataValue);
        end;

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(SetFileMetadataOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        exit(AFSOperationResponse);
    end;

    procedure PutFileUI(AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        Filename: Text;
        SourceInStream: InStream;
    begin
        if UploadIntoStream('', '', '', FileName, SourceInStream) then
            AFSOperationResponse := PutFileStream(Filename, SourceInStream, AFSOptionalParameters);

        exit(AFSOperationResponse);
    end;

    procedure PutFileStream(FilePath: Text; var SourceInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        SourceContentVariant: Variant;
    begin
        SourceContentVariant := SourceInStream;
        AFSOperationResponse := PutFile(FilePath, AFSOptionalParameters, SourceContentVariant);
        exit(AFSOperationResponse);
    end;

    procedure PutFileText(FilePath: Text; SourceText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        SourceContentVariant: Variant;
    begin
        SourceContentVariant := SourceText;
        AFSOperationResponse := PutFile(FilePath, AFSOptionalParameters, SourceContentVariant);
        exit(AFSOperationResponse);
    end;

    local procedure PutFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var SourceContentVariant: Variant): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        TextTempBlob: Codeunit "Temp Blob";
        AFSOperation: Enum "AFS Operation";
        HttpContent: HttpContent;
        SourceInStream: InStream;
        SourceText: Text;
        SourceTextStream: InStream;
        SourceTextOutStream: OutStream;
    begin
        AFSOperationPayload.SetOperation(AFSOperation::PutRange);
        AFSOperationPayload.SetPath(FilePath);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        case true of
            SourceContentVariant.IsInStream():
                begin
                    SourceInStream := SourceContentVariant;

                    PutFileRanges(AFSOperationResponse, HttpContent, SourceInStream);
                end;
            SourceContentVariant.IsText():
                begin
                    SourceText := SourceContentVariant;
                    TextTempBlob.CreateOutStream(SourceTextOutStream);
                    SourceTextOutStream.WriteText(SourceText);
                    TextTempBlob.CreateInStream(SourceTextStream);

                    PutFileRanges(AFSOperationResponse, HttpContent, SourceTextStream);
                end;
        end;

        exit(AFSOperationResponse);
    end;

    local procedure PutFileRanges(var AFSOperationResponse: Codeunit "AFS Operation Response"; var HttpContent: HttpContent; var SourceInStream: InStream)
    var
        TempBlob: Codeunit "Temp Blob";
        MaxAllowedRange: Integer;
        CurrentPostion: Integer;
        BytesToWrite: Integer;
        BytesLeftToWrite: Integer;
        SmallerStream: InStream;
        SmallerOutStream: OutStream;
        ResponseIndex: Integer;
    begin
        MaxAllowedRange := AFSHttpContentHelper.GetMaxRange();
        BytesLeftToWrite := AFSHttpContentHelper.GetContentLength(SourceInStream);
        CurrentPostion := 0;
        while BytesLeftToWrite > 0 do begin
            ResponseIndex += 1;
            if BytesLeftToWrite > MaxAllowedRange then
                BytesToWrite := MaxAllowedRange
            else
                BytesToWrite := BytesLeftToWrite;

            Clear(TempBlob);
            Clear(SmallerStream);
            Clear(SmallerOutStream);
            TempBlob.CreateOutStream(SmallerOutStream);
            CopyStream(SmallerOutStream, SourceInStream, BytesToWrite);
            TempBlob.CreateInStream(SmallerStream);
            AFSHttpContentHelper.AddFilePutContentHeaders(HttpContent, AFSOperationPayload, SmallerStream, CurrentPostion, CurrentPostion + BytesToWrite - 1);
            CurrentPostion += BytesToWrite;
            BytesLeftToWrite -= BytesToWrite;
            AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, HttpContent, StrSubstNo(PutFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName()));

            // A way to handle multiple responses
            OnPutFileRangesAfterPutOperation(ResponseIndex, AFSOperationResponse);
        end;
    end;

    procedure DeleteFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::DeleteFile);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(FilePath);

        AFSOperationResponse := AFSWebRequestHelper.DeleteOperation(AFSOperationPayload, StrSubstNo(DeleteFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath(), AFSOperationPayload.GetFileShareName(), 'Delete'));

        exit(AFSOperationResponse);
    end;

    procedure CopyFile(SourceFileURI: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::CopyFile);
        AFSOperationPayload.AddRequestHeader('x-ms-copy-source', SourceFileURI);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(DestinationFilePath);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(CopyFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        exit(AFSOperationResponse);
    end;

    procedure AbortCopyFile(DestinationFilePath: Text; CopyID: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::AbortCopyFile);
        AFSOperationPayload.AddRequestHeader('x-ms-copy-action', 'abort');
        AFSOperationPayload.AddUriParameter('copyid', CopyID);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);
        AFSOperationPayload.SetPath(DestinationFilePath);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, StrSubstNo(AbortCopyFileOperationNotSuccessfulErr, AFSOperationPayload.GetPath()));
        exit(AFSOperationResponse);
    end;

    procedure FileAcquireLease(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::LeaseFile);
        AFSOperationPayload.SetPath(FilePath);
        exit(AcquireLease(AFSOptionalParameters, ProposedLeaseId, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseAcquireLbl, FileLbl, AFSOperationPayload.GetPath())));
    end;

    procedure FileReleaseLease(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::LeaseFile);
        AFSOperationPayload.SetPath(FilePath);
        exit(ReleaseLease(AFSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseReleaseLbl, FileLbl, AFSOperationPayload.GetPath())));
    end;

    procedure FileBreakLease(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::LeaseFile);
        AFSOperationPayload.SetPath(FilePath);
        exit(BreakLease(AFSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseBreakLbl, FileLbl, AFSOperationPayload.GetPath())));
    end;

    procedure FileChangeLease(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid; ProposedLeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOperation: Enum "AFS Operation";
    begin
        AFSOperationPayload.SetOperation(AFSOperation::LeaseFile);
        AFSOperationPayload.SetPath(FilePath);
        exit(ChangeLease(AFSOptionalParameters, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseChangeLbl, FileLbl, AFSOperationPayload.GetPath())));
    end;

    #region Private Lease-functions
    local procedure AcquireLease(AFSOptionalParameters: Codeunit "AFS Optional Parameters"; ProposedLeaseId: Guid; var LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        LeaseAction: Enum "AFS Lease Action";
        DurationSeconds: Integer;
    begin
        DurationSeconds := -1;

        AFSOptionalParameters.LeaseAction(LeaseAction::Acquire);
        AFSOptionalParameters.LeaseDuration(DurationSeconds);
        if not IsNullGuid(ProposedLeaseId) then
            AFSOptionalParameters.ProposedLeaseId(ProposedLeaseId);

        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, OperationNotSuccessfulErr);
        if AFSOperationResponse.IsSuccessful() then
            LeaseId := AFSFormatHelper.RemoveCurlyBracketsFromString(AFSOperationResponse.GetHeaderValueFromResponseHeaders('x-ms-lease-id'));
        exit(AFSOperationResponse);
    end;

    local procedure ReleaseLease(AFSOptionalParameters: Codeunit "AFS Optional Parameters"; LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        LeaseAction: Enum "AFS Lease Action";
    begin
        AFSOptionalParameters.LeaseAction(LeaseAction::Release);

        CheckGuidNotNull(LeaseId, 'LeaseId', 'x-ms-lease-id');

        AFSOptionalParameters.LeaseId(LeaseId);

        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    local procedure BreakLease(AFSOptionalParameters: Codeunit "AFS Optional Parameters"; LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        LeaseAction: Enum "AFS Lease Action";
    begin
        AFSOptionalParameters.LeaseAction(LeaseAction::Break);

        if not IsNullGuid(LeaseId) then
            AFSOptionalParameters.LeaseId(LeaseId);
        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    local procedure ChangeLease(AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        LeaseAction: Enum "AFS Lease Action";
    begin
        AFSOptionalParameters.LeaseAction(LeaseAction::Change);

        CheckGuidNotNull(LeaseId, 'LeaseId', 'x-ms-lease-id');
        CheckGuidNotNull(ProposedLeaseId, 'ProposedLeaseId', 'x-ms-proposed-lease-id');

        AFSOptionalParameters.LeaseId(LeaseId);
        AFSOptionalParameters.ProposedLeaseId(ProposedLeaseId);

        AFSOperationPayload.SetOptionalParameters(AFSOptionalParameters);

        AFSOperationResponse := AFSWebRequestHelper.PutOperation(AFSOperationPayload, OperationNotSuccessfulErr);
        LeaseId := AFSFormatHelper.RemoveCurlyBracketsFromString(AFSOperationResponse.GetHeaderValueFromResponseHeaders('x-ms-lease-id'));
        exit(AFSOperationResponse);
    end;

    local procedure CheckGuidNotNull(ValueVariant: Variant; ParameterName: Text; HeaderIdentifer: Text)
    begin
        if ValueVariant.IsGuid() then
            if IsNullGuid(ValueVariant) then
                Error(ParameterMissingErr, ParameterName, HeaderIdentifer);
    end;
    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnPutFileRangesAfterPutOperation(ResponseIndex: Integer; var AFSOperationResponse: Codeunit "AFS Operation Response")
    begin
    end;
}