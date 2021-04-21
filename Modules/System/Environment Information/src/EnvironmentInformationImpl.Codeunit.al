// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3702 "Environment Information Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        TestabilitySoftwareAsAService: Boolean;
        TestabilitySandbox: Boolean;
        IsSaasInitialized: Boolean;
        IsSaaSConfig: Boolean;
        IsSandboxConfig: Boolean;
        IsSandboxInitialized: Boolean;
        DefaultSandboxEnvironmentNameTxt: Label 'Sandbox', Locked = true;
        DefaultProductionEnvironmentNameTxt: Label 'Production', Locked = true;

    procedure IsProduction(): Boolean
    begin
        exit(NavTenantSettingsHelper.IsProduction())
    end;

    procedure IsSandbox(): Boolean
    begin
        if TestabilitySandbox then
            exit(true);

        if not IsSandboxInitialized then begin
            IsSandboxConfig := NavTenantSettingsHelper.IsSandbox();
            IsSandboxInitialized := true;
        end;
        exit(IsSandboxConfig);
    end;

    procedure GetEnvironmentName(): Text
    var
        EnvironmentName: Text;
    begin
        EnvironmentName := NavTenantSettingsHelper.GetEnvironmentName();
        if EnvironmentName <> '' then
            exit(EnvironmentName);

        if IsProduction() then
            exit(DefaultProductionEnvironmentNameTxt);

        exit(DefaultSandboxEnvironmentNameTxt);
    end;

    procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
    begin
        TestabilitySandbox := EnableSandboxForTest;
    end;

    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        TestabilitySoftwareAsAService := EnableSoftwareAsAServiceForTest;
    end;

    procedure IsSaaS(): Boolean
    var
        ServerSettings: Codeunit "Server Setting";
    begin
        if TestabilitySoftwareAsAService then
            exit(true);

        if not IsSaasInitialized then begin
            IsSaaSConfig := IsSandbox() or ServerSettings.GetEnableMembershipEntitlement();
            IsSaasInitialized := true;
        end;

        exit(IsSaaSConfig);
    end;

    procedure IsSaaSInfrastructure(): Boolean
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
    begin
        if TestabilitySoftwareAsAService then
            exit(true);

        exit(IsSaaS() and UserAccountHelper.IsAzure());
    end;

    procedure IsOnPrem(): Boolean
    begin
        exit(GetAppId() = 'NAV');
    end;

    procedure IsFinancials(): Boolean
    begin
        exit(GetAppId() = 'FIN');
    end;

    procedure GetApplicationFamily(): Text
    begin
        exit(NavTenantSettingsHelper.GetApplicationFamily());
    end;

    procedure VersionInstalled(AppID: Guid): Integer
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetModuleInfo(AppId, AppInfo);
        exit(AppInfo.DataVersion.Major());
    end;

    local procedure GetAppId() AppId: Text
    begin
        OnBeforeGetApplicationIdentifier(AppId);
        if AppId = '' then
            AppId := ApplicationIdentifier();
    end;

    [InternalEvent(false)]
    procedure OnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
        // An event which asks for the AppId to be filled in by the subscriber.
        // Do not use this event in a production environment. This should be subscribed to only in tests.
    end;
}

