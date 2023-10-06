// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Globalization;
using System.Reflection;

permissionset 1992 "Guided Experience - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Read",
                             "Translation - Edit";

    Permissions = tabledata AllObj = r,
                  tabledata "Checklist Item" = imd,
                  tabledata "Checklist Item Role" = imd, // the modify permissions are necessary for the Checklist Item Roles page to work correctly
                  tabledata "Checklist Item User" = imd,
                  tabledata "Checklist Setup" = im,
                  tabledata "Guided Experience Item" = imd,
                  tabledata "Primary Guided Experience Item" = imd,
                  tabledata "User Checklist Status" = im,
                  tabledata "Spotlight Tour Text" = imd;
}
