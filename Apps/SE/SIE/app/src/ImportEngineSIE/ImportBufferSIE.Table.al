// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 5314 "Import Buffer SIE"
{
    Caption = 'SIE Import Buffer';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Import Field 1"; Text[100])
        {
            Caption = 'Import Field 1';
            DataClassification = SystemMetadata;
        }
        field(3; "Import Field 2"; Text[100])
        {
            Caption = 'Import Field 2';
            DataClassification = SystemMetadata;
        }
        field(4; "Import Field 3"; Text[100])
        {
            Caption = 'Import Field 3';
            DataClassification = SystemMetadata;
        }
        field(5; "Import Field 4"; Text[100])
        {
            Caption = 'Import Field 4';
            DataClassification = SystemMetadata;
        }
        field(6; "Import Field 5"; Text[100])
        {
            Caption = 'Import Field 5';
            DataClassification = SystemMetadata;
        }
        field(7; "Import Field 6"; Text[100])
        {
            Caption = 'Import Field 6';
            DataClassification = SystemMetadata;
        }
        field(8; "Import Field 7"; Text[100])
        {
            Caption = 'Import Field 7';
            DataClassification = SystemMetadata;
        }
        field(9; "Import Field 8"; Text[100])
        {
            Caption = 'Import Field 8';
            DataClassification = SystemMetadata;
        }
        field(10; "Import Field 9"; Text[100])
        {
            Caption = 'Import Field 9';
            DataClassification = SystemMetadata;
        }
        field(11; "Import Field 10"; Text[100])
        {
            Caption = 'Import Field 10';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}

