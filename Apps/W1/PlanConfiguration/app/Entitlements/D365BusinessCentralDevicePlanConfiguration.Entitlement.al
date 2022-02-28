// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

entitlement "D365 Business Central Device - Plan Configuration"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'D365 Business Central Device Users';
    Id = '100e1865-35d4-4463-aaff-d38eee3a1116';

    ObjectEntitlements = "Plan Configuration - Edit";
}
