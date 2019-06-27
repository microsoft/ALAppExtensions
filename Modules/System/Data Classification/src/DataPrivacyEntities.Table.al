// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1180 "Data Privacy Entities"
{
    Access = Public; // TODO: Evaluate proper access modifier.
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
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table No."),
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
            CalcFormula = Count (Field WHERE(TableNo = FIELD("Table No."),
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

    var
        SimilarFieldsLbl: Label 'Classify Similar Fields for %1', Comment = '%1=Table Caption';

    [Scope('OnPrem')]
    procedure InsertRow(TableNo: Integer; PageNo: Integer; KeyFieldNo: Integer; EntityFilter: Text; PrivacyBlockedFieldNo: Integer)
    var
        OutStream: OutStream;
    begin
        if Get(TableNo) then
            exit;

        Init();
        Include := true;
        "Table No." := TableNo;
        "Key Field No." := KeyFieldNo;
        "Privacy Blocked Field No." := PrivacyBlockedFieldNo;

        if EntityFilter <> '' then begin
            "Entity Filter".CreateOutStream(OutStream);
            OutStream.WriteText(EntityFilter);
        end;

        "Default Data Sensitivity" := "Default Data Sensitivity"::Personal;
        CalcFields("Table Caption");
        "Similar Fields Label" := StrSubstNo(SimilarFieldsLbl, "Table Caption");
        "Page No." := PageNo;

        Insert();
    end;
}

