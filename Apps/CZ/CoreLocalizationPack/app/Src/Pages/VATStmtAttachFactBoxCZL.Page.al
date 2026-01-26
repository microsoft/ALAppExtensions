// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31218 "VAT Stmt. Attach. Factbox CZL"
{
    Caption = 'Attachments';
    PageType = ListPart;
    DeleteAllowed = true;
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "VAT Statement Attachment CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of VAT statement attachment.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the VAT statement attachment.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file name of VAT statement attachment.';

                    trigger OnDrillDown()
                    begin
                        Rec.Export(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenInDetail)
            {
                ApplicationArea = Basic, Suite;
                Image = ViewDetails;
                Caption = 'Show details';
                ToolTip = 'Open the document in detail.';
                Visible = true;

                trigger OnAction()
                var
                    VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
                begin
                    VATStatementAttachmentCZL.CopyFilters(Rec);
                    Page.RunModal(Page::"VAT Stmt. Attachment Sheet CZL", VATStatementAttachmentCZL);
                end;
            }
            fileuploadaction(UploadFiles)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Upload files';
                AllowMultipleFiles = true;
                Visible = true;
                Image = Import;
                ToolTip = 'Upload the file from your device.';

                trigger OnAction(files: List of [FileUpload])
                var
                    VATStatementName: Record "VAT Statement Name";
                begin
                    VATStatementName.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name");
                    Rec.Import(files, VATStatementName);
                    CurrPage.Update();
                end;
            }
            action(DownloadInRepeater)
            {
                ApplicationArea = All;
                Caption = 'Download';
                Image = Download;
                Enabled = DownloadEnabled;
                Scope = Repeater;
                ToolTip = 'Download the file to your device. Depending on the file, you will need an app to view or edit the file.';

                trigger OnAction()
                begin
                    if Rec."File Name" <> '' then
                        Rec.Export(true)
                    else
                        Error(CannotDownloadFileWithEmptyNameErr);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DownloadEnabled := Rec.HasAttachmentContent() and (not IsMultipleSelection());
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        // When adding this factbox to a main page, the UpadtePropagation property is set to "Both" to ensure the main page is updated when a record is deleted.
        // This is necessary to call `CurrPage.Update()` to have the property take effect.
        CurrPage.Update();
    end;

    var
        DownloadEnabled: Boolean;
        CannotDownloadFileWithEmptyNameErr: Label 'Cannot download a file with empty name!';

    local procedure IsMultipleSelection(): Boolean
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        CurrPage.SetSelectionFilter(VATStatementAttachmentCZL);
        exit(VATStatementAttachmentCZL.Count() > 1);
    end;
}

