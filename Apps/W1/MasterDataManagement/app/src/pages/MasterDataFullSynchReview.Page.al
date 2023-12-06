namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;


page 7234 "Master Data Full Synch. Review"
{
    Caption = 'Master Data Initial Synchronization';
    PageType = Worksheet;
    SourceTable = "Master Data Full Synch. R. Ln.";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    Permissions = tabledata "Master Data Full Synch. R. Ln." = imd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Name; Rec.GetTableName())
                {
                    Caption = 'Table Name';
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name.';
                }
                field("Dependency Filter"; Rec."Dependency Filter")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a dependency to the synchronization of another record, such as a customer that must be synchronized before a contact can be synchronized.';
                    Visible = false;
                }
                field("Job Queue Entry Status"; Rec."Job Queue Entry Status")
                {
                    ApplicationArea = Suite;
                    StyleExpr = JobQueueEntryStatusStyle;
                    ToolTip = 'Specifies the status of the job queue entry.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowJobQueueLogEntry();
                    end;
                }
                field(ActiveSession; Rec.IsActiveSession())
                {
                    ApplicationArea = Suite;
                    Caption = 'Active Session';
                    ToolTip = 'Specifies whether the session is active.';
                    Visible = false;
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the synchronization direction.';
                    Visible = false;
                }
                field("To Int. Table Job Status"; Rec."To Int. Table Job Status")
                {
                    ApplicationArea = Suite;
                    StyleExpr = ToIntTableJobStatusStyle;
                    ToolTip = 'Specifies the status of jobs for data going to the source table. ';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowSynchJobLog(Rec."To Int. Table Job ID");
                    end;
                }
                field("From Int. Table Job Status"; Rec."From Int. Table Job Status")
                {
                    ApplicationArea = Suite;
                    StyleExpr = FromIntTableJobStatusStyle;
                    ToolTip = 'Specifies the status of jobs for data coming from the source table. ';
                    Caption = 'Job Status';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowSynchJobLog(Rec."From Int. Table Job ID");
                    end;
                }
                field("Initial Synchronization Recommendation"; InitialSynchRecommendation)
                {
                    Caption = 'Synchronization Mode';
                    ApplicationArea = Suite;
                    Enabled = SynchRecommendationDrillDownEnabled;
                    StyleExpr = InitialSynchRecommendationStyle;
                    ToolTip = 'Specifies the recommended action for the initial synchronization.';

                    trigger OnDrillDown()
                    var
                        IntegrationFieldMapping: Record "Integration Field Mapping";
                        IntegrationTableMapping: Record "Integration Table Mapping";
                    begin
                        if not (InitialSynchRecommendation in [MatchBasedCouplingTxt, CouplingCriteriaSelectedTxt]) then
                            exit;

                        if not IntegrationTableMapping.Get(Rec.Name) then
                            exit;

                        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
                        IntegrationFieldMapping.SetRange("Constant Value", '');
                        if Page.RunModal(Page::"Match Based Coupling Criteria", IntegrationFieldMapping) = Action::LookupOK then
                            CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Start)
            {
                ApplicationArea = Suite;
                Caption = 'Start All';
                Enabled = ActionStartEnabled;
                Image = Start;
                ToolTip = 'Start all the default integration jobs for synchronizing data from the chosen source company, as defined on the Synchronization Tables page. Tables with finished job status will be skipped.';

                trigger OnAction()
                var
                    MasterDataManagement: Codeunit "Master Data Management";
                    QuestionTxt: Text;
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    QuestionTxt := StartInitialSynchTeamOwnershipModelQst;
                    if Confirm(QuestionTxt) then
                        Rec.Start();
                end;
            }
            action(Restart)
            {
                ApplicationArea = Suite;
                Caption = 'Restart';
                Enabled = ActionRestartEnabled;
                Image = Refresh;
                ToolTip = 'Restart the synchronization for the selected table.';

                trigger OnAction()
                var
                    MasterDataManagement: Codeunit "Master Data Management";
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    Rec.Delete();
                    Rec.Generate(InitialSynchRecommendations, true, DeletedLines);
                    Rec.Start();
                end;
            }
            action(Reset)
            {
                ApplicationArea = Suite;
                Caption = 'Reset';
                Enabled = ActionResetEnabled;
                Image = ResetStatus;
                ToolTip = 'Removes all lines, readds all default tables and recalculates synchronization modes.';
                trigger OnAction()
                begin
                    Rec.DeleteAll();
                    Clear(InitialSynchRecommendations);
                    Clear(DeletedLines);
                    Rec.Generate(true);
                end;
            }
            action(ScheduleFullSynch)
            {
                ApplicationArea = Suite;
                Caption = 'Use Full Synchronization';
                Enabled = ActionRecommendFullSynchEnabled;
                Image = RefreshLines;
                ToolTip = 'This will create new coupled records based on the records from source company.';

                trigger OnAction()
                begin
                    if InitialSynchRecommendations.ContainsKey(Rec.Name) then
                        InitialSynchRecommendations.Remove(Rec.Name);
                    InitialSynchRecommendations.Add(Rec.Name, Rec."Initial Synch Recommendation"::"Full Synchronization");
                    Rec.Generate(InitialSynchRecommendations, true, DeletedLines);
                end;
            }
            action(ScheduleMatchBasedCpl)
            {
                ApplicationArea = Suite;
                Caption = 'Use Match-Based Coupling';
                Enabled = ActionRecommendMatchBasedCouplingEnabled;
                Image = RefreshLines;
                ToolTip = 'This will try to match the existing local records with the records from source company, based on the criteria that you define.';

                trigger OnAction()
                begin
                    if InitialSynchRecommendations.ContainsKey(Rec.Name) then
                        InitialSynchRecommendations.Remove(Rec.Name);
                    InitialSynchRecommendations.Add(Rec.Name, Rec."Initial Synch Recommendation"::"Couple Records");
                    Rec.Generate(InitialSynchRecommendations, true, DeletedLines);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Start_Promoted; Start)
                {
                }
                actionref(Restart_Promoted; Restart)
                {
                }
                actionref(ScheduleFullSynch_Promoted; ScheduleFullSynch)
                {
                }
                actionref(ScheduleMatchBasedCpl_Promoted; ScheduleMatchBasedCpl)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        ActionStartEnabled := (not Rec.IsThereActiveSessionInProgress()) and Rec.IsThereBlankStatusLine();
        ActionResetEnabled := (not Rec.IsThereActiveSessionInProgress());
        ActionRestartEnabled := (not Rec.IsThereActiveSessionInProgress()) and ((Rec."Job Queue Entry Status" = Rec."Job Queue Entry Status"::Error) or (Rec."Job Queue Entry Status" = Rec."Job Queue Entry Status"::Finished));
        ActionRecommendFullSynchEnabled := ActionResetEnabled and (Rec."Initial Synch Recommendation" = Rec."Initial Synch Recommendation"::"Couple Records");
        ActionRecommendMatchBasedCouplingEnabled := ActionResetEnabled and (Rec."Initial Synch Recommendation" = Rec."Initial Synch Recommendation"::"Full Synchronization");
        JobQueueEntryStatusStyle := Rec.GetStatusStyleExpression(Format(Rec."Job Queue Entry Status"));
        ToIntTableJobStatusStyle := Rec.GetStatusStyleExpression(Format(Rec."To Int. Table Job Status"));
        FromIntTableJobStatusStyle := Rec.GetStatusStyleExpression(Format(Rec."From Int. Table Job Status"));
        if not InitialSynchRecommendations.ContainsKey(Rec.Name) then
            InitialSynchRecommendations.Add(Rec.Name, Rec."Initial Synch Recommendation");

        if Rec."Initial Synch Recommendation" <> Rec."Initial Synch Recommendation"::"Couple Records" then
            InitialSynchRecommendation := Format(Rec."Initial Synch Recommendation")
        else begin
            IntegrationFieldMapping.SetRange("Integration Table Mapping Name", Rec.Name);
            IntegrationFieldMapping.SetRange("Use For Match-Based Coupling", true);
            if IntegrationFieldMapping.IsEmpty() then
                InitialSynchRecommendation := MatchBasedCouplingTxt
            else
                InitialSynchRecommendation := CouplingCriteriaSelectedTxt
        end;
        if InitialSynchRecommendation = CouplingCriteriaSelectedTxt then
            InitialSynchRecommendationStyle := 'Subordinate'
        else
            InitialSynchRecommendationStyle := Rec.GetInitialSynchRecommendationStyleExpression(Format(Rec."Initial Synch Recommendation"));
        SynchRecommendationDrillDownEnabled := (InitialSynchRecommendation in [MatchBasedCouplingTxt, CouplingCriteriaSelectedTxt]);
    end;

    trigger OnOpenPage()
    begin
        Clear(DeletedLines);
        Rec.Generate(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        DeletedLines.Add(Rec.Name);
    end;

    var
        ActionStartEnabled: Boolean;
        ActionResetEnabled: Boolean;
        ActionRestartEnabled: Boolean;
        ActionRecommendFullSynchEnabled: Boolean;
        ActionRecommendMatchBasedCouplingEnabled: Boolean;
        SynchRecommendationDrillDownEnabled: Boolean;
        InitialSynchRecommendations: Dictionary of [Code[20], Integer];
        DeletedLines: List of [Code[20]];
        JobQueueEntryStatusStyle: Text;
        ToIntTableJobStatusStyle: Text;
        FromIntTableJobStatusStyle: Text;
        StartInitialSynchTeamOwnershipModelQst: Label 'This will synchronize all coupled and non-coupled records. \\Use this option only once - right after enabling the data synchronization with the source company. After this, scheduled synchronization jobs will keep running the synchronization and you can view the logs and manage the synchronization from Synchronization Tables page. \\The initial synchronization will run in the background, so you can continue with other tasks. \\To check the status, return to this page or refresh it. \\Do you want to continue?';
        InitialSynchRecommendation: Text;
        InitialSynchRecommendationStyle: Text;
        MatchBasedCouplingTxt: Label 'Select Coupling Criteria';
        CouplingCriteriaSelectedTxt: Label 'Match-Based Coupling';
}



