// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

page 31079 "Invt. Movement Templates CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Inventory Movement Templates';
    PageType = List;
    SourceTable = "Invt. Movement Template CZL";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name for inventory movement template.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for inventory movement template.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the entry.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the Gen. Bus. Posting Group that applies to the entry.';
                }
            }
        }
    }
}
