// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment.Configuration;
using System.Apps;
using System.Email;

entitlement "Azure AD Application Api"
{
    Type = ApplicationScope;
    Id = 'API.ReadWrite.All';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Exten. Mgt. - Admin",
                         "Email - Admin",
                         "Feature Key - Admin";
#pragma warning restore                    
}
