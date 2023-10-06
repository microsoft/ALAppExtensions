// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10021 "IRS 1096 - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "IRS 1096 Objects";

    Permissions = tabledata "IRS 1096 Form Header" = R,
                  tabledata "IRS 1096 Form Line" = R,
                  tabledata "IRS 1096 Form Line Relation" = R;
}
