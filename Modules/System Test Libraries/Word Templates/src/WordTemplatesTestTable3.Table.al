// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 130445 "Word Templates Test Table 3"
{
    DataClassification = SystemMetadata;
    Caption = 'Word Templates Test Table 3';

    fields
    {
        field(1; "Id"; Guid)
        {
        }
        field(2; "Value"; Text[100])
        {
            Caption = 'Value';
        }
        field(3; "Value 2"; Text[100])
        {
            Caption = 'Value';
        }
        field(4; "Value 3"; Text[100])
        {
            Caption = 'Value';
        }
        field(5; "Value 4"; Text[100])
        {
            Caption = 'Test Value';
        }
    }

    keys
    {
        key(PK; "Id")
        {
            Clustered = true;
        }
    }
}