// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Reflection;

/// <summary>
/// Holds information about records to look up.
/// </summary>
table 9555 "Record Selection Buffer"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; "Record System Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Field 1"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Field 2"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Field 3"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Field 4"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Field 5"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(7; "Field 6"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Field 7"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(9; "Field 8"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Field 9"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Field 10"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Record System Id")
        {
            Clustered = true;
        }
    }
}