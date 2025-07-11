// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device.UniversalPrint;

permissionset 2752 "UniversalPrint - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Microsoft Universal Print - Objects';

    Permissions = page "Add Universal Printers Wizard" = X,
                     codeunit "Universal Print Document Ready" = X,
                     page "Universal Printer Settings" = X,
                     table "Universal Printer Settings" = X,
                     codeunit "Universal Printer Setup" = X,
                     page "Universal Printer Tray List" = X,
                     codeunit "Universal Print Graph Helper" = X,
                     table "Universal Print Share Buffer" = X,
                     page "Universal Print Shares List" = X;
}
