// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

page 31115 "Cross Application CZL"
{
    Caption = 'Cross Application';
    Editable = false;
    PageType = List;
    SourceTable = "Cross Application Buffer CZL";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Table ID applied this entry.';
                    Visible = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Table Name applied this entry.';
                }
                field("Applied Document No."; Rec."Applied Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Document No. applied this entry.';
                }
                field("Applied Document Line No."; Rec."Applied Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Line No. of document applied this entry.';
                    Visible = false;
                }
                field("Applied Document Date"; Rec."Applied Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Document Date of document applied this entry.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Amount (LCY) of document applied this entry.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowDocumentLine)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document Line';
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortcutKey = 'Ctrl+F7';
                ToolTip = 'Displays related applied document line.';

                trigger OnAction()
                begin
                    OnShowCrossApplicationDocument(Rec."Table ID", Rec."Applied Document No.", Rec."Applied Document Line No.");
                end;
            }
        }
    }

    [IntegrationEvent(false, false)]
    local procedure OnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    begin
    end;
}
