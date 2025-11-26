namespace Microsoft.DataMigration;

using System.Reflection;

page 4008 "Intelligent Cloud Stat Factbox"
{
    Caption = 'Migration Information';
    SourceTable = "Hybrid Replication Summary";
    PageType = CardPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            field("Next Scheduled Run"; NextScheduledRun)
            {
                Caption = 'Next Scheduled Run';
                Tooltip = 'Specifies the date and time of the next scheduled migration.';
                Enabled = false;
                Editable = false;
                ApplicationArea = Basic, Suite;
                Visible = ShowNextScheduled;
            }

            group(Group1)
            {
                ShowCaption = false;
                cuegroup(MigrationStatistics)
                {
                    Caption = 'Migration Statistics';
                    InstructionalText = 'Migration Statistics';
                    ShowCaption = true;

                    field("Total Successful Tables"; TotalSuccessfulTables)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Tables Successful';
                        ToolTip = 'Indicates the total number of tables that have been successfully migrated.';
                        Style = Favorable;
                        StyleExpr = (TotalSuccessfulTables > 0);
                    }

                    field("Tables not Migrated"; TotalTablesNotMigrated)
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = TablesNotMigratedEnabled;
                        Style = Ambiguous;
                        StyleExpr = (TotalTablesNotMigrated > 0);
                        Caption = 'Tables not Migrated';
                        ToolTip = 'Indicates the number of tables that are ignored during the migration.';

                        trigger OnDrillDown()
                        begin
                            ShowTablesNotMigrated();
                        end;
                    }
                }

                field(Spacer1; '')
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    Enabled = false;
                    MultiLine = false;
                    ToolTip = ' ';
                }

                cuegroup(RunStatistics)
                {
                    Caption = 'Run Statistics';
                    ShowCaption = true;

                    field("Tables Successful"; Rec."Tables Successful")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Tables Successful';
                        Tooltip = 'Indicates the number of tables that were successful for the selected migration.';
                        Style = Favorable;
                        StyleExpr = (Rec."Tables Successful" > 0);

                        trigger OnDrillDown()
                        var
                            HybridReplicationDetail: Record "Hybrid Replication Detail";
                        begin
                            HybridReplicationDetail.SetRange("Run ID", Rec."Run ID");
                            HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Successful);
                            Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
                        end;
                    }
                    field("Tables Failed"; Rec."Tables Failed")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Tables Failed';
                        Tooltip = 'Indicates the number of tables that failed for the selected migration.';
                        Style = Unfavorable;
                        StyleExpr = (Rec."Tables Failed" > 0);

                        trigger OnDrillDown()
                        var
                            HybridReplicationDetail: Record "Hybrid Replication Detail";
                        begin
                            HybridReplicationDetail.SetRange("Run ID", Rec."Run ID");
                            HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
                            Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
                        end;
                    }
                }

                cuegroup(RunStatistics2)
                {
                    Caption = '_';
                    ShowCaption = false;

                    field("Tables Remaining"; Rec."Tables Remaining")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Tables Remaining';
                        Tooltip = 'Indicates the number of remaining tables to migrate for the selected migration.';
                        Style = Ambiguous;
                        StyleExpr = (Rec."Tables Remaining" > 0);

                        trigger OnDrillDown()
                        var
                            HybridReplicationDetail: Record "Hybrid Replication Detail";
                        begin
                            HybridReplicationDetail.SetRange("Run ID", Rec."Run ID");
                            HybridReplicationDetail.SetFilter(Status, '%1|%2', HybridReplicationDetail.Status::NotStarted, HybridReplicationDetail.Status::InProgress);
                            Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
                        end;
                    }

                    field("Tables with Warnings"; Rec."Tables with Warnings")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Tables with Warnings';
                        Tooltip = 'Indicates the number of tables that had warnings for the selected migration.';
                        Style = Ambiguous;
                        StyleExpr = (Rec."Tables with Warnings" > 0);

                        trigger OnDrillDown()
                        var
                            HybridReplicationDetail: Record "Hybrid Replication Detail";
                        begin
                            HybridReplicationDetail.SetRange("Run ID", Rec."Run ID");
                            HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Warning);
                            Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);
                        end;
                    }
                }

                field(Spacer2; '')
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    MultiLine = false;
                    ToolTip = ' ';
                }

                cuegroup(CompanyStatus)
                {
                    Caption = 'Company Status';
                    ShowCaption = true;

                    field("Not Initialized Companies"; Rec."Companies Not Initialized")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Not Initialized Companies';
                        Tooltip = 'Indicates the number of companies that must be initialized before they can be used.';
                        Style = Unfavorable;
                        StyleExpr = (Rec."Companies Not Initialized" > 0);

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Hybrid Companies List");
                        end;
                    }

                    field(Warnings; NumberOfWarnings)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Warnings';
                        ToolTip = 'Specifies the number of warnings for the selected migration.';
                        Style = Unfavorable;
                        StyleExpr = (NumberOfWarnings > 0);

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Cloud Migration Warnings");
                        end;
                    }

                    field("Validation Errors"; ValidationErrors)
                    {
                        ApplicationArea = All;
                        Caption = 'Validation Errors';
                        Style = Unfavorable;
                        StyleExpr = (ValidationErrors > 0);
                        ToolTip = 'Indicates the total number of failed post migration validation tests, for all migrated companies.';
                        Visible = (NumberOfRegisteredValidators > 0);

                        trigger OnDrillDown()
                        var
                            MigrationValidationRegistery: Record "Migration Validator Registry";
                            MigrationValidationTest: Record "Migration Validation Test";
                            MigrationValidationResults: Page "Migration Validation Results";
                            ValidatorFilter: Text;
                            SeparatorChar: Text;
                        begin
                            MigrationValidationRegistery.SetRange("Migration Type", MigrationType);
                            if MigrationValidationRegistery.FindSet() then
                                repeat
                                    if ValidatorFilter <> '' then
                                        SeparatorChar := '|';

                                    ValidatorFilter := SeparatorChar + ValidatorFilter;
                                until MigrationValidationRegistery.Next() = 0;

                            MigrationValidationTest.SetFilter("Validator Code", ValidatorFilter);
                            MigrationValidationResults.SetTableView(MigrationValidationTest);
                            MigrationValidationResults.Run();
                        end;
                    }
                }

                field(Spacer3; '')
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    MultiLine = false;
                    ToolTip = ' ';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RefreshStats();
    end;

    procedure RefreshStats()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        MigrationValidationError: Record "Migration Validation Error";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        CanShowTablesNotMigrated(TablesNotMigratedEnabled);
        if TablesNotMigratedEnabled then
            TotalTablesNotMigrated := HybridCloudManagement.GetTotalTablesNotMigrated();

        if IntelligentCloudSetup.Get() then begin
            NextScheduledRun := IntelligentCloudSetup.GetNextScheduledRunDateTime(CurrentDateTime());
            MigrationType := IntelligentCloudSetup."Product ID";
        end;

        ShowNextScheduled := NextScheduledRun <> 0DT;

        if Rec."Run ID" <> '' then begin
            TotalSuccessfulTables := HybridCloudManagement.GetTotalSuccessfulTables();
            TotalTablesNotMigrated := HybridCloudManagement.GetTotalTablesNotMigrated();
            SourceProduct := HybridCloudManagement.GetChosenProductName();
        end;

        UpdateWarningCounts();

        MigrationValidatorRegistry.SetRange("Migration Type", MigrationType);
        NumberOfRegisteredValidators := MigrationValidatorRegistry.Count();

        MigrationValidationError.SetRange("Migration Type", MigrationType);
        ValidationErrors := MigrationValidationError.Count();
    end;

    local procedure ShowTablesNotMigrated()
    var
        HybridCompany: Record "Hybrid Company";
        TempIntelligentCloudNotMigrated: Record "Intelligent Cloud Not Migrated" temporary;
        TableMetadata: Record "Table Metadata";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then begin
            TempIntelligentCloudNotMigrated.Reset();
            TempIntelligentCloudNotMigrated.DeleteAll();
            repeat
                TableMetadata.Reset();
                TableMetadata.SetRange(ReplicateData, false);
                TableMetadata.SetFilter(ID, '<%1|>%2', 2000000000, 2000000300);
                TableMetadata.SetFilter(Name, '<>*Buffer');
                TableMetadata.ChangeCompany(HybridCompany.Name);
                if TableMetadata.FindSet() then
                    repeat
                        TempIntelligentCloudNotMigrated.Init();
                        TempIntelligentCloudNotMigrated."Company Name" := HybridCompany.Name;
                        TempIntelligentCloudNotMigrated."Table Name" := HybridCloudManagement.ConstructTableName(TableMetadata.Name, TableMetadata.ID);
                        TempIntelligentCloudNotMigrated."Table Id" := TableMetadata.ID;
                        TempIntelligentCloudNotMigrated.Insert();
                    until TableMetadata.Next() = 0;
            until HybridCompany.Next() = 0;
        end;

        // Now add the system tables
        TableMetadata.Reset();
        TableMetadata.SetRange(ReplicateData, false);
        TableMetadata.SetRange(DataPerCompany, false);
        TableMetadata.SetFilter(ID, '<%1|>%2', 2000000000, 2000000300);
        TableMetadata.SetFilter(Name, '<>*Buffer');
        if TableMetadata.FindSet() then
            repeat
                TempIntelligentCloudNotMigrated.Init();
                TempIntelligentCloudNotMigrated."Company Name" := '';
                TempIntelligentCloudNotMigrated."Table Name" := HybridCloudManagement.ConstructTableName(TableMetadata.Name, TableMetadata.ID);
                TempIntelligentCloudNotMigrated."Table Id" := TableMetadata.ID;
                TempIntelligentCloudNotMigrated.Insert();
            until TableMetadata.Next() = 0;

        Page.Run(4019, TempIntelligentCloudNotMigrated);
    end;

    local procedure UpdateWarningCounts()
    var
        ICloudMigrationWarning: Interface "Cloud Migration Warning";
        CloudMigrationWarningType: Enum "Cloud Migration Warning Type";
        WarningImplementations: List of [Integer];
        WarningImplementation: Integer;
    begin
        NumberOfWarnings := 0;
        WarningImplementations := CloudMigrationWarningType.Ordinals();
        foreach WarningImplementation in WarningImplementations do begin
            ICloudMigrationWarning := "Cloud Migration Warning Type".FromInteger(WarningImplementation);
            NumberOfWarnings += ICloudMigrationWarning.GetWarningCount();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure CanShowTablesNotMigrated(var Enabled: Boolean)
    begin
    end;

    var
        NextScheduledRun: DateTime;
        SourceProduct: Text;
        TotalSuccessfulTables: Integer;
        TotalTablesNotMigrated: Integer;
        ShowNextScheduled: Boolean;
        TablesNotMigratedEnabled: Boolean;
        MigrationType: Text;
        NumberOfWarnings: Integer;
        NumberOfRegisteredValidators: Integer;
        ValidationErrors: Integer;
}

