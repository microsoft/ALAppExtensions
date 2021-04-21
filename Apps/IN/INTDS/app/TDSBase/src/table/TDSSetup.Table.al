table 18693 "TDS Setup"
{
    Caption = 'TDS Setup';
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Tax Type"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Tax Type";
        }
        field(3; "TDS Nil Challan Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "Nil Pay TDS Document Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }
}