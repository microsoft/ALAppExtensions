tableextension 4814 "Intrastat Report Customer" extends Customer
{
    fields
    {
        field(4810; "Default Trans. Type"; Code[10])
        {
            Caption = 'Default Trans. Type';
            TableRelation = "Transaction Type";
        }
        field(4811; "Default Trans. Type - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            TableRelation = "Transaction Type";
        }
        field(4812; "Def. Transport Method"; Code[10])
        {
            Caption = 'Default Transport Method';
            TableRelation = "Transport Method";
        }
    }
}