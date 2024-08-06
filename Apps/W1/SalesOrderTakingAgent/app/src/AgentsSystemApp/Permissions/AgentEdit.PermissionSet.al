// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

permissionset 4302 "Agent - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Agent - Read";

    Permissions = tabledata "Agent Task" = IMD,
                  tabledata "Agent Task File" = IMD,
                  tabledata "Agent Task Message" = IMD,
                  tabledata "Agent Task Message Attachment" = IMD,
                  tabledata "Agent Task Step" = IMD,
                  tabledata "Agent Task Timeline Entry" = IMD,
                  tabledata "Agent Task Timeline Entry Step" = IMD;
}