// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

permissionset 20111 "AMC Banking - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'AMC Banking - Edit';

    IncludedPermissionSets = "AMC Banking - Read";

    Permissions = tabledata "AMC Bank Banks" = IMD,
                  tabledata "AMC Bank Pmt. Type" = IMD,
                  tabledata "AMC Banking Setup" = IMD;
}