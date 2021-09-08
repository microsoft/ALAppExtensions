// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds the mapping between email account and scenarios.
/// One scenarios is mapped to one email account.
/// One email account can be used for multiple scenarios.
/// </summary>
table 8906 "Email Scenario"
{
    Access = Internal;

    fields
    {
        field(1; Scenario; Enum "Email Scenario")
        {
            DataClassification = SystemMetadata;
        }

        field(2; Connector; Enum "Email Connector")
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