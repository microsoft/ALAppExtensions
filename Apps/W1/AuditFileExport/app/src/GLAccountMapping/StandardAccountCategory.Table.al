table 5262 "Standard Account Category"
{
    DataClassification = CustomerContent;
    Caption = 'Standard Account Category';

    fields
    {
        field(1; "Standard Account Type"; enum "Standard Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Type';
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Standard Account Type", "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {

        }
    }

    trigger OnDelete()
    var
        StandardAccount: Record "Standard Account";
    begin
        StandardAccount.SetRange(Type, "Standard Account Type");
        StandardAccount.SetRange("Category No.", "No.");
        StandardAccount.DeleteAll(true);
    end;
}
