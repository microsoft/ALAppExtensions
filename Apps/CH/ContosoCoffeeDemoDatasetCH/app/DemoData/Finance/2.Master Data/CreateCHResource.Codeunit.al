codeunit 11613 "Create CH Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateCHVatPostingGroups: Codeunit "Create CH VAT Posting Groups";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Rec, BernLbl, 92, 101.2, 45, 184, '3000', '', CreateCHVatPostingGroups.Normal());
            CreateResource.Lina():
                ValidateRecordFields(Rec, BallwilLbl, 110, 121, 45.24887, 221, '6275', '', CreateCHVatPostingGroups.Normal());
            CreateResource.Marty():
                ValidateRecordFields(Rec, BernLbl, 83, 91.3, 45, 166, '3000', '', CreateCHVatPostingGroups.Normal());
            CreateResource.Terry():
                ValidateRecordFields(Rec, BernLbl, 92, 101.2, 45, 184, '3000', '', CreateCHVatPostingGroups.Normal());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercent: Decimal; UnitPrice: Decimal; PostCode: Code[20]; County: Text[30]; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercent);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate(County, County);
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    var
        BernLbl: Label 'Bern', MaxLength = 30;
        BallwilLbl: Label 'Ballwil', MaxLength = 30;
}