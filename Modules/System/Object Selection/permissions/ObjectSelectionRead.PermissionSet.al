// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Reflection;

using System.Environment.Configuration;
using System.Apps;

permissionset 358 "Object Selection - Read"
{
    Assignable = false;

    Permissions = tabledata "Page Data Personalization" = R, // Page.Run requires this
                  tabledata "Published Application" = r,
                  tabledata AllObjWithCaption = r;
}
