// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1750 "Fields Sync Status"
{
    Access = Internal;

    fields
    {
        field(1; ID; Code[2])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Last Sync Date Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

