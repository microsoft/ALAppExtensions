// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

page 4814 "Intrastat Report Checklist"
{
    ApplicationArea = All;
    Caption = 'Intrastat Report Checklist';
    PageType = List;
    SourceTable = "Intrastat Report Checklist";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.") { }
                field("Field Name"; Rec."Field Name")
                {
                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEditFieldName();
                    end;
                }
                field("Filter Expression"; Rec."Filter Expression") { }
                field("Reversed Filter Expression"; Rec."Reversed Filter Expression") { }
                field("Must Be Blank For Filter Expr."; Rec."Must Be Blank For Filter Expr.") { }
            }
        }
    }
}