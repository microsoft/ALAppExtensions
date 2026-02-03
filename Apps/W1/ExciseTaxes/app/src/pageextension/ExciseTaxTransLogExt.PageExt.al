// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.Ledger;
using Microsoft.Inventory.Ledger;
using Microsoft.Sustainability.ExciseTax;

pageextension 7416 "Excise Tax Trans Log Ext" extends "Sust. Excise Taxes Trans. Logs"
{
    layout
    {
        addafter("Log Type")
        {
            field("Excise Tax Type"; Rec."Excise Tax Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the excise tax type.';
            }
            field("Excise Entry Type"; Rec."Excise Entry Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the excise entry type.';
            }
        }
        addafter("Source Unit of Measure Code")
        {
            field("Excise Unit of Measure Code"; Rec."Excise Unit of Measure Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the unit of measure for excise tax calculation.';
            }
        }
        addafter("Source Qty.")
        {
            field("Quantity for Excise Tax"; Rec."Quantity for Excise Tax")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity for tax calculation.';
            }
            field("Tax Rate %"; Rec."Tax Rate %")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tax rate percentage.';
            }
            field("Tax Amount"; Rec."Tax Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the calculated tax amount.';
            }
        }
        addafter("Certificate Amount")
        {
            field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the related item ledger entry number.';
                Visible = false;
            }
            field("FA Ledger Entry No."; Rec."FA Ledger Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the related fixed asset ledger entry number.';
                Visible = false;
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            group("Excise Tax")
            {
                Caption = 'Excise Tax';

                action("Item Ledger Entry")
                {
                    ApplicationArea = All;
                    Caption = 'Item Ledger Entry';
                    ToolTip = 'View the related item ledger entry.';
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Entry No." = field("Item Ledger Entry No.");
                    Enabled = Rec."Item Ledger Entry No." <> 0;
                    Image = ItemLedger;
                }
                action("FA Ledger Entry")
                {
                    ApplicationArea = All;
                    Caption = 'FA Ledger Entry';
                    ToolTip = 'View the related fixed asset ledger entry.';
                    RunObject = Page "FA Ledger Entries";
                    RunPageLink = "Entry No." = field("FA Ledger Entry No.");
                    Enabled = Rec."FA Ledger Entry No." <> 0;
                    Image = FixedAssets;
                }
            }
        }
        addlast(Promoted)
        {
            group("Excise Tax_Promoted")
            {
                Caption = 'Excise Tax';

                actionref("Item Ledger Entry_Promoted"; "Item Ledger Entry")
                {
                }
                actionref("FA Ledger Entry_Promoted"; "FA Ledger Entry")
                {
                }
            }
        }
    }
}