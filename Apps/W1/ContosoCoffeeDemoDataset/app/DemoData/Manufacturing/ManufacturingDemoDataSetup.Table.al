table 4760 "Manufacturing Demo Data Setup"
{
    ObsoleteReason = 'The table is moved to "Manufacturing Module Setup" table';
    InherentEntitlements = rimdX;
    InherentPermissions = rimdX;
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Is DemoData Populated"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(8; "Starting Year"; Integer)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                "Working Date" := DMY2Date(1, 1, "Starting Year");
            end;
        }
        field(9; "Working Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(17; "Company Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = VAT,"Sales Tax";
        }
        field(18; "Base VAT Code"; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(24; "Adjust for Payment Discount"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(30; "Finished Code"; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group";
            ValidateTableRelation = false;
        }
        field(31; "Retail Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Retail - Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(32; "Raw Mat Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Raw Mat - Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
        field(33; "Manufact Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Capacity - Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
        field(34; "Domestic Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Domestic - Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(37; "Manufacturing Location"; code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Location";
            ValidateTableRelation = false;
        }
        field(38; "Price Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(39; "Rounding Precision"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rounding Precision';
            InitValue = 0.01;
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