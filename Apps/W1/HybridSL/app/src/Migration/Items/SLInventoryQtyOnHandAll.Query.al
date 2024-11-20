// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

query 47000 "SL Inventory QtyOnHand All"
{
    QueryType = Normal;

    elements
    {
        dataitem(SL_ItemSite; "SL ItemSite")
        {
            column(InvtID; InvtID)
            {
            }
            column(QtyOnHand; QtyOnHand)
            {
                Method = Sum;
            }
            filter(CpnyID; CpnyID)
            {
            }
        }
    }
}
