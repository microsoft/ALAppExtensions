// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149003 "BCPT Log Entries"
{
    Caption = 'BCPT Log Entries';
    PageType = List;
    Editable = false;
    SourceTable = "BCPT Log Entry";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Rec."BCPT Code")
                {
                    ToolTip = 'Specifies the BCPT Code of the BCPT.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("BCPT Line No."; Rec."BCPT Line No.")
                {
                    ToolTip = 'Specifies the Line No. of the BCPT.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Tag; Rec.Tag)
                {
                    ToolTip = 'Specifies the Tag that we entered in the BCPT header.';
                    ApplicationArea = All;
                }
                field(Version; Rec.Version)
                {
                    Caption = 'Version No.';
                    ToolTip = 'Specifies the Version No. of the BCPT execution.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the Entry No. of the BCPT.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(StartTime; Format(Rec."Start Time", 0, '<Year4>-<Month,2>-<Day,2> <Hours24>:<Minutes,2>:<Seconds,2><Second dec.>'))
                {
                    Caption = 'Start Time';
                    ToolTip = 'Specifies the start time of the BCPT scenario.';
                    ApplicationArea = All;
                }
                field(EndTime; Format(Rec."End Time", 0, '<Year4>-<Month,2>-<Day,2> <Hours24>:<Minutes,2>:<Seconds,2><Second dec.>'))
                {
                    Caption = 'End Time';
                    ToolTip = 'Specifies the end time of the BCPT scenario.';
                    ApplicationArea = All;
                }
                field(CodeunitID; Rec."Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit id of the BCPT.';
                    ApplicationArea = All;
                }
                field(CodeunitName; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the codeunit name of the BCPT.';
                    ApplicationArea = All;
                }
                field(SessionId; Rec."Session No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique session this scenario was run in. You can use the Session No. to correlated log entries.';
                }
                field(Operation; Rec.Operation)
                {
                    ToolTip = 'Specifies the single operation of the BCPT.';
                    ApplicationArea = All;
                }
                field(Message; Rec.Message)
                {
                    Caption = 'Message';
                    ToolTip = 'Specifies when the message from the test.';
                    ApplicationArea = All;
                }
                field(DurationMin; Rec."Duration (ms)")
                {
                    Caption = 'Duration (ms)';
                    ToolTip = 'Specifies the duration of the iteration.';
                    ApplicationArea = All;
                }
                field(NoOfSQLStmts; Rec."No. of SQL Statements")
                {
                    Caption = 'No. of SQL Statements';
                    ToolTip = 'Specifies the No. of SQL Statements of the iteration.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the iteration.';
                    ApplicationArea = All;
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete entries within filter';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Deletes all the log entries.';

                trigger OnAction()
                begin
                    if not Confirm(DoYouWantToDeleteQst, false) then
                        exit;
                    Rec.DeleteAll();
                    CurrPage.Update(false);
                end;
            }
            action(ShowErrors)
            {
                ApplicationArea = All;
                Visible = not IsFilteredToErrors;
                Caption = 'Show errors';
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Shows only errors.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Error);
                    IsFilteredToErrors := true;
                    CurrPage.Update(false);
                end;
            }
            action(ClearShowErrors)
            {
                ApplicationArea = All;
                Visible = IsFilteredToErrors;
                Caption = 'Show success and errors';
                Image = RemoveFilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Clears the filter on errors.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status);
                    IsFilteredToErrors := false;
                    CurrPage.Update(false);
                end;
            }
            action(ShowSimultaneous)
            {
                ApplicationArea = All;
                Visible = not IsFilteredToThisLine;
                Caption = 'Show sessions running at the same time as this';
                Image = FilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Shows all the sessions that are running at the same time.';

                trigger OnAction()
                begin
                    Rec.SetRange("Start Time", 0DT, Rec."End Time");
                    Rec.SetFilter("End Time", '>=%1', Rec."Start Time");
                    IsFilteredToThisLine := true;
                    CurrPage.Update(false);
                end;
            }
            action(ClearShowSimultaneous)
            {
                ApplicationArea = All;
                Visible = IsFilteredToThisLine;
                Caption = 'Show sessions for all times';
                Image = RemoveFilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Show all sessions.';

                trigger OnAction()
                begin
                    Rec.SetRange("Start Time");
                    Rec.SetRange("End Time");
                    IsFilteredToThisLine := false;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        DoYouWantToDeleteQst: Label 'Do you want to delete all entries within the filter?';
        IsFilteredToThisLine: Boolean;
        IsFilteredToErrors: Boolean;
}