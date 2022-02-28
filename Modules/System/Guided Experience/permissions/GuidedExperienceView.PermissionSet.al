// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1992 "Guided Experience - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Read",
                             "Upgrade Tags - View";

    Permissions = tabledata AllObj = r,
#if not CLEAN18
#pragma warning disable AL0432
                  tabledata "Assisted Setup Log" = imd,
                  tabledata "Business Setup Icon" = imd,
#pragma warning restore
#endif
                  tabledata "Checklist Item" = imd,
                  tabledata "Checklist Item Role" = imd, // the modify permissions are necessary for the Checklist Item Roles page to work correctly
                  tabledata "Checklist Item User" = imd,
                  tabledata "Checklist Setup" = im,
                  tabledata "Guided Experience Item" = imd,
                  tabledata "User Checklist Status" = im,
                  tabledata "Spotlight Tour Text" = imd;
}
