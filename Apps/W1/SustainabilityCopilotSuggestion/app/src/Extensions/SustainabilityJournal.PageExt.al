// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;
using Microsoft.Sustainability.Journal;

pageextension 6290 "Sustainability Journal" extends "Sustainability Journal"
{
    layout
    {
        addafter("Emission CO2")
        {
            field("Calculated by Copilot"; Rec."Calculated by Copilot")
            {
                ApplicationArea = All;
            }
        }
        modify("Fuel/Electricity")
        {
            BlankZero = true;
        }
        modify(Distance)
        {
            BlankZero = true;
        }
        modify("Custom Amount")
        {
            BlankZero = true;
        }
        modify("Installation Multiplier")
        {
            BlankZero = true;
        }
        modify("Time Factor")
        {
            BlankZero = true;
        }
        modify("Emission CO2")
        {
            BlankZero = true;
            Style = Strong;
        }
        modify("Emission CH4")
        {
            BlankZero = true;
        }
        modify("Emission N2O")
        {
            BlankZero = true;
        }
    }

    actions
    {
        addlast(Prompting)
        {
            action("Calculate CO2")
            {
                Caption = 'Calculate CO2';
                Image = SparkleFilled;
                ApplicationArea = All;
                Visible = CopilotVisible;
                ToolTip = 'Suggest CO2 emissions of the journal lines using Copilot.';
                trigger OnAction()
                var
                    SustainabilityJnlLine: Record "Sustainability Jnl. Line";
                    SustEmisSuggestionImpl: Codeunit "Sust. Emis. Suggestion Impl.";
                begin
                    SustainabilityJnlLine.SetFilter("Journal Template Name", Rec."Journal Template Name");
                    SustainabilityJnlLine.SetFilter("Journal Batch Name", Rec."Journal Batch Name");
                    CurrPage.SetSelectionFilter(SustainabilityJnlLine);
                    SustainabilityJnlLine.CopyFilters(Rec);

                    SustEmisSuggestionImpl.CalculateEmissionByCopilot(SustainabilityJnlLine);
                end;
            }
        }
        addafter(Post_Promoted)
        {
            actionref(CalculateCO2_Promoted; "Calculate CO2") { }
        }
    }
    trigger OnOpenPage()
    var
        SustEmisSuggestionImpl: Codeunit "Sust. Emis. Suggestion Impl.";
    begin
        CopilotVisible := SustEmisSuggestionImpl.IsReadyToUse();
    end;

    var
        CopilotVisible: Boolean;
}