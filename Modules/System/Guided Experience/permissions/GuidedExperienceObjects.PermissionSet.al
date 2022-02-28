// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1994 "Guided Experience - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Confirm Management - Objects",
                             "Environment Info. - Objects",
                             "Navigation Bar Subs. - Objects";

    Permissions = Codeunit "Assisted Setup Installation" = X,
                  Codeunit "Assisted Setup Upgrade Tag" = X,
                  Codeunit "Assisted Setup Upgrade" = X,
                  Codeunit "Checklist Administration" = X,
                  Codeunit "Checklist Banner" = X,
                  Codeunit "Checklist Implementation" = X,
                  Codeunit "Checklist" = X,
                  Codeunit "Guided Experience Impl." = X,
                  Codeunit "Guided Experience Upgrade Tag" = X,
                  Codeunit "Guided Experience Upgrade" = X,
                  Codeunit "Guided Experience" = X,
                  Page "Assisted Setup" = X,
                  Page "Checklist Administration" = X,
                  Page "Checklist Banner" = X,
                  Page "Checklist Item Roles" = X,
                  Page "Checklist Item Users" = X,
                  Page "Checklist Resurfacing" = X,
                  Page "Guided Experience Item List" = X,
                  Page "Manual Setup" = X,
                  Page Checklist = X,
                  Table "Checklist Item Buffer" = X,
                  Table "Checklist Item Role" = X,
                  Table "Checklist Item User" = X,
                  Table "Checklist Item" = X,
                  Table "Checklist Setup" = X,
                  Table "Guided Experience Item" = X,
                  Table "Spotlight Tour Text" = X,
#if not CLEAN18
#pragma warning disable AL0432
                  Codeunit "Assisted Setup" = X,
                  Codeunit "Manual Setup" = X,
                  Table "Assisted Setup Log" = X,
                  Table "Assisted Setup" = X,
                  Table "Business Setup Icon" = X,
                  Table "Manual Setup" = X,
#pragma warning restore
#endif
                  Table "User Checklist Status" = X;
}
