// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

permissionset 5585 "Dig. Voucher - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Digital Voucher - Objects";

    Permissions = tabledata "Digital Voucher Entry Setup" = R,
                  tabledata "Digital Voucher Setup" = R,
                  tabledata "Voucher Entry Source Code" = R;
}
