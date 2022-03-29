// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1432 "Net Promoter Score Setup"
{
    Access = Internal;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "API URL"; BLOB)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Expire Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Time Between Requests"; Integer)
        {
            ObsoleteReason = 'This field is not needed and it is not used anymore.';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(5; "Request Timeout"; Integer)
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

    fieldgroups
    {
    }
}

