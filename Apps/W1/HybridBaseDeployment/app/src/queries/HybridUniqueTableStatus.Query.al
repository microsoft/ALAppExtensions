// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

query 4002 "Hybrid Unique Table Status"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; "Hybrid Replication Detail")
        {
            column(Company_Name; "Company Name")
            {
            }
            column(Table_Name; "Table Name")
            {
            }
            column(Status; Status)
            {
            }
            column(ReplicationCount)
            {
                Method = Count;
            }
        }
    }
}