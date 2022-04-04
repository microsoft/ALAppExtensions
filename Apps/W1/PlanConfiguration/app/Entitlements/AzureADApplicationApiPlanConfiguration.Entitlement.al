// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

entitlement "Azure AD Application Api - Plan Configuration"
{
    Type = ApplicationScope;
    Id = 'API.ReadWrite.All';

    ObjectEntitlements = "Plan Configuration - Read";
}
