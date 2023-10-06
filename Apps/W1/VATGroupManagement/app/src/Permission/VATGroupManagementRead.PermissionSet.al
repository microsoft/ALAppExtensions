// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

permissionset 4712 "VATGroupManagement - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'VATGroupManagement - Read';

    IncludedPermissionSets = "VATGroupManagement - Objects";

    Permissions = tabledata "VAT Group Approved Member" = R,
                    tabledata "VAT Group Calculation" = R,
                    tabledata "VAT Group Submission Header" = R,
                    tabledata "VAT Group Submission Line" = R;
}
