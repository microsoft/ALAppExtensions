// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.Sustainability.ExciseTax;

pageextension 7414 "Excise Journal Line Ext" extends "Sustainability Excise Journal"
{
    layout
    {
        modify("Entry Type")
        {
            Visible = not EnableExciseTax;
        }
        modify("Total Emission Cost")
        {
            Visible = not EnableExciseTax;
        }
        addafter("Posting Date")
        {
            field("Excise Tax Type"; Rec."Excise Tax Type")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                ToolTip = 'Specifies the excise tax type for this journal line.';
            }
            field("Excise Entry Type"; Rec."Excise Entry Type")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                ToolTip = 'Specifies which entry type was used to calculate the quantity from Item Ledger Entries for this journal line.';
            }
        }
        addafter("Source Unit of Measure Code")
        {
            field("Excise Unit of Measure Code"; Rec."Excise Unit of Measure Code")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                Editable = false;
                ToolTip = 'Specifies the unit of measure for the excise tax quantity.';
            }
        }
        addafter("Source Qty.")
        {
            field("Quantity for Excise Tax"; Rec."Quantity for Excise Tax")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                Editable = false;
                ToolTip = 'Specifies the quantity for excise tax calculation.';
            }
            field("Tax Rate %"; Rec."Tax Rate %")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                ToolTip = 'Specifies the tax rate percentage applied to this journal line.';
            }
            field("Tax Amount"; Rec."Tax Amount")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                ToolTip = 'Specifies the calculated excise tax amount for this journal line.';
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("Generate Excise Tax Entries")
            {
                ApplicationArea = All;
                Caption = 'Generate Excise Tax Entries';
                ToolTip = 'Generate excise tax journal entries based on Item Ledger Entry quantities for the specified date range.';
                Image = CreateDocuments;
                Enabled = EnableExciseTax;

                trigger OnAction()
                var
                    CreateExciseTaxJnlEntries: Report "Create Excise Tax Jnl. Entries";
                begin
                    CreateExciseTaxJnlEntries.SetExciseJournalLine(Rec);
                    CreateExciseTaxJnlEntries.RunModal();
                end;
            }
        }
        modify(Calculate)
        {
            Enabled = not EnableExciseTax;
        }
        addafter(Calculate_Promoted)
        {
            actionref("Generate Excise Tax Entries_Promoted"; "Generate Excise Tax Entries")
            {
            }
        }
    }
}