// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1997 "Spotlight Tour Text"
{
    Caption = 'Spotlight Tour Text';
    Access = Internal;

    fields
    {
        field(1; "Guided Experience Item Code"; Code[300])
        {
            Caption = 'Guided Experience Item Code';
            DataClassification = SystemMetadata;
            TableRelation = "Guided Experience Item".Code;
        }
        field(2; "Guided Experience Item Version"; Integer)
        {
            Caption = 'Version';
            DataClassification = SystemMetadata;
            TableRelation = "Guided Experience Item".Version;
        }
        field(3; "Spotlight Tour Step"; Enum "Spotlight Tour Text")
        {
            Caption = 'Spotlight Tour Step';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(4; "Spotlight Tour Text"; Text[250])
        {
            Caption = 'Spotlight Tour Text';
            DataClassification = OrganizationIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Guided Experience Item Code", "Guided Experience Item Version", "Spotlight Tour Step")
        {

        }
    }
}