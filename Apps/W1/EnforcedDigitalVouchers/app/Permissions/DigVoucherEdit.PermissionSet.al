// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

permissionset 5584 "Dig. Voucher - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Dig. Voucher - Read";

    Permissions = tabledata "Digital Voucher Entry Setup" = IMD,
                  tabledata "Digital Voucher Setup" = IMD,
                  tabledata "Voucher Entry Source Code" = IMD;
}
