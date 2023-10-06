// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

using System.Reflection;

permissionset 9986 "Word Templates - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Word Templates - Objects",
                             "Object Selection - Read";

    Permissions = tabledata "Word Template" = R,
                  tabledata "Word Template Field" = r,
                  tabledata "Word Templates Table" = r,
                  tabledata "Word Templates Related Table" = r,
                  tabledata AllObjWithCaption = r,
                  tabledata AllObj = r,
                  tabledata Field = r;
}