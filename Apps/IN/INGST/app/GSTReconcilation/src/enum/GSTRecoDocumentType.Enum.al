// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

enum 18281 "GSTReco Document Type"
{
    value(0; Invoice)
    {
        Caption = 'Invoice';
    }
    value(1; "Revised Invoice")
    {
        Caption = 'Revised Invoice';
    }
    value(2; "Debit Note")
    {
        Caption = 'Debit Note';
    }
    value(3; "Revised Debit Note")
    {
        Caption = 'Revised Debit Note';
    }
    value(4; "Credit Note")
    {
        Caption = 'Credit Note';
    }
    value(5; "Revised Credit Note")
    {
        Caption = 'Revised Credit Note';
    }
    value(6; "ISD Credit")
    {
        Caption = 'ISD Credit';
    }
    value(7; "TDS Credit")
    {
        Caption = 'TDS Credit';
    }
    value(8; "TCS Credit")
    {
        Caption = 'TCS Credit';
    }
}
