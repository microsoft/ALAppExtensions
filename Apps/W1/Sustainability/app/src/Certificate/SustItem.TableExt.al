namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6220 "Sust. Item" extends Item
{
    fields
    {
        field(6210; "Sust. Cert. No."; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Certificate"."No." where(Type = const(Item));
            Caption = 'Sustainability Certificate No.';

            trigger OnValidate()
            begin
                UpdateCertificateInformation();
            end;
        }
        field(6211; "Sust. Cert. Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sustainability Certificate Name';
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
        field(6214; "Default Sust. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Default Sust. Account';

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Default Sust. Account" = '' then
                    ClearDefaultEmissionInformation(Rec)
                else begin
                    SustainabilityAccount.Get(Rec."Default Sust. Account");

                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);
                end;
            end;
        }
        field(6215; "Default CO2 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CO2 Emission';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CO2 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6216; "Default CH4 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CH4 Emission';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CH4 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6217; "Default N2O Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default N2O Emission';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default N2O Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";

    local procedure UpdateCertificateInformation()
    var
        SustCertificate: Record "Sustainability Certificate";
    begin
        Rec.TestField(Type, Rec.Type::Inventory);
        Rec."Sust. Cert. Name" := '';

        if SustCertificate.Get(SustCertificate.Type::Item, Rec."Sust. Cert. No.") then
            Rec.Validate("Sust. Cert. Name", SustCertificate.Name);
    end;

    procedure ClearDefaultEmissionInformation(var Item: Record Item)
    begin
        Item.Validate("Default N2O Emission", 0);
        Item.Validate("Default CH4 Emission", 0);
        Item.Validate("Default CO2 Emission", 0);
    end;
}