// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
table 149000 "BCPT Header"
{
    DataClassification = SystemMetadata;
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Duration (minutes)"; integer)
        {
            Caption = 'Duration (minutes)';
            InitValue = 1;
            MinValue = 1;
            MaxValue = 240; // 4 hrs
        }
        field(4; Status; Enum "BCPT Header Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(5; "Started at"; DateTime)
        {
            Caption = 'Started at';
            Editable = false;
        }
        field(6; "Default Min. User Delay (ms)"; Integer)
        {
            Caption = 'Default Min. User Delay (ms)';
            InitValue = 100;
            MinValue = 100;
            MaxValue = 10000;
        }
        field(7; "Default Max. User Delay (ms)"; Integer)
        {
            Caption = 'Default Max. User Delay (ms)';
            InitValue = 1000;
            MinValue = 100;
            MaxValue = 30000;
            trigger OnValidate()
            begin
                If "Default Max. User Delay (ms)" < "Default Min. User Delay (ms)" then
                    "Default Max. User Delay (ms)" := "Default Min. User Delay (ms)";
            end;
        }
        field(8; "Work date starts at"; Date)
        {
            Caption = 'Work date starts at';
        }
        field(9; "1 Day Corresponds to (minutes)"; integer)
        {
            Caption = '1 Work Day Corresponds to (minutes)';
            InitValue = 10;
            MinValue = 1;
            MaxValue = 1440;
        }
        field(10; "No. of tests running"; Integer)
        {
            Caption = 'No. of tests running';
            trigger OnValidate()
            var
                BCPTLine: Record "BCPT Line";
                BCPTHeaderCU: Codeunit "BCPT Header";
            begin
                if "No. of tests running" < 0 then
                    "No. of tests running" := 0;

                if "No. of tests running" <> 0 then
                    exit;

                case Status of
                    Status::Running:
                        begin
                            BCPTLine.SetRange("BCPT Code", "Code");
                            BCPTLine.SetRange(Status, BCPTLine.Status::" ");
                            if not BCPTLine.IsEmpty then
                                exit;
                            BCPTHeaderCU.SetRunStatus(Rec, Rec.Status::Completed);
                            BCPTLine.SetRange("BCPT Code", "Code");
                            BCPTLine.SetRange(Status);
                            BCPTLine.ModifyAll(Status, BCPTLine.Status::Completed);
                        end;
                    Status::Cancelled:
                        begin
                            BCPTLine.SetRange("BCPT Code", "Code");
                            BCPTLine.ModifyAll(Status, BCPTLine.Status::Cancelled);
                        end;
                end;
            end;
        }
        field(11; Tag; Text[20])
        {
            Caption = 'Tag';
            DataClassification = CustomerContent;
        }
        field(13; Version; Integer)
        {
            Caption = 'Version';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(16; "Base Version"; Integer)
        {
            Caption = 'Base Version';
            DataClassification = CustomerContent;
            MinValue = 0;
            trigger OnValidate()
            begin
                if "Base Version" > Version then
                    Error(BaseVersionMustBeLessThanVersionErr)
            end;
        }

        field(17; "Total No. of Sessions"; Integer)
        {
            Caption = 'Total No. of Sessions';
            FieldClass = FlowField;
            CalcFormula = sum("BCPT Line"."No. of Sessions" where("BCPT Code" = field("Code")));
        }
        field(15; CurrentRunType; Enum "BCPT Run Type")
        {
            Caption = 'Current Run Type';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    var
        BaseVersionMustBeLessThanVersionErr: Label 'Base Version must be less than or equal to Version';
}