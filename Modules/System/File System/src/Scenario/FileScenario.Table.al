// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Holds the mapping between file account and scenarios.
/// One scenarios is mapped to one file account.
/// One file account can be used for multiple scenarios.
/// </summary>
table 70004 "File Scenario"
{
    Access = Internal;

    fields
    {
        field(1; Scenario; Enum "File Scenario")
        {
            DataClassification = SystemMetadata;
        }

        field(2; Connector; Enum "File System Connector")
        {
            DataClassification = SystemMetadata;
        }

        field(3; "Account Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Scenario)
        {
            Clustered = true;
        }
    }
}