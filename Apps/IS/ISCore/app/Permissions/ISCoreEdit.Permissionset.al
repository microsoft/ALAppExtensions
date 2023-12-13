// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.IRS;

permissionset 14602 "IS Core - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'IS Core - Edit';

    IncludedPermissionSets = "IS Core - Read";

    Permissions = tabledata "IS IRS Groups" = IMD,
        tabledata "IS IRS Numbers" = IMD,
        tabledata "IS IRS Types" = IMD;
}