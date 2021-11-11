// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9026 "User Login Times - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "User Login Time Tracker Impl." = X,
                  Codeunit "User Login Time Tracker" = X,
                  Table "User Login" = X;
}
