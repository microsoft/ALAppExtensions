// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Foundation.UOM;

table 18004 "GST Group"
{
    Caption = 'GST Group';
    DataCaptionFields = Code, Description;
    DrillDownPageId = "GST Group";
    LookupPageId = "GST Group";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
        }
        field(3; "GST Place Of Supply"; enum "GST Dependency Type")
        {
            Caption = 'GST Place Of Supply';
            DataClassification = CustomerContent;
        }
        field(4; "Description"; Code[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
        field(6; "Component Calc. Type"; Enum "Component Calc Type")
        {
            Caption = 'Component Calc. Type';
            DataClassification = CustomerContent;
        }
        field(7; "Cess Credit"; Enum "GST Credit")
        {
            Caption = 'Cess Credit';
            DataClassification = CustomerContent;
        }
        field(8; "Cess UOM"; Code[10])
        {
            Caption = 'Cess UOM';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
