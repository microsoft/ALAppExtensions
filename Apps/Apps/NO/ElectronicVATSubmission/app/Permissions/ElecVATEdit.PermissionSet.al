// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10682 "Elec. VAT - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Elec. VAT - Read";

    Permissions = tabledata "Elec. VAT Setup" = IMD;
}
