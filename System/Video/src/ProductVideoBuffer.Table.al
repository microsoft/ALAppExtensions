// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1470 "Product Video Buffer"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Product Video Buffer';
    ReplicateData = false;
    //TableType = Temporary; // need to fix AS0034 and AS0039 first

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; Title; Text[250])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Video Url"; Text[2048])
        {
            Caption = 'Video Url';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Assisted Setup ID"; Integer)
        {
            Caption = 'Assisted Setup ID';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'All assisted setups shall be shown';
            ObsoleteTag = '18.0';
        }
        field(5; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'Product videos are no more grouped.';
            ObsoleteTag = '18.0';
        }
        field(6; "Table Num"; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "System ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("Published Application".Name where(ID = FIELD("App ID"), "Tenant Visible" = CONST(true)));
            Editable = false;
        }
        field(10; Category; Enum "Video Category")
        {
            Caption = 'Category';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }
}

