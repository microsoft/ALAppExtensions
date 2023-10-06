// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

/// <summary>
/// Holds information about custom fields
/// </summary>
table 9981 "Word Template Custom Field"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Related Table Code"; Code[5])
        {
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[25]) // We have a limit of 40 characters for mail merge. With custom fields we prepend 11 characters, hence with rounding we set this to 25.
        {
            DataClassification = CustomerContent;
        }
        field(3; Value; Text[2048])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PrimaryKey; "Related Table Code", Name)
        {
            Clustered = true;
        }
    }

}