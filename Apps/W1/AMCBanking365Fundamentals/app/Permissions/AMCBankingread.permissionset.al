#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

permissionset 20114 "AMC Banking - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'AMC Banking - Read';
#if not CLEAN28 
    IncludedPermissionSets = "AMC Banking- Objects";
    Permissions = tabledata "AMC Bank Banks" = R,
                  tabledata "AMC Bank Pmt. Type" = R,
                  tabledata "AMC Banking Setup" = R;
#endif
}
#endif