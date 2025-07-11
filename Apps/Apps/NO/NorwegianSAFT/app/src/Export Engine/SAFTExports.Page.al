// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Telemetry;

page 10686 "SAF-T Exports"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "SAF-T Export Header";
    Editable = false;
    CardPageId = "SAF-T Export Card";
    Caption = 'SAF-T Exports';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Mapping Range Code"; "Mapping Range Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping range code that represents the SAF-T reporting period.';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the version of the SAF-T file to be generated.';
                }
                field(StartingDate; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the SAF-T reporting period.';
                }
                field(EndingDate; "Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the SAF-T reporting period.';
                }
                field(ParallelProcessing; "Parallel Processing")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the change will be processed by parallel background jobs.';
                }
                field("Max No. Of Jobs"; "Max No. Of Jobs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of background jobs that can be processed at the same time.';
                }
                field(SplitByMonth; "Split By Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if multiple SAF-T files will be generated per each month.';
                }
                field(SplitByDate; "Split By Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether multiple SAF-T files will be generated for each day.';
                }
                field(EarliestStartDateTime; "Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the overall status of one or more SAF-T files being generated.';
                }
                field(ExecutionStartDateTime; "Execution Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was started.';
                }
                field(ExecutionEndDateTime; "Execution End Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was completed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Start;
                Caption = 'Start';
                ToolTip = 'Start the generation of the SAF-T file.';

                trigger OnAction()
                begin
                    codeunit.Run(Codeunit::"SAF-T Export Mgt.", Rec);
                    CurrPage.Update();
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = ExportFile;
                Caption = 'Download File';
                ToolTip = 'Download the generated SAF-T file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    FeatureTelemetry.LogUptake('1000HT7', NOValueAddedTaxTok, Enum::"Feature Uptake Status"::"Used");
                    SAFTExportMgt.DownloadZipFileFromExportHeader(Rec);
                    FeatureTelemetry.LogUsage('1000HT8', NOValueAddedTaxTok, 'NO Downloaded the Generated SAF-T Files');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        FeatureTelemetry.LogUptake('1000HT5', NOValueAddedTaxTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NOValueAddedTaxTok: Label 'NO Set Up Value-added Tax', Locked = true;
}
