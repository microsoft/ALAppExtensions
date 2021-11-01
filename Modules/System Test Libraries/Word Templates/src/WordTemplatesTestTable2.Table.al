// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 130444 "Word Templates Test Table 2"
{
    DataClassification = SystemMetadata;
    Caption = 'Word Templates Test Table 2';

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Value"; Text[100])
        {
            Caption = 'Value';
        }
        field(3; "Child Id"; Guid)
        {
        }
        field(4; "Child Code"; Code[30])
        {
        }
        field(5; "Value 2"; Text[100])
        {
            Caption = 'Test Value';
        }
        field(6; "Value 3"; Text[100])
        {
            Caption = 'Test Value';
        }
        field(7; "Value 4"; Text[100])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}