// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 20101 AMCBankOwnreference
{
    Extensible = false;

    value(0; "Recipient Name")
    {
        Caption = 'Recipient Name';
    }
    value(1; "Recipient No.")
    {
        Caption = 'Recipient No.';
    }
    value(2; "Recipient No./Name")
    {
        Caption = 'Recipient No. & Name';
    }
    value(3; "Journal Description")
    {
        Caption = 'Journal Description';
    }

    value(4; "Transaction unique ref.")
    {
        Caption = 'Transaction unique reference';
    }

}
