// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Ledger;

tableextension 6292 "Sustainability Ledger Entry" extends "Sustainability Ledger Entry"
{
    fields
    {
        field(6290; "Calculated by Copilot"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculated by Copilot';
            Editable = false;
            ToolTip = 'Specifies if the emission has been calculated by Copilot or not.';
        }
    }
}