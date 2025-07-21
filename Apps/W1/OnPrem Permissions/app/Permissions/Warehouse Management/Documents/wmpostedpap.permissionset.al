// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 4668 "WM-POSTED PA/P"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read posted put away, etc.';

    IncludedPermissionSets = "Warehouse Documents - Read";
}
