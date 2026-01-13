// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;

pageextension 6291 "Sustain. Account Subcategories" extends "Sustain. Account Subcategories"
{
    layout
    {
        addafter("Emission Factor CO2")
        {
            field("Calculated by Copilot"; Rec."Calculated by Copilot")
            {
                ApplicationArea = All;
            }
            field("Emission Factor Source"; Rec."Emission Factor Source")
            {
                ApplicationArea = All;
            }
        }

    }
}