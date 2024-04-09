// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6125 "E-Document Logs"
{
    ApplicationArea = Basic, Suite;
    Caption = 'E-Document Logs';
    SourceTable = "E-Document Log";
    PageType = List;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            group("Document Data Lines")
            {
                ShowCaption = false;
                repeater(DocumentLines)
                {
                    ShowCaption = false;
                    field("Entry No."; Rec."Entry No.")
                    {
                        ToolTip = 'Specifies the log entry no.';
                    }
                    field("Service Code"; Rec."Service Code")
                    {
                        ToolTip = 'Specifies the service code for the document.';
                    }
                    field("Document Format"; Rec."Document Format")
                    {
                        ToolTip = 'Specifies the document format for the document.';
                    }
                    field("Service Integration"; Rec."Service Integration")
                    {
                        ToolTip = 'Specifies the integration code for the document.';
                    }
                    field(Status; Rec.Status)
                    {
                        ToolTip = 'Specifies the status of the document.';
                    }
                    field("Created At"; Rec.SystemCreatedAt)
                    {
                        ToolTip = 'Specifies the time log was created';
                    }
                    field("Data Storage Size"; Rec."E-Doc. Data Storage Size")
                    {
                        Caption = 'File Size (B)';
                        ToolTip = 'Specifies the file size of the document in bytes.';
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExportFile)
            {
                Caption = 'Export File';
                ToolTip = 'Exports file.';
                Image = ExportAttachment;
                Enabled = IsExportEnabled;

                trigger OnAction()
                begin
                    Rec.ExportDataStorage();
                end;
            }
            action("OpenMappingLogs")
            {
                Caption = 'Open Mapping Logs';
                ToolTip = 'Opens mapping logs related to E-Document';
                Image = Log;

                trigger OnAction()
                var
                    EDocMappingLog: Record "E-Doc. Mapping Log";
                    EDocMappingLogsPage: Page "E-Doc. Mapping Logs";
                begin
                    if not Rec.CanHaveMappingLogs() then begin
                        Message(RecordDoesNotHaveMappingLogsMsg, Rec.Status);
                        exit;
                    end;

                    EDocMappingLog.SetRange("E-Doc Log Entry No.", Rec."Entry No.");
                    if not EDocMappingLog.FindSet() then begin
                        Message(NoMappingLogsFoundMsg, rec."Service Code");
                        exit;
                    end;

                    EDocMappingLogsPage.SetTableView(EDocMappingLog);
                    EDocMappingLogsPage.RunModal();
                end;
            }
        }
        area(Promoted)
        {
            actionref(ExportFile_Promoted; ExportFile) { }
            actionref(OpenMappingLogs_Promoted; OpenMappingLogs) { }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsExportEnabled := Rec."E-Doc. Data Storage Entry No." <> 0;
    end;

    var
        IsExportEnabled: Boolean;
        RecordDoesNotHaveMappingLogsMsg: Label '%1 Log entry type does not support Mapping Logs.', Comment = '%1 - The log status indicating the type';
        NoMappingLogsFoundMsg: Label 'No Mapping Logs were found for this entry. Mapping Logs are only generated when E-Document Service %1 has defined export/import mapping rules.', Comment = '%1 - E-Document Service code';
}
