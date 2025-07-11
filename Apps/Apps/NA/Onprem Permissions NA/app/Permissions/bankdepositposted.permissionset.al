// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 27003 "BANKDEPOSIT-POSTED"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Posted Bank Deposits';

    Permissions = tabledata "Bank Comment Line" = Ri,
                  tabledata "Posted Deposit Header" = Ri,
                  tabledata "Posted Deposit Line" = Ri,
                  tabledata "User Setup" = r;
}
