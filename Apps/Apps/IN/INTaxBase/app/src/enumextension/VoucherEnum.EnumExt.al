// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

enumextension 18548 "Voucher Enum" extends "Gen. Journal Template Type"
{
#pragma warning disable AS0013,PTE0023 // The IDs should have been in the range [18543..18597]
    value(18000; "Cash Receipt Voucher")
    {
        Caption = 'Cash Receipt Voucher';
    }
    value(18001; "Cash Payment Voucher")
    {
        Caption = 'Cash Payment Voucher';
    }
    value(18002; "Bank Receipt Voucher")
    {
        Caption = 'Bank Receipt Voucher';
    }
    value(18003; "Bank Payment Voucher")
    {
        Caption = 'Bank Payment Voucher';
    }
    value(18004; "Contra Voucher")
    {
        Caption = 'Contra Voucher';
    }
    value(18005; "Journal Voucher")
    {
        Caption = 'Journal Voucher';
    }
#pragma warning restore AS0013,PTE0023 // The IDs should have been in the range [18543..18597]
}
