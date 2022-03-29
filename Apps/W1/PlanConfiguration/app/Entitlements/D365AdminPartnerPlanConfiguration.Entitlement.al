// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

entitlement "D365 Admin - Partner - Plan Configuration"
{
    Type = Role;
    RoleType = Delegated;
    Id = '00000000-0000-0000-0000-000000000009';

    ObjectEntitlements = "Plan Configuration - Edit";
}
