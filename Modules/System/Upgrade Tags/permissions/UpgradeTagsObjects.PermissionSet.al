// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9994 "Upgrade Tags - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Upgrade Tag - Tags" = X,
                  Codeunit "Upgrade Tag Impl." = X,
                  Codeunit "Upgrade Tag Install" = X,
                  Codeunit "Upgrade Tag" = X,
                  Table "Upgrade Tag Backup" = X,
                  Table "Upgrade Tags" = X;
}
