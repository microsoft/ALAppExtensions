// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10050 "IRS 1099 Form Instructions"
{
    PageType = List;
    SourceTable = "IRS 1099 Form Instruction";
    ApplicationArea = BasicUS;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period No."; Rec."Period No.")
                {
                    Tooltip = 'Specifies the period of the 1099 form box.';
                    Visible = false;
                }
                field("Form No."; Rec."Form No.")
                {
                    Tooltip = 'Specifies the 1099 form number that box belongs to.';
                    Visible = false;
                }
                field(Header; Rec.Header)
                {
                    ToolTip = 'Specifies the header of the instruction text.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the instruction text.';
                }
            }
        }
    }
}
