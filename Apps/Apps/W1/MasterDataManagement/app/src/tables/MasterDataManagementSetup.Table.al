namespace Microsoft.Integration.MDM;

using System.Threading;
using System.Environment;
using Microsoft.Foundation.Company;
using System.Telemetry;
using Microsoft.Integration.SyncEngine;
using Microsoft.Utilities;

table 7230 "Master Data Management Setup"
{
    Caption = 'Master Data Management Setup';
    Permissions = tabledata "Master Data Mgt. Coupling" = rd,
                  tabledata "Master Data Mgt. Subscriber" = rid,
                  tabledata "Job Queue Entry" = rm;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(60; "Is Enabled"; Boolean)
        {
            Caption = 'Synchronization Enabled';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Is Enabled" then
                    if "Company Name" = '' then
                        Error(MustPickSourceCompanyErr);
            end;
        }
        field(151; "Company Name"; Text[30])
        {
            Caption = 'Source Company';
            TableRelation = Company;
            DataClassification = OrganizationIdentifiableInformation;

            trigger OnLookup()
            var
                Company: Record Company;
            begin
                if not LookupCompanies(Company) then
                    exit;

                Rec.Validate("Company Name", Company.Name);
            end;

            trigger OnValidate()
            var
                MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
                MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
                MasterDataManagement: Codeunit "Master Data Management";
                CurrentCompanyName: Text[30];
            begin
                if Rec."Is Enabled" then
                    if Rec."Company Name" <> xRec."Company Name" then
                        Error('');

                if Rec."Company Name" = CompanyName() then
                    Error(MustNotPickCurrentCompanyErr);

                if (xRec."Company Name" <> '') and (xRec."Company Name" <> Rec."Company Name") then
                    if not MasterDataMgtCoupling.IsEmpty() then
                        if not Confirm(StrSubstNo(CouplingsWillBeDeletedQst, xRec."Company Name")) then
                            Error('');

                CurrentCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(MasterDataMgtSubscriber."Company Name"));
                MasterDataManagement.RemoveSubsidiarySubscriptionFromMasterCompany(xRec."Company Name", CurrentCompanyName);
                MasterDataManagement.AddSubsidiarySubscriptionToMasterCompany(Rec."Company Name", CurrentCompanyName);
                MasterDataMgtCoupling.DeleteAll();
            end;
        }
        field(152; "Delay Job Scheduling"; Boolean)
        {
            Caption = 'Delay Synchronization Job Scheduling';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if IsTemporary() then
            exit;

        if "Is Enabled" then
            EnableConnection()
        else
            DisableConnection();
    end;

    trigger OnModify()
    var
        IsEnabledChanged: Boolean;
    begin
        if IsTemporary() then
            exit;

        if "Is Enabled" then
            EnableConnection()
        else
            DisableConnection();

        GetConfigurationUpdates(IsEnabledChanged);
    end;

    trigger OnDelete()
    begin
        if IsTemporary() then
            exit;

        DisableConnection();
    end;

    procedure LookupCompanies(var Company: Record Company): Boolean
    var
        Companies: Page Companies;
        Result: Boolean;
    begin
        Company.SetFilter(Name, '<>%1', CompanyName());
        Companies.SetTableView(Company);
        Companies.SetRecord(Company);
        Companies.LookupMode := true;
        Result := Companies.RunModal() = ACTION::LookupOK;
        if Result then
            Companies.GetRecord(Company)
        else
            Clear(Company);

        exit(Result);
    end;

    local procedure EnableConnection()
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        IntegrationTableMapping: Record "Integration Table Mapping";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        MasterDataMgtSetupDefault: Codeunit "Master Data Mgt. Setup Default";
        MasterDataManagement: Codeunit "Master Data Management";
        CurrentCompanyName: Text[30];
        ResetConfig: Boolean;
    begin
        FeatureTelemetry.LogUptake('0000JIL', MasterDataManagement.GetFeatureName(), Enum::"Feature Uptake Status"::"Set up");
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.IsEmpty() then
            ResetConfig := true
        else
            ResetConfig := Confirm(ResetConfigQst);
        if ResetConfig then
            MasterDataMgtSetupDefault.ResetConfiguration(Rec);
        CurrentCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(MasterDataMgtSubscriber."Company Name"));
        MasterDataManagement.AddSubsidiarySubscriptionToMasterCompany(Rec."Company Name", CurrentCompanyName);
        Message(StrSubstNo(SynchronizationEnabledMsg, Rec."Company Name"));
        Session.LogMessage('0000JIM', Rec."Company Name", Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
        Session.LogMessage('0000JIN', CurrentCompanyName, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
    end;

    local procedure GetConfigurationUpdates(var IsEnabledChanged: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        IsEnabledChanged := "Is Enabled" <> xRec."Is Enabled";
        if not IsEnabledChanged then
            if MasterDataManagementSetup.Get() then
                IsEnabledChanged := "Is Enabled" <> MasterDataManagementSetup."Is Enabled";
    end;

    local procedure DisableConnection()
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        CurrentCompanyName: Text[30];
    begin
        CurrentCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(Rec."Company Name"));

        MasterDataManagement.RemoveSubsidiarySubscriptionFromMasterCompany(Rec."Company Name", CurrentCompanyName);
        UpdateDataSynchJobQueueEntriesStatus();

        if not MasterDataMgtCoupling.IsEmpty() then
            if Confirm(StrSubstNo(KeepTheCouplingsQst, Rec."Company Name")) then
                exit
            else begin
                IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
                if IntegrationTableMapping.FindSet() then
                    repeat
                        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
                        IntegrationFieldMapping.DeleteAll();
                    until IntegrationTableMapping.Next() = 0;
                IntegrationTableMapping.DeleteAll();
                MasterDataMgtCoupling.DeleteAll();
            end;
    end;

    internal procedure SynchronizeNow(DoFullSynch: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
    begin
        MasterDataManagementSetupDefaults.GetPrioritizedMappingList(TempNameValueBuffer);

        TempNameValueBuffer.Ascending(true);
        if not TempNameValueBuffer.FindSet() then
            exit;

        repeat
            if IntegrationTableMapping.Get(TempNameValueBuffer.Value) then
                IntegrationTableMapping.SynchronizeNow(DoFullSynch);
        until TempNameValueBuffer.Next() = 0;
    end;

    local procedure UpdateDataSynchJobQueueEntriesStatus()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        NewStatus: Option;
    begin
        if "Is Enabled" then
            NewStatus := JobQueueEntry.Status::Ready
        else
            NewStatus := JobQueueEntry.Status::"On Hold";
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"Integration Master Data Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if IntegrationTableMapping.FindSet() then
            repeat
                JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
                if JobQueueEntry.FindSet() then
                    repeat
                        JobQueueEntry.SetStatus(NewStatus);
                    until JobQueueEntry.Next() = 0;
            until IntegrationTableMapping.Next() = 0;
    end;

    var
        SynchronizationEnabledMsg: label 'The synchronization of data from company %1 is enabled. \\To review the tables and fields that will be synchronized, choose action Synchronization Tables. \\To perform the initial synchronization of data from %1, choose Start Initial Synchronization. \\After the initial synchronization is done, job queue entries will continue to synchronize modifications.', Comment = '%1 - a company name';
        CouplingsWillBeDeletedQst: label 'All the couplings with records from previous source company %1 will be deleted. Do you want to continue?', Comment = '%1 - a company name';
        KeepTheCouplingsQst: label 'Data synchronization with company %1 is disabled. \\We recommend to keep the table setup and coupling information, especially if you intend to reenable the synchronization with the same company. \\Do you want to keep the table setup and coupling information?', Comment = '%1 - a company name';
        MustNotPickCurrentCompanyErr: label 'You are currently signed into this company. \\Choose a different company to synchronize data with.';
        MustPickSourceCompanyErr: label 'You must choose a source company to synchronize data from.';
        ResetConfigQst: label 'There are existing synchronization table definitions in this company. Do you want to reset them to the default configuration?';
}
