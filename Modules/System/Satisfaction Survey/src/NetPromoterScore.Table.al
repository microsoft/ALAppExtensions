// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1433 "Net Promoter Score"
{
    Access = Internal;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; "User SID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(4; "Last Request Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Send Request"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "User SID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

