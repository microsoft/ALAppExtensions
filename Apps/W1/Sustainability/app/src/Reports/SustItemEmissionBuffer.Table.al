// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Reports;

using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sustainability.Setup;

table 6250 "Sust. Item Emission Buffer"
{
    Caption = 'Sustainability Item Emission Buffer';
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Direction"; Option)
        {
            Caption = 'Direction';
            OptionMembers = Inbound,Outbound;
        }
        field(3; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(4; "Transaction Type"; Enum "Item Ledger Entry Type")
        {
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Source Type"; Enum "Analysis Source Type")
        {
            Caption = 'Source Type';
        }
        field(7; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor
            else
            if ("Source Type" = const(Item)) Item;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(9; "Item Name"; Text[100])
        {
            Caption = 'Item Name';
        }
        field(15; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(20; "CO2e Emission"; Decimal)
        {
            Caption = 'CO2e Emission';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(30; "Emission CO2"; Decimal)
        {
            Caption = 'Emission CO2';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(31; "Emission CH4"; Decimal)
        {
            Caption = 'Emission CH4';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(32; "Emission N2O"; Decimal)
        {
            Caption = 'Emission N2O';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}