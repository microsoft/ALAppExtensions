// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration.Word;

table 130444 "Word Templates Test Table 2"
{
    DataClassification = SystemMetadata;
    Caption = 'Word Templates Test Table 2';
    ReplicateData = false;

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
#pragma warning disable AL0468
        field(8; "Word Templates Test Table 2 Field"; Text[100]) // Field name and caption exceeeds 30 characters for test purpose
#pragma warning restore AL0468
        {
            Caption = 'Word Templates Test Table 2 Field';
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