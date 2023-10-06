// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Telemetry;

page 5266 "Audit File Export Documents"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "Audit File Export Header";
    Editable = false;
    CardPageId = "Audit File Export Doc. Card";
    Caption = 'Audit File Export Documents';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(DocumentId; Rec.ID)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unique identifier of the audit file export document.';
                }
                field(GLAccountMappingCode; Rec."G/L Account Mapping Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account mapping code that represents the reporting period.';
                }
                field(AuditFileExportFormat; Rec."Audit File Export Format")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the format which is used for exporting the audit file.';
                }
                field(StartingDate; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the reporting period.';
                }
                field(EndingDate; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the reporting period.';
                }
                field(ParallelProcessing; Rec."Parallel Processing")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the audit file generation will be processed by parallel background jobs.';
                }
                field("Max No. Of Jobs"; Rec."Max No. Of Jobs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of background jobs that can be run at the same time.';
                }
                field(SplitByMonth; Rec."Split By Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if multiple audit files will be generated per each month.';
                }
                field(SplitByDate; Rec."Split By Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether multiple audit files will be generated for each day.';
                }
                field(EarliestStartDateTime; Rec."Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the overall status of one or more audit files being generated.';
                }
                field(ExecutionStartDateTime; Rec."Execution Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the audit file generation was started.';
                }
                field(ExecutionEndDateTime; Rec."Execution End Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the audit file generation was completed.';
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
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Start;
                Caption = 'Start';
                ToolTip = 'Start the generation of the audit file.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    if not Rec.Get(Rec.ID) then
                        exit;
                    AuditFileExportMgt.StartExport(Rec);
                    CurrPage.Update();
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ExportFile;
                Caption = 'Download File';
                ToolTip = 'Download the generated audit file.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.DownloadFileFromExportHeader(Rec);
                    FeatureTelemetry.LogUsage('0000JN5', AuditFileExportTok, 'Audit files were downloaded');
                end;
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AuditFileExportTok: label 'Audit File Export', Locked = true;
}
