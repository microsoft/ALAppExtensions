// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 132514 "Record Link Test Cross Company"
{
    ReplicateData = false;
    DataPerCompany = false;
    InherentEntitlements = RIMD;
    InherentPermissions = RIMD;

    fields
    {
        field(1; PK; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; Field; Text[50])
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; PK, Field)
        {
            Clustered = true;
        }
    }
}
