#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 2889 "SL Designer Subscribers - Edit"
{
    Access = Internal;
    Assignable = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
    ObsoleteTag = '19.0';

    IncludedPermissionSets = "SL Designer Subscribers - Read";

    Permissions = tabledata "SmartList Designer Handler" = IMD;
}
#endif