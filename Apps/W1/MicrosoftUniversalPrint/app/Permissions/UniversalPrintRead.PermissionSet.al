// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device.UniversalPrint;

permissionset 2759 "UniversalPrint - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Microsoft Universal Print - Read';

    IncludedPermissionSets = "UniversalPrint - Objects";

    Permissions = tabledata "Universal Printer Settings" = R,
                    tabledata "Universal Print Share Buffer" = R;
}
