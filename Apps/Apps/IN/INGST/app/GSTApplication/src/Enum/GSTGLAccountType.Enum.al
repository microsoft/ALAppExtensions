// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

enum 18430 "GST GL Account Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Payable Account")
    {
        Caption = 'Payable Account';
    }
    value(2; "Payables Account (Interim)")
    {
        Caption = 'Payables Account (Interim)';
    }
    value(3; "Receivable Account")
    {
        Caption = 'Receivable Account';
    }
    value(4; "Receivable Account (Interim)")
    {
        Caption = 'Receivable Account (Interim)';
    }
    value(5; "Receivable Acc. (Dist)")
    {
        Caption = 'Receivable Acc. (Dist)';
    }
    value(6; "Receivable Acc. Interim (Dist)")
    {
        Caption = 'Receivable Acc. Interim (Dist)';
    }
    value(7; "Refund Account")
    {
        Caption = 'Refund Account';
    }
    value(8; "Expense Account")
    {
        Caption = 'Expense Account';
    }
    value(9; "Credit Mismatch Account")
    {
        Caption = 'Credit Mismatch Account';
    }
}
