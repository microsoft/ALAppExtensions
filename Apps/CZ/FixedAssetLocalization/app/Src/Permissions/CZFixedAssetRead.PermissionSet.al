// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11760 "CZ Fixed Asset - Read CZF"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Fixed Asset - Read';

    IncludedPermissionSets = "CZ Fixed Asset - Objects CZF";

    Permissions = tabledata "Classification Code CZF" = R,
                  tabledata "FA Extended Posting Group CZF" = R,
                  tabledata "FA History Entry CZF" = R,
                  tabledata "Tax Depreciation Group CZF" = R;
}
