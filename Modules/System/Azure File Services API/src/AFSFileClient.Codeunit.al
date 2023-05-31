codeunit 50101 "AFS File Client"
{
    Access = Public;

    var
        AFSClientImpl: Codeunit "AFS Client Impl.";

    procedure Initialize(StorageAccount: Text; FileShare: Text; Authorization: Interface "Storage Service Authorization")
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        AFSClientImpl.Initialize(StorageAccount, FileShare, '', Authorization, StorageServiceAuthorization.GetDefaultAPIVersion());
    end;

    procedure Initialize(StorageAccount: Text; FileShare: Text; Authorization: Interface "Storage Service Authorization"; APIVersion: Enum "Storage Service API Version")
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        AFSClientImpl.Initialize(StorageAccount, FileShare, '', Authorization, APIVersion);
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        AFSClientImpl.SetBaseUrl(BaseUrl);
    end;

    procedure CreateFile(FilePath: Text; InStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.CreateFile(FilePath, InStream, AFSOptionalParameters));
    end;

    procedure CreateFile(FilePath: Text; InStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.CreateFile(FilePath, InStream, AFSOptionalParameters));
    end;

    procedure CreateFile(FilePath: Text; FileSize: Integer): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.CreateFile(FilePath, FileSize, AFSOptionalParameters));
    end;

    procedure CreateFile(FilePath: Text; FileSize: Integer; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.CreateFile(FilePath, FileSize, AFSOptionalParameters));
    end;

    procedure GetFileAsFile(FilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.GetFileAsFile(FilePath, AFSOptionalParameters));
    end;

    procedure GetFileAsFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.GetFileAsFile(FilePath, AFSOptionalParameters));
    end;

    procedure GetFileAsStream(FilePath: Text; var TargetInStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.GetFileAsStream(FilePath, TargetInStream, AFSOptionalParameters));
    end;

    procedure GetFileAsStream(FilePath: Text; var TargetInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.GetFileAsStream(FilePath, TargetInStream, AFSOptionalParameters));
    end;

    procedure GetFileAsText(FilePath: Text; var TargetText: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.GetFileAsText(FilePath, TargetText, AFSOptionalParameters));
    end;

    procedure GetFileAsText(FilePath: Text; var TargetText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.GetFileAsText(FilePath, TargetText, AFSOptionalParameters));
    end;

    procedure PutFileUI(): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.PutFileUI(AFSOptionalParameters));
    end;

    procedure PutFileUI(AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.PutFileUI(AFSOptionalParameters));
    end;

    procedure PutFileStream(FilePath: Text; var SourceInStream: InStream): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.PutFileStream(FilePath, SourceInStream, AFSOptionalParameters));
    end;

    procedure PutFileStream(FilePath: Text; var SourceInStream: InStream; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.PutFileStream(FilePath, SourceInStream, AFSOptionalParameters));
    end;

    procedure PutFileText(FilePath: Text; var SourceText: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.PutFileText(FilePath, SourceText, AFSOptionalParameters));
    end;

    procedure PutFileText(FilePath: Text; var SourceText: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.PutFileText(FilePath, SourceText, AFSOptionalParameters));
    end;

    procedure DeleteFile(FilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.DeleteFile(FilePath, AFSOptionalParameters));
    end;

    procedure DeleteFile(FilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.DeleteFile(FilePath, AFSOptionalParameters));
    end;

    procedure ListDirectory(DirectoryPath: Text; var AFSDirectoryContent: Record "AFS Directory Content"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, false, AFSOptionalParameters));
    end;

    procedure ListDirectory(DirectoryPath: Text; var AFSDirectoryContent: Record "AFS Directory Content"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, false, AFSOptionalParameters));
    end;

    procedure ListDirectory(DirectoryPath: Text; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, PreserveDirectoryContent, AFSOptionalParameters));
    end;

    procedure ListDirectory(DirectoryPath: Text; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.ListDirectory(DirectoryPath, AFSDirectoryContent, PreserveDirectoryContent, AFSOptionalParameters));
    end;

    procedure CreateDirectory(DirectoryPath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.CreateDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    procedure CreateDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.CreateDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    procedure DeleteDirectory(DirectoryPath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.DeleteDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    procedure DeleteDirectory(DirectoryPath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.DeleteDirectory(DirectoryPath, AFSOptionalParameters));
    end;

    procedure CopyFile(SourceFileURI: Text; DestinationFilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.CopyFile(SourceFileURI, DestinationFilePath, AFSOptionalParameters));
    end;

    procedure CopyFile(SourceFileURI: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.CopyFile(SourceFileURI, DestinationFilePath, AFSOptionalParameters));
    end;

    procedure AbortCopyFile(DestinationFilePath: Text; CopyID: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.AbortCopyFile(DestinationFilePath, CopyID, AFSOptionalParameters));
    end;

    procedure AbortCopyFile(DestinationFilePath: Text; CopyID: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.AbortCopyFile(DestinationFilePath, CopyID, AFSOptionalParameters));
    end;

    procedure ListHandles(Path: Text; var AFSHandle: Record "AFS Handle"): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.ListHandles(Path, AFSHandle, AFSOptionalParameters));
    end;

    procedure ListHandles(Path: Text; var AFSHandle: Record "AFS Handle"; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.ListHandles(Path, AFSHandle, AFSOptionalParameters));
    end;

    procedure RenameFile(SourceFilePath: Text; DestinationFilePath: Text): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.RenameFile(SourceFilePath, DestinationFilePath, AFSOptionalParameters))
    end;

    procedure RenameFile(SourceFilePath: Text; DestinationFilePath: Text; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.RenameFile(SourceFilePath, DestinationFilePath, AFSOptionalParameters))
    end;

    procedure AcquireLease(FilePath: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.FileAcquireLease(FilePath, AFSOptionalParameters, ProposedLeaseId, LeaseId));
    end;

    procedure AcquireLease(FilePath: Text; ProposedLeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.FileAcquireLease(FilePath, AFSOptionalParameters, ProposedLeaseId, LeaseId));
    end;

    procedure ChangeLease(FilePath: Text; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.FileChangeLease(FilePath, AFSOptionalParameters, LeaseId, ProposedLeaseId));
    end;

    procedure ChangeLease(FilePath: Text; ProposedLeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"; var LeaseId: Guid): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.FileChangeLease(FilePath, AFSOptionalParameters, LeaseId, ProposedLeaseId));
    end;

    procedure ReleaseLease(FilePath: Text; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.FileReleaseLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    procedure ReleaseLease(FilePath: Text; LeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.FileReleaseLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    procedure BreakLease(FilePath: Text; LeaseId: Guid): Codeunit "AFS Operation Response"
    var
        AFSOptionalParameters: Codeunit "AFS Optional Parameters";
    begin
        exit(AFSClientImpl.FileBreakLease(FilePath, AFSOptionalParameters, LeaseId));
    end;

    procedure BreakLease(FilePath: Text; LeaseId: Guid; AFSOptionalParameters: Codeunit "AFS Optional Parameters"): Codeunit "AFS Operation Response"
    begin
        exit(AFSClientImpl.FileBreakLease(FilePath, AFSOptionalParameters, LeaseId));
    end;
}