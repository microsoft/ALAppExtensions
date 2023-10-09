// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Feedback;

using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;

permissionset 1432 "Satisfaction Survey - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Add-in" = r,
                  tabledata "User Personalization" = r,
                  tabledata "Net Promoter Score" = r,
                  tabledata "Net Promoter Score Setup" = r,
                  tabledata "User Property" = r;
}
