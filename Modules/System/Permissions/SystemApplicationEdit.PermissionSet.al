// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 22 "System Application - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "System Application - View",
                             "Cues and KPIs - Edit",
                             "Data Classification - Edit",
                             "Email - Edit",
                             "Guided Experience - Edit",
                             "Language - Edit",
#if not CLEAN19
                             "SL Designer Subscribers - Edit",
#endif
                             "Translation - Edit",
                             "Word Templates - Edit";
}
