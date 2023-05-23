// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9844 "User Selection - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "User Selection" = X,
                  Page "User Lookup" = X;
}
