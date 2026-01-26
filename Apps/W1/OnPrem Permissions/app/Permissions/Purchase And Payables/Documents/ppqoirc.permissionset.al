// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7947 "P&P-Q/O/I/R/C"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create purchase orders, etc.';

    IncludedPermissionSets = "Payables Documents - Edit";
}
