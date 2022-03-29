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
                  Codeunit "Default Permission Set In Plan" = X,
                  Codeunit "Plan Ids" = X,
                  Codeunit "Plan Installer" = X,
                  Codeunit "Plan Upgrade Tag" = X,
                  Codeunit "Plan Upgrade" = X,
                  Codeunit "Plan Configuration" = X,
                  Codeunit "Plan Configuration Impl." = X,
                  Page "Custom Permission Set In Plan" = X,
                  Page "Default Permission Set In Plan" = X,
                  Page Plans = X,
                  Page "Plan Configuration Card" = X,
                  Page "Plan Configuration List" = X,
                  Page "Plan Configurations Part" = X,
                  Page "Plans FactBox" = X,
                  Page "User Plan Members FactBox" = X,
                  Page "User Plan Members" = X,
                  Page "User Plans FactBox" = X,
                  Query Plan = X,
                  Query "Users in Plans" = X,
                  Table "Custom Permission Set In Plan" = X,
                  Table "Default Permission Set In Plan" = X,
                  Table Plan = X,
                  Table "Plan Configuration" = X,
                  Table "User Plan" = X;
}
