// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

using System.Text;
using System.Integration.Sharepoint;
using System.Utilities;
using System.DataAdministration;

codeunit 4580 "Ext. SharePoint Connector Impl" implements "External File Storage Connector"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Ext. SharePoint Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Use SharePoint to store and retrieve files.', MaxLength = 250;
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';

    /// <summary>
    /// Gets a List of Files stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="TempFileAccountContent">A list with all files stored in the path.</param>
    procedure ListFiles(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        OrginalPath: Text;
    begin
        OrginalPath := Path;
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetFolderFilesByServerRelativeUrl(Path, SharePointFile) then
            ShowError(SharePointClient);

        FilePaginationData.SetEndOfListing(true);

        if not SharePointFile.FindSet() then
            exit;

        repeat
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := SharePointFile.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::"File";
            TempFileAccountContent."Parent Directory" := CopyStr(OrginalPath, 1, MaxStrLen(TempFileAccountContent."Parent Directory"));
            TempFileAccountContent.Insert();
        until SharePointFile.Next() = 0;
    end;

    /// <summary>
    /// Gets a file from the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read to.</param>
    procedure GetFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        SharePointClient: Codeunit "SharePoint Client";
        Content: HttpContent;
        TempBlobStream: InStream;
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);

        if not SharePointClient.DownloadFileContentByServerRelativeUrl(Path, TempBlobStream) then
            ShowError(SharePointClient);

        // Platform fix: For some reason the Stream from DownloadFileContentByServerRelativeUrl dies after leaving the interface
        Content.WriteFrom(TempBlobStream);
        Content.ReadAs(Stream);
    end;

    /// <summary>
    /// Create a file in the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <param name="Stream">The Stream were the file is read from.</param>
    procedure CreateFile(AccountId: Guid; Path: Text; Stream: InStream)
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        ParentPath, FileName : Text;
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        SplitPath(Path, ParentPath, FileName);
        if SharePointClient.AddFileToFolder(ParentPath, FileName, Stream, SharePointFile, false) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Copies as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure CopyFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
    begin
        TempBlob.CreateInStream(Stream);

        GetFile(AccountId, SourcePath, Stream);
        CreateFile(AccountId, TargetPath, Stream);
    end;

    /// <summary>
    /// Move as file inside the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="SourcePath">The source file path.</param>
    /// <param name="TargetPath">The target file path.</param>
    procedure MoveFile(AccountId: Guid; SourcePath: Text; TargetPath: Text)
    var
        Stream: InStream;
    begin
        GetFile(AccountId, SourcePath, Stream);
        CreateFile(AccountId, TargetPath, Stream);
        DeleteFile(AccountId, SourcePath);
    end;

    /// <summary>
    /// Checks if a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    /// <returns>Returns true if the file exists</returns>
    procedure FileExists(AccountId: Guid; Path: Text): Boolean
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetFolderFilesByServerRelativeUrl(GetParentPath(Path), SharePointFile) then
            ShowError(SharePointClient);

        SharePointFile.SetRange(Name, GetFileName(Path));
        exit(not SharePointFile.IsEmpty());
    end;

    /// <summary>
    /// Deletes a file exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The file path inside the file account.</param>
    procedure DeleteFile(AccountId: Guid; Path: Text)
    var
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.DeleteFileByServerRelativeUrl(Path) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Gets a List of Directories stored on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to get the file.</param>
    /// <param name="Path">The file path to list.</param>
    /// <param name="FilePaginationData">Defines the pagination data.</param>
    /// <param name="Files">A list with all directories stored in the path.</param>
    procedure ListDirectories(AccountId: Guid; Path: Text; FilePaginationData: Codeunit "File Pagination Data"; var TempFileAccountContent: Record "File Account Content" temporary)
    var
        SharePointFolder: Record "SharePoint Folder";
        SharePointClient: Codeunit "SharePoint Client";
        OrginalPath: Text;
    begin
        OrginalPath := Path;
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if not SharePointClient.GetSubFoldersByServerRelativeUrl(Path, SharePointFolder) then
            ShowError(SharePointClient);

        FilePaginationData.SetEndOfListing(true);

        if not SharePointFolder.FindSet() then
            exit;

        repeat
            TempFileAccountContent.Init();
            TempFileAccountContent.Name := SharePointFolder.Name;
            TempFileAccountContent.Type := TempFileAccountContent.Type::Directory;
            TempFileAccountContent."Parent Directory" := CopyStr(OrginalPath, 1, MaxStrLen(TempFileAccountContent."Parent Directory"));
            TempFileAccountContent.Insert();
        until SharePointFolder.Next() = 0;
    end;

    /// <summary>
    /// Creates a directory on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure CreateDirectory(AccountId: Guid; Path: Text)
    var
        SharePointFolder: Record "SharePoint Folder";
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.CreateFolder(Path, SharePointFolder) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Checks if a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    /// <returns>Returns true if the directory exists</returns>
    procedure DirectoryExists(AccountId: Guid; Path: Text) Result: Boolean
    var
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);

        Result := SharePointClient.FolderExistsByServerRelativeUrl(Path);

        if not SharePointClient.GetDiagnostics().IsSuccessStatusCode() then
            ShowError(SharePointClient);
    end;

    /// <summary>
    /// Deletes a directory exists on the provided account.
    /// </summary>
    /// <param name="AccountId">The file account ID which is used to send out the file.</param>
    /// <param name="Path">The directory path inside the file account.</param>
    procedure DeleteDirectory(AccountId: Guid; Path: Text)
    var
        SharePointClient: Codeunit "SharePoint Client";
    begin
        InitPath(AccountId, Path);
        InitSharePointClient(AccountId, SharePointClient);
        if SharePointClient.DeleteFolderByServerRelativeUrl(Path) then
            exit;

        ShowError(SharePointClient);
    end;

    /// <summary>
    /// Gets the registered accounts for the SharePoint connector.
    /// </summary>
    /// <param name="TempAccounts">Out parameter holding all the registered accounts for the SharePoint connector.</param>
    procedure GetAccounts(var TempAccounts: Record "File Account" temporary)
    var
        Account: Record "Ext. SharePoint Account";
    begin
        if not Account.FindSet() then
            exit;

        repeat
            TempAccounts."Account Id" := Account.Id;
            TempAccounts.Name := Account.Name;
            TempAccounts.Connector := Enum::"Ext. File Storage Connector"::"SharePoint";
            TempAccounts.Insert();
        until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        SharePointAccountLocal: Record "Ext. SharePoint Account";
    begin
        if not SharePointAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        SharePointAccountLocal.SetRecFilter();
        Page.Run(Page::"Ext. SharePoint Account", SharePointAccountLocal);
    end;

    /// <summary>
    /// Register an file account for the SharePoint connector.
    /// </summary>
    /// <param name="TempAccount">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var TempAccount: Record "File Account" temporary): Boolean
    var
        SharePointAccountWizard: Page "Ext. SharePoint Account Wizard";
    begin
        SharePointAccountWizard.RunModal();

        exit(SharePointAccountWizard.GetAccount(TempAccount));
    end;

    /// <summary>
    /// Deletes an file account for the SharePoint connector.
    /// </summary>
    /// <param name="AccountId">The ID of the SharePoint account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        SharePointAccountLocal: Record "Ext. SharePoint Account";
    begin
        if SharePointAccountLocal.Get(AccountId) then
            exit(SharePointAccountLocal.Delete());

        exit(false);
    end;

    /// <summary>
    /// Gets a description of the SharePoint connector.
    /// </summary>
    /// <returns>A short description of the SharePoint connector.</returns>
    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    /// <summary>
    /// Gets the SharePoint connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Stream: InStream;
    begin
        NavApp.GetResource('connector-logo.png', Stream);
        exit(Base64Convert.ToBase64(Stream));
    end;

    internal procedure IsAccountValid(var TempAccount: Record "Ext. SharePoint Account" temporary): Boolean
    begin
        if TempAccount.Name = '' then
            exit(false);

        if IsNullGuid(TempAccount."Client Id") then
            exit(false);

        if IsNullGuid(TempAccount."Tenant Id") then
            exit(false);

        if TempAccount."SharePoint Url" = '' then
            exit(false);

        if TempAccount."Base Relative Folder Path" = '' then
            exit(false);

        exit(true);
    end;

    internal procedure CreateAccount(var AccountToCopy: Record "Ext. SharePoint Account"; ClientSecretOrCertificate: SecretText; CertificatePassword: SecretText; var TempFileAccount: Record "File Account" temporary)
    var
        NewExtSharePointAccount: Record "Ext. SharePoint Account";
    begin
        NewExtSharePointAccount.TransferFields(AccountToCopy);
        NewExtSharePointAccount.Id := CreateGuid();

        case NewExtSharePointAccount."Authentication Type" of
            Enum::"Ext. SharePoint Auth Type"::"Client Secret":
                NewExtSharePointAccount.SetClientSecret(ClientSecretOrCertificate);
            Enum::"Ext. SharePoint Auth Type"::Certificate:
                begin
                    NewExtSharePointAccount.SetCertificate(ClientSecretOrCertificate);
                    NewExtSharePointAccount.SetCertificatePassword(CertificatePassword);
                end;
        end;

        NewExtSharePointAccount.Insert();

        TempFileAccount."Account Id" := NewExtSharePointAccount.Id;
        TempFileAccount.Name := NewExtSharePointAccount.Name;
        TempFileAccount.Connector := Enum::"Ext. File Storage Connector"::"SharePoint";
    end;

    local procedure InitSharePointClient(var AccountId: Guid; var SharePointClient: Codeunit "SharePoint Client")
    var
        SharePointAccount: Record "Ext. SharePoint Account";
        SharePointAuth: Codeunit "SharePoint Auth.";
        SharePointAuthorization: Interface "SharePoint Authorization";
        Scopes: List of [Text];
        AccountDisabledErr: Label 'The account "%1" is disabled.', Comment = '%1 - Account Name';
    begin
        SharePointAccount.Get(AccountId);
        if SharePointAccount.Disabled then
            Error(AccountDisabledErr, SharePointAccount.Name);

        Scopes.Add('00000003-0000-0ff1-ce00-000000000000/.default');

        case SharePointAccount."Authentication Type" of
            Enum::"Ext. SharePoint Auth Type"::"Client Secret":
                SharePointAuthorization := SharePointAuth.CreateAuthorizationCode(
                    Format(SharePointAccount."Tenant Id", 0, 4),
                    Format(SharePointAccount."Client Id", 0, 4),
                    SharePointAccount.GetClientSecret(SharePointAccount."Client Secret Key"),
                    Scopes);
            Enum::"Ext. SharePoint Auth Type"::Certificate:
                SharePointAuthorization := SharePointAuth.CreateClientCredentials(
                    Format(SharePointAccount."Tenant Id", 0, 4),
                    Format(SharePointAccount."Client Id", 0, 4),
                    SharePointAccount.GetCertificate(SharePointAccount."Certificate Key"),
                    SharePointAccount.GetCertificatePassword(SharePointAccount."Certificate Password Key"),
                    Scopes);
        end;

        SharePointClient.Initialize(SharePointAccount."SharePoint Url", SharePointAuthorization);
    end;

    local procedure PathSeparator(): Text
    begin
        exit('/');
    end;

    local procedure ShowError(var SharePointClient: Codeunit "SharePoint Client")
    var
        ErrorOccuredErr: Label 'An error occured.\%1', Comment = '%1 - Error message from sharepoint';
    begin
        Error(ErrorOccuredErr, SharePointClient.GetDiagnostics().GetErrorMessage());
    end;

    local procedure GetParentPath(Path: Text) ParentPath: Text
    begin
        if (Path.TrimEnd(PathSeparator()).Contains(PathSeparator())) then
            ParentPath := Path.TrimEnd(PathSeparator()).Substring(1, Path.LastIndexOf(PathSeparator()));
    end;

    local procedure GetFileName(Path: Text) FileName: Text
    begin
        if (Path.TrimEnd(PathSeparator()).Contains(PathSeparator())) then
            FileName := Path.TrimEnd(PathSeparator()).Substring(Path.LastIndexOf(PathSeparator()) + 1);
    end;

    local procedure InitPath(AccountId: Guid; var Path: Text)
    var
        SharePointAccount: Record "Ext. SharePoint Account";
    begin
        SharePointAccount.Get(AccountId);
        Path := CombinePath(SharePointAccount."Base Relative Folder Path", Path);
    end;

    local procedure CombinePath(Parent: Text; Child: Text): Text
    begin
        if Parent = '' then
            exit(Child);

        if Child = '' then
            exit(Parent);

        if not Parent.EndsWith(PathSeparator()) then
            Parent += PathSeparator();

        exit(Parent + Child);
    end;

    local procedure SplitPath(Path: Text; var ParentPath: Text; var FileName: Text)
    begin
        ParentPath := Path.TrimEnd(PathSeparator()).Substring(1, Path.LastIndexOf(PathSeparator()));
        FileName := Path.TrimEnd(PathSeparator()).Substring(Path.LastIndexOf(PathSeparator()) + 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure EnvironmentCleanup_OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ExtSharePointAccount: Record "Ext. SharePoint Account";
    begin
        ExtSharePointAccount.SetRange(Disabled, false);
        if ExtSharePointAccount.IsEmpty() then
            exit;

        ExtSharePointAccount.ModifyAll(Disabled, true);
    end;
}