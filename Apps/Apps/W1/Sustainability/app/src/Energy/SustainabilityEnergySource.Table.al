// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Energy;

table 6233 "Sustainability Energy Source"
{
    DataClassification = CustomerContent;
    Caption = 'Sustainability Energy Source';
    LookupPageId = "Sustainability Energy Sources";
    DrillDownPageId = "Sustainability Energy Sources";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            ToolTip = 'Specifies the number assigned to the energy source.';
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}