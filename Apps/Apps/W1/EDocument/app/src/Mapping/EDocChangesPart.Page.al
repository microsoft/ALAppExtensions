// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6123 "E-Doc. Changes Part"
{
    ApplicationArea = Basic, Suite;
    PageType = ListPart;
    SourceTable = "E-Doc. Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater("E-Doc Changes")
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indent;
                TreeInitialState = CollapseAll;
                field(LineNo; Rec."Line No.")
                {
                    Caption = 'Line No';
                    Visible = ShowLineNo;
                    ToolTip = 'Specifies the line number.';
                }
                field("Table ID Caption"; Rec."Table ID Caption")
                {
                    Caption = 'Table';
                    ToolTip = 'Specifies the caption of the table.';
                }
                field("Field ID Caption"; Rec."Field ID Caption")
                {
                    Caption = 'Field';
                    ToolTip = 'Specifies the caption of the field.';
                }
                field("Find Value"; Rec."Find Value")
                {
                    Caption = 'Original Value';
                    ToolTip = 'Specifies the value the original value of the field.';
                }
                field("Replace Value"; Rec."Replace Value")
                {
                    Caption = 'New Value';
                    ToolTip = 'Specifies the new value of the field.';
                }
                field(Indent; Rec.Indent)
                {
                    Visible = false;
                    Caption = 'Indent';
                    ToolTip = 'Specifies the indent used to group certain entries together.';
                }
            }
        }
    }

    var
        ShowLineNo: Boolean;

    internal procedure SetChanges(var DocumentMapping: Record "E-Doc. Mapping" temporary)
    begin
        if DocumentMapping.FindSet() then
            repeat
                Rec := DocumentMapping;
                Rec.Insert();
            until DocumentMapping.Next() = 0;
        Rec.SetCurrentKey("Table ID", "Field ID");
    end;

    internal procedure ShowLines()
    begin
        ShowLineNo := true;
    end;
}
