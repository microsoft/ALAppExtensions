tableextension 5017 "Serv. Decl. Purch. Line" extends "Purchase Line"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            TableRelation = "Service Transaction Type";
            Caption = 'Service Transaction Type Code';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                TestField("No.");
                if Type <> Type::Item then
                    exit;
                Item.Get("No.");
                Item.TestField(Type, Item.Type::Service);
            end;
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';

            trigger OnValidate()
            var
                PurchHeader: Record "Purchase Header";
            begin
                PurchHeader.Get("Document Type", "Document No.");
                if "Applicable For Serv. Decl." then
                    PurchHeader.TestField("Applicable For Serv. Decl.");
            end;
        }
    }
}