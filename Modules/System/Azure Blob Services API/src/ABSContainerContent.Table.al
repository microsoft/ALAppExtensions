// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about container content in a storage account.
/// </summary>
table 9043 "ABS Container Content"
{
    Access = Public;
    Extensible = false;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            Access = Internal;
        }
        field(2; "Parent Directory"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent Directory';
        }
        field(3; Level; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Level';
        }
        field(4; "Full Name"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Full Name';
        }
        field(10; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(11; "Creation Time"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Creation Time';
        }
        field(12; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Modified';
        }
        field(13; "Content Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Length';
        }
        field(14; "Content Type"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Type';
        }
        field(15; "Blob Type"; Text[15])
        {
            DataClassification = SystemMetadata;
            Caption = 'Blob Type';
            Access = Internal;
        }
        field(100; "XML Value"; Blob)
        {
            DataClassification = SystemMetadata;
            Caption = 'XML Value';
        }
        field(110; URI; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'URI';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}