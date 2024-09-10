
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

permissionset 4408 "SOA - Read"
{
    Caption = 'Sales Order Taker Agent - Read';
    Assignable = false;

    Permissions = tabledata "SOA Setup" = R;

}