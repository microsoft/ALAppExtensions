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
                    begin
                        if not BCPTHeader.Get(BCPTCode) then
                            Error(CannotFindBCPTSuiteErr, BCPTCode);

                        BCPTHeader.CalcFields("Total No. of Sessions");
                        CurrentBCPTHeader := BCPTHeader;
                        DurationInMins := BCPTHeader."Duration (minutes)";
                        NoOfInstances := BCPTHeader."Total No. of Sessions";
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
        }
    }

    var
        CurrentBCPTHeader: Record "BCPT Header";
        CannotFindBCPTSuiteErr: Label 'The specified BCPT Suite with code %1 cannot be found.', Comment = '%1 = BCPT Suite id.';
        EnableActions: Boolean;
        BCPTCode: Code[10];
        DurationInMins: Integer;
        NoOfInstances: Integer;

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
        CurrentBCPTHeader.CurrentRunType := CurrentBCPTHeader.CurrentRunType::BCPT;
        CurrentBCPTHeader.Modify();
        BCPTStartTests.StartNextBenchmarkTests(CurrentBCPTHeader);
    end;
}