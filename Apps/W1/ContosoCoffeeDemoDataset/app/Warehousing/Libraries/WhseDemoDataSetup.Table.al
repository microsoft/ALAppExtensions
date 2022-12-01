table 4763 "Whse Demo Data Setup"
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
        field(3; "Auto Create Whse. Employees"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Auto Create Whse. Employees';
        }
        field(8; "Starting Year"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Year';
            trigger OnValidate()
            begin
                "Working Date" := DMY2Date(1, 1, "Starting Year");
            end;
        }
        field(9; "Working Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Working Date';
        }
        field(17; "Company Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = VAT,"Sales Tax";
            Caption = 'Company Type';
        }
        field(24; "Adjust for Payment Discount"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Adjust for Payment Discount';
        }
        field(31; "Retail Code"; code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Retail - Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(34; "Domestic Code"; code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Domestic - Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(35; "Resale Code"; code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Resale - Inventory Posting Group';
            TableRelation = "Inventory Posting Group";
        }

        field(38; "Price Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            InitValue = 1;
            Caption = 'Price Factor';
        }
        field(39; "Rounding Precision"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision';
            InitValue = 0.01;
        }


        field(40; "S. Customer No."; Code[20])
        {
            Caption = 'Small Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(41; "S. Cust. Posting Group"; Code[20])
        {
            Caption = 'Small Cust. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
            ValidateTableRelation = false;
        }
        field(42; "SCust. Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Small Cust. Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ValidateTableRelation = false;
        }
        field(43; "L. Customer No."; Code[20])
        {
            Caption = 'Large Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(44; "L. Cust. Posting Group"; Code[20])
        {
            Caption = 'Large Cust. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group";
            ValidateTableRelation = false;
        }
        field(45; "LCust. Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Large Cust. Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ValidateTableRelation = false;
        }
        field(50; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = false;
        }
        field(51; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Posting Group";
            ValidateTableRelation = false;
        }
        field(52; "Vend. Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Vend.  Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ValidateTableRelation = false;
        }
        field(60; "Main Item No."; Code[20])
        {
            Caption = 'Main Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(61; "Complex Item No."; Code[20])
        {
            Caption = 'Complex Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(70; "Location Basic"; Code[10])
        {
            Caption = 'Location Basic';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;
        }
        field(80; "Location Simple Logistics"; Code[10])
        {
            Caption = 'Location Simple Logistics';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;
        }
        field(90; "Location Advanced Logistics"; Code[10])
        {
            Caption = 'Location Advanced Logistics';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}