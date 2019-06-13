// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3702 "Environment Information Impl."
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        TestabilitySoftwareAsAService: Boolean;
        TestabilitySandbox: Boolean;
        IsSaasInitialized: Boolean;
        IsSaaSConfig: Boolean;
        IsSandboxConfig: Boolean;
        IsSandboxInitialized: Boolean;
        MemberShipEntitlementValueTxt: Label 'Membership Entitlement. IsEmpty returned %1.', Locked=true;

    [Scope('OnPrem')]
    procedure IsProduction(): Boolean
    begin
        exit(NavTenantSettingsHelper.IsProduction())
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
    begin
        TestabilitySandbox := EnableSandboxForTest;
    end;

    [Scope('OnPrem')]
    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        TestabilitySoftwareAsAService := EnableSoftwareAsAServiceForTest;
    end;

    [Scope('OnPrem')]
    procedure IsSaaS(): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
    begin
        if TestabilitySoftwareAsAService then
          exit(true);

        if not IsSaasInitialized then begin
          IsSaaSConfig := not MembershipEntitlement.IsEmpty();
          SendTraceTag('00008TO','SaaS',VERBOSITY::Normal,StrSubstNo(MemberShipEntitlementValueTxt,not IsSaaSConfig),
            DATACLASSIFICATION::SystemMetadata);
          IsSaasInitialized := true;
        end;

        exit(IsSaaSConfig);
    end;

    [Scope('OnPrem')]
    procedure IsOnPrem(): Boolean
    begin
        exit(GetAppId() = 'NAV');
    end;

    [Scope('OnPrem')]
    procedure IsInvoicing(): Boolean
    begin
        exit(GetAppId() = 'INV');
    end;

    [Scope('OnPrem')]
    procedure IsFinancials(): Boolean
    begin
        exit(GetAppId() = 'FIN');
    end;

    local procedure GetAppId() AppId: Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        EnvironmentInformation.OnBeforeGetApplicationIdentifier(AppId);
        if AppId = '' then
          AppId := ApplicationIdentifier();
    end;
}

