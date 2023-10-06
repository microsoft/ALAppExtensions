// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10020 "IRS 1096 - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "IRS 1096 - Read";

    Permissions = tabledata "IRS 1096 Form Header" = IMD,
                  tabledata "IRS 1096 Form Line" = IMD,
                  tabledata "IRS 1096 Form Line Relation" = IMD;
}
