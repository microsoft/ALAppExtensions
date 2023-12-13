// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 11780 "VAT Statement Names CZL" extends "VAT Statement Names"
{
    layout
    {
        addlast(Control1)
        {
            field("Comments CZL"; Rec."Comments CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the number of comments for VAT statement.';
            }
            field("Attachments CZL"; Rec."Attachments CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the number of attachments for VAT statement.';
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(CommentsCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "VAT Stmt. Comment Sheet CZL";
                RunPageLink = "VAT Statement Template Name" = field("Statement Template Name"),
                              "VAT Statement Name" = field(Name);
                ToolTip = 'Specifies VAT statement comments.';
            }
            action(AttachmentsCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Attachments';
                Image = Attachments;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "VAT Stmt. Attachment Sheet CZL";
                RunPageLink = "VAT Statement Template Name" = field("Statement Template Name"),
                              "VAT Statement Name" = field(Name);
                ToolTip = 'Specifies VAT statement attachments.';
            }
        }
    }
}
