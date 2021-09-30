// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// This permission set should always be internal
permissionset 2147 "D365 Automation APIV2"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  query * = X,
                  page "APIV2 - Aut. Companies" = X,
                  page "APIV2 - Aut. Config. Packages" = X,
                  page "APIV2 - Aut. Extension Depl." = X,
                  page "APIV2 - Aut. Extension Upload" = X,
                  page "APIV2 - Aut. Extensions" = X,
                  page "APIV2 - Aut. Permission Sets" = X,
                  page "APIV2 - Aut. Profiles" = X,
                  page "APIV2 - Aut. Scheduled Jobs" = X,
                  page "APIV2 - Aut. User Gr. Members" = X,
                  page "APIV2 - Aut. User Group Perm." = X,
                  page "APIV2 - Aut. User Groups" = X,
                  page "APIV2 - Aut. User Permissions" = X,
                  page "APIV2 - Aut. Users" = X;
}