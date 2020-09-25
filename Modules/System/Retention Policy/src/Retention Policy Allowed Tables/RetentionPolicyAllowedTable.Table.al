// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 3903 "Retention Policy Allowed Table"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Default Date Field No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Mandatory Min. Reten. Days"; Integer)
        {
            DataClassification = SystemMetadata;
            MinValue = 0;
            MaxValue = 365000; // ~1000 years
        }
        field(20; "Reten. Pol. Filtering "; enum "Reten. Pol. Filtering")
        {
            DataClassification = SystemMetadata;
        }
        field(30; "Reten. Pol. Deleting"; enum "Reten. Pol. Deleting")
        {
            DataClassification = SystemMetadata;
        }
        field(100; "Table Filters"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Table Id")
        {
            Clustered = true;
        }
    }
}