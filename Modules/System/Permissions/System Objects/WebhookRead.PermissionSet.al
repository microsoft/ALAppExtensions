// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 98 "Webhook - Read"
{
    Access = Internal;
    Assignable = False;

    Permissions = tabledata "API Webhook Notification" = R,
                  tabledata "API Webhook Notification Aggr" = R,
                  tabledata "API Webhook Subscription" = R,
                  tabledata "Webhook Notification" = R,
                  tabledata "Webhook Subscription" = R;
}
