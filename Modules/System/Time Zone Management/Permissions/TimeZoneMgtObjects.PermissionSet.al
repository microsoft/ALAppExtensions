// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8720 TimeZoneMgtObjects
{
    Caption = 'Time Zone Management - Objects';
    Assignable = false;
    Permissions = codeunit "DateTime Offset" = X,
        codeunit "DateTime Offset Impl." = X,
        codeunit "Daylight Saving Time Info" = X,
        codeunit "Daylight Saving Time Info Impl" = X,
        codeunit "Time Zone Info Initializer" = X;
}