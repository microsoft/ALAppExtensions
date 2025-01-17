// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.IRS;

permissionset 14601 "IS Core - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'IS Core - Objects';

    IncludedPermissionSets = "IS Core - Objects";

    Permissions = tabledata "IS IRS Groups" = R,
        tabledata "IS IRS Numbers" = R,
        tabledata "IS IRS Types" = R;
}