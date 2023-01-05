// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8720 "Date & Time - Objects"
{
    Caption = 'Date & Time - Objects';
    Assignable = false;
    Access = Internal;

    Permissions = codeunit "Time Zone" = X,
        codeunit "Time Zone Impl." = X,
        codeunit "Time Zone Info Initializer" = X;
}