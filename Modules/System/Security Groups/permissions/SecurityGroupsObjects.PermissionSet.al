// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

permissionset 9031 "Security Groups - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Security Group" = X,
                  xmlport "Export/Import Security Groups" = X,
                  page "Copy Security Group" = X,
                  page "Sec. Group Permissions Part" = X,
                  page "Security Group Members" = X,
                  page "Security Group Members Part" = X,
                  page "Security Group Permission Sets" = X,
                  page "Security Groups" = X,
                  page "New Security Group" = X,
                  page "Security Group Lookup" = X,
                  table "Security Group" = X;
}
