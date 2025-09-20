// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Setup;

table 6259 "Sustainability Disclaimer"
{
    Caption = 'Disclaimer';
    DataClassification = CustomerContent;
    LookupPageId = "Sustainability Disclaimer";
    DrillDownPageId = "Sustainability Disclaimer";

    fields
    {
        field(1; "Document Type"; Enum "Sustainability Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; Disclaimer; Text[250])
        {
            Caption = 'Disclaimer';
        }
    }
    keys
    {
        key(PK; "Document Type")
        {
            Clustered = true;
        }
    }
}