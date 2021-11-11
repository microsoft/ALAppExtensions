// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 774 "Azure AD Plan - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Graph - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "Azure AD Plan Impl." = X,
                  Codeunit "Azure AD Plan" = X,
                  Codeunit "Plan Ids" = X,
                  Codeunit "Plan Installer" = X,
                  Codeunit "Plan Upgrade Tag" = X,
                  Codeunit "Plan Upgrade" = X,
                  Page "Plans FactBox" = X,
                  Page "User Plan Members FactBox" = X,
                  Page "User Plan Members" = X,
                  Page "User Plans FactBox" = X,
                  Page Plans = X,
                  Query "Users in Plans" = X,
                  Query Plan = X,
                  Table "User Plan" = X,
                  Table Plan = X;
}
