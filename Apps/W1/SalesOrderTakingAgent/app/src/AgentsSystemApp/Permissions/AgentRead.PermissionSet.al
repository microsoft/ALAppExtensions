// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

permissionset 4301 "Agent - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Agent - Objects";

    Permissions = tabledata Agent = R,
                  tabledata "Agent Access Control" = R,
                  tabledata "Agent Task" = R,
                  tabledata "Agent Task File" = R,
                  tabledata "Agent Task Message Attachment" = R,
                  tabledata "Agent Task Message" = R,
                  tabledata "Agent Task Step" = R,
                  tabledata "Agent Task Timeline Entry" = R,
                  tabledata "Agent Task Timeline Entry Step" = R;
}