// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.History;

query 3303 "PA Posted Purch. Inv. Users"
{
    Access = Internal;
    QueryType = Normal;
    InherentEntitlements = X;
    InherentPermissions = X;

    elements
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            filter(SystemCreatedAt; SystemCreatedAt)
            {
            }
            column(SystemCreatedBy; SystemCreatedBy)
            {
            }
            column(NumberOfInvoices)
            {
                Method = Count;
            }
        }
    }
}
