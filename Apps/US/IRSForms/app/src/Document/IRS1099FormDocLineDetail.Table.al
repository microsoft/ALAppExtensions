// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;

table 10038 "IRS 1099 Form Doc. Line Detail"
{
    DataClassification = CustomerContent;
    Caption = 'IRS 1099 Form Document Line Detail';

    DrillDownPageId = "IRS 1099 Form Doc Line Details";
    LookupPageId = "IRS 1099 Form Doc Line Details";

    fields
    {
        field(1; "Document ID"; Integer)
        {
        }
        field(5; "Line No."; Integer)
        {
        }
        field(6; "Vendor Ledger Entry No."; Integer)
        {
        }
        field(100; "Document Type"; Enum "Gen. Journal Document Type")
        {
            CalcFormula = lookup("Vendor Ledger Entry"."Document Type" where("Entry No." = field("Vendor Ledger Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Document No."; Code[20])
        {
            CalcFormula = lookup("Vendor Ledger Entry"."Document No." where("Entry No." = field("Vendor Ledger Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; Description; Text[100])
        {
            CalcFormula = lookup("Vendor Ledger Entry".Description where("Entry No." = field("Vendor Ledger Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "IRS 1099 Reporting Amount"; Decimal)
        {
            CalcFormula = lookup("Vendor Ledger Entry"."IRS 1099 Reporting Amount" where("Entry No." = field("Vendor Ledger Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Document ID", "Line No.", "Vendor Ledger Entry No.")
        {
            Clustered = true;
        }
    }
}
