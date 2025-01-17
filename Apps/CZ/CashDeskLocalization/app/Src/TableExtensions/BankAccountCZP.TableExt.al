// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;

tableextension 11778 "Bank Account CZP" extends "Bank Account"
{
    fields
    {
        field(11750; "Account Type CZP"; Enum "Bank Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
