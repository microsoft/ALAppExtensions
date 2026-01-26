// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31134 "VAT Stmt. Attachment Sheet CZL"
{
    AutoSplitKey = true;
    Caption = 'VAT Statement Attachment Sheet';
    DataCaptionFields = "VAT Statement Template Name", "VAT Statement Name";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "VAT Statement Attachment CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
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
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Import)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import';
                Ellipsis = true;
                Image = Import;
                ToolTip = 'Import an attachment.';
                Visible = false;

                trigger OnAction()
                begin
                    if Rec.Import() then
                        CurrPage.SaveRecord();
                end;
            }
            fileuploadaction(ImportFiles)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import files';
                AllowMultipleFiles = true;
                Visible = true;
                Image = Import;
                ToolTip = 'Import files as attachments.';

                trigger OnAction(files: List of [FileUpload])
                var
                    VATStatementName: Record "VAT Statement Name";
                begin
                    VATStatementName.Get(Rec."VAT Statement Template Name", Rec."VAT Statement Name");
                    Rec.Import(files, VATStatementName);
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Import_Promoted; Import)
                {
                }
                actionref(ImportFiles_Promoted; ImportFiles)
                {
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Date := Rec.GetDefaultDate();
    end;
}
