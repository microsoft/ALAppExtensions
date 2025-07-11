// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

using Microsoft.Finance.GeneralLedger.Account;

tableextension 18243 "GST Bank Account Posting Group" extends "Bank Account Posting Group"
{
    fields
    {
        field(18243; "GST Rounding Account"; Code[20])
        {
            Caption = 'GST Rounding Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(False), "Account Type" = filter(Posting));
        }
    }

}
