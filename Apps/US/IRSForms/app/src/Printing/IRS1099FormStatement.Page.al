// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10051 "IRS 1099 Form Statement"
{
    ApplicationArea = BasicUS;
    AutoSplitKey = true;
    MultipleNewLines = true;
    PageType = List;
    SaveValues = true;
    SourceTable = "IRS 1099 Form Statement Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Row No."; Rec."Row No.")
                {
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the line.';
                }
                field("Print Value Type"; Rec."Print Value Type")
                {
                    Tooltip = 'Specifies the print value type of the statement. If the Amount is selected then the amount calculated by the filter expression is printed. If the Yes/No option is selected, then either Yes or No is printed based on the Yes/No condition.';
                }
                field("Filter Expression"; Rec."Filter Expression")
                {
                    ToolTip = 'Specifies the filter expression of the statement.';
                }
                field("Row Totaling"; Rec."Row Totaling")
                {
                    ToolTip = 'Specifies a row-number interval or a series of row numbers.';
                }
                field("Print with"; Rec."Print with")
                {
                    ToolTip = 'Specifies whether amounts on the Form statement will be printed with their original sign or with the sign reversed.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

}

