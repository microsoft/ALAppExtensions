// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1434 "Satisfaction Survey - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure Key Vault - Objects",
                             "Client Type Mgt. - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "Satisfaction Survey Impl." = X,
                  Codeunit "Satisfaction Survey Installer" = X,
                  Codeunit "Satisfaction Survey Mgt." = X,
                  Codeunit "Satisfaction Survey Upgr. Tag" = X,
                  Codeunit "Satisfaction Survey Upgrade" = X,
                  Codeunit "Satisfaction Survey Viewer" = X,
                  Page "Satisfaction Survey" = X,
                  Table "Net Promoter Score Setup" = X,
                  Table "Net Promoter Score" = X;
}
