// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9198 "Time Zone Selection - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Time Zone Selection Impl." = X,
                  Codeunit "Time Zone Selection" = X,
                  Page "Time Zones Lookup" = X;
}
