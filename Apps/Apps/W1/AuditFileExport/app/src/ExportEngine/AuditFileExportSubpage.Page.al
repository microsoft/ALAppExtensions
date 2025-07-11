// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5269 "Audit File Export Subpage"
{
    PageType = ListPart;
    SourceTable = "Audit File Export Line";
    Caption = 'Lines';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(AuditFileExportLine)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the selected audit file.';
                }
                field(Progress; Rec.Progress)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the progress of the generation of the selected audit file.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the generation of the selected audit file.';
                }
                field("Created Date/Time"; Rec."Created Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the generation of the selected audit file was completed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestartTask)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Restart';
                ToolTip = 'Restart the generation of the selected audit file.';
                Image = PostingEntries;

                trigger OnAction();
                var
                    AuditFileExportLine: Record "Audit File Export Line";
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    CurrPage.SetSelectionFilter(AuditFileExportLine);
                    AuditFileExportMgt.RestartTaskOnExportLine(AuditFileExportLine);
                    CurrPage.Update();
                end;
            }
            action(ShowError)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Error';
                ToolTip = 'Show the error that occurred during the generation the selected audit file.';
                Image = Error;

                trigger OnAction();
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.ShowErrorOnExportLine(Rec);
                    CurrPage.Update();
                end;
            }
            action(LogEntries)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                ToolTip = 'Show the activity log for the generation of the selected audit file.';
                Image = Log;

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.ShowActivityLog(Rec);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Image = ExportFile;
                Caption = 'Download as File';
                ToolTip = 'Download the audit file for the selected line.';

                trigger OnAction()
                var
                    AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
                begin
                    AuditFileExportMgt.DownloadFileFromAuditFileExportLine(Rec);
                end;
            }
            action(RefreshPage)
            {
                ApplicationArea = Basic, Suite;
                Image = Refresh;
                Caption = 'Refresh the page';
                ToolTip = 'Refresh the page to see the export progress.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
