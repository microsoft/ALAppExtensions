// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Receivables;

tableextension 31001 "Cust. Ledger Entry CZZ" extends "Cust. Ledger Entry"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
        field(31011; "Adv. Letter Template Code CZZ"; Code[20])
        {
            Caption = 'Advance Letter Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Sales));
        }
    }
}
