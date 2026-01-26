// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

permissionset 4851 "AAC - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Read';

    IncludedPermissionSets = "AAC - Objects";

    Permissions = tabledata "Automatic Account Header" = R,
    tabledata "Automatic Account Line" = R;
}