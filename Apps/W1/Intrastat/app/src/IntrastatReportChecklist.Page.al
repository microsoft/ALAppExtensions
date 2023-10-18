// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

page 4814 "Intrastat Report Checklist"
{
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
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the number of the table field that this entry in the checklist uses.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the name of the table field that this entry in the checklist uses.';

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEditFieldName();
                    end;
                }
                field("Filter Expression"; Rec."Filter Expression")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the filter expression that must be applied to the Intrastat line. The check for fields is run only on the lines that meet the filter criteria.';
                }
                field("Reversed Filter Expression"; Rec."Reversed Filter Expression")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies that the check for fields is run only on those lines that do not match the filter expression. If the line is not filtered, this field is ignored.';
                }
                field("Must Be Blank For Filter Expr."; Rec."Must Be Blank For Filter Expr.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the filter expression that must be applied to the Intrastat line where field must be blank. The check for fields is run only on the lines that meet the filter criteria.';
                }
            }
        }
    }
}