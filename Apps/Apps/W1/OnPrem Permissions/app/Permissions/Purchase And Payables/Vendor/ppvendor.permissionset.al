// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 5601 "P&P-VENDOR"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read vendors and entries';

    IncludedPermissionSets = "Vendor - View";
}
