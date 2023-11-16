namespace Microsoft.DataMigration;

using System.Reflection;
using System.Apps;

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 40010 "Add Migration Table Mappings"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "AllObj";
    UsageCategory = Administration;
    SaveValues = true;
    Permissions = tabledata "NAV App Installed App" = r, tabledata AllObj = r, tabledata "Published Application" = r;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(SourceTableNameGroup)
            {
                Caption = 'Source Table';
                field(SourceTableName; SourceTableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the source table. Use underscores in place of special characters, similar to how table names appear in SQL Server Management Studio.';
                    Caption = 'Name';

                    trigger OnValidate()
                    var
                        MigrationTableMapping: Record "Migration Table Mapping";
                        NewSourceTableName: Text;
                    begin
                        if SourceTableName = '' then
                            exit;

                        MigrationTableMapping.ValidateSourceTableName(MigrationTableMapping, SourceTableName);
                        NewSourceTableName := MigrationTableMapping.GetSourceTableName(MigrationTableMapping);
                        if NewSourceTableName <> '' then
                            SourceTableName := NewSourceTableName;
                        SourceTableAppID := MigrationTableMapping.GetSourceTableAppID(MigrationTableMapping);
                        DataPerCompany := MigrationTableMapping."Data Per Company";
                        CurrPage.Update(true);
                    end;
                }

                field(SourceTableAppID; SourceTableAppID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the source table. Leave blank if the table is in C/AL. If it is an AL table, use the AppID GUID of the main app .';
                    Caption = 'App ID';

                    trigger OnValidate()
                    var
                        TestGuid: Guid;
                    begin
                        if SourceTableAppID <> '' then
                            Evaluate(TestGuid, SourceTableAppID);

                        CurrPage.Update(true);
                    end;
                }

                field(DataPerCompany; DataPerCompany)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the table data is per company';
                    Caption = 'Data Per Company';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }

            group(TargetTable)
            {
                Caption = 'Target Table';
                field(TargetTableType; TargetMigrationTableType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the destination table.';
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        UpdateTableType();
                        CurrPage.Update(true);
                    end;
                }

                group(ExtensionsFilterGroup)
                {
                    ShowCaption = false;

                    field(ExtensionsFilter; ExtensionsFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Extension Names';
                        ToolTip = 'Specifies the name of the extension for the mapping.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            PublishedApplication: Record "Published Application";
                            MigrationTableMapping: Record "Migration Table Mapping";
                            ExtensionManagement: Page "Extension Management";
                        begin
                            MigrationTableMapping.FilterOutBlacklistedPublishers(PublishedApplication);

                            ExtensionManagement.SetTableView(PublishedApplication);
                            ExtensionManagement.LookupMode(true);
                            if not (ExtensionManagement.RunModal() in [Action::LookupOK, Action::OK]) then
                                exit;

                            ExtensionManagement.SetSelectionFilter(PublishedApplication);

                            UpdateObjectsFilter(PublishedApplication);
                            Rec.SetFilter("App Package ID", AppFilter);
                            CurrPage.Update(false);
                        end;
                    }

                    field(ClearExtensionsFilterLbl; ClearExtensionsFilterLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ClearExtensionsFilter();
                        end;
                    }

                    field(AppFilter; AppFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'App Filter';
                        ToolTip = 'Specifies the current filter selection for the apps.';
                        Editable = false;
                        Visible = false;
                    }
                }
            }
            repeater(TargetTables)
            {
                Caption = 'Target tables';
                Editable = false;

                field(AppID; AppID)
                {
                    ToolTip = 'Specifies the Application ID.';
                    Caption = 'Application ID';
                }
                field(AppName; AppName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Application Name.';
                    Caption = 'Application Name';
                }
                field(TableID; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    ToolTip = 'Specifies the ID of the destination table.';
                }

                field(ObjectName; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the destination table.';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not (CloseAction in [Action::OK, Action::LookupOK]) then
            exit(true);

        exit(SaveNewTableMappings());
    end;

    local procedure UpdateObjectsFilter(var PublishedApplication: Record "Published Application")
    begin
        PublishedApplication.SetRange(Installed, true);
        if not PublishedApplication.FindSet() then begin
            ClearExtensionsFilter();
            exit;
        end;

        repeat
            AppFilter += '|' + Format(PublishedApplication."Package ID");
            ExtensionsFilter += ', ' + PublishedApplication.Name;
        until PublishedApplication.Next() = 0;

        AppFilter := AppFilter.TrimStart('|');
        ExtensionsFilter := ExtensionsFilter.TrimStart(', ');
    end;

    local procedure SaveNewTableMappings(): Boolean
    var
        SelectedAllObj: Record AllObj;
    begin
        if SourceTableName = '' then begin
            Message(ProvideSourceTableNameErr);
            exit(false);
        end;

        CurrPage.SetSelectionFilter(SelectedAllObj);
        if not SelectedAllObj.FindSet() then
            exit(true);

        repeat
            SaveMigrationTableMapping(SelectedAllObj);
        until SelectedAllObj.Next() = 0;
        exit(true);
    end;

    local procedure SaveMigrationTableMapping(var AllObj: Record AllObj)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        ExistingMigrationTableMapping: Record "Migration Table Mapping";
        PublishedApplication: Record "Published Application";
    begin
        MigrationTableMapping."Table ID" := AllObj."Object ID";
        MigrationTableMapping."Target Table Type" := TargetMigrationTableType;
        if MigrationTableMapping."Target Table Type" = MigrationTableMapping."Target Table Type"::"Table Extension" then
            MigrationTableMapping."Table ID" := -AllObj."Object ID";

        MigrationTableMapping."Data Per Company" := DataPerCompany;

        if MigrationTableMapping."Target Table Type" = TargetMigrationTableType::Table then
            MigrationTableMapping."Table Name" := AllObj."Object Name"
        else
            MigrationTableMapping."Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(MigrationTableMapping."Table Name"));

        MigrationTableMapping."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(MigrationTableMapping."Table Name"));
        MigrationTableMapping.SetSourceTableName(SourceTableAppID);

        PublishedApplication.Get(AllObj."App Runtime Package ID");
        MigrationTableMapping."App ID" := PublishedApplication.ID;
        MigrationTableMapping."Extension Name" := PublishedApplication.Name;
        MigrationTableMapping."Extension Package ID" := PublishedApplication."Package ID";
        if ExistingMigrationTableMapping.Get(MigrationTableMapping."App ID", MigrationTableMapping."Table ID") then
            ExistingMigrationTableMapping.Delete();

        MigrationTableMapping.Insert();
    end;

    local procedure UpdateTableType()
    begin
        if TargetMigrationTableType = TargetMigrationTableType::Table then
            Rec.SetRange("Object Type", Rec."Object Type"::Table)
        else
            Rec.SetRange("Object Type", Rec."Object Type"::TableExtension);
    end;

    local procedure ClearExtensionsFilter()
    begin
        Clear(ExtensionsFilter);
        Clear(AppFilter);
        Rec.SetRange("App Package ID");
        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    var
        PublishedApplication: Record "Published Application";
        MigrationTableMapping: Record "Migration Table Mapping";
    begin
        DataPerCompany := true;
        UpdateTableType();
        if AppFilter = '' then begin
            MigrationTableMapping.FilterOutBlacklistedPublishers(PublishedApplication);
            UpdateObjectsFilter(PublishedApplication);
        end;

        Rec.SetFilter("App Package ID", AppFilter)
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
        TargetMigrationTableType: Enum "Migration Table Type";
        AppID: Text;
        AppName: Text;
        SourceTableName: Text;
        SourceTableAppID: Text;
        DataPerCompany: Boolean;
        ExtensionsFilter: Text;
        AppFilter: Text;
        ClearExtensionsFilterLbl: Label 'Clear filter';
        ProvideSourceTableNameErr: Label 'You need to provide source table name.';
}