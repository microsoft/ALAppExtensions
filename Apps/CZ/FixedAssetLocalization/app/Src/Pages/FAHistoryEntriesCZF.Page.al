// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using System.Security.User;

page 31248 "FA History Entries CZF"
{
    Caption = 'FA History Entries';
    DataCaptionFields = "FA No.";
    Editable = false;
    PageType = List;
    SourceTable = "FA History Entry CZF";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("FA No."; Rec."FA No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the fixed asset number.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the type of fixed asset history entry.';
                }
                field("Old Value"; Rec."Old Value")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the old fixed asset value before change was made.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the new fixed asset value after change was made.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the posting date for the fixed asset history entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the document no. for the fixed asset history entry.';
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entriy number which the history entry was closed.';
                    Visible = false;
                }
                field(Disposal; Rec.Disposal)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies disposal fixed asset entries.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Print)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Print';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    FAHistoryEntryCZF: Record "FA History Entry CZF";
                begin
                    FAHistoryEntryCZF := Rec;
                    CurrPage.SetSelectionFilter(FAHistoryEntryCZF);
                    Report.Run(Report::"FA Assignment/Discard CZF", true, false, FAHistoryEntryCZF);
                end;
            }
        }
    }
}
