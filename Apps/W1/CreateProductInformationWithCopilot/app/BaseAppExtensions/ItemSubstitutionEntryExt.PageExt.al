// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;
using System.Environment;

pageextension 7330 "Item Substitution Entry Ext." extends "Item Substitution Entry"
{
    actions
    {
        addfirst(Prompting)
        {
            action("Suggest Substitution Prompting")
            {
                ApplicationArea = All;
                Caption = 'Suggest with Copilot';
                Image = SparkleFilled;
                ToolTip = 'Get item substitution suggestion from Copilot';

                trigger OnAction()
                begin
                    ItemSubstSuggestionImpl.GetItemSubstitutionSuggestion(Rec);
                end;
            }
        }
        addlast(processing)
        {
            action("Suggest Substitution")
            {
                ApplicationArea = All;
                Caption = 'Suggest with Copilot';
                Image = SparkleFilled;
                ToolTip = 'Get item substitution suggestion from Copilot';
                Visible = ProcessingActionVisible;

                trigger OnAction()
                begin
                    ItemSubstSuggestionImpl.GetItemSubstitutionSuggestion(Rec);
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(SuggestSubstitution_Promoted; "Suggest Substitution") { }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ProcessingActionVisible := not EnvironmentInformation.IsSaaSInfrastructure();
    end;

    var
        ItemSubstSuggestionImpl: Codeunit "Item Subst. Suggestion Impl.";
        ProcessingActionVisible: Boolean;
}