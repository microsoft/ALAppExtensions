// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;
using Microsoft.Sustainability.Account;
tableextension 6291 "Sustain. Account Subcategory" extends "Sustain. Account Subcategory"
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
        field(6291; "Emission Factor Source"; Text[1024])
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Source';
            ToolTip = 'Specifies the source of the emission factor';
        }
    }
}