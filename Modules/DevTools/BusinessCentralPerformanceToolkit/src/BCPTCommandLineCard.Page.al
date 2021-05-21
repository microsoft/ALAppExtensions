// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
page 149002 "BCPT CommandLine Card"
{
    Caption = 'BCPT CommandLine Runner';
    PageType = Card;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Select Code"; BCPTCode)
                {
                    Caption = 'Select Code', Locked = true;
                    ToolTip = 'Specifies the ID of the suite.';
                    ApplicationArea = All;
                    TableRelation = "BCPT Header".Code;

                    trigger OnValidate()
                    var
                        BCPTHeader: record "BCPT Header";
                        BCPTLine: record "BCPT Line";
                    begin
                        if not BCPTHeader.Get(BCPTCode) then
                            Error(CannotFindBCPTSuiteErr, BCPTCode);

                        BCPTHeader.CalcFields("Total No. of Sessions");
                        CurrentBCPTHeader := BCPTHeader;
                        DurationInMins := BCPTHeader."Duration (minutes)";
                        NoOfInstances := BCPTHeader."Total No. of Sessions";
                        BCPTLine.SetRange("BCPT Code", BCPTCode);
                        NoOfTests := BCPTLine.Count();
                    end;
                }

                field("Duration (minutes)"; DurationInMins)
                {
                    Caption = 'Duration (minutes)', Locked = true;
                    ToolTip = 'Specifies the duration the suite will be run.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. of Instances"; NoOfInstances)
                {
                    Caption = 'No. of Instances', Locked = true;
                    ToolTip = 'Specifies the number of instances that will be created.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. of Tests"; NoOfTests)
                {
                    Caption = 'No. of Tests', Locked = true;
                    ToolTip = 'Specifies the number of BCPT Suite Lines present in the BCPT Suite';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(StartNext)
            {
                Enabled = EnableActions;
                ApplicationArea = All;
                Caption = 'Start Next', Locked = true;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Starts the next available test.';

                trigger OnAction()
                begin
                    StartNextBCPT();
                end;
            }
            action(StartNextPRT)
            {
                Enabled = EnableActions;
                ApplicationArea = All;
                Caption = 'Start Next in Single Run mode', Locked = true;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Starts the next available test in PRT mode.';

                trigger OnAction()
                begin
                    StartNextBCPTAsPRT();
                end;
            }
        }
    }

    var
        CurrentBCPTHeader: Record "BCPT Header";
        CannotFindBCPTSuiteErr: Label 'The specified BCPT Suite with code %1 cannot be found.', Comment = '%1 = BCPT Suite id.';
        EnableActions: Boolean;
        BCPTCode: Code[10];
        DurationInMins: Integer;
        NoOfInstances: Integer;
        NoOfTests: Integer;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        EnableActions := (EnvironmentInformation.IsSaas() and EnvironmentInformation.IsSandbox()) or EnvironmentInformation.IsOnPrem();
    end;

    local procedure StartNextBCPT()
    var
        BCPTStartTests: Codeunit "BCPT Start Tests";
    begin
        if CurrentBCPTHeader.CurrentRunType <> CurrentBCPTHeader.CurrentRunType::BCPT then begin
            CurrentBCPTHeader.LockTable();
            CurrentBCPTHeader.Find();
            CurrentBCPTHeader.CurrentRunType := CurrentBCPTHeader.CurrentRunType::BCPT;
            CurrentBCPTHeader.Modify();
            Commit();
        end;
        BCPTStartTests.StartNextBenchmarkTests(CurrentBCPTHeader);
        CurrentBCPTHeader.Find();
    end;

    local procedure StartNextBCPTAsPRT()
    var
        BCPTStartTests: Codeunit "BCPT Start Tests";
    begin
        CurrentBCPTHeader.CurrentRunType := CurrentBCPTHeader.CurrentRunType::PRT;
        CurrentBCPTHeader.Modify();
        BCPTStartTests.StartNextBenchmarkTests(CurrentBCPTHeader);
    end;
}