// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.WithholdingTax;

permissionset 6787 "WHT - Edit"
{
    Caption = 'Withholding Tax - Edit';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "WHT - Read";

    Permissions =
        tabledata "Temp Withholding Tax Entry" = IMD,
        tabledata "Withholding Tax Cert. Buffer" = IMD,
        tabledata "Withholding Tax Entry" = IMD;
}
