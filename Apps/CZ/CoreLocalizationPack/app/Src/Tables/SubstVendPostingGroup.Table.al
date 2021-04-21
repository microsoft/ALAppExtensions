table 11729 "Subst. Vend. Posting Group CZL"
{
    Caption = 'Subst. Vendor Posting Group';
    LookupPageID = "Subst. Vend. Post. Groups CZL";

    fields
    {
        field(1; "Parent Vendor Posting Group"; Code[20])
        {
            Caption = 'Parent Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
            DataClassification = CustomerContent;
        }
        field(2; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Vendor Posting Group" = "Parent Vendor Posting Group" then
                    Error(PostGrpSubstErr);
            end;
        }
    }

    keys
    {
        key(Key1; "Parent Vendor Posting Group", "Vendor Posting Group")
        {
            Clustered = true;
        }
    }

    var
        PostGrpSubstErr: Label 'Posting Group cannot substitute itself.';
}

