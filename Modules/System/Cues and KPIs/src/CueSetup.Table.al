// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9701 "Cue Setup"
{
    Access = Internal;
    Caption = 'Cue Setup';
    Permissions = tabledata Field = r;

    fields
    {
        field(1; "User Name"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User Name';
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User Name");
            end;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table),
                                                                 "Object Name" = FILTER('*Cue*'));
            trigger OnValidate()
            begin
                // Force a calculation, even if the FieldNo hasn't yet been filled out (i.e. the record hasn't been inserted yet)
                CalcFields("Table Name")
            end;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Cue ID';
            TableRelation = Field."No.";

            trigger OnLookup()
            var
                Field: Record "Field";
                FieldSelection: Codeunit "Field Selection";
            begin
                // Look up in the Fields virtual table
                // Filter on Table No=Table No and Type=Decimal|Integer. This should give us approximately the
                // fields that are "valid" for a cue control.
                Field.SetRange(TableNo, "Table ID");
                Field.SetFilter(Type, '%1|%2', Field.Type::Decimal, Field.Type::Integer);
                if FieldSelection.Open(Field) Then
                    Validate("Field No.", Field."No.");
            end;
        }
        field(4; "Field Name"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table ID"),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Cue Name';
            FieldClass = FlowField;
            Editable = false;
        }
        field(5; "Low Range Style"; Enum "Cues And KPIs Style")
        {
            Caption = 'Low Range Style', Comment = 'The Style to use if the cue''s value is below Threshold 1';
        }
        field(6; "Threshold 1"; Decimal)
        {

            trigger OnValidate()
            var
                CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
            begin
                CuesAndKPIsImpl.ValidateThresholds(Rec);
            end;
        }
        field(7; "Middle Range Style"; Enum "Cues And KPIs Style")
        {
            Caption = 'Middle Range Style', Comment = 'The Style to use if the cue''s value is between Threshold 1 and Threshold 2';
        }
        field(8; "Threshold 2"; Decimal)
        {

            trigger OnValidate()
            var
                CuesAndKPIsImpl: Codeunit "Cues And KPIs Impl.";
            begin
                CuesAndKPIsImpl.ValidateThresholds(Rec);
            end;
        }
        field(9; "High Range Style"; Enum "Cues And KPIs Style")
        {
            Caption = 'High Range Style', Comment = 'The Style to use if the cue''s value is above Threshold 2';
        }
        field(10; "Table Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object ID" = FIELD("Table ID"),
                                                                           "Object Type" = CONST(Table)));
            FieldClass = FlowField;
            Editable = false;
        }
        field(11; Personalized; Boolean)
        {
            Caption = 'Personalized';
        }
    }

    keys
    {
        key(Key1; "User Name", "Table ID", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Table Name", "Field Name", "Threshold 1", Personalized, "Threshold 2")
        {
        }
    }
}
