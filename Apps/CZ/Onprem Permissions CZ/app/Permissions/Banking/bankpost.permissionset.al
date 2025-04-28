// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 11701 "BANK-POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Bank Payment, Statement Post';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bank Export/Import Setup" = R;
}
