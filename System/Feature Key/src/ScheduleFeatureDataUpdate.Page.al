// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page provide the dialog where user can run or schedule the feature datat update.
/// </summary>
page 2612 "Schedule Feature Data Update"
{
    Caption = 'Feature Data Update';
    DataCaptionExpression = Rec."Feature Key";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Feature Data Update Status";
    SourceTableTemporary = true;
    Permissions = tabledata "Feature Data Update Status" = rim;

    layout
    {
        area(content)
        {
            group(Step1)
            {
                Caption = 'Step 1';
                Visible = Step1Visible;
                group(general)
                {
                    Caption = 'What is updated';
                    group(descr)
                    {
                        ShowCaption = false;
                        field(Description; Description)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Visible = Description <> '';
                            Editable = false;
                            MultiLine = true;
                            ToolTip = 'Specifies the description of what is going to happen during the data update task.';
                        }
                    }
                }
                group(Review)
                {
                    ShowCaption = false;
                    field(ReviewData; ReviewDataTok)
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = DataUpdateImplemented;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            if not FeatureManagementFacade.ReviewData(Rec) then
                                Message(NoDataMsg);
                        end;
                    }
                }
                group(agreement)
                {
                    ShowCaption = false;
                    field(Agreed; Agreed)
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = DataUpdateImplemented;
                        Caption = 'I accept the data update';
                        ToolTip = 'Specifies whether the user does understand the update procedure and agree to proceed.';

                        trigger OnValidate()
                        begin
                            NextEnable := Agreed;
                            Rec.Validate("Background Task", false);
                        end;
                    }
                }
            }
            group(Step2)
            {
                Caption = 'Step 2';
                Visible = Step2Visible;
                group(CurrSessionText)
                {
                    ShowCaption = false;
                    Visible = not "Background Task";
                    InstructionalText = 'The data update task will be running in the current session.';
                }
                group(BackgroundSessionText)
                {
                    ShowCaption = false;
                    Visible = "Background Task";
                    InstructionalText = 'The data update task will be running in the background session.';
                }
                group(Background)
                {
                    ShowCaption = false;
                    Visible = CanCreateTask;
                    field(BackgroundTask; Rec."Background Task")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Run In Background Session';
                        ToolTip = 'Specifies whether the task should be run in the current or in the background session.';
                    }
                }
                group(setup)
                {
                    Caption = 'Schedule Background Task';
                    Visible = "Background Task";
                    group(SetupBackgroundTask)
                    {
                        ShowCaption = false;
                        field("Start Date/Time"; Rec."Start Date/Time")
                        {
                            ApplicationArea = Basic, Suite;
                            Enabled = not RunNow;
                            Caption = 'Start Date/Time';
                            ToolTip = 'Specifies the earliest date and time when the task should be run in the background session.';
                        }
                        field(RunNow; RunNow)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Run Immediately';
                            ToolTip = 'Specifies whether the task should be run immediately in the background session.';

                            trigger OnValidate()
                            begin
                                if RunNow then
                                    Rec."Start Date/Time" := CurrentDateTime();
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = All;
                Caption = '&Back';
                Enabled = BackEnable;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowStep(false);
                    WizardStep -= 1;
                    ShowStep(true);
                    CurrPage.Update(true);
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = '&Next';
                Enabled = NextEnable;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowStep(false);
                    WizardStep += 1;
                    ShowStep(true);
                    CurrPage.Update(true);
                end;
            }
            action(Update)
            {
                ApplicationArea = All;
                Caption = '&Update';
                Visible = not "Background Task";
                Enabled = FinishEnable;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    Rec."Start Date/Time" := 0DT;
                    ConfirmTask();
                end;
            }
            action(Schedule)
            {
                ApplicationArea = All;
                Caption = '&Schedule';
                Visible = "Background Task";
                Enabled = FinishEnable;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ConfirmTask();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        NextEnable := true;
        WizardStep := 1;
    end;

    trigger OnOpenPage()
    begin
        CanCreateTask := TaskScheduler.CanCreateTask();
        DataUpdateImplemented := FeatureManagementFacade.GetImplementation(Rec);
        if DataUpdateImplemented then
            Description := FeatureManagementFacade.GetTaskDescription(Rec)
        else
            Description := StrSubstNo(NotImplementedMsg, Rec."Feature Key");
        ShowStep(true);
    end;

    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        Description: Text;
        Agreed: Boolean;
        RunNow: Boolean;
        CanCreateTask: Boolean;
        ReviewDataTok: Label 'Review affected data';
        NoDataMsg: Label 'There is no data to be updated. Complete the update in the current session to enable the feature.';
        NotImplementedMsg: Label 'The feature %1 cannot be enabled because data update handling is not implemented.', Comment = '%1 - feature key id';
        [InDataSet]
        DataUpdateImplemented: Boolean;
        [InDataSet]
        Step1Visible: Boolean;
        [InDataSet]
        Step2Visible: Boolean;
        [InDataSet]
        NextEnable: Boolean;
        [InDataSet]
        BackEnable: Boolean;
        [InDataSet]
        FinishEnable: Boolean;
        WizardStep: Integer;

    local procedure ConfirmTask()
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        if FeatureDataUpdateStatus.Get(Rec."Feature Key", Rec."Company Name") then begin
            FeatureDataUpdateStatus.TransferFields(Rec);
            FeatureDataUpdateStatus.Confirmed := true;
            FeatureDataUpdateStatus.Modify();
        end;
        CurrPage.Close();
    end;

    /// <summary>
    /// Inserts the copy of "Feature Data Update Status" record as a temporary source of the page.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">the instance of the actual record</param>
    procedure Set(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        Rec := FeatureDataUpdateStatus;
        Rec.Insert()
    end;

    local procedure ShowStep(Visible: Boolean)
    begin
        case WizardStep of
            1:
                begin
                    Step1Visible := Visible;
                    NextEnable := Agreed;
                    BackEnable := false;
                    FinishEnable := false;
                end;
            2:
                begin
                    Step2Visible := Visible;
                    BackEnable := true;
                    NextEnable := false;
                    FinishEnable := true;
                end;
        end;
    end;
}