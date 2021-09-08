// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149004 "BCPT Lines"
{
    Caption = 'BCPT Suite Lines';
    PageType = ListPart;
    SourceTable = "BCPT Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("LoadTestCode"; Rec."BCPT Code")
                {
                    ToolTip = 'Specifies the ID of the BCPT.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ToolTip = 'Specifies the line number of the BCPT line.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field(CodeunitID; Rec."Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit id to run.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(CodeunitName; Rec."Codeunit Name")
                {
                    ToolTip = 'Specifies the name of the codeunit.';
                    ApplicationArea = All;
                }
                field(Parameters; Rec.Parameters)
                {
                    ToolTip = 'Specifies a list of parameters for the codeunit in the form of parameter1=a, parameter2=b, ...';
                    ApplicationArea = All;
                }
                field(NoOfInstances; Rec."No. of Sessions")
                {
                    ToolTip = 'Specifies the No. of Sessions.';
                    ApplicationArea = All;
                }
                field(RunInForeground; Rec."Run in Foreground")
                {
                    ToolTip = 'Specifies whether the scenarios will be executed in foreground or background.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the BCPT line.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the BCPT.';
                    ApplicationArea = All;
                }
                field(MinDelay; Rec."Min. User Delay (ms)")
                {
                    ToolTip = 'Specifies the min. user delay in ms of the BCPT.';
                    ApplicationArea = All;
                }
                field(MaxDelay; Rec."Max. User Delay (ms)")
                {
                    ToolTip = 'Specifies the max. user delay in ms of the BCPT.';
                    ApplicationArea = All;
                }
                field(Frequency; Rec."Delay (sec. btwn. iter.)")
                {
                    ToolTip = 'Specifies the frequency of the BCPT.';
                    ApplicationArea = All;
                }
                field(FreqType; Rec."Delay Type")
                {
                    ToolTip = 'Specifies the frequency type of the BCPT.';
                    ApplicationArea = All;
                }
                field(NoOfIterations; Rec."No. of Iterations")
                {
                    ToolTip = 'Specifies the number of iterations of the BCPT for this role.';
                    ApplicationArea = All;
                }
                field(Duration; Rec."Total Duration (ms)")
                {
                    ToolTip = 'Specifies Total Duration of the BCPT for this role.';
                    ApplicationArea = All;
                }
                field(AvgDuration; BCPTLineCU.GetAvgDuration(Rec))
                {
                    ToolTip = 'Specifies average duration of the BCPT for this role.';
                    Caption = 'Average Duration (ms)';
                    ApplicationArea = All;
                }
                field(NoOfSQLStmts; Rec."No. of SQL Statements")
                {
                    ToolTip = 'Specifies No. of SQL Statements of the BCPT for this role.';
                    ApplicationArea = All;
                }
                field(AvgSQLStmts; BCPTLineCU.GetAvgSQLStmts(Rec))
                {
                    ToolTip = 'Specifies average number of sql statements of the BCPT for this role.';
                    Caption = 'Avg. No. of SQL Statements';
                    ApplicationArea = All;
                }
                field(NoOfIterationsBase; Rec."No. of Iterations - Base")
                {
                    ToolTip = 'Specifies the number of iterations of the BCPT for this role for the base version.';
                    Caption = 'No. of Iterations Base';
                    ApplicationArea = All;
                }
                field(DurationBase; Rec."Total Duration - Base (ms)")
                {
                    ToolTip = 'Specifies Total Duration of the BCPT for this role for the base version.';
                    Caption = 'Total Duration Base (ms)';
                    ApplicationArea = All;
                }
                field(AvgDurationBase; GetAvg(Rec."No. of Iterations - Base", Rec."Total Duration - Base (ms)"))
                {
                    ToolTip = 'Specifies average duration of the BCPT for this role for the base version.';
                    Caption = 'Average Duration Base (ms)';
                    ApplicationArea = All;
                }
                field(NoOfSQLStmtsBase; Rec."No. of SQL Statements - Base")
                {
                    ToolTip = 'Specifies No. of SQL Statements of the BCPT for this role for the base version.';
                    Caption = 'No. of SQL Statements Base';
                    ApplicationArea = All;
                }
                field(AvgSQLStmtsBase; GetAvg(Rec."No. of Iterations - Base", Rec."No. of SQL Statements - Base"))
                {
                    ToolTip = 'Specifies average number of sql statements of the BCPT for this role for the base version.';
                    Caption = 'Avg. No. of SQL Statements Base';
                    ApplicationArea = All;
                }
                field(SQLStmtsDeltaPct; GetDiffPct(GetAvg(Rec."No. of Iterations - Base", Rec."No. of SQL Statements - Base"), GetAvg(Rec."No. of Iterations", Rec."No. of SQL Statements")))
                {
                    ToolTip = 'Specifies difference in number of sql statements of the BCPT for this role compared to the base version.';
                    Caption = 'Change in No. of SQL Statements (%)';
                    ApplicationArea = All;
                }
                field(AvgDurationDeltaPct; GetDiffPct(GetAvg(Rec."No. of Iterations - Base", Rec."Total Duration - Base (ms)"), GetAvg(Rec."No. of Iterations", Rec."Total Duration (ms)")))
                {
                    ToolTip = 'Specifies difference in duration of the BCPT for this role compared to the base version.';
                    Caption = 'Change in Duration (%)';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                Scope = Repeater;
                ToolTip = 'Add a new line.';

                trigger OnAction()
                var
                    NextBCPTLine: Record "BCPT Line";
                begin
                    // Missing implementation for very first record
                    NextBCPTLine := Rec;
                    Rec.init();
                    if NextBCPTLine.Find('>') then
                        Rec."Line No." := (NextBCPTLine."Line No." - Rec."Line No.") div 2
                    else
                        Rec."Line No." += 10000;
                    Rec.Insert(true);
                end;
            }
            action(Start)
            {
                ApplicationArea = All;
                Caption = 'Start this line in foreground';
                Image = Start;
                Tooltip = 'Starts running the BCPT Suite.';

                trigger OnAction()
                begin
                    Codeunit.Run(codeunit::"BCPT Role Wrapper", Rec);
                end;
            }
            action(Indent)
            {
                ApplicationArea = All;
                Visible = false;
                Caption = 'Make Child';  //'Indent';
                Image = Indent;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Make this process a child of the above session.';
                trigger OnAction()
                begin
                    BCPTLineCU.Indent(Rec);
                end;
            }
            action(Outdent)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
                Caption = 'Make Session';  //'Outdent';
                Image = DecreaseIndent;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Make this process its own session.';

                trigger OnAction()
                begin
                    BCPTLineCU.Outdent(Rec);
                end;
            }
        }
    }
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLineCU: Codeunit "BCPT Line";

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Min. User Delay (ms)" := BCPTHeader."Default Min. User Delay (ms)";
        Rec."Max. User Delay (ms)" := BCPTHeader."Default Max. User Delay (ms)";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."BCPT Code" = '' then
            exit(true);
        if Rec."BCPT Code" <> BCPTHeader.Code then
            if BCPTHeader.Get(Rec."BCPT Code") then;
    end;

    local procedure GetAvg(NoOfIterations: Integer; TotalNo: Integer): Integer
    begin
        if NoOfIterations = 0 then
            exit(0);
        exit(TotalNo div NoOfIterations);
    end;

    local procedure GetDiffPct(BaseNo: Integer; No: Integer): Decimal
    begin
        if BaseNo = 0 then
            exit(0);
        exit(round((100 * (No - BaseNo)) / BaseNo, 0.1));
    end;

    internal procedure Refresh()
    begin
        CurrPage.Update(false);
        if Rec.Find() then;
    end;
}