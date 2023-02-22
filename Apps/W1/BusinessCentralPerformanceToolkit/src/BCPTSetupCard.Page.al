// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149001 "BCPT Setup Card"
{
    Caption = 'BCPT Suite';
    PageType = Document;
    SourceTable = "BCPT Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Enabled = Rec.Status <> Rec.Status::Running;

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the ID of the test suite.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the test suite.';
                    ApplicationArea = All;
                }
                field(Tag; Rec.Tag)
                {
                    ToolTip = 'Specifies a version or scenario the test is being run for. The Tag will be transferred to the log entries and enables comparison between scenarios.';
                    ApplicationArea = All;
                }
                field(DurationMin; Rec."Duration (minutes)")
                {
                    ToolTip = 'Specifies the duration of the test. Enter the duration in minutes you want the test to run for.';
                    ApplicationArea = All;
                }
                field(MinDelay; Rec."Default Min. User Delay (ms)")
                {
                    ToolTip = 'Specifies the fastest user input.';
                    ApplicationArea = All;
                }
                field(MaxDelay; Rec."Default Max. User Delay (ms)")
                {
                    ToolTip = 'Specifies the slowest user input.';
                    ApplicationArea = All;
                }
                field(WorkdateStarts; Rec."Work date starts at")
                {
                    ToolTip = 'Specifies the starting workdate to be used by the tests.';
                    ApplicationArea = All;
                }
                field(OneDayCorrespondsTo; Rec."1 Day Corresponds to (minutes)")
                {
                    ToolTip = 'Specifies how many test minutes should correspond to one day.';
                    ApplicationArea = All;
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the current version of the test run. Log entries will get this version no.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(BaseVersion; Rec."Base Version")
                {
                    ToolTip = 'Specifies the Base version of the test run. Used for comparisons in the lines.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the test.';
                    ApplicationArea = All;
                }
                field(Started; Rec."Started at")
                {
                    ToolTip = 'Specifies when the test was started.';
                    ApplicationArea = All;
                }
                field(TotalNoOfSessions; Rec."Total No. of Sessions")
                {
                    ToolTip = 'Specifies the total number of sessions defined in the lines. Click the number to refresh.';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            part(BCPTLines; "BCPT Lines")
            {
                ApplicationArea = All;
                Enabled = Rec.Status <> Rec.Status::Running;
                SubPageLink = "BCPT Code" = FIELD("Code"), "Version Filter" = field(Version), "Base Version Filter" = field("Base Version");
                UpdatePropagation = Both;
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(Start)
            {
                Enabled = (EnableActions and (Rec.Status <> Rec.Status::Running));
                ApplicationArea = All;
                Caption = 'Start';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Starts running the BCPT Suite.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Rec.Find();
                    Rec.CurrentRunType := Rec.CurrentRunType::BCPT;
                    Rec.Modify();
                    BCPTStartTests.StartBCPTSuite(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(StartPRT)
            {
                Enabled = (EnableActions and (Rec.Status <> Rec.Status::Running));
                ApplicationArea = All;
                Caption = 'Start in Single Run mode';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Starts and run the tests in the suite for only one iteration.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Rec.Find();
                    Rec.CurrentRunType := Rec.CurrentRunType::PRT;
                    Rec.Modify();
                    BCPTStartTests.StartBCPTSuite(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Stop)
            {
                Enabled = Rec.Status = Rec.Status::Running;
                ApplicationArea = All;
                Caption = 'Stop';
                Image = Stop;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Stops the BCPT Suite that is running.';

                trigger OnAction()
                var
                    BCPTLine: Record "BCPT Line";
                    Window: Dialog;
                    MaxDateTime: DateTime;
                    SomethingWentWrongErr: Label 'It is taking longer to stop the run than expected. You can reopen the page later to check the status or you can invoke "Reset Status" action.';
                begin
                    CurrPage.Update(false);
                    Rec.Find();
                    if Rec.Status <> Rec.Status::Running then
                        exit;
                    Window.Open('Cancelling all sessions...');
                    MaxDateTime := CurrentDateTime() + (60000 * 5); // Wait for a max of 5 mins
                    BCPTStartTests.StopBCPTSuite(Rec);

                    BCPTLine.SetRange("BCPT Code", Rec.Code);
                    BCPTLine.SetFilter(Status, '<> %1', BCPTLine.Status::Cancelled);
                    if not BCPTLine.IsEmpty then
                        repeat
                            Sleep(1000);
                            if CurrentDateTime > MaxDateTime then
                                Error(SomethingWentWrongErr);
                        until BCPTLine.IsEmpty;
                    Window.Close();

                    CurrPage.Update(false);
                    CurrPage.BCPTLines.Page.Refresh();
                end;
            }
            action(RefreshStatus)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refreshes the page.';
                Image = Refresh;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Find();
                    CurrPage.Update(false);
                end;
            }
            action(ResetStatus)
            {
                Enabled = Rec.Status = Rec.Status::Running;
                ApplicationArea = All;
                Caption = 'Reset Status';
                ToolTip = 'Reset the status.';
                Image = ResetStatus;

                trigger OnAction()
                begin
                    BCPTHeaderCU.ResetStatus(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(LogEntries)
            {
                ApplicationArea = All;
                Caption = 'Log Entries';
                Image = Entries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Open log entries.';
                RunObject = page "BCPT Log Entries";
                RunPageLink = "BCPT Code" = Field(Code), Version = field(Version);
            }
        }
    }

    var
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTHeaderCU: Codeunit "BCPT Header";
        EnableActions: Boolean;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        EnableActions := (EnvironmentInformation.IsSaas() and EnvironmentInformation.IsSandbox()) or EnvironmentInformation.IsOnPrem();
    end;
}