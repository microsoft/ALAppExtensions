// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18024 "GST Invoice Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Self Invoice")
    {
        Caption = 'Self Invoice';
    }
    value(2; "Debit Note")
    {
        Caption = 'Debit Note';
    }
    value(3; Supplementary)
    {
        Caption = 'Supplementary';
    }
    value(4; "Non-GST")
    {
        Caption = 'Non-GST';
    }
}
