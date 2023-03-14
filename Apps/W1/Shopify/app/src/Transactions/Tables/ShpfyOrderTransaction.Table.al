/// <summary>
/// Table Shpfy Order Transaction (ID 30133).
/// </summary>
table 30133 "Shpfy Order Transaction"
{
    Access = Internal;
    Caption = 'Shopify Order Transaction';
    DataClassification = SystemMetadata;
    LookupPageID = "Shpfy Order Transactions";

    fields
    {
        field(1; "Shopify Transaction Id"; BigInteger)
        {
            Caption = 'Shopify Transaction Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; Type; enum "Shpfy Transaction Type")
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Gateway; Text[30])
        {
            Caption = 'Gateway';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; Status; enum "Shpfy Transaction Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; Test; Boolean)
        {
            Caption = 'Test';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; Authorization; Code[50])
        {
            Caption = 'Authorization';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; Currency; Code[20])
        {
            Caption = 'Currency';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Gift Card Id"; BigInteger)
        {
            Caption = 'Gift Card Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(15; "Source Name"; Code[20])
        {
            Caption = 'Source Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(16; "Credit Card Bin"; Code[10])
        {
            Caption = 'Credit Card Bin';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(17; "AVS Result Code"; Code[1])
        {
            Caption = 'AVS Result Code'; //http://www.emsecommerce.net/avs_cvv2_response_codes.htm
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(18; "CVV Result Code"; Code[1])
        {
            Caption = 'CVV Result Code'; //http://www.emsecommerce.net/avs_cvv2_response_codes.htm
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(19; "Credit Card Number"; Text[30])
        {
            Caption = 'Credit Card Number';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; "Credit Card Company"; Text[50])
        {
            Caption = 'Credit Card company';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; "Parent Id"; BigInteger)
        {
            Caption = 'Parent Id';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Shpfy Order Transaction";
        }
        field(22; "Error Code"; Text[30])
        {
            Caption = 'Error Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; "Sales Document No."; code[20])
        {
            Caption = 'Sales Document No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."No." where("Shpfy Order Id" = field("Shopify Order Id")));
        }

        field(102; "Posted Invoice No."; Code[20])
        {
            Caption = 'Posted Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header"."No." where("Shpfy Order Id" = field("Shopify Order Id")));
        }
        field(103; "Shop Code"; code[20])
        {
            Caption = 'Shop Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Order Header"."Shop Code" where("Shopify Order Id" = field("Shopify Order Id")));
        }
        field(104; "Payment Method"; Code[10])
        {
            Caption = 'Payment Method';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Payment Method Mapping"."Payment Method Code" where("Shop Code" = field("Shop Code"), Gateway = field(Gateway), "Credit Card Company" = field("Credit Card Company")));
        }
        field(105; "Payment Priority"; Integer)
        {
            Caption = 'Payment Priority';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Payment Method Mapping".Priority where("Shop Code" = field("Shop Code"), Gateway = field(Gateway), "Credit Card Company" = field("Credit Card Company")));
        }
    }

    keys
    {
        key(Key1; "Shopify Transaction Id")
        {
            Clustered = true;
        }
        key(Idx001; "Gift Card Id")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataCapture: Record "Shpfy Data Capture";
    begin
        DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
        DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Transaction");
        DataCapture.SetRange("Linked To Id", Rec.SystemId);
        if not DataCapture.IsEmpty then
            DataCapture.DeleteAll(false);
    end;
}

