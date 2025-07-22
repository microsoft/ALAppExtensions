// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Shpfy - Admin Permissions (ID 30103).
/// </summary>
permissionset 30103 "Shpfy - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Shopify - Admin', MaxLength = 30;

    IncludedPermissionSets = "Shpfy - Edit";

    Permissions =
        tabledata "Shpfy Registered Store New" = IMD;
}