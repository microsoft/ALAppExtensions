// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

table 31012 "Advance Letter Link Buffer CZZ"
{
    Caption = 'Advance Letter Link Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Advance Letter Type"; Enum "Advance Letter Type CZZ")
        {
            Caption = 'Advance Letter Type';
            DataClassification = CustomerContent;
        }
        field(2; "CV Ledger Entry No."; Integer)
        {
            Caption = 'CV Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Advance Letter Type" = const(Sales)) "Cust. Ledger Entry" where("Document Type" = const(Payment)) else
            if ("Advance Letter Type" = const(Purchase)) "Vendor Ledger Entry" where("Document Type" = const(Payment));
        }
        field(3; "Advance Letter No."; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Advance Letter Type" = const(Sales)) "Sales Adv. Letter Header CZZ"."No." where(Status = const("To Pay")) else
            if ("Advance Letter Type" = const(Purchase)) "Purch. Adv. Letter Header CZZ"."No." where(Status = const("To Pay"));
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
    keys
    {
        key(PK; "Advance Letter Type", "CV Ledger Entry No.", "Advance Letter No.")
        {
            Clustered = true;
        }
    }
}
