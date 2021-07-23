// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2530 "S&R-Q/O/I/R/C, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post sales orders, etc.';

    IncludedPermissionSets = "Recievables Documents - Post";
}
