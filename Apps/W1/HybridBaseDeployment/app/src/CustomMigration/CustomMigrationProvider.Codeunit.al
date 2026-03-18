// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using Microsoft.Utilities;
using System.Reflection;

/// <summary>
/// Default custom cloud migration provider
/// </summary>
codeunit 40034 "Custom Migration Provider" implements "Custom Migration Provider", "Custom Migration Table Mapping"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetReplicationTableMappingName(): Text
    begin
        exit(GetTableName(Database::"Replication Table Mapping"))
    end;

    procedure GetMigrationSetupTableMappingName(): Text
    begin
        exit(GetTableName(Database::"Migration Setup Table Mapping"));
    end;

    procedure GetCompaniesTableName(): Text
    begin
        exit(CompanyTok);
    end;

    procedure ShowConfigureMigrationTablesMappingStep(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit(false);

        if IntelligentCloudSetup."Custom Migration Provider" <> IntelligentCloudSetup."Custom Migration Provider"::"Custom Migration Provider" then
            exit(false);

        exit(IntelligentCloudSetup."Custom Migration Enabled");
    end;

    local procedure GetTableName(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);
        exit(TableMetadata.Name + BCTableSeparatorTok + LowerCase(Format(GetAppId()).TrimStart(OpenBraceTok).TrimEnd(CloseBraceTok)));
    end;

    procedure GetDisplayName(): Text[250]
    begin
        exit(CustomMigrationDisplayNameLbl);
    end;

    procedure GetDescription(): Text
    begin
        exit(CustomMigrationDescriptionLbl);
    end;

    procedure GetAppId(): Guid
    var
        CurrentAppModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentAppModuleInfo);
        exit(CurrentAppModuleInfo.Id);
    end;

    procedure GetDemoDataType() DemoDataType: Enum "Company Demo Data Type"
    begin
        exit(DemoDataType::"Production - Setup Data Only");
    end;

    procedure SetupReplicationTableMappings()
    begin
        OnSetupReplicationTableMappings();
    end;

    procedure SetupMigrationSetupTableMappings()
    begin
        OnSetupMigrationSetupTableMappings();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'OnOpenNewUI', '', false, false)]
    local procedure HandleOnOpenNewUI(var OpenNewUI: Boolean)
    begin
        if GetCustomMigrationEnabled() then
            OpenNewUI := true;
    end;

    local procedure GetCustomMigrationEnabled(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit(false);

        exit(IntelligentCloudSetup."Custom Migration Enabled" and
             (IntelligentCloudSetup."Custom Migration Provider" = IntelligentCloudSetup."Custom Migration Provider"::"Custom Migration Provider"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupReplicationTableMappings()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMigrationSetupTableMappings()
    begin
    end;

    var
        CompanyTok: Label 'Company', Locked = true;
        BCTableSeparatorTok: Label '$', Locked = true;
        OpenBraceTok: Label '{', Locked = true;
        CloseBraceTok: Label '}', Locked = true;
        CustomMigrationDisplayNameLbl: Label 'Custom Migration', MaxLength = 250;
        CustomMigrationDescriptionLbl: Label 'The custom cloud migration can bring data from any SQL source. We strongly recommend reading the documentation before making changes, to avoid data loss and incorrect data replication.';
}