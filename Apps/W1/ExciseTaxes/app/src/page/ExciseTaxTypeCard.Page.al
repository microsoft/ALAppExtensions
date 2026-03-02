// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

page 7415 "Excise Tax Type Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Excise Tax Type";
    Caption = 'Excise Tax Type Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique tax identifier.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the tax name for UI display.';
                }
                field("Tax Basis"; Rec."Tax Basis")
                {
                    ToolTip = 'Specifies how this tax is calculated (Weight, Sugar Content, THC Content, Volume, Spirit Volume).';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether this tax type is active and available for use.';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Report Caption"; Rec."Report Caption")
                {
                    ToolTip = 'Specifies additional description for reporting purposes.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Configure Rates")
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
            actionref("Configure Rates_Promoted"; "Configure Rates")
            {
            }
            actionref("Item/FA Rates_Promoted"; "Item/FA Rates")
            {
            }
        }
    }
}