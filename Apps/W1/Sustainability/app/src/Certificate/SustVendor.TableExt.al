namespace Microsoft.Sustainability.Certificate;

using Microsoft.Purchases.Vendor;

tableextension 6219 "Sust. Vendor" extends Vendor
{
    fields
    {
        field(6210; "Sust. Cert. No."; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Certificate"."No." where(Type = const(Vendor));
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
        }
    }

    local procedure UpdateCertificateInformation()
    var
        SustCertificate: Record "Sustainability Certificate";
    begin
        Rec."Sust. Cert. Name" := '';

        if SustCertificate.Get(Rec."Sust. Cert. No.") then
            Rec."Sust. Cert. Name" := SustCertificate.Name;
    end;
}