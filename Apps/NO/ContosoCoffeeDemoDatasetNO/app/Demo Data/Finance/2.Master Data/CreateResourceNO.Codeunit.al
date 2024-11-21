codeunit 10706 "Create Resource NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, CityLbl, 490, 539, 970, PostCodeLbl, CreateVatPostingGroupsNO.Low());
            CreateResource.Lina():
                ValidateRecordFields(Rec, CityLbl, 580, 638, 1170, PostCodeLbl, CreateVatPostingGroupsNO.Low());
            CreateResource.Marty():
                ValidateRecordFields(Rec, CityLbl, 440, 484, 880, PostCodeLbl, CreateVatPostingGroupsNO.Low());
            CreateResource.Terry():
                ValidateRecordFields(Rec, CityLbl, 490, 539, 970, PostCodeLbl, CreateVatPostingGroupsNO.Low());
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
        CityLbl: Label 'BREGER', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '5003', MaxLength = 20;
}