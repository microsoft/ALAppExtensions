// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 10688 "SAF-T Export Subpage"
{
    PageType = ListPart;
    SourceTable = "SAF-T Export Line";
    Caption = 'Lines';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(SAFTExportLine)
            {
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the selected SAF-T file.';
                }
                field(Progress; Progress)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the progress of the selected SAF-T file.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the selected SAF-T file.';
                }
                field("Created Date/Time"; "Created Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the generation of the selected SAF-T file was completed.';
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
                ToolTip = 'Restart the generation of the selected SAF-T file.';
                Image = PostingEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    SAFTExportLine: Record "SAF-T Export Line";
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    CurrPage.SetSelectionFilter(SAFTExportLine);
                    SAFTExportMgt.RestartTaskOnExportLine(SAFTExportLine);
                    CurrPage.Update();
                end;
            }
            action(ShowError)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Error';
                ToolTip = 'Show the error that occurred when generating the selected SAF-T file.';
                Image = Error;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    SAFTExportMgt.ShowErrorOnExportLine(Rec);
                    CurrPage.Update();
                end;
            }
            action(LogEntries)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                ToolTip = 'Show the activity log for the generation of the selected SAF-T file.';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    SAFTExportMgt.ShowActivityLog(Rec);
                end;
            }
        }
    }
}
