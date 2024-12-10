codeunit 14614 "Create Resource IS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl, 5000, 5500, 10000);
            CreateResource.Lina():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl, 6000, 6600, 12100);
            CreateResource.Marty():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl, 4500, 4950, 9000);
            CreateResource.Terry():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl, 5000, 5500, 10000);
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; PostCode: Code[20]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        Resource.Validate(City, City);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
    end;

    var
        CityLbl: Label 'Reykjavik', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '101', MaxLength = 20;
}