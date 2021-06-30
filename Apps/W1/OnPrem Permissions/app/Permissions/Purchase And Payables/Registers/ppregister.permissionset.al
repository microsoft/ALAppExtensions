// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3561 "P&P-REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read G/L registers (P&P)';

    IncludedPermissionSets = "Payables Registers - Read";
}
