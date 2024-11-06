// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;
using System.AI;

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
                Enabled = IsCapabilityRegistered;
                Visible = IsCapabilityRegistered;

                trigger OnAction()
                begin
                    ItemSubstSuggestionImpl.GetItemSubstitutionSuggestion(Rec);
                end;
            }
        }
    }

    var
        ItemSubstSuggestionImpl: Codeunit "Item Subst. Suggestion Impl.";
        IsCapabilityRegistered: Boolean;

    trigger OnOpenPage()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        IsCapabilityRegistered := CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Create Product Information");
    end;

}