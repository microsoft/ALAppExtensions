// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

table 4594 "SOA Task"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; "ID"; BigInteger)
        {
            AutoIncrement = true;
        }
        field(2; Status; Option)
        {
            OptionMembers = "In Progress","Succeeded";
        }
        field(3; "Access Token Retrieved"; Boolean)
        {
        }
        field(4; "Send Replies Successful"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "ID")
        {
            Clustered = true;
        }
    }
}