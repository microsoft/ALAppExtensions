// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 2012 "Entity Text - Edit"
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = "Entity Text - View";

    Permissions = tabledata "Azure OpenAi Settings" = IMD,
        tabledata "Entity Text" = IMD;
}