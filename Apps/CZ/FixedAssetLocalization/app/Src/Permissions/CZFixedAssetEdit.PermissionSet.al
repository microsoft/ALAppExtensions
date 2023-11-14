// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11761 "CZ Fixed Asset - Edit CZF"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Fixed Asset - Edit';

    IncludedPermissionSets = "CZ Fixed Asset - Read CZF";

    Permissions = tabledata "Classification Code CZF" = IMD,
                  tabledata "FA Extended Posting Group CZF" = IMD,
                  tabledata "FA History Entry CZF" = IMD,
                  tabledata "Tax Depreciation Group CZF" = IMD;
}
