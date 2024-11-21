codeunit 11211 "Create Resource SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateVatPostingGroupsSE: Codeunit "Create Vat Posting Groups SE";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, CityLbl, 510, 561, 44.45545, 1010, PostCodeLbl, ContosoUtilities.AdjustDate(20050525D), CreateVatPostingGroupsSE.VAT12());
            CreateResource.Lina():
                ValidateRecordFields(Rec, CityLbl, 610, 671, 44.54545, 1210, PostCodeLbl, ContosoUtilities.AdjustDate(18780101D), CreateVatPostingGroupsSE.VAT12());
            CreateResource.Marty():
                ValidateRecordFields(Rec, CityLbl, 450, 495, 45.6044, 910, PostCodeLbl, ContosoUtilities.AdjustDate(18750301D), CreateVatPostingGroupsSE.VAT12());
            CreateResource.Terry():
                ValidateRecordFields(Rec, CityLbl, 510, 561, 44.45545, 1010, PostCodeLbl, ContosoUtilities.AdjustDate(18750301D), CreateVatPostingGroupsSE.VAT12());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20]; EmploymentDate: Date; VatProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Employment Date", EmploymentDate);
        Resource.Validate("VAT Prod. Posting Group", VatProdPostingGroup);
    end;

    var
        CityLbl: Label 'STOCKHOLM', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '114 32', MaxLength = 20;
}