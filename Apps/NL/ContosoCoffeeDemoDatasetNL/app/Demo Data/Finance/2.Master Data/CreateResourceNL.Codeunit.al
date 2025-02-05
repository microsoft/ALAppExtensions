codeunit 11511 "Create Resource NL"
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
                ValidateRecordFields(Rec, AmsterdamCityLbl, 77, 84.7, 155, PostCode1053UTLbl, 20050525D);
            CreateResource.Lina():
                ValidateRecordFields(Rec, ApeldoornCityLbl, 93, 102.3, 186, PostCode3781ENLbl, 19990101D);
            CreateResource.Marty():
                ValidateRecordFields(Rec, AmsterdamCityLbl, 70, 77, 139, PostCode1053UTLbl, 19960301D);
            CreateResource.Terry():
                ValidateRecordFields(Rec, AmsterdamCityLbl, 77, 84.7, 155, PostCode1053UTLbl, 19960301D);
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal; PostCode: Code[20]; EmploymentDate: Date)
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Employment Date", EmploymentDate);
    end;

    var
        AmsterdamCityLbl: Label 'Amsterdam', MaxLength = 30;
        ApeldoornCityLbl: Label 'Apeldoorn', MaxLength = 30;
        PostCode1053UTLbl: Label '1053 UT', MaxLength = 20;
        PostCode3781ENLbl: Label '3781 EN', MaxLength = 20;
}