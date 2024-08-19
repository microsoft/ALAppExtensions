namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;

tableextension 6220 "Sust. Item" extends Item
{
    fields
    {
        field(6210; "Sust. Cert. No."; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Certificate"."No." where(Type = const(Item));
            Caption = 'Sust. Certificate No.';

            trigger OnValidate()
            begin
                UpdateCertificateInformation();
            end;
        }
        field(6211; "Sust. Cert. Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sust. Certificate Name';
            Editable = false;

            trigger OnValidate()
            begin
                if Rec."Sust. Cert. Name" <> '' then
                    Rec.TestField("Sust. Cert. No.");
            end;
        }
        field(6212; "GHG Credit"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'GHG Credit';

            trigger OnValidate()
            begin
                if not Rec."GHG Credit" then
                    Rec.TestField("Carbon Credit Per UOM", 0);
            end;
        }
        field(6213; "Carbon Credit Per UOM"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Credit Per UOM';

            trigger OnValidate()
            begin
                Rec.TestField("GHG Credit");
            end;
        }
    }

    local procedure UpdateCertificateInformation()
    var
        SustCertificate: Record "Sustainability Certificate";
    begin
        Rec.TestField(Type, Rec.Type::Inventory);
        Rec."Sust. Cert. Name" := '';

        if SustCertificate.Get(Rec."Sust. Cert. No.") then
            Rec.Validate("Sust. Cert. Name", SustCertificate.Name);
    end;
}