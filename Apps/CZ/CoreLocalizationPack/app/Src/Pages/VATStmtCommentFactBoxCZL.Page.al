// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31219 "VAT Stmt. Comment Factbox CZL"
{
    Caption = 'Comments';
    PageType = ListPart;
    DeleteAllowed = true;
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "VAT Statement Comment Line CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date the comment was created.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment for VAT statement.';
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
                ToolTip = 'Open the comment in detail.';
                Visible = true;

                trigger OnAction()
                var
                    VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
                begin
                    VATStatementCommentLineCZL.CopyFilters(Rec);
                    Page.RunModal(Page::"VAT Stmt. Comment Sheet CZL", VATStatementCommentLineCZL);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        // When adding this factbox to a main page, the UpadtePropagation property is set to "Both" to ensure the main page is updated when a record is deleted.
        // This is necessary to call `CurrPage.Update()` to have the property take effect.
        CurrPage.Update();
    end;
}

