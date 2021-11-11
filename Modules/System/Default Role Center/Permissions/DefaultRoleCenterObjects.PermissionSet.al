// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8999 "Default Role Center - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Default Role Center Impl." = X,
                  Codeunit "Default Role Center" = X,
                  Page "Blank Role Center" = X;
}
