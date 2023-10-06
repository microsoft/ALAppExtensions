// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

/// <summary>
/// Holds information about containers in a storage account.
/// </summary>
table 9044 "ABS Container"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name', Locked = true;
        }
        field(11; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last-Modified', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
        }
        field(12; "Lease Status"; Text[15])
        {
            DataClassification = SystemMetadata;
            Caption = 'LeaseStatus', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
            Access = Internal;
        }
        field(13; "Lease State"; Text[15])
        {
            DataClassification = SystemMetadata;
            Caption = 'LeaseState', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
            Access = Internal;
        }
        field(14; "Default Encryption Scope"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'DefaultEncryptionScope', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
            Access = Internal;
        }
        field(15; "Deny Encryption Scope Override"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'DenyEncryptionScopeOverride', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
        }
        field(16; "Has Immutability Policy"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'HasImmutabilityPolicy', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
        }
        field(17; "Has Legal Hold"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'HasLegalHold', Locked = true;
            Description = 'Caption matches the corresponding property as defined in https://go.microsoft.com/fwlink/?linkid=2210590';
        }
        field(100; "XML Value"; Blob)
        {
            DataClassification = SystemMetadata;
            Caption = 'XML Value', Locked = true;
        }
        field(110; URI; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'URI', Locked = true;
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