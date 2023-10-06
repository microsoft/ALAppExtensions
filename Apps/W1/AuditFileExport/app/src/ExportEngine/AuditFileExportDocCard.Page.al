// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment;

page 5267 "Audit File Export Doc. Card"
{
    PageType = Card;
    SourceTable = "Audit File Export Header";
    Caption = 'Audit File Export Document';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(AuditFileExportFormat; Rec."Audit File Export Format")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the format which is used for exporting the audit file.';
                }
                field(GLAccountMappingCode; Rec."G/L Account Mapping Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the G/L account mapping code that represents the reporting period.';
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
                field(SplitByMonth; Rec."Split By Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if multiple audit files will be generated per month.';
                }
                field(SplitByDate; Rec."Split By Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether multiple audit files will be generated for each day.';
                }
                field("Header Comment"; Rec."Header Comment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment that is exported to the header of the audit file';
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact that is exported to the header of the audit file';
                }
                field(ZipFileGeneration; Rec."Archive to Zip")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that all files will be packed into a Zip archive.';
                    Visible = not IsSaaS;
                }
                field(CreateMultipleZipFiles; Rec."Create Multiple Zip Files")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that multiple Zip files will be generated.';
                }
            }
            group(Processing)
            {
                Caption = 'Processing';

                field(ParallelProcessing; Rec."Parallel Processing")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the audit file generation will be processed by parallel background jobs.';
                    Enabled = IsParallelProcessingAllowed;

                    trigger OnValidate()
                    begin
                        CalcParallelProcessingEnabled();
                        CurrPage.Update();
                    end;
                }
                field("Max No. Of Jobs"; Rec."Max No. Of Jobs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of background jobs that can be run at the same time.';
                    Enabled = IsParallelProcessingEnabled;
                }
                field(EarliestStartDateTime; Rec."Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                    Enabled = IsParallelProcessingEnabled;
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
                field(LatestDataCheckDateTime; Rec."Latest Data Check Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the most recent data check was run.';
                }
                field(DataCheckStatus; Rec."Data check status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the most recent data check.';
                }
            }
            part(ExportLines; "Audit File Export Subpage")
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
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CheckRulesSyntax;
                Caption = 'Data check';
                ToolTip = 'Check that data is ready to be exported to the audit file.';

                trigger OnAction()
                var
                    IAuditFileExportDataCheck: Interface "Audit File Export Data Check";
                begin
                    IAuditFileExportDataCheck := Rec."Audit File Export Format";
                    IAuditFileExportDataCheck.CheckDataToExport(Rec);
                end;
            }
            action(Start)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Start;
                Caption = 'Start';
                ToolTip = 'Start the generation of the audit file.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.StartExport(Rec);
                    CurrPage.Update();
                end;
            }
            action(CreateAuditFiles)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateXML;
                Caption = 'Recreate Audit Files';
                ToolTip = 'Recreate the files using the already collected audit data.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.GenerateAuditFileWithCheck(Rec);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ExportFile;
                Caption = 'Download Files';
                ToolTip = 'Download the generated audit files.';
                RunObject = page "Audit Files";
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
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsParallelProcessingAllowed := TaskScheduler.CanCreateTask();
        if not IsParallelProcessingAllowed then
            AuditFileExportMgt.ThrowNoParallelExecutionNotification();
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
        IsParallelProcessingEnabled := Rec."Parallel Processing";
    end;
}
