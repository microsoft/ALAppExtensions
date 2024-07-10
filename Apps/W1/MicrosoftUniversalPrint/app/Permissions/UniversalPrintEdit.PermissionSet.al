// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device.UniversalPrint;

permissionset 2757 "UniversalPrint - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'MicrosoftUniversalPrint - Edit';

    IncludedPermissionSets = "UniversalPrint - Read";

    Permissions = tabledata "Universal Printer Settings" = IMD,
                    tabledata "Universal Print Share Buffer" = IMD;
}
