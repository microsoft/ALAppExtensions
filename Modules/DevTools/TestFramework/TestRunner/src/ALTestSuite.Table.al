// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 130451 "AL Test Suite"
{
    DataCaptionFields = Name, Description;
    LookupPageID = "AL Test Suites";
    ReplicateData = false;
    Permissions = TableData "AL Test Suite" = rimd, TableData "Test Method Line" = rimd;

    fields
    {
        field(1; Name; Code[10])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Tests to Execute"; Integer)
        {
            CalcFormula = Count("Test Method Line" WHERE("Test Suite" = FIELD(Name),
                                                          "Line Type" = CONST(Function),
                                                          Run = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Tests not Executed"; Integer)
        {
            CalcFormula = Count("Test Method Line" WHERE("Test Suite" = FIELD(Name),
                                                          "Line Type" = CONST(Function),
                                                          Run = CONST(true),
                                                          Result = CONST(" ")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; Failures; Integer)
        {
            CalcFormula = Count("Test Method Line" WHERE("Test Suite" = FIELD(Name),
                                                          "Line Type" = CONST(Function),
                                                          Run = CONST(true),
                                                          Result = CONST(Failure)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Last Run"; DateTime)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Run Type"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = " ",All,"Active Codeunit","Active Test";
        }
        field(8; "Test Runner Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(9; "Stability Run"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "CC Tracking Type"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = "Disabled","Per Run","Per Codeunit","Per Test";
        }
        field(11; "CC Track All Sessions"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "CC Exporter ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "CC Coverage Map"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = "Disabled","Per Codeunit","Per Test";
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
    }

    trigger OnDelete()
    var
        TestMethodLine: Record "Test Method Line";
    begin
        TestMethodLine.SetRange("Test Suite", Name);
        TestMethodLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        TestRunnerMgt: Codeunit "Test Runner - Mgt";
    begin
        if "Test Runner Id" = 0 then
            "Test Runner Id" := TestRunnerMgt.GetDefaultTestRunner();
    end;
}

