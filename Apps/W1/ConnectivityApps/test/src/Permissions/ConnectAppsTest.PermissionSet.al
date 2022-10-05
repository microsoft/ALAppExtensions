// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 139528 "Connect. Apps Test"
{
    Assignable = true;
    Caption = 'Connectivity Apps Test', MaxLength = 30;
    Permissions =
        codeunit "Connect. Apps Checklist Tests" = X,
        codeunit "Connect. Apps Visibility Tests" = X,
        codeunit "Connectivity App Defn. Tests" = X,
        codeunit "Connectivity Apps Tests" = X;
}
