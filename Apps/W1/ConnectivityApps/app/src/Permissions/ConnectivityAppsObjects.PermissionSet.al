// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 20352 "Connectivity Apps - Objects"
{
    Assignable = false;
    Access = Internal;
    Caption = 'Connectivity Apps - Objects';

    Permissions = codeunit "Connectivity Apps" = X,
                    codeunit "Connectivity App Definitions" = X,
                    codeunit "Connectivity Apps Guided Exp." = X,
                    codeunit "Connectivity Apps Impl." = X,
                    codeunit "Connectivity Apps Logo Mgt." = X,
                    codeunit "Connectivity Apps Logo Refresh" = X,
                    page "Banking App" = X,
                    page "Banking Apps" = X,
                    page "Connectivity App" = X,
                    page "Connectivity Apps" = X,
                    table "Connectivity App" = X,
                    table "Conn. App Country/Region" = X,
                    table "Connectivity App Description" = X,
                    table "Connectivity App Logo" = X;
}
