// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

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
        }
        field(2; Name; Text[1024])
        {
            Caption = 'Name';
        }
        field(3; Description; Text[2048])
        {
            Caption = 'Description';
        }
        field(4; "Country/Region"; Code[20])
        {
            Caption = 'Country/Region';
            TableRelation = "Country/Region";
        }
        field(5; Category; Enum "Connectivity Apps Category")
        {
            Caption = 'Category';
        }
        field(6; Publisher; Text[250])
        {
            Caption = 'Publisher';
        }
        field(7; "Provider Support URL"; Text[2048])
        {
            Caption = 'Provider Support URL';
            ExtendedDatatype = URL;
        }
        field(8; "AppSource URL"; Text[2048])
        {
            Caption = 'Provider Support URL';
            ExtendedDatatype = URL;
        }
        field(9; Logo; Media)
        {
            Caption = 'Logo';
        }
    }

    keys
    {
        key(Key1; "App Id", "Country/Region")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Publisher, Name, "Country/Region", Description, Logo)
        {
        }
    }
}
