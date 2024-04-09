// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Security.User;

page 31156 "Cash Desk Users CZP"
{
    Caption = 'Cash Desk Users';
    DataCaptionFields = "Cash Desk No.";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Cash Desk User CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cash Desk No."; Rec."Cash Desk No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Cash Desk Code for assigning rights. Specifies options: issue or post.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = "User Lookup";
                    ToolTip = 'Specifies the ID of the user associated with the entry.';
                }
                field("User Full Name"; Rec."User Full Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the short name for the user.';
                }
                field(Create; Rec.Create)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the user has rights for creating cash desk document.';
                }
                field(Issue; Rec.Issue)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the user has rights for issuing cash desk document.';
                }
                field(Post; Rec.Post)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the user has rights for posting cash desk document.';
                }
                field("Post EET Only"; Rec."Post EET Only")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the user has the right to post only the documents that are marked as "EET Transaction" = Yes.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
}
