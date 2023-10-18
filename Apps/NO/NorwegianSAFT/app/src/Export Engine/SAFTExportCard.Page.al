// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment;

page 10687 "SAF-T Export Card"
{
    PageType = Card;
    SourceTable = "SAF-T Export Header";
    Caption = 'SAF-T Export';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Mapping Range Code"; "Mapping Range Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping range code that represents the SAF-T reporting period.';
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
                    Enabled = IsParallelProcessingAllowed;

                    trigger OnValidate()
                    begin
                        CalcParallelProcessingEnabled();
                        CurrPage.Update();
                    end;
                }
                field("Max No. Of Jobs"; "Max No. Of Jobs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of background jobs processed at the same time.';
                    Enabled = IsParallelProcessingEnabled;
                }
                field(SplitByMonth; "Split By Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if multiple SAF-T files will be generated per month.';
                }
                field(SplitByDate; "Split By Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether multiple SAF-T files will be generated for each day.';
                }
                field("Header Comment"; "Header Comment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment that is exported to the HeaderComment XML node of the SAF-T file';
                }
                field(EarliestStartDateTime; "Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                    Enabled = IsParallelProcessingEnabled;
                }
                field("Folder Path"; "Folder Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the complete path of the public folder that the SAF-T file is exported to.';
                    Visible = not IsSaaS;
                }
                field(DisableZipFileGeneration; "Disable Zip File Generation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the ZIP file would not be generated automatically. This option is available only if the folder path is specified.';
                    Visible = not IsSaaS;
                }
                field(CreateMultipleZipFiles; "Create Multiple Zip Files")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that multiple ZIP files will be generated.';
                }
                field(ExportCurrencyInformation; "Export Currency Information")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that currency information must be included in the export to the SAF-T file.';
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
                field(LatestDataCheckDateTime; "Latest Data Check Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the most recent data check was run.';
                }
                field(DataCheckStatus; "Data check status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the most recent data check.';
                }
            }
            part(ExportLines; "SAF-T Export Subpage")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = ID = field(ID);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DataCheck)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = CheckRulesSyntax;
                Caption = 'Data check';
                ToolTip = 'Check that data is ready to be exported to the SAF-T file.';
                RunObject = Codeunit "SAF-T Data Check";
            }
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
            action(GenerateZipFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Archive;
                Visible = Not IsSaaS;
                Caption = 'Regenerate Zip File';
                ToolTip = 'Generate the ZIP file again.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    SAFTExportMgt.GenerateZipFileWithCheck(Rec);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = ExportFile;
                Caption = 'Download Files';
                ToolTip = 'Download the generated SAF-T files.';
                RunObject = Page "SAF-T Export Files";
                RunPageLink = "Export ID" = field("ID");
            }
        }
    }

    var
        IsParallelProcessingAllowed: Boolean;
        IsParallelProcessingEnabled: Boolean;
        IsSaaS: Boolean;

    trigger OnOpenPage()
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsParallelProcessingAllowed := TaskScheduler.CanCreateTask();
        if not IsParallelProcessingAllowed then
            SAFTExportMgt.ThrowNoParallelExecutionNotification();
        IsSaaS := EnvironmentInformation.IsSaaS();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        IsParallelProcessingEnabled := TaskScheduler.CanCreateTask();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcParallelProcessingEnabled();
    end;

    local procedure CalcParallelProcessingEnabled()
    begin
        IsParallelProcessingEnabled := "Parallel Processing";
    end;
}
