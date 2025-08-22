// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Setup page for External Storage functionality.
/// Allows configuration of automatic upload and deletion policies.
/// </summary>
page 8750 "DA External Storage Setup"
{
    PageType = Card;
    SourceTable = "DA External Storage Setup";
    Caption = 'External Storage Setup';
    UsageCategory = None;
    ApplicationArea = Basic, Suite;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Delete After"; Rec."Delete After")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Auto Upload"; Rec."Auto Upload")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Auto Delete"; Rec."Auto Delete")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group(Status)
            {
                Caption = 'Status';

                field("Has Uploaded Files"; Rec."Has Uploaded Files")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RunExternalStorageSync)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Run External Storage Sync';
                Image = Process;
                ToolTip = 'Run the external storage synchronization with options to sync to or from external storage.';

                trigger OnAction()
                begin
                    Report.Run(Report::"DA External Storage Sync");
                end;
            }
        }
        area(Navigation)
        {
            action(OpenDocumentAttachmentsExternal)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Document Attachments - External Storage List';
                Image = Document;
                ToolTip = 'Open the document attachment list with information about the external storage.';
                RunObject = page "Document Attachment - External";
            }
        }
        area(Promoted)
        {
            actionref(RunExternalStorageSync_Promoted; RunExternalStorageSync)
            {
            }
            actionref(OpenDocumentAttachmentsExternal_Promoted; OpenDocumentAttachmentsExternal)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
