tableextension 4811 "Intrastat Report Item" extends Item
{
    fields
    {
        field(4810; "Exclude from Intrastat Report"; Boolean)
        {
            Caption = 'Exclude from Intrastat Report';
        }
        field(4811; "Supplementary Unit of Measure"; Code[10])
        {
            Caption = 'Supplementary Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }
    }
}