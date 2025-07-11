// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10030 "IRS Forms - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "IRS Forms - Objects";

    Permissions = tabledata "IRS Forms Setup" = R,
                  tabledata "IRS Reporting Period" = R,
                  tabledata "IRS 1099 Vendor Form Box Setup" = R,
                  tabledata "IRS 1099 Form Statement Line" = R,
                  tabledata "IRS 1099 Form Doc. Line" = R,
                  tabledata "IRS 1099 Form Doc. Line Detail" = R,
                  tabledata "IRS 1099 Form Doc. Header" = R,
                  tabledata "IRS 1099 Form" = R,
                  tabledata "IRS 1099 Form Box" = R,
                  tabledata "IRS 1099 Form Report" = R,
                  tabledata "IRS 1099 Form Instruction" = R,
                  tabledata "IRS 1099 Vendor Form Box Adj." = R,
                  tabledata "IRS 1099 Email Queue" = R;
}
