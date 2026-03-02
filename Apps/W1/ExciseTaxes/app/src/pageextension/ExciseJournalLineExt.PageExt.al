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
                CaptionClass = GetCaptionClass(Rec.FieldNo("Quantity for Excise Tax"));
                Editable = false;
                ToolTip = 'Specifies the quantity for excise tax calculation.';
            }
            field("Excise Duty"; Rec."Excise Duty")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                CaptionClass = GetCaptionClass(Rec.FieldNo("Excise Duty"));
                ToolTip = 'Specifies the excise duty applied to this journal line.';
            }
            field("Tax Amount"; Rec."Tax Amount")
            {
                ApplicationArea = All;
                Visible = EnableExciseTax;
                CaptionClass = GetCaptionClass(Rec.FieldNo("Tax Amount"));
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

    var
        ExciseCaptionTxt: Label '%1 (%2)', Comment = '%1 = Field Caption, %2 = Report Caption';

    local procedure GetCaptionClass(FieldNo: Integer): Text
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        ExciseTaxType: Record "Excise Tax Type";
    begin
        if not SustainabilityExciseJnlBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJournalBatchName) then
            exit;

        GetExciseTaxType(ExciseTaxType, SustainabilityExciseJnlBatch."Excise Tax Type Filter");

        case FieldNo of
            Rec.FieldNo("Quantity for Excise Tax"):
                if ExciseTaxType."Report Caption" <> '' then
                    exit(StrSubstNo(ExciseCaptionTxt, Rec.FieldCaption("Quantity for Excise Tax"), ExciseTaxType."Report Caption"))
                else
                    exit(Rec.FieldCaption("Quantity for Excise Tax"));
            Rec.FieldNo("Excise Duty"):
                if ExciseTaxType."Report Caption" <> '' then
                    exit(StrSubstNo(ExciseCaptionTxt, Rec.FieldCaption("Excise Duty"), ExciseTaxType."Report Caption"))
                else
                    exit(Rec.FieldCaption("Excise Duty"));
            Rec.FieldNo("Tax Amount"):
                if ExciseTaxType."Report Caption" <> '' then
                    exit(StrSubstNo(ExciseCaptionTxt, Rec.FieldCaption("Tax Amount"), ExciseTaxType."Report Caption"))
                else
                    exit(Rec.FieldCaption("Tax Amount"));
        end;
    end;

    local procedure GetExciseTaxType(var ExciseTaxType: Record "Excise Tax Type"; ExciseTaxTypeCode: Code[20])
    begin
        if not ExciseTaxType.Get(ExciseTaxTypeCode) then
            exit;
    end;
}