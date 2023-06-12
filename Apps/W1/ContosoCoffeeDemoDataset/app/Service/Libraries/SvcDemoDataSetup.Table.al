table 4765 "Svc Demo Data Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "Is DemoData Populated"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is DemoData Populated';
        }
        field(8; "Starting Year"; Integer)
        {
            Caption = 'Starting Year';
            trigger OnValidate()
            begin
                "Working Date" := DMY2Date(1, 1, "Starting Year");
            end;
        }
        field(9; "Working Date"; Date)
        {
            Caption = 'Working Date';
        }
        field(17; "Company Type"; Option)
        {
            OptionMembers = VAT,"Sales Tax";
            Caption = 'Company Type';
        }
        field(24; "Adjust for Payment Discount"; Boolean)
        {
            Caption = 'Adjust for Payment Discount';
        }
        field(31; "Retail Code"; code[20])
        {
            Caption = 'Retail - Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(34; "Domestic Code"; code[10])
        {
            Caption = 'Domestic - VAT Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(35; "Resale Code"; code[20])
        {
            Caption = 'Resale - Inventory Posting Group';
            TableRelation = "Inventory Posting Group";
        }
        field(36; "VAT Prod. Posting Group Code"; code[20])
        {
            Caption = 'VAT Prod. Posting Group Code';
            TableRelation = "VAT Product Posting Group";
        }
        field(38; "Price Factor"; Decimal)
        {
            InitValue = 1;
            Caption = 'Price Factor';
        }
        field(39; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            InitValue = 0.01;
        }
        field(40; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    Rec."Customer VAT Bus. Code" := Customer."VAT Bus. Posting Group";
            end;
        }
        field(41; "Cust. Posting Group"; Code[20])
        {
            Caption = 'Cust. Posting Group';
            TableRelation = "Customer Posting Group";
            ValidateTableRelation = false;
        }
        field(42; "Cust. Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Cust. Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            ValidateTableRelation = false;
        }
        field(60; "Item 1 No."; Code[20])
        {
            Caption = 'Item 1 No.';
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(61; "Item 2 No."; Code[20])
        {
            Caption = 'Item 2 No.';
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(63; "Customer VAT Bus. Code"; code[20])
        {
            Caption = 'Customer - VAT Business Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(70; "Resource L1 No."; Code[20])
        {
            Caption = 'Resource Local 1 No.';
            TableRelation = Resource;
            ValidateTableRelation = false;
        }
        field(71; "Resource L2 No."; Code[20])
        {
            Caption = 'Resource Local 2 No.';
            TableRelation = Resource;
            ValidateTableRelation = false;
        }
        field(72; "Resource R1 No."; Code[20])
        {
            Caption = 'Resource Remote 1 No.';
            TableRelation = Resource;
            ValidateTableRelation = false;
        }
        field(73; "Resource R2 No."; Code[20])
        {
            Caption = 'Resource Remote 2 No.';
            TableRelation = Resource;
            ValidateTableRelation = false;
        }
        field(80; "Svc. Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Svc. Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Primary Key") { }
    }
}