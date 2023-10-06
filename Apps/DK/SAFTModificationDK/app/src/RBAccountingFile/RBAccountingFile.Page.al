// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Enums;
using System.Telemetry;

page 13687 "RB Accounting File"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            group(MappingHeader)
            {
                Caption = 'Mapping Header';

                InstructionalText = 'Please select a mapping header to use for export.';

                field(Code; GLAccountMappingHeader.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping code that represents the reporting period.';
                    TableRelation = "G/L Account Mapping Header".Code;

                    trigger OnValidate()
                    begin
                        GLAccountMappingHeader.Get(GLAccountMappingHeader.Code);
                        StartingDate := GLAccountMappingHeader."Starting Date";
                        EndingDate := GLAccountMappingHeader."Ending Date";
                        CurrPage.Update();
                    end;
                }
            }
            group(Options)
            {
                Caption = 'Period for Accounting File Export';

                field(StartingDate; StartingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies starting date for Accounting File Export';
                }
                field(EndingDate; EndingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies ending date for Accounting File Export';
                }

                field("Income Statement Amount Calculation Method"; AmtCalcMethodIncomeStatement)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Income Statement Amount Calculation Method';
                    ToolTip = 'Specifies the amount calculation method for income statement accounts.';
                }
                field("Balance Sheet Amount Calculation Method"; AmtCalcMethodBalanceSheet)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance Sheet Amount Calculation Method';
                    ToolTip = 'Specifies the amount calculation method for balance sheet accounts.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateFile)
            {
                ApplicationArea = All;
                Image = Export;
                Caption = 'Generate File';
                ToolTip = 'Generate Regnskab Basis Accounting File for selected mapping header and period.';

                trigger OnAction()
                var
                    RegnskabBasisExport: Codeunit "Regnskab Basis Export";
                begin
                    FeatureTelemetry.LogUsage('0000KT8', 'Regnskab Basis Export', 'Run Generate File action.');
                    if GLAccountMappingHeader."Period Type" = GLAccountMappingHeader."Period Type"::None then
                        Error(SelectMappingErr)
                    else begin
                        RegnskabBasisExport.Initialize(StartingDate, EndingDate, GLAccountMappingHeader, ';', AmtCalcMethodIncomeStatement, AmtCalcMethodBalanceSheet);
                        RegnskabBasisExport.Run();
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(GenerateFile_Promoted; GenerateFile)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        FeatureTelemetry.LogUsage('0000KT9', 'Regnskab Basis Export', 'Open RB Accounting File page.');
        SetDefaults();
    end;

    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AmtCalcMethodIncomeStatement: Enum "Analysis Amount Type";
        AmtCalcMethodBalanceSheet: Enum "Analysis Amount Type";
        StartingDate: Date;
        EndingDate: Date;
        SelectMappingErr: Label 'Please select an initialized mapping header with appropriate period first.';

    local procedure SetDefaults()
    begin
        AmtCalcMethodIncomeStatement := AmtCalcMethodIncomeStatement::"Net Change";
        AmtCalcMethodBalanceSheet := AmtCalcMethodBalanceSheet::"Balance at Date";
    end;
}
