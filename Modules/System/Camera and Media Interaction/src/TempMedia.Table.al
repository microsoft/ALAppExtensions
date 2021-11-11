#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 4152 "Temp Media"
{
    Access = Internal;
#pragma warning disable AS0034
    TableType = Temporary;
#pragma warning restore AS0034


    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Media; Media)
        {
            DataClassification = SystemMetadata;
        }

        field(3; MediaSet; MediaSet)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}

#endif