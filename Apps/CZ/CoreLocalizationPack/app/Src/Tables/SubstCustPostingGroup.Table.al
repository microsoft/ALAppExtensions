table 11728 "Subst. Cust. Posting Group CZL"
{
    Caption = 'Subst. Customer Posting Group';
    LookupPageID = "Subst. Cust. Post. Groups CZL";

    fields
    {
        field(1; "Parent Customer Posting Group"; Code[20])
        {
            Caption = 'Parent Customer Posting Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Customer Posting Group" = "Parent Customer Posting Group" then
                    Error(PostGrpSubstErr);
            end;
        }
    }

    keys
    {
        key(Key1; "Parent Customer Posting Group", "Customer Posting Group")
        {
            Clustered = true;
        }
    }

    var
        PostGrpSubstErr: Label 'Posting Group cannot substitute itself.';
}

