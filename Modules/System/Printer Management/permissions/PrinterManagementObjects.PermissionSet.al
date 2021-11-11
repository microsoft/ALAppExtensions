// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2617 "Printer Management - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Printer Setup Impl." = X,
                  Codeunit "Printer Setup" = X,
                  Page "Printer Management" = X;
}
