codeunit 14130 "Create Resource MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupsMX: Codeunit "Create Vat Posting Groups MX";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, MexicoCityLbl, 690, 759, 1390, MexicoPostCodeLbl, CreateVatPostingGroupsMX.VAT8());
            CreateResource.Lina():
                ValidateRecordFields(Rec, LondonCityLbl, 830, 913, 1660, LondonPostCodeLbl, CreateVatPostingGroupsMX.VAT8());
            CreateResource.Marty():
                ValidateRecordFields(Rec, MexicoCityLbl, 620, 682, 1250, MexicoPostCodeLbl, CreateVatPostingGroupsMX.VAT8());
            CreateResource.Terry():
                ValidateRecordFields(Rec, MexicoCityLbl, 690, 759, 1390, MexicoPostCodeLbl, CreateVatPostingGroupsMX.VAT8());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal; PostCode: Code[20]; VatProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Post Code", PostCode);
        Resource."Country/Region Code" := '';
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("VAT Prod. Posting Group", VatProdPostingGroup);
    end;

    var
        MexicoCityLbl: Label 'Mexico City', MaxLength = 30, Locked = true;
        LondonCityLbl: Label 'London', MaxLength = 30, Locked = true;
        MexicoPostCodeLbl: Label '01030', MaxLength = 20;
        LondonPostCodeLbl: Label 'GB-N16 34Z', MaxLength = 20;
}