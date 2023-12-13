// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

using Microsoft.Finance.Currency;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 31263 "Value Entry CZA" extends "Value Entry"
{
    fields
    {
        field(31001; "Invoice-to Source No. CZA"; Code[20])
        {
            Caption = 'Invoice-to Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer else
            if ("Source Type" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }
        field(31002; "Delivery-to Source No. CZA"; Code[20])
        {
            Caption = 'Delivery-to Source No.';
            TableRelation = if ("Source Type" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("Source No.")) else
            if ("Source Type" = const(Vendor)) "Order Address".Code where("Vendor No." = field("Source No."));
            DataClassification = CustomerContent;
        }
        field(31006; "Currency Code CZA"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(31007; "Currency Factor CZA"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            DataClassification = CustomerContent;
        }
    }
}
