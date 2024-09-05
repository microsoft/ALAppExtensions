// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Integration.D365Sales;
using Microsoft.Service.Setup;
using System;
using Microsoft.Utilities;
using Microsoft.Foundation.NoSeries;

codeunit 6615 "FS Integration Mgt."
{
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        OAuthConnectionStringFormatTok: Label 'Url=%1; AccessToken=%2; ProxyVersion=%3; %4', Locked = true;
        ConnectionStringFormatTok: Label 'Url=%1; UserName=%2; Password=%3; ProxyVersion=%4; %5', Locked = true;
        UserDoesNotExistCRMErr: Label 'There is no user with email address %1 in %2. Enter a valid email address.', Comment = '%1 = User email address, %2 = Dataverse service name';
        MicrosoftDynamicsFSIntegrationTxt: Label 'bcbi_FieldServiceIntegration', Locked = true;
        TeamNotFoundErr: Label 'Cannot find the default owning team for the coupled business unit %1 selected on page %2. To continue, you can select another business unit or revert to the default business unit that was created during setup.', Comment = '%1 = business unit name, %2 = setup page caption';
        TeamNotFoundTxt: Label 'The team was not found.', Locked = true;
        CategoryTok: Label 'AL Field Service Integration', Locked = true;
        RoleNotFoundForBusinessUnitTxt: Label 'Integration role is not found for business unit.', Locked = true;
        IntegrationRoleNotFoundErr: Label 'There is no integration role %1 for business unit %2.', Comment = '%1 = role name, %2 = business unit name';
        CannotAssignRoleToTeamTxt: Label 'Cannot assign role to team.', Locked = true;
        CannotAssignRoleToTeamErr: Label 'Cannot assign role %3 to team %1 for business unit %2.', Comment = '%1 = team name, %2 = business unit name, %3 = security role name';
        FieldServiceAdministratorProfileIdLbl: label '8d988915-e392-e111-9d8c-000c2959f9b8', Locked = true;
        CannotAssignFieldSecurityProfileToUserTelemetryLbl: Label 'Cannot assign field security profile to integration user.', Locked = true;
        CannotAssignFieldSecurityProfileToUserQst: Label 'To enable the setup, you must sign in to %1 as administrator and assign the column security profile "Field Service - Administrator" to the Business Central integration user. Do you want to open the Business Central integration user card in %1?', Comment = '%1 - Dataverse environment URL';
        NoPermissionsTxt: Label 'No permissions.', Locked = true;

    [TryFunction]
    internal procedure ImportFSSolution(ServerAddress: Text; IntegrationUserEmail: Text; AdminUserEmail: Text; AdminUserPassword: SecretText; AccessToken: SecretText; AdminADDomain: Text; ProxyVersion: Integer; ForceRedeploy: Boolean; ImportSolutionFailed: Boolean)
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        CRMRole: Record "CRM Role";
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
        CRMProductName: Codeunit "CRM Product Name";
        PageCDSConnectionSetup: Page "CDS Connection Setup";
        CRMHelper: DotNet CrmHelper;
        UserGUID: Guid;
        IntegrationRoleGUID: Guid;
        FieldSecurityProfileGUID: Guid;
        DefaultOwningTeamGUID: Guid;
        TempConnectionStringWithPlaceholders: Text;
        TempConnectionString: SecretText;
        SolutionInstalled: Boolean;
        SolutionOutdated: Boolean;
        ImportSolution: Boolean;
    begin
        CRMIntegrationManagement.CheckConnectRequiredFields(ServerAddress, IntegrationUserEmail);
        CDSConnectionSetup.Get();
        if not AccessToken.IsEmpty() then begin
            TempConnectionStringWithPlaceholders :=
                StrSubstNo(OAuthConnectionStringFormatTok, ServerAddress, '%1', ProxyVersion, CDSIntegrationImpl.GetAuthenticationTypeToken(CDSConnectionSetup));
            TempConnectionString := SecretStrSubstNo(TempConnectionStringWithPlaceholders, AccessToken);
        end
        else
            if AdminADDomain <> '' then begin
                TempConnectionStringWithPlaceholders := StrSubstNo(
                    ConnectionStringFormatTok, ServerAddress, AdminUserEmail, '%1', ProxyVersion, CDSIntegrationImpl.GetAuthenticationTypeToken(CDSConnectionSetup, AdminADDomain));
                TempConnectionString := SecretStrSubstNo(TempConnectionStringWithPlaceholders, AdminUserPassword);
            end
            else begin
                TempConnectionStringWithPlaceholders := StrSubstNo(
                    ConnectionStringFormatTok, ServerAddress, AdminUserEmail, '%1', ProxyVersion, CDSIntegrationImpl.GetAuthenticationTypeToken(CDSConnectionSetup));
                TempConnectionString := SecretStrSubstNo(TempConnectionStringWithPlaceholders, AdminUserPassword);
            end;

        if CDSConnectionSetup."Authentication Type" = CDSConnectionSetup."Authentication Type"::OAuth then
            TempConnectionString := CDSIntegrationImpl.ReplaceUserNamePasswordInConnectionstring(CDSConnectionSetup, AdminUserEmail, AdminUserPassword);

        if not InitializeFSConnection(CRMHelper, TempConnectionString) then
            CRMIntegrationManagement.ProcessConnectionFailures();

        UserGUID := CRMHelper.GetUserId(IntegrationUserEmail);
        if IsNullGuid(UserGUID) then
            Error(UserDoesNotExistCRMErr, IntegrationUserEmail, CRMProductName.CDSServiceName());

        SolutionInstalled := CRMHelper.CheckSolutionPresence(MicrosoftDynamicsFSIntegrationTxt);
        if SolutionInstalled then
            SolutionOutdated := CRMIntegrationManagement.IsSolutionOutdated(TempConnectionStringWithPlaceholders, MicrosoftDynamicsFSIntegrationTxt);

        if ForceRedeploy then
            ImportSolution := (not SolutionInstalled) or SolutionOutdated
        else
            ImportSolution := not SolutionInstalled;

        if ImportSolution then
            if not ImportDefaultFSSolution(CRMHelper) then begin
                ImportSolutionFailed := true;
                CRMIntegrationManagement.ProcessConnectionFailures();
            end;

        IntegrationRoleGUID := CRMHelper.GetRoleId(GetFieldServiceIntegrationRoleID());
        if not CRMHelper.CheckRoleAssignedToUser(UserGUID, IntegrationRoleGUID) then
            CRMHelper.AssociateUserWithRole(UserGUID, IntegrationRoleGUID);

        if CDSIntegrationImpl.IsIntegrationEnabled() then begin
            CDSIntegrationImpl.RegisterConnection();
            CDSIntegrationImpl.ActivateConnection();
            CDSConnectionSetup.Get();
            DefaultOwningTeamGUID := CDSIntegrationImpl.GetOwningTeamId(CDSConnectionSetup);
            if IsNullGuid(DefaultOwningTeamGUID) then begin
                Session.LogMessage('0000MWY', TeamNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(TeamNotFoundErr, CDSIntegrationImpl.GetDefaultBusinessUnitName(), PageCDSConnectionSetup.Caption);
            end;
            CRMRole.SetRange(ParentRoleId, IntegrationRoleGUID);
            CRMRole.SetRange(BusinessUnitId, CDSIntegrationImpl.GetCoupledBusinessUnitId());
            if not CRMRole.FindFirst() then begin
                Session.LogMessage('0000MWZ', RoleNotFoundForBusinessUnitTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(IntegrationRoleNotFoundErr, IntegrationRoleGUID, CDSIntegrationImpl.GetDefaultBusinessUnitName());
            end;
            if not CDSIntegrationImpl.AssignTeamRole(CrmHelper, DefaultOwningTeamGUID, CRMRole.RoleId) then begin
                Session.LogMessage('0000MX0', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(CannotAssignRoleToTeamErr, DefaultOwningTeamGUID, CDSIntegrationImpl.GetDefaultBusinessUnitName(), CRMRole.Name);
            end;
            if not CDSIntegrationImpl.AssignTeamRole(CrmHelper, DefaultOwningTeamGUID, CRMRole.RoleId) then begin
                Session.LogMessage('0000MX1', CannotAssignRoleToTeamTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                Error(CannotAssignRoleToTeamErr, DefaultOwningTeamGUID, CDSIntegrationImpl.GetDefaultBusinessUnitName(), CRMRole.Name);
            end;
        end;

        FieldSecurityProfileGUID := TextToGuid(FieldServiceAdministratorProfileIdLbl);
        if not CRMHelper.CheckFieldSecurityProfileAssignedToUser(UserGUID, FieldSecurityProfileGUID) then
            CRMHelper.AssociateUserWithFieldSecurityProfile(UserGUID, FieldSecurityProfileGUID);

        if not CRMHelper.CheckFieldSecurityProfileAssignedToUser(UserGUID, FieldSecurityProfileGUID) then begin
            Session.LogMessage('0000MX2', CannotAssignFieldSecurityProfileToUserTelemetryLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if Confirm(StrSubstNo(CannotAssignFieldSecurityProfileToUserQst, CDSConnectionSetup."Server Address")) then
                CDSIntegrationImpl.ShowIntegrationUser(CDSConnectionSetup);
            Error('');
        end
    end;

    [TryFunction]
    local procedure TryTouchFSSolutionEntities()
    var
        FSProjectTask: Record "FS Project Task";
        Cnt: Integer;
    begin
        Cnt := FSProjectTask.Count();
        if Cnt > 0 then
            exit;
    end;

    internal procedure IsFSSolutionInstalled(): Boolean
    begin
        if TryTouchFSSolutionEntities() then
            exit(true);

        ClearLastError();
        exit(false);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure InitializeFSConnection(var CRMHelper: DotNet CrmHelper; ConnectionString: SecretText)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if ConnectionString.IsEmpty() then begin
            FSConnectionSetup.Get();
            CRMHelper := CRMHelper.CrmHelper(FSConnectionSetup.GetConnectionStringWithCredentials().Unwrap());
        end else
            CRMHelper := CRMHelper.CrmHelper(ConnectionString.Unwrap());
        if not CRMIntegrationManagement.TestCRMConnection(CRMHelper) then
            CRMIntegrationManagement.ProcessConnectionFailures();
    end;

    [TryFunction]
    local procedure ImportDefaultFSSolution(var CRMHelper: DotNet CrmHelper)
    begin
        CRMHelper.ImportDefaultFieldServiceSolution()
    end;

    local procedure GetFieldServiceIntegrationRoleID(): Text
    begin
        exit('c11b4fa8-956b-439d-8b3c-021e8736a78b');
    end;

    local procedure TextToGuid(TextVar: Text): Guid
    var
        GuidVar: Guid;
    begin
        if not Evaluate(GuidVar, TextVar) then;
        exit(GuidVar);
    end;

    internal procedure TestManualServiceOrderNoSeriesFlag(IntegrationType: Enum "FS Integration Type")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        NoSeries: Codeunit "No. Series";
        CannotInvoiceErrorInfo: ErrorInfo;
        NoManualNoSeriesTitleErr: Label 'Service Order No. Series must be set to manual.';
        NoManualNoSeriesErr: Label 'Please make sure that the No. Series setup is correct.';
        SetToManualLbl: Label 'Set to Manual';
        OpenNoSeriesListLbl: Label 'Open No. Series. list';
    begin
        if not (IntegrationType in [IntegrationType::Service, IntegrationType::Both]) then
            exit;

        ServiceMgtSetup.Get();
        if not NoSeries.IsManual(ServiceMgtSetup."Service Order Nos.") then begin
            CannotInvoiceErrorInfo.Title := NoManualNoSeriesTitleErr;
            CannotInvoiceErrorInfo.Message := NoManualNoSeriesErr;

            if ServiceMgtSetup."Service Order Nos." <> '' then
                CannotInvoiceErrorInfo.AddAction(
                    SetToManualLbl,
                    Codeunit::"FS Integration Mgt.",
                    'SetServiceOrderNoSeriesToManual'
                );

            CannotInvoiceErrorInfo.PageNo := Page::"No. Series";
            CannotInvoiceErrorInfo.AddNavigationAction(OpenNoSeriesListLbl);
            Error(CannotInvoiceErrorInfo);
        end;
    end;

    procedure SetServiceOrderNoSeriesToManual(ErrorInfo: ErrorInfo)
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        NoSeries: Record "No. Series";
    begin
        ServiceMgtSetup.Get();
        NoSeries.Get(ServiceMgtSetup."Service Order Nos.");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);
    end;

    internal procedure TestOneServiceItemLinePerOrder(IntegrationType: Enum "FS Integration Type")
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        if not (IntegrationType in [IntegrationType::Service, IntegrationType::Both]) then
            exit;

        ServiceMgtSetup.Get();
        ServiceMgtSetup.TestField("One Service Item Line/Order", false);
    end;

    internal procedure TestOneServiceItemLinePerOrderModificationIsAllowed(ServiceMgtSetup: Record "Service Mgt. Setup")
    var
        ConnectionSetup: Record "FS Connection Setup";
    begin
        if not ServiceMgtSetup."One Service Item Line/Order" then
            exit;

        if not ConnectionSetup.IsIntegrationTypeServiceEnabled() then
            exit;

        ConnectionSetup.TestField("Is Enabled", false);
    end;

    internal procedure GetDefaultWorkOrderIncident(): Guid
    var
        ConnectionSetup: Record "FS Connection Setup";
    begin
        ConnectionSetup.Get();

        if IsNullGuid(ConnectionSetup."Default Work Order Incident ID") then begin
            ConnectionSetup."Default Work Order Incident ID" := GenerateDefaultWorkOrderIncident();
            ConnectionSetup.Modify();
        end;

        exit(ConnectionSetup."Default Work Order Incident ID");
    end;

    internal procedure GenerateDefaultWorkOrderIncident(): Guid
    var
        IncidentType: Record "FS Incident Type";
        IncidentTypeNameLbl: Label 'Business Central - Default Incident Type';
    begin
        IncidentType.IncidentTypeId := CreateGuid();
        IncidentType.Name := IncidentTypeNameLbl;
        IncidentType.Insert();

        exit(IncidentType.IncidentTypeId);
    end;

    internal procedure GetBookingStatusCompleted(): Guid
    var
        FSBookingStatus: Record "FS Booking Status";
        EmptyGuid: Guid;
    begin
        FSBookingStatus.SetRange(FieldServiceStatus, FSBookingStatus.FieldServiceStatus::Completed);
        if not FSBookingStatus.FindFirst() then
            exit(EmptyGuid);

        exit(FSBookingStatus.BookingStatusId);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure RegisterFSConnectionOnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        RecRef: RecordRef;
    begin
        if not FSConnectionSetup.Get() then begin
            if not FSConnectionSetup.WritePermission() then begin
                Session.LogMessage('0000MYK', NoPermissionsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;
            FSConnectionSetup.Init();
            FSConnectionSetup.Insert();
        end;

        RecRef.GetTable(FSConnectionSetup);
        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        if not FSConnectionSetup."Is Enabled" then
            ServiceConnection.Status := ServiceConnection.Status::Disabled
        else
            if FSConnectionSetup.TestConnection() then
                ServiceConnection.Status := ServiceConnection.Status::Connected
            else
                ServiceConnection.Status := ServiceConnection.Status::Error;
        ServiceConnection.InsertServiceConnectionExtended(
          ServiceConnection, RecRef.RecordId, FSConnectionSetup.TableCaption(), FSConnectionSetup."Server Address", Page::"FS Connection Setup", Page::"FS Connection Setup Wizard");
    end;
}