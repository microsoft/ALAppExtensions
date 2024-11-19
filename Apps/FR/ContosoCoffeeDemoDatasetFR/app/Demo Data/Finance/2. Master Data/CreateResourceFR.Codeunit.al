codeunit 10872 "Create Resource FR"
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
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, ParisLbl, 77, 84.7, 45.35484, 155, PostCode75000Lbl);
            CreateResource.Marty():
                ValidateRecordFields(Rec, ParisLbl, 70, 77, 44.60432, 139, PostCode75000Lbl);
            CreateResource.Lina():
                ValidateRecordFields(Rec, ParisLbl, 93, 102.3, 45, 186, PostCode75008Lbl);
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
        ParisLbl: Label 'Paris', MaxLength = 30, Locked = true;
        PostCode75000Lbl: Label '75000', MaxLength = 20;
        PostCode75008Lbl: Label '75008', MaxLength = 20;
}