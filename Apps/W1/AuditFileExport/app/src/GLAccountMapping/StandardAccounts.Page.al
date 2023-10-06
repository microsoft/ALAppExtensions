// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5263 "Standard Accounts"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Standard Account";
    Caption = 'Standard Accounts';

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the standard account code that is used for mapping.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the standard account that is used for mapping.';
                }
                field("Category No."; Rec."Category No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category of standard general ledger accounts that is used for mapping.';
                    Visible = false;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
}
