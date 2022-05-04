// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9008 "User Login"
{
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "User SID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(2; "First Login Date"; Date)
        {
        }
        field(3; "Penultimate Login Date"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Last Login Date"; DateTime)
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
        key(Key2; "Last Login Date")
        {
        }
    }

    fieldgroups
    {
    }
}

