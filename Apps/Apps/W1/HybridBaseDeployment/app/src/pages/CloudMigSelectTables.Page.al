namespace Microsoft.DataMigration;

using System.Integration;
using System.Reflection;

page 40041 "Cloud Mig - Select Tables"
{
    PageType = Worksheet;
    ApplicationArea = All;
    SourceTable = "Intelligent Cloud Status";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Select tables to migrate';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;

                field(HybridCompanyNameFilter; CompanyFilterDisplayName)
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the filter to lookup the data for selected company.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                        FilterText: Text;
                    begin
                        HybridReplicationStatistics.LookupCompanies(FilterText, CompanyFilterDisplayName);
                        Rec.SetFilter("Company Name", FilterText);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        CloudMigReplicateDataMgt.FilterCompanies(Rec, CompanyFilterDisplayName);
                    end;
                }
                field(TableNameFilter; TableNameFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Specifies the name of the table to filter the data.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if CloudMigReplicateDataMgt.LookupTableData(Rec, TableNameFilter) then
                            CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    var
                        AllObj: Record AllObj;
                    begin
                        if TableNameFilter = '' then begin
                            Rec.SetRange("Table Id");
                            CurrPage.Update(false);
                            exit;
                        end;

                        AllObj.SetFilter("Object Name", '@*' + TableNameFilter + '*');
                        CloudMigReplicateDataMgt.LookupTableData(Rec, TableNameFilter, AllObj);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(TablesToMigrate)
            {
                Editable = false;

                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the table to be migrated.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    Caption = 'Company Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the company that the table belongs to.';
                }
                field("Table Id"; Rec."Table Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Table Id';
                    ToolTip = 'Specifies the ID of the table to be migrated.';
                }
                field("Synced Version"; Rec."Synced Version")
                {
                    Visible = false;
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Synced Version';
                    ToolTip = 'Specifies the version of the table that is synced to the cloud. This version is used to delta sync the data.';
                }
                field(Blocked; Rec.Blocked)
                {
                    Visible = false;
                    ApplicationArea = All;
                    Caption = 'Blocked';
                    ToolTip = 'Specifies if the table is blocked. This value is set if the table fails replication.';
                }
                field("Replicate Data"; Rec."Replicate Data")
                {
                    ApplicationArea = All;
                    Caption = 'Replicate Data';
                    ToolTip = 'Specifies if the data should be replicated to the cloud.';
                }
                field("Preserve Cloud Data"; Rec."Preserve Cloud Data")
                {
                    ApplicationArea = All;
                    Caption = 'Preserve the Cloud Data';
                    ToolTip = 'Specifies if the data should only be delta synced. Setting this value to false will delete all data from the table before copying the data from on-premises database.';
                }
                field(ViewOnly; IsInternal)
                {
                    ApplicationArea = All;
                    Caption = 'View only';
                    ToolTip = 'Specifies if the replication properties of the table cannot be changed.';
                    Visible = IsInternalVisible;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(IncludeTablesInMigration)
            {
                ApplicationArea = All;
                Caption = 'Include in migration';
                Image = Apply;
                ToolTip = 'Marks the selected tables for replication.';

                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CurrPage.SetSelectionFilter(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.CheckCanChangeTheTable(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.IncludeExcludeTablesFromCloudMigration(IntelligentCloudStatus, true);
                    CurrPage.Update(false);
                end;
            }
            action(ExcludeTablesFromMigration)
            {
                ApplicationArea = All;
                Caption = 'Exclude from migration';
                Image = UnApply;
                ToolTip = 'Removes the mark for replication from the selected tables.';

                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CurrPage.SetSelectionFilter(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.CheckCanChangeTheTable(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.IncludeExcludeTablesFromCloudMigration(IntelligentCloudStatus, false);
                    CurrPage.Update(false);
                end;
            }
            action(DeltaSyncTables)
            {
                ApplicationArea = All;
                Caption = 'Preserve data';
                Image = MovementWorksheet;
                ToolTip = 'Defines that the data is not deleted before the cloud migration.';

                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CurrPage.SetSelectionFilter(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.CheckCanChangeTheTable(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.ChangePreserveCloudData(IntelligentCloudStatus, true);
                    CurrPage.Update(false);
                end;
            }
            action(ReplaceSyncTables)
            {
                ApplicationArea = All;
                Caption = 'Clear data before migration';
                Image = RefreshPlanningLine;
                ToolTip = 'Defines that the table data is deleted before the cloud migration.';

                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CurrPage.SetSelectionFilter(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.CheckCanChangeTheTable(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.ChangePreserveCloudData(IntelligentCloudStatus, false);
                    CurrPage.Update(false);
                end;
            }
            action(ManageCustomTables)
            {
                ApplicationArea = All;
                Caption = 'Manage custom tables';
                ToolTip = 'Manage custom table mappings for the migration. This functionality can be used to rename the table during replication or to split on-premises table with customizations to main table and table extensions.';
                RunObject = page "Migration Table Mapping";
                RunPageMode = Edit;
                Image = TransferToGeneralJournal;
            }
            action(ShowModifiedOnly)
            {
                ApplicationArea = All;
                Caption = 'View changed records';
                ToolTip = 'Shows the changed records only.';
                Image = ShowMatrix;

                trigger OnAction()
                var
                    ChangedIntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CloudMigReplicateDataMgt.GetChangedTables(ChangedIntelligentCloudStatus);
                    ChangedIntelligentCloudStatus.MarkedOnly(true);
                    Page.RunModal(Page::"Cloud Mig - Select Tables", ChangedIntelligentCloudStatus);
                    CurrPage.Update(false);
                end;
            }
            action(ShowHistory)
            {
                ApplicationArea = All;
                Caption = 'Show history';
                Image = History;
                ToolTip = 'Shows all changes that were done to how the data is replicated.';
                RunObject = page "Cloud Mig Change Data Log";
            }
            action(ResetToDefault)
            {
                ApplicationArea = All;
                Caption = 'Reset to default';
                ToolTip = 'Returns the record to the original values.';
                Image = Restore;
                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                begin
                    CurrPage.SetSelectionFilter(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.CheckCanChangeTheTable(IntelligentCloudStatus);
                    CloudMigReplicateDataMgt.ResetToDefault(IntelligentCloudStatus);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Category6)
            {
                Caption = 'Replicate data';
                ShowAs = SplitButton;

                actionref(IncludeTablesInMigration_Promoted; IncludeTablesInMigration)
                {
                }
                actionref(ExcludeTablesFromMigration_Promoted; ExcludeTablesFromMigration)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Delta Sync';
                ShowAs = SplitButton;

                actionref(DeltaSyncTables_Promoted; DeltaSyncTables)
                {
                }
                actionref(ReplaceSyncTables_Promoted; ReplaceSyncTables)
                {
                }
            }
            actionref(ShowModifiedOnly_Promoted; ShowModifiedOnly)
            {
            }
            actionref(ResetToDefault_Promoted; ResetToDefault)
            {
            }
            actionref(ShowHistory_Promoted; ShowHistory)
            {
            }
            actionref(ManageCustomTables_Promoted; ManageCustomTables)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        CanChangeSetup: Boolean;
    begin
        OnCanChangeSetup(CanChangeSetup);
        if not CanChangeSetup then
            Error(ChangingSetupRequiresBCMigrationErr);

        CloudMigReplicateDataMgt.ShowDocumentationNotification();
        IsInternalVisible := not Rec.MarkedOnly();
    end;

    [InternalEvent(false, false)]
    local procedure OnCanChangeSetup(var CanChangeSetup: Boolean)
    begin
    end;

    trigger OnAfterGetRecord()
    begin
        if IsInternalVisible then
            IsInternal := not CloudMigReplicateDataMgt.CheckRecordCanBeModified(Rec."Table Id");
    end;

    var
        CloudMigReplicateDataMgt: Codeunit "Cloud Mig. Replicate Data Mgt.";
        IsInternalVisible: Boolean;
        IsInternal: Boolean;
        TableNameFilter: Text;
        CompanyFilterDisplayName: Text;
        ChangingSetupRequiresBCMigrationErr: Label 'Enable cloud migration and select a product before modifying how the data is replicated. Changing which data is replicated is only supported for migrations from Business Central.';
}
