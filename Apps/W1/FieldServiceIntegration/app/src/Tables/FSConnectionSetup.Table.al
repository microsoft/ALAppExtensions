// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.CRM.Outlook;
using Microsoft.Foundation.UOM;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.D365Sales;
using Microsoft.Integration.SyncEngine;
using Microsoft.Service.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using System.Environment;
using System.Environment.Configuration;
using System.Security.Encryption;
using System.Threading;
using Microsoft.Projects.Resources.Resource;

table 6623 "FS Connection Setup"
{
    Caption = 'Dynamics 365 Field Service Integration Setup';
    Permissions = tabledata "FS Connection Setup" = r;
    InherentEntitlements = rX;
    InherentPermissions = rX;
    DataClassification = CustomerContent;
    ReplicateData = true;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "Server Address"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Field Service URL';

            trigger OnValidate()
            var
                EnvironmentInfo: Codeunit "Environment Information";
            begin
                CRMIntegrationManagement.CheckModifyCRMConnectionURL("Server Address");

                if "Server Address" <> '' then
                    if EnvironmentInfo.IsSaaS() or (StrPos("Server Address", '.dynamics.com') > 0) then
                        "Authentication Type" := "Authentication Type"::Office365
                    else
                        "Authentication Type" := "Authentication Type"::AD;
                UpdateConnectionString();
            end;
        }
        field(3; "User Name"; Text[250])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "User Name" := DelChr("User Name", '<>');
                CheckUserName();
                UpdateDomainName();
                UpdateConnectionString();
            end;
        }
        field(4; "User Password Key"; Guid)
        {
            Caption = 'User Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;

            trigger OnValidate()
            begin
                if not IsTemporary() then
                    if "User Password Key" <> xRec."User Password Key" then
                        xRec.DeletePassword();
            end;
        }
        field(59; "Restore Connection"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Restore Connection';
        }
        field(60; "Is Enabled"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Enabled';

            trigger OnValidate()
            var
                CRMConnectionSetup: Record "CRM Connection Setup";
                FSSetupDefaults: Codeunit "FS Setup Defaults";
                CRMConnectionSetupPage: Page "CRM Connection Setup";
            begin
                if "Is Enabled" then begin
                    TestField("Job Journal Template");
                    TestField("Job Journal Batch");
                    if not CRMConnectionSetup.IsEnabled() then
                        Error(CRMConnSetupMustBeEnabledErr, CRMConnectionSetupPage.Caption());
                    if "Hour Unit of Measure" = '' then
                        Error(HourUnitOfMeasureMustBePickedErr);
                    if not RemoveExistingCouplingOfResources() then
                        Error('');
                end;
                UpdateConnectionDetails();
                RefreshDataFromFS();
                if "Is Enabled" then begin
                    TestIntegrationUserRequirements();
                    FSSetupDefaults.ResetConfiguration(Rec);
                    Session.LogMessage('0000MAT', CRMConnEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end else
                    Session.LogMessage('0000MAU', CRMConnDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end;
        }
        field(63; "FS Version"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Field Service Version';
        }
        field(67; "Is FS Solution Installed"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is CRM Solution Installed';
        }
        field(76; "Proxy Version"; Integer)
        {
            Caption = 'Proxy Version';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                UpdateProxyVersionInConnectionString();
            end;
        }
        field(118; CurrencyDecimalPrecision; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Currency Decimal Precision';
            Description = 'Number of decimal places that can be used for currency.';
        }
        field(124; BaseCurrencyId; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Currency';
            Description = 'Unique identifier of the base currency of the organization.';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
        }
        field(133; BaseCurrencyPrecision; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Base Currency Precision';
            Description = 'Number of decimal places that can be used for the base currency.';
            MaxValue = 4;
            MinValue = 0;
        }
        field(134; BaseCurrencySymbol; Text[5])
        {
            DataClassification = SystemMetadata;
            Caption = 'Base Currency Symbol';
            Description = 'Symbol used for the base currency.';
        }
        field(135; "Authentication Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Authentication Type';
            OptionCaption = 'OAuth 2.0,AD,IFD,OAuth';
            OptionMembers = Office365,AD,IFD,OAuth;

            trigger OnValidate()
            begin
                case "Authentication Type" of
                    "Authentication Type"::Office365:
                        Domain := '';
                    "Authentication Type"::AD:
                        UpdateDomainName();
                end;
                UpdateConnectionString();
            end;
        }
        field(136; "Connection String"; Text[250])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Connection String';
        }
        field(137; Domain; Text[250])
        {
            Caption = 'Domain';
            DataClassification = OrganizationIdentifiableInformation;
            Editable = false;
        }
        field(138; "Server Connection String"; BLOB)
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Server Connection String';
        }
        field(139; "Disable Reason"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Disable Reason';
        }
        field(200; "Job Journal Template"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Project Journal Template';
            TableRelation = "Job Journal Template";
        }
        field(201; "Job Journal Batch"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Project Journal Batch';
            TableRelation = "Job Journal Batch".Name where("Journal Template Name" = field("Job Journal Template"));
        }
        field(202; "Hour Unit of Measure"; Code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Hour Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(203; "Line Synch. Rule"; Enum "FS Work Order Line Synch. Rule")
        {
            DataClassification = SystemMetadata;
            Caption = 'Synchronize work order products/services';
        }
        field(204; "Line Post Rule"; Enum "FS Work Order Line Post Rule")
        {
            DataClassification = SystemMetadata;
            Caption = 'Automatically post project journal lines';
        }
        field(300; "Integration Type"; Enum "FS Integration Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Integration Type';

            trigger OnValidate()
            var
                IntegrationMgt: Codeunit "FS Integration Mgt.";
            begin
                IntegrationMgt.TestManualNoSeriesFlag(Rec."Integration Type");
                IntegrationMgt.TestOneServiceItemLinePerOrder(Rec."Integration Type");
            end;
        }
        field(301; "Default Work Order Incident ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Default Work Order Incident ID';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        if IsTemporary() then
            exit;
        if "User Password Key" <> xRec."User Password Key" then
            xRec.DeletePassword();
    end;

    trigger OnDelete()
    begin
        if IsTemporary() then
            exit;
        DeletePassword();
    end;

    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        FSIntegrationMgt: Codeunit "FS Integration Mgt.";
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
        CRMProductName: Codeunit "CRM Product Name";
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        TempUserPassword: SecretText;
        ConnectionErr: Label 'The connection setup cannot be validated. Verify the settings and try again.\Detailed error description: %1.', Comment = '%1 Error message from the provider (.NET exception message)';
        ConnectionStringFormatTok: Label 'Url=%1; UserName=%2; Password=%3; ProxyVersion=%4; %5', Locked = true;
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        DetailsMissingErr: Label 'A %1 URL and user name are required to enable a connection.', Comment = '%1 = CRM product name';
        MissingUsernameTok: Label '{USER}', Locked = true;
        MissingPasswordTok: Label '{PASSWORD}', Locked = true;
        AccessTokenTok: Label 'AccessToken', Locked = true;
        ClientSecretConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; ClientSecret=%4; ProxyVersion=%5', Locked = true;
        ClientSecretAuthTxt: Label 'AuthType=ClientSecret', Locked = true;
        ClientSecretTok: Label '{CLIENTSECRET}', Locked = true;
        CertificateConnectionStringFormatTxt: Label '%1; Url=%2; ClientId=%3; Certificate=%4; ProxyVersion=%5', Locked = true;
        CertificateAuthTxt: Label 'AuthType=Certificate', Locked = true;
        CertificateTok: Label '{CERTIFICATE}', Locked = true;
        ClientIdTok: Label '{CLIENTID}', Locked = true;
        UserNameMustIncludeDomainErr: Label 'The user name must include the domain when the authentication type is set to Active Directory.';
        UserNameMustBeEmailErr: Label 'The user name must be a valid email address when the authentication type is set to Office 365.';
        ConnectionStringPwdPlaceHolderMissingErr: Label 'The connection string must include the password placeholder {PASSWORD}.';
        ConnectionStringPwdOrClientSecretPlaceHolderMissingErr: Label 'The connection string must include either the password placeholder {PASSWORD}, the client secret placeholder {CLIENTSECRET} or the certificate placeholder {CERTIFICATE}.', Comment = '{PASSWORD}, {CERTIFICATE} and {CLIENTSECRET} are locked strings - do not translate them.';
        SystemAdminRoleTemplateIdTxt: Label '{627090FF-40A3-4053-8790-584EDC5BE201}', Locked = true;
        SystemAdminErr: Label 'User %1 has the %2 role on server %3.\\You must choose a user that does not have the %2 role.', Comment = '%1 user name, %2 - security role name, %3 - server address';
        BCRolesErr: Label 'User %1 does not have the required roles on server %4.\\You must choose a user that has the roles %2 and %3.', Comment = '%1 user name, %2 - security role name,  %3 - security role name, %4 - server address';
        UserNotLicensedErr: Label 'User %1 is not licensed on server %2.', Comment = '%1 user name, %2 - server address';
        UserNotActiveErr: Label 'User %1 is disabled on server %2.', Comment = '%1 user name, %2 - server address';
        UserHasNoRolesErr: Label 'User %1 has no user roles assigned on server %2.', Comment = '%1 user name, %2 - server address';
        BCIntegrationUserFSRoleIdTxt: Label '{c11b4fa8-956b-439d-8b3c-021e8736a78b}', Locked = true;
        CDSConnectionMustBeEnabledErr: Label 'You must enable the connection to Dataverse before you can set up the connection to %1.\\Choose ''Set up Dataverse connection'' in %2 page.', Comment = '%1 = CRM product name, %2 = Assisted Setup page caption.';
        CRMConnectionMustBeEnabledErr: Label 'You must enable the connection to Dynamics 365 Sales before you can set up the connection to %1.\\Choose ''Set up a connection to Dynamics 365 Sales'' in %2 page.', Comment = '%1 = FS product name, %2 = Assisted Setup page caption.';
        ShowDataverseConnectionSetupLbl: Label 'Show Dataverse Connection Setup';
        ShowCRMConnectionSetupLbl: Label 'Show Microsoft Dynamics 365 Connection Setup';
        DeploySucceedMsg: Label 'The solution, user roles, and entities have been deployed.';
        DeployFailedMsg: Label 'The deployment of the solution succeeded, but the deployment of user roles failed.';
        DeploySolutionFailedMsg: Label 'The deployment of the solution failed.';
        CategoryTok: Label 'AL Field Service Integration', Locked = true;
        CRMConnDisabledTxt: Label 'Field Service connection has been disabled.', Locked = true;
        CRMConnEnabledTxt: Label 'Field Service connection has been enabled.', Locked = true;
        DefaultingToDataverseServiceClientTxt: Label 'Defaulting to DataverseServiceClient', Locked = true;
        CRMConnSetupMustBeEnabledErr: label 'You must enable the connection in page %1', Comment = '%1 - page caption';
        HourUnitOfMeasureMustBePickedErr: label 'Field Service uses a fixed unit of measure for bookable resources - hour. You must pick a corresponding resource unit of measure.';
        UncoupleResourcesQst: label 'The current coupling of Resource records to Product entity will be removed. New mapping will be set up between Resource table and Bookable Resource entity. All resources will be uncoupled, but not deleted. Do you want to continue?';

    local procedure RemoveExistingCouplingOfResources(): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        IntegrationTableMapping.SetRange("Table ID", Database::Resource);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"CRM Product");
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);

        CRMIntegrationRecord.SetRange("Table ID", Database::Resource);

        if IntegrationTableMapping.IsEmpty() and CRMIntegrationRecord.IsEmpty() then
            exit(true);

        if not Confirm(UncoupleResourcesQst) then
            exit(false);

        if not IntegrationTableMapping.IsEmpty() then
            CRMIntegrationRecord.DeleteAll();

        IntegrationTableMapping.DeleteAll(true);
        exit(true);
    end;

    internal procedure EnsureCDSConnectionIsEnabled();
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if Get() then
            if "Is Enabled" then
                exit;

        if CDSConnectionSetup.Get() then
            if CDSConnectionSetup."Is Enabled" then
                exit;

        CDSConnectionNotEnabledError();
    end;

    internal procedure EnsureCRMConnectionIsEnabled();
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
    begin
        if Get() then
            if "Is Enabled" then
                exit;

        if CRMConnectionSetup.Get() then
            if CRMConnectionSetup."Is Enabled" then
                exit;

        CRMConnectionNotEnabledError();
    end;

    internal procedure LoadConnectionStringElementsFromCDSConnectionSetup();
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if Get() then
            if "Is Enabled" then
                exit;

        if CDSConnectionSetup.Get() then
            if CDSConnectionSetup."Is Enabled" then begin
                "Server Address" := CDSConnectionSetup."Server Address";
                "User Name" := CDSConnectionSetup."User Name";
                "User Password Key" := CDSConnectionSetup."User Password Key";
                "Authentication Type" := CDSConnectionSetup."Authentication Type";
                "Proxy Version" := CDSConnectionSetup."Proxy Version";
                if not Modify() then
                    Insert();
                SetConnectionString(CDSConnectionSetup."Connection String");
                exit;
            end;

        CDSConnectionNotEnabledError();
    end;

    internal procedure DeployFSSolution(ForceRedeploy: Boolean);
    var
        DummyCRMConnectionSetup: Record "CRM Connection Setup";
        AdminEmail: Text;
        AdminPassword: SecretText;
        AccessToken: SecretText;
        AdminADDomain: Text;
        ImportSolutionFailed: Boolean;
    begin
        if not ForceRedeploy and FSIntegrationMgt.IsFSSolutionInstalled() then
            exit;

        DummyCRMConnectionSetup.EnsureCDSConnectionIsEnabled();
        case "Authentication Type" of
            "Authentication Type"::Office365:
                CDSIntegrationImpl.GetAccessToken("Server Address", true, AccessToken);
            "Authentication Type"::AD:
                if not PromptForCredentials(AdminEmail, AdminPassword, AdminADDomain) then
                    exit;
            else
                if not PromptForCredentials(AdminEmail, AdminPassword) then
                    exit;
        end;

        if FSIntegrationMgt.ImportFSSolution("Server Address", "User Name", AdminEmail, AdminPassword, AccessToken, AdminADDomain, GetProxyVersion(), ForceRedeploy, ImportSolutionFailed) then
            Message(DeploySucceedMsg)
        else
            if ImportSolutionFailed then
                Message(DeploySolutionFailedMsg)
            else
                Message(DeployFailedMsg);
    end;

    internal procedure CountCRMJobQueueEntries(var ActiveJobs: Integer; var TotalJobs: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not "Is Enabled" then begin
            TotalJobs := 0;
            ActiveJobs := 0;
        end else begin
            if "Is FS Solution Installed" then
                JobQueueEntry.SetFilter("Object ID to Run", GetJobQueueEntriesObjectIDToRunFilter())
            else
                JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
            TotalJobs := JobQueueEntry.Count();

            JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
            ActiveJobs := JobQueueEntry.Count();
        end;
    end;

    internal procedure SetPassword(PasswordText: SecretText)
    begin
        if IsTemporary() then begin
            TempUserPassword := PasswordText;
            exit;
        end;
        if IsNullGuid("User Password Key") then
            "User Password Key" := CreateGuid();

        IsolatedStorageManagement.Set("User Password Key", PasswordText, DATASCOPE::Company);
    end;

    internal procedure DeletePassword()
    begin
        if IsTemporary() then begin
            Clear(TempUserPassword);
            exit;
        end;

        if IsNullGuid("User Password Key") then
            exit;

        IsolatedStorageManagement.Delete(Format("User Password Key"), DATASCOPE::Company);
    end;

    internal procedure RegisterConnection()
    begin
        if not HasTableConnection(TableConnectionType::CRM, "Primary Key") then
            RegisterConnectionWithName("Primary Key");
    end;

    [NonDebuggable]
    internal procedure RegisterConnectionWithName(ConnectionName: Text)
    begin
        RegisterTableConnection(TableConnectionType::CRM, ConnectionName, GetConnectionStringWithCredentials().Unwrap());
        SetDefaultTableConnection(TableConnectionType::CRM, GetDefaultFSConnection(ConnectionName));
    end;

    internal procedure UnregisterConnection(): Boolean
    begin
        exit(UnregisterConnectionWithName("Primary Key"));
    end;

    [TryFunction]
    internal procedure UnregisterConnectionWithName(ConnectionName: Text)
    begin
        UnregisterTableConnection(TableConnectionType::CRM, ConnectionName);
    end;

    [NonDebuggable]
    internal procedure GetConnectionStringWithCredentials() ConnectionString: SecretText
    var
        ConnectionStringWithPlaceholders: Text;
        PasswordPlaceHolderPos: Integer;
    begin
        ConnectionStringWithPlaceholders := GetConnectionStringAsStoredInSetup();

        // if the setup record is temporary and connection string contains access token, this is a temp setup record constructed for the admin log-on
        // in this case just use the connection string
        if IsTemporary() and ConnectionStringWithPlaceholders.Contains(AccessTokenTok) then
            exit(ConnectionStringWithPlaceholders);

        if ConnectionStringWithPlaceholders = '' then
            ConnectionStringWithPlaceholders := UpdateConnectionString();

        // if auth type is Office365 and connection string contains {ClientSecret} token
        // then we will connect via OAuth client credentials grant flow, and construct the connection string accordingly, with the actual client secret
        if "Authentication Type" = "Authentication Type"::Office365 then begin
            if ConnectionStringWithPlaceholders.Contains(ClientSecretTok) then begin
                ConnectionStringWithPlaceholders := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, "Server Address", CDSIntegrationImpl.GetCDSConnectionClientId(), '%1', GetProxyVersion());
                ConnectionString := SecretStrSubstNo(ConnectionStringWithPlaceholders, CDSIntegrationImpl.GetCDSConnectionClientSecret());
                exit(ConnectionString);
            end;

            if ConnectionStringWithPlaceholders.Contains(CertificateTok) then begin
                ConnectionString := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, "Server Address", CDSIntegrationImpl.GetCDSConnectionFirstPartyAppId(), CDSIntegrationImpl.GetCDSConnectionFirstPartyAppCertificate(), GetProxyVersion());
                exit(ConnectionString);
            end;
        end;

        PasswordPlaceHolderPos := StrPos(ConnectionStringWithPlaceholders, MissingPasswordTok);
        ConnectionStringWithPlaceholders :=
          CopyStr(ConnectionStringWithPlaceholders, 1, PasswordPlaceHolderPos - 1) + '%1' +
          CopyStr(ConnectionStringWithPlaceholders, PasswordPlaceHolderPos + StrLen(MissingPasswordTok));
        ConnectionString := SecretStrSubstNo(ConnectionStringWithPlaceholders, GetPassword());
    end;

    [NonDebuggable]
    internal procedure GetPassword(): SecretText
    var
        Value: SecretText;
    begin
        if IsTemporary() then
            exit(TempUserPassword);
        if not IsNullGuid("User Password Key") then
            IsolatedStorageManagement.Get("User Password Key", DATASCOPE::Company, Value);
        exit(Value);
    end;

    local procedure GetUserName() UserName: Text
    begin
        if "User Name" = '' then
            UserName := MissingUsernameTok
        else
            UserName := CopyStr("User Name", StrPos("User Name", '\') + 1);
    end;

    internal procedure GetJobQueueEntriesObjectIDToRunFilter(): Text
    begin
        exit(
          StrSubstNo(
            '%1|%2|%3|%4|%5|%6',
            Codeunit::"Integration Synch. Job Runner",
            Codeunit::"CRM Statistics Job",
            Codeunit::"Auto Create Sales Orders",
            Codeunit::"Auto Process Sales Quotes",
            Codeunit::"Int. Uncouple Job Runner",
            Codeunit::"Int. Coupling Job Runner"));
    end;

    internal procedure PerformTestConnection()
    begin
        VerifyTestConnection();
        Message(ConnectionSuccessMsg);
    end;

    internal procedure VerifyTestConnection(): Boolean
    begin
        if ("Server Address" = '') or ("User Name" = '') then
            Error(DetailsMissingErr, CRMProductName.FSServiceName());

        CRMIntegrationManagement.ClearState();

        if not TestConnection() then
            Error(ConnectionErr, CRMIntegrationManagement.GetLastErrorMessage());

        TestIntegrationUserRequirements();

        exit(true);
    end;

    internal procedure TestConnection() Success: Boolean
    var
        TestConnectionName: Text;
    begin
        TestConnectionName := Format(CreateGuid());
        UnregisterConnectionWithName(TestConnectionName);
        RegisterConnectionWithName(TestConnectionName);
        SetDefaultTableConnection(
          TableConnectionType::CRM, GetDefaultFSConnection(TestConnectionName), true);
        Success := TryReadSystemUsers();

        UnregisterConnectionWithName(TestConnectionName);
    end;

    internal procedure TestIntegrationUserRequirements()
    var
        CRMRole: Record "CRM Role";
        TempCRMRole: Record "CRM Role" temporary;
        CRMSystemuserroles: Record "CRM Systemuserroles";
        CRMSystemuser: Record "CRM Systemuser";
        BCIntAdminCRMRoleName: Text;
        BCIntUserCRMRoleName: Text;
        SystemAdminCRMRoleName: Text;
        TestConnectionName: Text;
        BCIntegrationAdminRoleDeployed: Boolean;
        BCIntegrationRolesDeployed: Boolean;
        ChosenUserIsSystemAdmin: Boolean;
        ChosenUserHasBCFSSecurityRole: Boolean;
    begin
        TestConnectionName := Format(CreateGuid());
        UnregisterConnectionWithName(TestConnectionName);
        RegisterConnectionWithName(TestConnectionName);
        SetDefaultTableConnection(
          TableConnectionType::CRM, GetDefaultFSConnection(TestConnectionName), true);

        if CRMRole.FindSet() then
            repeat
                TempCRMRole.TransferFields(CRMRole);
                TempCRMRole.Insert();
                if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationUserFSRoleIdTxt then begin
                    BCIntegrationAdminRoleDeployed := true;
                    BCIntAdminCRMRoleName := TempCRMRole.Name;
                end;
            until CRMRole.Next() = 0;

        BCIntegrationRolesDeployed := BCIntegrationAdminRoleDeployed;

        CRMSystemuser.SetFilter(InternalEMailAddress, StrSubstNo('@%1', "User Name"));
        if CRMSystemuser.FindFirst() then begin
            if CRMSystemuser.IsDisabled then
                Error(UserNotActiveErr, "User Name", "Server Address");
            if "Authentication Type" <> "Authentication Type"::Office365 then
                if not CRMSystemuser.IsLicensed then
                    Error(UserNotLicensedErr, "User Name", "Server Address");

            CRMSystemuserroles.SetRange(SystemUserId, CRMSystemuser.SystemUserId);
            if CRMSystemuserroles.FindSet() then
                repeat
                    if TempCRMRole.Get(CRMSystemuserroles.RoleId) then begin
                        if UpperCase(Format(TempCRMRole.RoleTemplateId)) = SystemAdminRoleTemplateIdTxt then begin
                            ChosenUserIsSystemAdmin := true;
                            SystemAdminCRMRoleName := TempCRMRole.Name
                        end;
                        if LowerCase(Format(TempCRMRole.RoleId)) = BCIntegrationUserFSRoleIdTxt then
                            ChosenUserHasBCFSSecurityRole := true;
                    end;
                until CRMSystemuserroles.Next() = 0
            else
                if ("Server Address" <> '') and ("Server Address" <> '@@test@@') then
                    Error(UserHasNoRolesErr, "User Name", "Server Address");

            if ChosenUserIsSystemAdmin then
                Error(SystemAdminErr, "User Name", SystemAdminCRMRoleName, "Server Address");

            if BCIntegrationRolesDeployed and not ChosenUserHasBCFSSecurityRole then
                Error(BCRolesErr, "User Name", BCIntAdminCRMRoleName, BCIntUserCRMRoleName, "Server Address");
        end;

        UnregisterConnectionWithName(TestConnectionName);
    end;

    [TryFunction]
    internal procedure TryReadSystemUsers()
    var
        CRMSystemuser: Record "CRM Systemuser";
    begin
        if CRMSystemuser.Count() > 0 then
            exit;
    end;

    internal procedure UpdateFromWizard(var SourceFSConnectionSetup: Record "FS Connection Setup"; PasswordText: SecretText)
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
        Validate("Server Address", SourceFSConnectionSetup."Server Address");
        Validate("Authentication Type", "Authentication Type"::Office365);
        Validate("User Name", SourceFSConnectionSetup."User Name");
        SetPassword(PasswordText);
        Validate("Proxy Version", SourceFSConnectionSetup."Proxy Version");
        Validate("Job Journal Template", SourceFSConnectionSetup."Job Journal Template");
        Validate("Job Journal Batch", SourceFSConnectionSetup."Job Journal Batch");
        Validate("Hour Unit of Measure", SourceFSConnectionSetup."Hour Unit of Measure");
        Validate("Line Synch. Rule", SourceFSConnectionSetup."Line Synch. Rule");
        Validate("Line Post Rule", SourceFSConnectionSetup."Line Post Rule");
        Modify(true);
    end;

    internal procedure EnableFSConnectionFromWizard()
    begin
        Get();
        Validate("Is Enabled", true);
        Modify(true);
    end;

    local procedure UpdateConnectionDetails()
    begin
        if "Is Enabled" = xRec."Is Enabled" then
            exit;

        if not UnregisterConnection() then
            ClearLastError();

        if "Is Enabled" then begin
            VerifyTestConnection();
            RegisterConnection();
            InstallIntegrationSolution();
            EnableIntegrationTables();
            if "Disable Reason" <> '' then
                Clear("Disable Reason");
        end else begin
            "FS Version" := '';
            "Is FS Solution Installed" := false;
            CurrencyDecimalPrecision := 0;
            Clear(BaseCurrencyId);
            BaseCurrencyPrecision := 0;
            BaseCurrencySymbol := '';
            UpdateFSJobQueueEntriesStatus();
        end;
    end;

    local procedure InstallIntegrationSolution()
    var
        AdminEmail: Text;
        AdminPassword: SecretText;
        AccessToken: SecretText;
        AdminADDomain: Text;
        ImportSolutionFailed: Boolean;
    begin
        if FSIntegrationMgt.IsFSSolutionInstalled() then
            exit;

        case "Authentication Type" of
            "Authentication Type"::Office365:
                CDSIntegrationImpl.GetAccessToken("Server Address", true, AccessToken);
            "Authentication Type"::AD:
                if not PromptForCredentials(AdminEmail, AdminPassword, AdminADDomain) then
                    exit;
            else
                if not PromptForCredentials(AdminEmail, AdminPassword) then
                    exit;
        end;

        FSIntegrationMgt.ImportFSSolution(
            "Server Address", "User Name", AdminEmail, AdminPassword, AccessToken, AdminADDomain, GetProxyVersion(), false, ImportSolutionFailed);
    end;

    local procedure EnableIntegrationTables()
    var
        FSSetupDefaults: Codeunit "FS Setup Defaults";
    begin
        Modify(); // Job Queue to read "Is Enabled"
        Commit();
        FSSetupDefaults.ResetConfiguration(Rec);
    end;

    internal procedure RefreshDataFromFS()
    begin
        RefreshDataFromFS(true);
    end;

    internal procedure RefreshDataFromFS(ResetSalesOrderMappingConfiguration: Boolean)
    begin
        if "Is Enabled" then begin
            "Is FS Solution Installed" := FSIntegrationMgt.IsFSSolutionInstalled();
            if not TryRefreshFSSettings() then
                exit;
        end;
    end;

    [TryFunction]
    local procedure TryRefreshFSSettings()
    var
        CRMOrganization: Record "CRM Organization";
    begin
        if CRMOrganization.FindFirst() then begin
            CurrencyDecimalPrecision := CRMOrganization.CurrencyDecimalPrecision;
            BaseCurrencyId := CRMOrganization.BaseCurrencyId;
            BaseCurrencyPrecision := CRMOrganization.BaseCurrencyPrecision;
            BaseCurrencySymbol := CRMOrganization.BaseCurrencySymbol;
        end
    end;

    [NonDebuggable]
    internal procedure PromptForCredentials(var AdminEmail: Text; var AdminPassword: SecretText): Boolean
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
    begin
        if TempOfficeAdminCredentials.IsEmpty() then begin
            TempOfficeAdminCredentials.Init();
            TempOfficeAdminCredentials.Insert(true);
            Commit();
            if Page.RunModal(Page::"Dynamics CRM Admin Credentials", TempOfficeAdminCredentials) <> Action::LookupOK then
                exit(false);
        end;
        if (not TempOfficeAdminCredentials.FindFirst()) or
           (TempOfficeAdminCredentials.Email = '') or (TempOfficeAdminCredentials.Password = '')
        then begin
            TempOfficeAdminCredentials.DeleteAll(true);
            exit(false);
        end;

        AdminEmail := TempOfficeAdminCredentials.Email;
        AdminPassword := TempOfficeAdminCredentials.Password;
        exit(true);
    end;

    [NonDebuggable]
    internal procedure PromptForCredentials(var AdminEmail: Text; var AdminPassword: SecretText; var AdminADDomain: Text): Boolean
    var
        TempOfficeAdminCredentials: Record "Office Admin. Credentials" temporary;
        BackslashPos: Integer;
    begin
        if TempOfficeAdminCredentials.IsEmpty() then begin
            TempOfficeAdminCredentials.Init();
            TempOfficeAdminCredentials.Insert(true);
            Commit();
            if Page.RunModal(Page::"Dynamics CRM Admin Credentials", TempOfficeAdminCredentials) <> Action::LookupOK then
                exit(false);
        end;
        if (not TempOfficeAdminCredentials.FindFirst()) or
           (TempOfficeAdminCredentials.Email = '') or (TempOfficeAdminCredentials.Password = '')
        then begin
            TempOfficeAdminCredentials.DeleteAll(true);
            exit(false);
        end;

        BackslashPos := StrPos(TempOfficeAdminCredentials.Email, '\');
        if (BackslashPos <= 1) or (BackslashPos = StrLen(TempOfficeAdminCredentials.Email)) then
            Error(UserNameMustIncludeDomainErr);
        AdminADDomain := CopyStr(TempOfficeAdminCredentials.Email, 1, BackslashPos - 1);
        AdminEmail := CopyStr(TempOfficeAdminCredentials.Email, BackslashPos + 1);
        AdminPassword := TempOfficeAdminCredentials.Password;
        exit(true);
    end;

    local procedure GetDefaultFSConnection(ConnectionName: Text): Text
    begin
        OnGetDefaultFSConnection(ConnectionName);
        exit(ConnectionName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDefaultFSConnection(var ConnectionName: Text)
    begin
    end;

    local procedure CrmAuthenticationType(): Text
    begin
        case "Authentication Type" of
            "Authentication Type"::Office365:
                exit('AuthType=Office365;');
            "Authentication Type"::AD:
                exit('AuthType=AD;' + GetDomain());
            "Authentication Type"::IFD:
                exit('AuthType=IFD;' + GetDomain() + 'HomeRealmUri= ;');
            "Authentication Type"::OAuth:
                exit('AuthType=OAuth;' + 'AppId= ;' + 'RedirectUri= ;' + 'TokenCacheStorePath= ;' + 'LoginPrompt=Auto;');
        end;
    end;

    internal procedure UpdateConnectionString() ConnectionString: Text
    begin
        if "Authentication Type" <> "Authentication Type"::Office365 then
            ConnectionString := StrSubstNo(ConnectionStringFormatTok, "Server Address", GetUserName(), MissingPasswordTok, GetProxyVersion(), CrmAuthenticationType())
        else
            if CDSIntegrationImpl.GetCDSConnectionFirstPartyAppId() <> '' then
                ConnectionString := StrSubstNo(CertificateConnectionStringFormatTxt, CertificateAuthTxt, "Server Address", ClientIdTok, CertificateTok, GetProxyVersion())
            else
                ConnectionString := StrSubstNo(ClientSecretConnectionStringFormatTxt, ClientSecretAuthTxt, "Server Address", ClientIdTok, ClientSecretTok, GetProxyVersion());

        SetConnectionString(ConnectionString);
    end;

    local procedure UpdateProxyVersionInConnectionString() ConnectionString: Text
    var
        LeftPart: Text;
        RightPart: Text;
        ProxyVersionTok: Text;
        IndexOfProxyVersion: Integer;
    begin
        ProxyVersionTok := 'ProxyVersion=';
        ConnectionString := GetConnectionStringAsStoredInSetup();

        // if the connection string is empty, just initialize it the standard way
        if ConnectionString = '' then begin
            ConnectionString := UpdateConnectionString();
            exit;
        end;

        IndexOfProxyVersion := ConnectionString.IndexOf(ProxyVersionTok);

        // if there is no proxy version in the connection string, just add it to the end
        if IndexOfProxyVersion = 0 then begin
            ConnectionString += ('; ' + ProxyVersionTok + Format(GetProxyVersion()));
            SetConnectionString(ConnectionString);
            exit;
        end;

        LeftPart := CopyStr(ConnectionString, 1, IndexOfProxyVersion - 1);
        RightPart := CopyStr(ConnectionString, IndexOfProxyVersion);

        // RightPart starts with ProxyVersion=
        // if there is no ; in it, then this is the end of the original connection string
        // just add proxy version to the end of LeftPart
        if RightPart.IndexOf(';') = 0 then begin
            ConnectionString := LeftPart + ProxyVersionTok + Format(GetProxyVersion());
            SetConnectionString(ConnectionString);
            exit;
        end;

        // in the remaining case, ProxyVersion=XYZ is in the middle of the string
        RightPart := CopyStr(RightPart, RightPart.IndexOf(';'));
        ConnectionString := LeftPart + ProxyVersionTok + Format(GetProxyVersion()) + RightPart;
        SetConnectionString(ConnectionString);
    end;

    local procedure UpdateDomainName()
    begin
        if "User Name" <> '' then
            if StrPos("User Name", '\') > 0 then
                Validate(Domain, CopyStr("User Name", 1, StrPos("User Name", '\') - 1))
            else
                Domain := '';
    end;

    local procedure CheckUserName()
    begin
        if "User Name" <> '' then
            case "Authentication Type" of
                "Authentication Type"::AD:
                    if StrPos("User Name", '\') = 0 then
                        Error(UserNameMustIncludeDomainErr);
                "Authentication Type"::Office365:
                    if StrPos("User Name", '@') = 0 then
                        Error(UserNameMustBeEmailErr);
            end;
    end;

    local procedure GetDomain(): Text
    var
        DomainLbl: Label 'Domain=%1;', Locked = true;
    begin
        if Domain <> '' then
            exit(StrSubstNo(DomainLbl, Domain));
    end;

    local procedure UpdateFSJobQueueEntriesStatus()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        NewStatus: Option;
    begin
        if "Is Enabled" then
            NewStatus := JobQueueEntry.Status::Ready
        else
            NewStatus := JobQueueEntry.Status::"On Hold";
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", Codeunit::"CRM Integration Table Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if CDSIntegrationImpl.IsIntegrationEnabled() then
            IntegrationTableMapping.SetFilter("Table ID", StrSubstNo('<>%1&<>%2&<>%3&<>%4', Database::"Job Journal Line", Database::"Job Task", Database::Resource, Database::"Service Item"));
        if IntegrationTableMapping.FindSet() then
            repeat
                JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId);
                if JobQueueEntry.FindSet() then
                    repeat
                        JobQueueEntry.SetStatus(NewStatus);
                    until JobQueueEntry.Next() = 0;
            until IntegrationTableMapping.Next() = 0;
    end;

    internal procedure GetConnectionStringAsStoredInSetup() ConnectionString: Text
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        InStream: InStream;
    begin
        if CRMConnectionSetup.Get("Primary Key") then
            CalcFields("Server Connection String");
        "Server Connection String".CreateInStream(InStream);
        InStream.ReadText(ConnectionString);
    end;

    internal procedure SetConnectionString(ConnectionString: Text)
    var
        OutStream: OutStream;
    begin
        if ConnectionString = '' then
            Clear("Server Connection String")
        else begin
            if "Authentication Type" <> "Authentication Type"::Office365 then
                if StrPos(ConnectionString, MissingPasswordTok) = 0 then
                    Error(ConnectionStringPwdPlaceHolderMissingErr);

            if "Authentication Type" = "Authentication Type"::Office365 then
                if (StrPos(ConnectionString, MissingPasswordTok) = 0) and (StrPos(ConnectionString, ClientSecretTok) = 0) and (StrPos(ConnectionString, CertificateTok) = 0) then
                    Error(ConnectionStringPwdOrClientSecretPlaceHolderMissingErr);

            Clear("Server Connection String");
            "Server Connection String".CreateOutStream(OutStream);
            OutStream.WriteText(ConnectionString);
        end;
        if not Modify() then;
    end;

    internal procedure IsEnabled(): Boolean
    begin
        if not Get() then
            exit(false);
        exit("Is Enabled");
    end;

    internal procedure GetProxyVersion(): Integer
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if "Proxy Version" >= 100 then
            exit("Proxy Version");

        if not EnvironmentInformation.IsSaaS() then
            exit("Proxy Version");

        Session.LogMessage('0000K7P', DefaultingToDataverseServiceClientTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(100);
    end;

    local procedure CDSConnectionNotEnabledError()
    var
        AssistedSetup: Page "Assisted Setup";
        CDSConnectionNotEnabledErrorInfo: ErrorInfo;
    begin
        CDSConnectionNotEnabledErrorInfo.DataClassification := CDSConnectionNotEnabledErrorInfo.DataClassification::SystemMetadata;
        CDSConnectionNotEnabledErrorInfo.ErrorType := CDSConnectionNotEnabledErrorInfo.ErrorType::Client;
        CDSConnectionNotEnabledErrorInfo.Verbosity := CDSConnectionNotEnabledErrorInfo.Verbosity::Error;
        CDSConnectionNotEnabledErrorInfo.Message := StrSubstNo(CDSConnectionMustBeEnabledErr, CRMProductName.FSServiceName(), AssistedSetup.Caption());
        CDSConnectionNotEnabledErrorInfo.AddNavigationAction(ShowDataverseConnectionSetupLbl);
        CDSConnectionNotEnabledErrorInfo.PageNo(Page::"CDS Connection Setup Wizard");
        Error(CDSConnectionNotEnabledErrorInfo);
    end;

    local procedure CRMConnectionNotEnabledError()
    var
        AssistedSetup: Page "Assisted Setup";
        CRMConnectionNotEnabledErrorInfo: ErrorInfo;
    begin
        CRMConnectionNotEnabledErrorInfo.DataClassification := CRMConnectionNotEnabledErrorInfo.DataClassification::SystemMetadata;
        CRMConnectionNotEnabledErrorInfo.ErrorType := CRMConnectionNotEnabledErrorInfo.ErrorType::Client;
        CRMConnectionNotEnabledErrorInfo.Verbosity := CRMConnectionNotEnabledErrorInfo.Verbosity::Error;
        CRMConnectionNotEnabledErrorInfo.Message := StrSubstNo(CRMConnectionMustBeEnabledErr, CRMProductName.FSServiceName(), AssistedSetup.Caption());
        CRMConnectionNotEnabledErrorInfo.AddNavigationAction(ShowCRMConnectionSetupLbl);
        CRMConnectionNotEnabledErrorInfo.PageNo(Page::"CRM Connection Setup Wizard");
        Error(CRMConnectionNotEnabledErrorInfo);
    end;
}

