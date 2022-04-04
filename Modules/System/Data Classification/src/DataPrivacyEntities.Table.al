// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of data privacy entities.
/// </summary>
table 1180 "Data Privacy Entities"
{
    Access = Public;
    Caption = 'Data Subjects';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Table Caption"; Text[80])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            FieldClass = FlowField;
        }
        field(3; "Key Field No."; Integer)
        {
            Caption = 'Key Field No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Key Field Name"; Text[30])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Key Field No.")));
            Caption = 'Key Field Name';
            FieldClass = FlowField;
        }
        field(5; "Entity Filter"; BLOB)
        {
            Caption = 'Entity Filter';
            DataClassification = SystemMetadata;
        }
        field(6; Include; Boolean)
        {
            Caption = 'Include';
        }
        field(7; "Fields"; Integer)
        {
            CalcFormula = Count(Field WHERE(TableNo = FIELD("Table No."),
                                             Enabled = CONST(true),
                                             Class = CONST(Normal)));
            Caption = 'Fields';
            FieldClass = FlowField;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Review Needed,Reviewed';
            OptionMembers = "Review Needed",Reviewed;
        }
        field(9; Reviewed; Boolean)
        {
            Caption = 'Reviewed';
        }
        field(10; "Status 2"; Option)
        {
            Caption = 'Status 2';
            OptionCaption = 'Review Needed,Reviewed';
            OptionMembers = "Review Needed",Reviewed;
        }
        field(11; "Page No."; Integer)
        {
            Caption = 'Page No.';
            DataClassification = SystemMetadata;
        }
        field(12; "Similar Fields Reviewed"; Boolean)
        {
            Caption = 'Similar Fields Reviewed';
        }
        field(13; "Similar Fields Label"; Text[120])
        {
            Caption = 'Similar Fields Label';
        }
        field(14; "Default Data Sensitivity"; Option)
        {
            Caption = 'Default Data Sensitivity';
            OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
            OptionMembers = Unclassified,Sensitive,Personal,"Company Confidential",Normal;
        }
        field(15; "Privacy Blocked Field No."; Integer)
        {
            Caption = 'Privacy Blocked Field No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Table No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

