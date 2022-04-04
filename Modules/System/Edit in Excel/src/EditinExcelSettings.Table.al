// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains settings for Edit in Excel.
/// </summary>
table 1480 "Edit in Excel Settings"
{
    DataClassification = SystemMetadata;
    Extensible = false;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; Id; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Use Centralized deployments"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Primary; Id)
        {
            Clustered = true;
        }
    }
}