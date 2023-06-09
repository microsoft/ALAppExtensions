table 30145 "Shpfy Refund Line"
{
    Caption = 'Refund Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Refund Line Id"; BigInteger)
        {
            Caption = 'Refund Line Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Refund Id"; BigInteger)
        {
            Caption = 'Refund Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Refund Header"."Refund Id";
            Editable = false;
        }
        field(3; "Order Line Id"; BigInteger)
        {
            Caption = 'Order Line Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Line"."Line Id";
            Editable = false;
        }
        field(4; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Restock Type"; Enum "Shpfy Restock Type")
        {
            Caption = 'Restock Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; Restocked; boolean)
        {
            Caption = 'Restocked';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Presentment Amount"; Decimal)
        {
            Caption = 'Presentment Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Subtotal Amount"; Decimal)
        {
            Caption = 'Subtotal Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Presentment Subtotal Amount"; Decimal)
        {
            Caption = 'Presentment Subtotal Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Total Tax Amount"; Decimal)
        {
            Caption = 'Total Tax Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Presentment Total Tax Amount"; Decimal)
        {
            Caption = 'Presentment Total Tax Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line"."Item No." where("Line Id" = field("Order Line Id")));
            Editable = false;
        }
        field(102; Description; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line".Description where("Line Id" = field("Order Line Id")));
            Editable = false;
        }
        field(103; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line"."Variant Code" where("Line Id" = field("Order Line Id")));
            Editable = false;
        }
        field(104; "Gift Card"; Boolean)
        {
            Caption = 'Gift Card';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Line"."Gift Card" where("Line Id" = field("Order Line Id")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Refund Id", "Refund Line Id")
        {
            Clustered = true;
        }
    }
}