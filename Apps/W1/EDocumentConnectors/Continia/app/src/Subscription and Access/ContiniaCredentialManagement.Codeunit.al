// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Environment;

codeunit 6395 "Continia Credential Management"
{
    Access = Internal;

    internal procedure IsClientCredentialsValid(): Boolean
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        if ConnectionSetup.Get() then
            exit((not ConnectionSetup.GetClientId().IsEmpty()) and (not ConnectionSetup.GetClientSecret().IsEmpty()));
    end;

    [NonDebuggable]
    internal procedure GetClientCredentialsApiBodyString(): Text
    var
        ConnectionSetup: Record "Continia Connection Setup";
        CredentialsStringPlaceholderTok: Label 'grant_type=password&username=%1&password=%2', Comment = '%1 - Client Id, %2 - Client Secret', Locked = true;
    begin
        if IsClientCredentialsValid() then begin
            ConnectionSetup.Get();
            exit(StrSubstNo(CredentialsStringPlaceholderTok, ConnectionSetup.GetClientId().Unwrap(), ConnectionSetup.GetClientSecret().Unwrap()));
        end;
    end;

    internal procedure InsertClientCredentials(ClientId: SecretText; ClientSecret: SecretText; TenantSubscriptionId: Code[50])
    var
        ConnectionSetup: Record "Continia Connection Setup";
        SessionManager: Codeunit "Continia Session Manager";
    begin
        if not ConnectionSetup.Get() then
            ConnectionSetup.Insert();

        ConnectionSetup.SetClientId(ClientId);
        ConnectionSetup.SetClientSecret(ClientSecret);
        ConnectionSetup."Local Client Identifier" := TenantSubscriptionId;
        ConnectionSetup.Modify();
        SessionManager.ClearAccessToken();
        SessionManager.RefreshClientIdentifier();
    end;

    internal procedure GetIsolatedStorageValue(ValueKey: Text; DataScope: DataScope) Value: SecretText
    begin
        if not HasIsolatedStorageValue(ValueKey, DataScope) then
            exit;

        IsolatedStorage.Get(ValueKey, DataScope, Value);
    end;

    [NonDebuggable]
    internal procedure HasIsolatedStorageValue(ValueKey: Text; DataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(ValueKey, DataScope));
    end;

    internal procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText; DataScope: DataScope) NewKey: Boolean
    begin
        if IsNullGuid(ValueKey) then
            NewKey := true;
        if NewKey then
            ValueKey := CreateGuid();

        IsolatedStorage.Set(ValueKey, Value, DataScope);
    end;

    internal procedure DeleteIsolatedStorageValue(var ValueKey: Guid; DataScope: DataScope): Boolean
    begin
        if IsNullGuid(ValueKey) then
            exit;
        exit(IsolatedStorage.Delete(ValueKey, DataScope));
    end;

    internal procedure GetCompanyGuidAsText(): Text[36]
    begin
        exit(CopyStr(LowerCase(Format(GetCompanyId())), 2, 36));
    end;

    internal procedure GetCompanyId(): Guid
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(Company.Id);
    end;

    internal procedure GetAppCode(): Text[10]
    begin
        exit('COMSEDOC')
    end;

    internal procedure GetAppVersion(): Text[10]
    var
        ModInfo: ModuleInfo;
        AppVer: Version;
        MajorMinorVersion: Text;
        Version: Integer;
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);
        AppVer := ModInfo.AppVersion;
        MajorMinorVersion := Format(AppVer.Major) + Format(AppVer.Minor);
        Evaluate(Version, PadStr(MajorMinorVersion, 6, '0'));
        exit(Format(Version));
    end;

    internal procedure GetAppFullName(): Text[80]
    begin
        exit('Continia Microsoft E-Document Connector')
    end;
}