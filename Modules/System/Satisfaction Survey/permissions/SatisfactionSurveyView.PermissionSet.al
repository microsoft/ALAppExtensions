// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Feedback;

using System.Reflection;

permissionset 1433 "Satisfaction Survey - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Satisfaction Survey - Read";

    Permissions = tabledata "Add-in" = i,
                  tabledata "Net Promoter Score" = imd,
                  tabledata "Net Promoter Score Setup" = imd;
}
