// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13619 BankAccRecLine extends "Bank Acc. Reconciliation Line"
{
    fields
    {
        field(13601; PaymentReference; Code[20]) { Caption = 'Payment Reference'; }
    }
}