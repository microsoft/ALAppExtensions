// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 863 "P&P-Q/O/I/R/C, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post purchase orders, etc.';

    IncludedPermissionSets = "Payables Documents - Post";
}
