// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Sales.Receivables;

#pragma warning disable AA0232
tableextension 31271 "Cust. Ledger Entry CZC" extends "Cust. Ledger Entry"
{
    fields
    {
        field(31060; "Compensation Amount (LCY) CZC"; Decimal)
        {
            Caption = 'Compensation Amount (LCY) CZC';
            FieldClass = FlowField;
            CalcFormula = sum("Compensation Line CZC"."Amount (LCY)" where("Source Type" = const(Customer), "Source Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(31061; "Compensation CZC"; Boolean)
        {
            Caption = 'Compensation';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
