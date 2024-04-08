// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10031 "IRS Forms - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "IRS Forms - Read";

    Permissions = tabledata "IRS Forms Setup" = IMD,
                  tabledata "IRS Reporting Period" = IMD,
                  tabledata "IRS 1099 Vendor Form Box Setup" = IMD,
                  tabledata "IRS 1099 Form Statement Line" = IMD,
                  tabledata "IRS 1099 Form Doc. Line" = IMD,
                  tabledata "IRS 1099 Form Doc. Line Detail" = IMD,
                  tabledata "IRS 1099 Form Doc. Header" = IMD,
                  tabledata "IRS 1099 Form" = IMD,
                  tabledata "IRS 1099 Form Box" = IMD,
                  tabledata "IRS 1099 Form Report" = IMD,
                  tabledata "IRS 1099 Form Instruction" = IMD,
                  tabledata "IRS 1099 Vendor Form Box Adj." = IMD,
                  tabledata "IRS 1099 Email Queue" = IMD;
}
