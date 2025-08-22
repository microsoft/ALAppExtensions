// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Journal;

tableextension 6290 "Sustainability Journal Line" extends "Sustainability Jnl. Line"
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