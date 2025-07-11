// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

table 18692 "TDS Section"
{
    Caption = 'Section';
    DrillDownPageId = "TDS Sections";
    LookupPageId = "TDS Sections";
    DataCaptionFields = "Code", "Description";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; ecode; Code[10])
        {
            Caption = 'ecode';
            DataClassification = CustomerContent;
        }
        field(4; Detail; Blob)
        {
            Caption = 'Detail';
            DataClassification = CustomerContent;
        }
        field(5; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
            DataClassification = CustomerContent;
        }
        field(6; "Indentation Level"; Integer)
        {
            Caption = 'Indentation Level';
            DataClassification = CustomerContent;
        }
        field(7; "Parent Code"; Code[20])
        {
            Caption = 'Parent Code';
            DataClassification = CustomerContent;
        }
        field(8; "Section Order"; Integer)
        {
            Caption = 'Section Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; "Presentation Order") { }
    }
}
