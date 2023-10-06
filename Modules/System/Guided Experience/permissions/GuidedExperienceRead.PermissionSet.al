// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Globalization;
using System.Reflection;
using System.Environment;
using System.Security.AccessControl;
using System.Apps;

permissionset 1991 "Guided Experience - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Objects",
                             "Translation - Read";

    Permissions = tabledata "All Profile" = r,
                  tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
                  tabledata "Checklist Item" = R,
                  tabledata "Checklist Item Buffer" = r, // needed for Checklist page to be searchable
                  tabledata "Checklist Item Role" = R,
                  tabledata "Checklist Item User" = R,
                  tabledata "Checklist Setup" = R,
                  tabledata Company = r,
                  tabledata "Guided Experience Item" = R,
                  tabledata "Primary Guided Experience Item" = r,
                  tabledata User = r,
                  tabledata "User Checklist Status" = R,
                  tabledata "User Personalization" = r,
                  tabledata "Media" = R,
                  tabledata "Published Application" = R,
                  tabledata "Spotlight Tour Text" = r;
}
