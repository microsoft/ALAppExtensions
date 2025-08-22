// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Ledger;

pageextension 6292 "Sustainability Ledger Entries" extends "Sustainability Ledger Entries"
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
    }
}