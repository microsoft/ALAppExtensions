// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

page 6784 "Wthldg. Tax Bus. Post. Group"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Withholding Tax Bus. Post. Group';
    PageType = List;
    SourceTable = "Wthldg. Tax Bus. Post. Group";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the group.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the Withholding tax business posting group.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup';
                Image = Setup;
                RunObject = Page "Withholding Tax Posting Setup";
                RunPageLink = "Wthldg. Tax Bus. Post. Group" = field(Code);
                ToolTip = 'View or edit the withholding tax posting setup information. This includes posting groups, revenue types, and accounts.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Setup_Promoted"; "Setup")
                {
                }
            }
        }
    }
}