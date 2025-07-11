// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

permissionset 4710 "VATGroupManagement - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'VAT Group Management - Edit';

    IncludedPermissionSets = "VATGroupManagement - Read";

    Permissions = tabledata "VAT Group Approved Member" = IMD,
                    tabledata "VAT Group Calculation" = IMD,
                    tabledata "VAT Group Submission Header" = IMD,
                    tabledata "VAT Group Submission Line" = IMD;
}
