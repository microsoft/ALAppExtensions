// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9807 "Field Selection - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Field Selection Impl." = X,
                  Codeunit "Field Selection" = X,
                  Page "Fields Lookup" = X;
}
