tableextension 5012 "Serv. Decl. Item" extends Item
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";

            trigger OnValidate()
            begin
                TestField(Type, Type::Service);
            end;
        }
        field(5011; "Exclude From Service Decl."; Boolean)
        {
            Caption = 'Exclude From Service Declaration';
        }
    }
}