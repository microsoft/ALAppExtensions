// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds information about containers in a storage account.
/// </summary>
table 9044 "ABS Container"
{
    Access = Public;
    Extensible = false;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(11; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Modified';
        }
        field(12; "Lease Status"; Text[15])
        {
            DataClassification = SystemMetadata;
            Caption = 'Lease Status';
            Access = Internal;
        }
        field(13; "Lease State"; Text[15])
        {
            DataClassification = SystemMetadata;
            Caption = 'Lease State';
            Access = Internal;
        }
        field(14; "Default Encryption Scope"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Default Encryption Scope';
            Access = Internal;
        }
        field(15; "Deny Encryption Scope Override"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Deny Encryption Scope Override';
        }
        field(16; "Has Immutability Policy"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Has Immutability Policy';
        }
        field(17; "Has Legal Hold"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Has Legal Hold';
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
        key(PK; "Name")
        {
            Clustered = true;
        }
    }
}