namespace Microsoft.DataMigration;

using System.Integration;

page 4006 "Intelligent Cloud Details"
{
    Caption = 'Table Migration Status';
    SourceTable = "Hybrid Replication Detail";
    PageType = Worksheet;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting(Status, "Company Name", "Table Name") order(ascending);

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
                        FilterCompanies();
                    end;
                }
                field(TableNameFilter; TableNameFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Specifies the name of the table to filter the data.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                    begin
                        if HybridReplicationStatistics.LookupTableData(TableNameFilter) then
                            Rec.SetRange("Table Name", TableNameFilter);

                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        if TableNameFilter = '' then
                            Rec.SetRange("Table Name")
                        else
                            Rec.SetFilter("Table Name", TableNameFilter);
                        CurrPage.Update(false);
                    end;
                }
            }

            repeater(Group)
            {
                ShowCaption = false;

                field(StartTime; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start time of the migration.';
                    Visible = false;
                }
                field(EndTime; Rec."End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end time of the migration.';
                    Visible = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company of the table.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the table.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the table.';
                    StyleExpr = StatusExpr;
                }
                field(Errors; Rec."Error Message")
                {
                    Caption = 'Message';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies any errors that happened during the migration.';
                    StyleExpr = StatusExpr;
                }
                field("Records Copied"; Rec.GetCopiedRecords())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Records Migrated';
                    ToolTip = 'Specifies the number of records in the table that have been migrated.';
                    Visible = false;
                    BlankZero = true;
                }
                field(RecordsCopiedLastRun; Rec."Records Copied")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Records Migrated Last run';
                    ToolTip = 'Specifies the number of records in the table that have been migrated in the last replication run.';
                    Visible = ShowRecordCounts;
                    BlankZero = true;
                }
                field("Total Records"; Rec."Total Records")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total records - Source Table';
                    ToolTip = 'Specifies the total number of records to copy from the source table.';
                    Visible = ShowRecordCounts;
                    BlankZero = true;
                    Editable = false;
                }
                field(TotalRecordsTargetTable; TotalRecordsTargetTable)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total records - Target Table';
                    ToolTip = 'Specifies the total number of records to copy in the target table.';
                    Visible = ShowRecordCounts;
                    BlankZero = true;
                    Editable = false;
                }

                field(DifferenceInRecords; DifferenceInRecords)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Difference';
                    ToolTip = 'Specifies the difference between records in the target table compared to the OnPrem table.';
                    Visible = ShowRecordCounts;
                    BlankZero = true;
                    Editable = false;
                }
            }
            group(StatusGroup)
            {
                ShowCaption = false;
                fixed(SummaryFixedLayout)
                {
                    ShowCaption = false;
                    group(LatestStatus)
                    {
                        Caption = 'Latest replication status';
                        field(NumberOfJournalRecords; LatestStatusTxt)
                        {
                            ApplicationArea = All;
                            StyleExpr = LatestStatusExpr;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Specifies the latest replication status for the selected table. Failed tables can be corrected by a new data replication.';

                            trigger OnDrillDown()
                            var
                                LatestHybridReplicationDetail: Record "Hybrid Replication Detail";
                            begin
                                GetLatestStatus(LatestHybridReplicationDetail);
                                LatestHybridReplicationDetail.SetRecFilter();
                                Page.Run(Page::"Intelligent Cloud Details", LatestHybridReplicationDetail);
                            end;
                        }
                    }
                    group("StartTimeGroup")
                    {
                        Caption = 'Replication Start Time';
                        field(StartTimeStatistic; Rec."Start Time")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the start time of the data replication.';
                        }
                    }
                    group("EndTimeGroup")
                    {
                        Caption = 'Replication End Time';
                        field(EndTimeStatistic; Rec."End Time")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the end time of the data replication.';
                        }
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ShowHistoryForThisTable)
            {
                ApplicationArea = All;
                Caption = 'Show all replications';
                ToolTip = 'Show all replications for the selected table.';
                Image = History;

                trigger OnAction()
                var
                    HybridReplicationDetail: Record "Hybrid Replication Detail";
                    IntelligentCloudDetails: Page "Intelligent Cloud Details";
                begin
                    HybridReplicationDetail.SetRange("Company Name", Rec."Company Name");
                    HybridReplicationDetail.SetRange("Table Name", Rec."Table Name");
                    HybridReplicationDetail.SetCurrentKey("End Time");
                    HybridReplicationDetail.Ascending(false);
                    IntelligentCloudDetails.SetTableView(HybridReplicationDetail);
                    IntelligentCloudDetails.Run();
                end;
            }
            action(UnblockTables)
            {
                ApplicationArea = All;
                Caption = 'Unblock table';
                ToolTip = 'Unblocks the failed table. Use this action to unblock the failed cloud migration table and move the data via other means.';
                Image = ReopenCancelled;
                Visible = UnblockTableVisible;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.UnblockTable(Rec."Company Name", Rec."Table Name");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Promoted actions for Cloud Migration page.';

                actionref(ShowHistoryForThisTable_Promoted; ShowHistoryForThisTable)
                {
                }
                actionref(UnblockTables_Promoted; UnblockTables)
                {
                }
            }
        }
    }

    local procedure FilterCompanies()
    var
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.SetRange(Name, CompanyFilterDisplayName);
        if HybridCompany.IsEmpty then
            Rec.SetFilter("Company Name", CompanyFilterDisplayName)
        else
            Rec.SetRange("Company Name", CompanyFilterDisplayName);
    end;

    trigger OnOpenPage()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
    begin
        IntelligentCloudStatus.SetRange(Blocked, true);
        UnblockTableVisible := not IntelligentCloudStatus.IsEmpty();
        CompanyFilterDisplayName := HybridReplicationStatistics.GetAllCompaniesLbl();
    end;

    trigger OnAfterGetRecord()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        Clear(StatusExpr);
        if Rec.Status = Rec.Status::Failed then begin
            GetLatestStatus(HybridReplicationDetail);
            if HybridReplicationDetail.Status = Rec.Status::Failed then
                StatusExpr := 'Unfavorable';
        end;

        UpdateRecordCountStatistics();
    end;

    trigger OnAfterGetCurrRecord()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        GetLatestStatus(HybridReplicationDetail);
        LatestStatusTxt := Format(HybridReplicationDetail.Status);
        Clear(LatestStatusExpr);
        case HybridReplicationDetail.Status of
            HybridReplicationDetail.Status::Failed:
                LatestStatusExpr := 'Unfavorable';
            HybridReplicationDetail.Status::Successful:
                LatestStatusExpr := 'Favorable';
        end;
    end;

    local procedure GetLatestStatus(var HybridReplicationDetail: Record "Hybrid Replication Detail")
    begin
        HybridReplicationDetail.SetRange("Table Name", Rec."Table Name");
        HybridReplicationDetail.SetRange("Company Name", Rec."Company Name");
        HybridReplicationDetail.SetCurrentKey("End Time");
        HybridReplicationDetail.FindLast();
    end;

    local procedure UpdateRecordCountStatistics()
    begin
        // if any tables have "Records Copied" > 0, then we show the field.
        if not ShowRecordCounts then begin
            ShowRecordCounts := Rec."Records Copied" > 0;
            exit;
        end;

        if not Rec.GetCountOfRecordsInTheTableSafe(Rec, TotalRecordsTargetTable) then begin
            TotalRecordsTargetTable := 0;
            DifferenceInRecords := 0;
#pragma warning disable AA0139
            Rec."Error Message" := CopyStr(CouldNotReadTargetTableCountLbl + Rec."Error Message", 1, MaxStrLen(Rec."Error Message")).TrimEnd(';');
#pragma warning restore AA0139
            if StatusExpr <> 'Unfavorable' then
                StatusExpr := 'Ambiguous';
            exit;
        end;

        DifferenceInRecords := TotalRecordsTargetTable - Rec."Total Records";
    end;

    var
        StatusExpr: Text;
        ShowRecordCounts: Boolean;
        TotalRecordsTargetTable: Integer;
        DifferenceInRecords: Integer;
        CompanyFilterDisplayName: Text;
        TableNameFilter: Text;
        UnblockTableVisible: Boolean;
        LatestStatusTxt: Text;
        LatestStatusExpr: Text;
        CouldNotReadTargetTableCountLbl: Label 'Could not get the target table count.;';
}
