codeunit 12217 "Create Resource IT"
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
                ValidateRecordFields(Rec, MilanoCityLbl, 77, 84.7, 45.35484, 155, PostCode20100Lbl);
            CreateResource.Terry():
                ValidateRecordFields(Rec, MilanoCityLbl, 77, 84.7, 45.35484, 155, PostCode20100Lbl);
            CreateResource.Marty():
                ValidateRecordFields(Rec, MilanoCityLbl, 70, 77, 44.60432, 139, PostCode20100Lbl);
            CreateResource.Lina():
                ValidateRecordFields(Rec, NapoliCityLbl, 93, 102.3, 45, 186, PostCode80100Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Post Code", PostCode);
    end;

    var
        MilanoCityLbl: Label 'Milano', MaxLength = 30, Locked = true;
        NapoliCityLbl: Label 'Napoli', MaxLength = 30, Locked = true;
        PostCode20100Lbl: Label '20100', MaxLength = 20;
        PostCode80100Lbl: Label '80100', MaxLength = 20;
}