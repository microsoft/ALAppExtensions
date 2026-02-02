// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

page 7414 "Excise Tax Types"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Excise Tax Type";
    CardPageId = "Excise Tax Type Card";
    Caption = 'Excise Tax Types';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique tax identifier.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the tax name for UI display.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether this tax type is active and available for use.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Entry Permissions")
            {
                Caption = 'Configure Entry Permissions';
                ToolTip = 'Configure entry type permissions for this tax type.';
                Image = Setup;
                RunObject = Page "Excise Tax Entry Permissions";
                RunPageLink = "Excise Tax Type Code" = field(Code);
            }
            action("Item/FA Rates")
            {
                Caption = 'Item/FA Rates';
                ToolTip = 'Configure tax rates for specific items and fixed assets.';
                Image = Setup;
                RunObject = Page "Excise Tax Item/FA Rates";
                RunPageLink = "Excise Tax Type Code" = field(Code);
            }
        }
        area(Promoted)
        {
            actionref("Entry Permissions_Promoted"; "Entry Permissions")
            {
            }
            actionref("Item/FA Rates_Promoted"; "Item/FA Rates")
            {
            }
        }
    }
}