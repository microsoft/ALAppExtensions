// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Integration;

permissionset 97 "Webhook - Edit"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Webhook - Read";

    Permissions = tabledata "API Webhook Notification" = IMD,
                  tabledata "API Webhook Notification Aggr" = IMD,
                  tabledata "API Webhook Subscription" = IMD,
                  tabledata "Webhook Notification" = IMD,
                  tabledata "Webhook Subscription" = imd;
}
