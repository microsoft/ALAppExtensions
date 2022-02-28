// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1991 "Guided Experience - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Objects",
                             "Translation - Read",
                             "Extension Management - Read",
                             "Upgrade Tags - Read",
                             "User Login Times - Read";

    Permissions = tabledata "All Profile" = r,
                  tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
#if not CLEAN18
#pragma warning disable AL0432
                  tabledata "Assisted Setup" = R, // needed for AccessByPermission
                  tabledata "Assisted Setup Log" = r,
                  tabledata "Manual Setup" = R, // big R needed for Manual Setup to be searchable
                  tabledata "Business Setup Icon" = r,
#pragma warning restore
#endif
                  tabledata "Checklist Item" = R,
                  tabledata "Checklist Item Buffer" = r, // needed for Checklist page to be searchable
                  tabledata "Checklist Item Role" = R,
                  tabledata "Checklist Item User" = R,
                  tabledata "Checklist Setup" = R,
                  tabledata Company = r,
                  tabledata "Guided Experience Item" = R,
                  tabledata User = r,
                  tabledata "User Checklist Status" = R,
                  tabledata "User Personalization" = r,
                  tabledata "Spotlight Tour Text" = r;
}
