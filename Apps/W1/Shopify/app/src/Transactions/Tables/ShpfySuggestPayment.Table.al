namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.Currency;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

/// <summary>
/// Table Shpfy Suggest Payment (ID 30154).
/// </summary>
table 30154 "Shpfy Suggest Payment"
{
    Access = Internal;
    Caption = 'Shopify Suggest Payment';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Shop Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(3; "Shpfy Transaction Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Transaction";
        }
        field(4; "Customer Ledger Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Cust. Ledger Entry";
        }
        field(5; "Customer No."; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = Customer;
        }
        field(6; "Invoice No."; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "Sales Invoice Header";
        }
        field(7; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Currency Code"; Code[10])
        {
            DataClassification = SystemMetadata;
            TableRelation = Currency;
        }
        field(9; "Gateway"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Cust. Ledger Entry Dim. Set Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Shpfy Order No."; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Shopify Order No." where("Shopify Order Id" = field("Shpfy Order Id")));
        }
        field(12; "Shpfy Gift Card Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "Payment Method Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(14; "Shpfy Order Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(15; "Credit Memo No."; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = "Sales Cr.Memo Header";
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}