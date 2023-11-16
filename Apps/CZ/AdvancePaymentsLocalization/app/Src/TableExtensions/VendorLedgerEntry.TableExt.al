// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

tableextension 31007 "Vendor Ledger Entry CZZ" extends "Vendor Ledger Entry"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Purch. Adv. Letter Header CZZ";
        }
        field(31011; "Adv. Letter Template Code CZZ"; Code[20])
        {
            Caption = 'Advance Letter Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Purchase));
        }
    }
}
