// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Sales.Receivables;

tableextension 31280 "Cust. Ledger Entry CZB" extends "Cust. Ledger Entry"
{
    fields
    {
#pragma warning disable AA0232
        field(11790; "Amount on Pmt. Order (LCY) CZB"; Decimal)
        {
            CalcFormula = - sum("Iss. Payment Order Line CZB"."Amount (LCY)" where(Type = const(Customer), "Applies-to C/V/E Entry No." = field("Entry No."), Status = const(" ")));
            Caption = 'Amount on Payment Order (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
    }
}
