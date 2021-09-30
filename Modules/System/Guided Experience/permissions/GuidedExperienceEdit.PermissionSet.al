// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1993 "Guided Experience - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - View",
                             "Translation - Edit";

    Permissions = tabledata "Checklist Item" = IMD,
                  tabledata "Checklist Item Role" = IMD, // the modify permissions are necessary for the Checklist Item Roles page to work correctly
                  tabledata "Checklist Item User" = IMD,
                  tabledata "Checklist Setup" = IMd,
                  tabledata "Spotlight Tour Text" = imd;
}
