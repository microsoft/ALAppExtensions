// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 20350 "Connectivity App"
{
    Access = Internal;
    TableType = Temporary;
    Caption = 'Connectivity Apps';
    Extensible = false;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "App Id"; Guid)
        {
            Caption = 'App Id';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[1024])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(3; Description; Text[2048])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(4; "Supported Countries"; Text[2048])
        {
            Caption = 'Supported Countries';
            DataClassification = SystemMetadata;
        }
        field(5; Category; Enum "Connectivity Apps Category")
        {
            Caption = 'Category';
            DataClassification = SystemMetadata;
        }
        field(6; Publisher; Text[250])
        {
            Caption = 'Publisher';
            DataClassification = SystemMetadata;
        }
        field(7; "Provider Support URL"; Text[2048])
        {
            Caption = 'Provider Support URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(8; "AppSource URL"; Text[2048])
        {
            Caption = 'Provider Support URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(9; Logo; Media)
        {
            Caption = 'Logo';
            DataClassification = SystemMetadata;
        }
        field(10; Country; Code[20])
        {
            Caption = 'Country';
            DataClassification = SystemMetadata;
            TableRelation = "Country/Region";
        }
    }

    keys
    {
        key(Key1; "App Id", Country)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Publisher, Name, Country, Description, Logo)
        {
        }
    }
}