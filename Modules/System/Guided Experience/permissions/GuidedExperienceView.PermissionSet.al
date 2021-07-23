// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1992 "Guided Experience - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Read",
                             "Upgrade Tags - View",
                             "Translation - Edit";

    Permissions = tabledata AllObj = r,
#if not CLEAN16
                  tabledata "Aggregated Assisted Setup" = imd,
                  tabledata "Assisted Setup" = imd,
#endif
#if not CLEAN18
                  tabledata "Assisted Setup Log" = imd,
                  tabledata "Business Setup Icon" = imd,
                  tabledata "Product Video Category" = imd,
#endif
                  tabledata "Checklist Item" = IMD,
                  tabledata "Checklist Item Role" = IMD, // the modify permissions are necessary for the Checklist Item Roles page to work correctly
                  tabledata "Checklist Item User" = IMD,
                  tabledata "Checklist Setup" = IM,
                  tabledata "Guided Experience Item" = imd,
                  tabledata "User Checklist Status" = im;
}
