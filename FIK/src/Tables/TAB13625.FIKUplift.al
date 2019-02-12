// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 13625 FIKUplift
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; Code; Code[10]) { }
        field(2; IsUpgraded; Boolean) { }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

}