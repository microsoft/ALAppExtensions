// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7567 "Geolocation - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Geolocation Impl." = X,
                  Codeunit Geolocation = X,
                  Page Geolocation = X;
}
