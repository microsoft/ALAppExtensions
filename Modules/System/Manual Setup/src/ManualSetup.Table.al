// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 3700 "Manual Setup"
{
    Access = Internal;
    Caption = 'Manual Setup';
    DataPerCompany = false;

    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(2; "App ID"; Guid)
        {
            Caption = 'App ID';
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(4; Keywords; Text[250])
        {
            Caption = 'Keywords';
        }
        field(5; "Setup Page ID"; Integer)
        {
            Caption = 'Setup Page ID';
        }
        field(6; Icon; Media)
        {
            Caption = 'Icon';
        }
        field(7; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Published Application".Name where(ID = FIELD("App ID")));
            Editable = false;
        }
        field(8; Category; Enum "Manual Setup Category")
        {
            Caption = 'Category';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Description, Name, Icon, Category)
        {
        }
    }
}

