// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
table 4690 "Recurrence Schedule"
{
    Access = Internal;

    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Pattern; Enum "Recurrence - Pattern")
        {
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                RecurrencePattern: Enum "Recurrence - Pattern";
                RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
            begin
                "Recurs Every" := 1;

                if (Pattern = RecurrencePattern::Monthly) or (Pattern = RecurrencePattern::Yearly) then
                    VALIDATE("Monthly Pattern", RecurrenceMonthlyPattern::"Specific Day");
            end;
        }
        field(3; "Recurs Every"; Integer)
        {
            DataClassification = SystemMetadata;
            InitValue = 1;
            MinValue = 1;
        }
        field(4; "Monthly Pattern"; Enum "Recurrence - Monthly Pattern")
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Recurs on Day"; Integer)
        {
            DataClassification = SystemMetadata;
            InitValue = 1;
            MaxValue = 31;
            MinValue = 1;
        }
        field(6; "Ordinal Recurrence No."; Enum "Recurrence - Ordinal No.")
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Start Time"; Time)
        {
            DataClassification = SystemMetadata;
        }
        field(9; "Recurs on Monday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Recurs on Tuesday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Recurs on Wednesday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Recurs on Thursday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "Recurs on Friday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(14; "Recurs on Saturday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(15; "Recurs on Sunday"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(16; Weekday; Enum "Recurrence - Day of Week")
        {
            DataClassification = SystemMetadata;
        }
        field(17; Month; Enum "Recurrence - Month")
        {
            DataClassification = SystemMetadata;
        }
        field(21; "Start Date"; Date)
        {
            DataClassification = SystemMetadata;
        }
        field(22; "End Date"; Date)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        IF ISNULLGUID(ID) THEN
            ID := CREATEGUID();
    end;
}

