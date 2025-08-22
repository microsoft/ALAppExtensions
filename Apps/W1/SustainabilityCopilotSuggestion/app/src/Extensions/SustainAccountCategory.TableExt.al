// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;

tableextension 6293 "Sustain. Account Category" extends "Sustain. Account Category"
{
    fields
    {
        field(6290; "Exclude From Copilot"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Exclude From Copilot';
            ToolTip = 'Specifies if the account category should be excluded from Copilot suggestions.';
        }
        field(6291; "Do Not Calc. Emiss. Factor"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Do Not Calc. Emiss. Factor';
            ToolTip = 'Specifies if the emission factor should be calculated for the account category.';
        }
    }
}