// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 2011 "Entity Text - View"
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = "Entity Text - Objects";

    Permissions = tabledata "Azure OpenAi Settings" = R,
        tabledata "Entity Text" = R;
}