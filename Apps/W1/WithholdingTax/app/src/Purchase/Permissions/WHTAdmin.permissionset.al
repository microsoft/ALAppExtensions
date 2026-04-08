// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.WithholdingTax;

permissionset 6784 "WHT - Admin"
{
    Caption = 'Withholding Tax - Admin';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "WHT - Edit";

    Permissions =
        tabledata "Wthldg. Tax Bus. Post. Group" = IMD,
        tabledata "Withholding Tax Posting Setup" = IMD,
        tabledata "Wthldg. Tax Prod. Post. Group" = IMD,
        tabledata "Withholding Tax Posting Buffer" = IMD,
        tabledata "Withholding Tax Revenue Types" = IMD;
}
