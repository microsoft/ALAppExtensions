// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using System.Apps;
using System.Reflection;

page 40016 "Add Custom Migration Mapping"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "AllObj";
    Permissions = tabledata "NAV App Installed App" = r, tabledata AllObj = r, tabledata "Published Application" = r;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Caption = 'Add migration table mappings for custom migration';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(ReplicationSettings)
            {
                Caption = 'Replication settings';
                field(MappingType; MappingType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the mapping should be saved to Replication Table Mapping or Migration Setup Table Mapping.';
                    Caption = 'Mapping Type';
                }

                field(DataPerCompany; DataPerCompany)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the table data is per company';
                    Caption = 'Data per-company';
                    trigger OnValidate()
                    begin
                        if not DataPerCompany then begin
                            GlobalPreserveCloudData := true;
                            Clear(CompanyName);
                            Clear(AllCompanies);
                        end;

                        CurrPage.Update(true);
                    end;
                }
                group(CompanySettingsGroup)
                {
                    Visible = DataPerCompany;
                    ShowCaption = false;

                    field(AllCompanies; AllCompanies)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if the table mapping applies to all companies.';
                        Caption = 'All companies';

                        trigger OnValidate()
                        begin
                            if AllCompanies then begin
                                CompanyName := AllCompaniesTok;
                                Message(UpdateTableNamesWithAllCompaniesTokMsg, AllCompaniesTok);
                            end else
                                Clear(CompanyName);
                        end;
                    }
                    field(CompanyName; CompanyName)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the company name associated with this table mapping. The value should be blank if the table is per-database.';
                        Caption = 'Company name';
                    }
                }
                field(GlobalPreserveCloudData; GlobalPreserveCloudData)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to preserve existing data in the cloud during replication for all selected tables. If set to true, existing data in the destination table will not be overwritten during replication, only new records will be added.';
                    Caption = 'Preserve cloud data';
                    trigger OnValidate()
                    begin
                        if GlobalPreserveCloudData then
                            DataPerCompany := true;

                        CurrPage.Update(true);
                    end;
                }
            }
            group(SourceTableNameGroup)
            {
                Caption = 'Source table';
                field(SourceTableName; SourceTableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the source table. Use underscores in place of special characters, similar to how table names appear in SQL Server Management Studio.';
                    Caption = 'Name';

                    trigger OnValidate()
                    var
                        MigrationTableMapping: Record "Migration Table Mapping";
                    begin
                        if SourceTableName = '' then
                            exit;

#pragma warning disable AA0139
                        SourceTableName := MigrationTableMapping.TrimSourceTableName(SourceTableName);
#pragma warning restore AA0139
                        CurrPage.Update(true);
                    end;
                }
            }

            group(TargetTable)
            {
                Caption = 'Target table';
                field(TargetTableName; TargetTableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the target table.';
                    Caption = 'Table name';
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        AllObj: Record AllObj;
                        PublishedApplication: Record "Published Application";
                        AllObjects: Page "All Objects";
                        SelectedAppID: Text;
                    begin
                        if DataPerCompany and (CompanyName = '') then
                            Error(CompanyNameMustBeSpecifiedErr);

                        AllObj.SetFilter("Object Type", '%1|%2', AllObj."Object Type"::Table, AllObj."Object Type"::"TableExtension");
                        AllObjects.SetTableView(AllObj);
                        AllObjects.LookupMode(true);
                        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
                            exit;

                        AllObjects.GetRecord(AllObj);
                        if not TableMetadata.Get(AllObj."Object ID") then
                            exit;

                        TargetTableName := TableMetadata.Name;
                        if PublishedApplication.Get(AllObj."App Runtime Package ID") then begin
                            SelectedAppID := LowerCase(Format(PublishedApplication.ID).TrimStart('{').TrimEnd('}'));
#pragma warning disable AA0139
                            TargetTableName := TargetTableName + BCTableSeparatorTok + SelectedAppID;
                            if AllObj."Object Type" = AllObj."Object Type"::"TableExtension" then
                                TargetTableName := TargetTableName + TableExtensionSuffixTok;
#pragma warning restore AA0139
                        end;

                        if DataPerCompany then
#pragma warning disable AA0139
                            DestinationTableName := ConvertStr(CompanyName + BCTableSeparatorTok + TargetTableName, InvalidSqlCharactersTok, ValidSqlReplacementTok);
#pragma warning restore AA0139
                    end;
                }
                field(DestinationTableName; DestinationTableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the destination table in the cloud database. Use underscores in place of special characters, similar to how table names appear in SQL Server Management Studio.';
                    Caption = 'Destination table name';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        HybridCompany: Record "Hybrid Company";
        CustomMigrationTableBuffer: Record "Custom Migration Table Buffer";
        NewCompanyName: Text[30];
        NewSourceTableName: Text[128];
        NewDestinationTableName: Text[128];
    begin
        if not (CloseAction in [Action::OK, Action::LookupOK]) then
            exit(true);

        if AllCompanies then begin
            HybridCompany.SetRange(Replicate, true);
            HybridCompany.SetFilter(Name, '<>%1', '');
            HybridCompany.FindSet();
            repeat
#pragma warning disable AA0139
                NewSourceTableName := SourceTableName.Replace(AllCompaniesTok, HybridCompany.Name);
                NewDestinationTableName := DestinationTableName.Replace(AllCompaniesTok, HybridCompany.Name);
                NewCompanyName := HybridCompany.Name;
#pragma warning restore AA0139
                CustomMigrationTableBuffer.SaveMigrationTableMapping(MappingType, NewSourceTableName, NewDestinationTableName, TargetTableName, NewCompanyName, DataPerCompany, GlobalPreserveCloudData);
            until HybridCompany.Next() = 0;
        end else
            CustomMigrationTableBuffer.SaveMigrationTableMapping(MappingType, SourceTableName, DestinationTableName, TargetTableName, CompanyName, DataPerCompany, GlobalPreserveCloudData);
        exit(true);
    end;

    trigger OnOpenPage()
    begin
        DataPerCompany := true;
    end;

    trigger OnAfterGetRecord()
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        NAVAppInstalledApp.SetRange("Package ID", Rec."App Package ID");
        Clear(AppID);
        Clear(AppName);
        if NAVAppInstalledApp.FindFirst() then begin
            AppID := Format(NAVAppInstalledApp."App ID", 0, 9).TrimStart('{').TrimEnd('}');
            AppName := NAVAppInstalledApp.Name;
        end;
    end;

    var
        TableMetadata: Record "Table Metadata";
        MappingType: Enum "Migration Mapping Type";
        AppID: Text;
        AppName: Text;
        SourceTableName: Text[128];
        DestinationTableName: Text[128];
        TargetTableName: Text[128];
        CompanyName: Text[30];
        DataPerCompany: Boolean;
        GlobalPreserveCloudData: Boolean;
        BCTableSeparatorTok: Label '$', Locked = true;
        TableExtensionSuffixTok: Label '$ext', Locked = true;
        InvalidSqlCharactersTok: Label '.\/-', Locked = true;
        ValidSqlReplacementTok: Label '____', Locked = true;
        AllCompaniesTok: Label '{$CompanyName$}', Locked = true;
        AllCompanies: Boolean;
        UpdateTableNamesWithAllCompaniesTokMsg: Label 'The %1 token in the source table and destination table name will be replaced with the name of the company that is selected for migration. Update the source and destination table names accordingly.', Comment = '%1 is this value that is not translated {$AllCompanies$}';
        CompanyNameMustBeSpecifiedErr: Label 'Company Name must be specified when Data Per Company is selected.', Comment = 'Error message shown when trying to select a table mapping that is per company without specifying a company name.';
}