table 5010 "Service Declaration Setup"
{

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }
        field(2; "Declaration No. Series"; Code[20])
        {
            Caption = 'Declaration No. Series';
            TableRelation = "No. Series";
        }
        field(3; "Report Item Charges"; Boolean)
        {
            Caption = 'Report Item Charges';
        }
        field(5; "Sell-To/Bill-To Customer No."; Enum "G/L Setup VAT Calculation")
        {
            Caption = 'Sell-To/Bill-To Customer No.';
        }
        field(6; "Buy-From/Pay-To Vendor No."; Enum "G/L Setup VAT Calculation")
        {
            Caption = 'Buy-From/Pay-To Vendor No.';
        }
        field(7; "Data Exch. Def. Code"; Code[20])
        {
            TableRelation = "Data Exch. Def";
        }
        field(8; "Enable VAT Registration No."; Boolean)
        {
            Caption = 'Enable VAT Registration No.';
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

