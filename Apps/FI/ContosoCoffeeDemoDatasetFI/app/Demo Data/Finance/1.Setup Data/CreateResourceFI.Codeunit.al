codeunit 13434 "Create Resource FI"
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
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, CityLbl, 77, 84.7, 45.35484, 155, PostCodeLbl, ContosoUtilities.AdjustDate(20050525D));
            CreateResource.Terry():
                ValidateRecordFields(Rec, CityLbl, 77, 84.7, 45.35484, 155, PostCodeLbl, ContosoUtilities.AdjustDate(18750301D));
            CreateResource.Marty():
                ValidateRecordFields(Rec, CityLbl, 70, 77, 44.60432, 139, PostCodeLbl, ContosoUtilities.AdjustDate(18750301D));
            CreateResource.Lina():
                ValidateRecordFields(Rec, CityLbl, 93, 102.3, 45, 186, PostCodeLbl, ContosoUtilities.AdjustDate(18780101D));
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20]; EmploymentDate: Date)
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Employment Date", EmploymentDate);
    end;

    var
        CityLbl: Label 'Helsinki', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '00170', MaxLength = 20;
}