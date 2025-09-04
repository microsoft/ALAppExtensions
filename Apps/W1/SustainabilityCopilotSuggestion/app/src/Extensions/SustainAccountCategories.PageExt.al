// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;

pageextension 6293 "Sustain. Account Categories" extends "Sustain. Account Categories"
{
    layout
    {
        addlast(GroupName)
        {
            field("Exclude From Copilot"; Rec."Exclude From Copilot")
            {
                ApplicationArea = All;
            }
            field("Do Not Calc. Emiss. Factor"; Rec."Do Not Calc. Emiss. Factor")
            {
                ApplicationArea = All;
            }
        }
    }
}