table 18015 "E-Commerce Merchant"
{
    Caption = 'E-Commerce Merchant';
    DataCaptionFields = "Customer No.", "Merchant Id";
    ObsoleteReason = 'New table 18017 introduced as "E-Comm. Merchant" with customer No. field length as 20';
#if CLEAN23
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';
#else
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';
#endif
    fields
    {
        field(1; "Customer No."; code[10])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            NotBlank = true;
        }
        field(2; "Merchant Id"; code[30])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Company GST Reg. No."; code[20])
        {
            Caption = 'Company GST Reg. No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos.";
        }
    }

    keys
    {
        key(PK; "Customer No.", "Merchant Id")
        {
            Clustered = true;
        }
    }
}