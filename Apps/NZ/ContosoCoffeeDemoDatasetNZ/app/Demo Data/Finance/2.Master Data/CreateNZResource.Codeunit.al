codeunit 17125 "Create NZ Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, AucklandPostmasterCityLbl, PostCode1030Lbl, 170, 187, 340, 45, CreateNZVATPostingGroup.VAT9());
            CreateResource.Lina():
                ValidateRecordFields(Rec, AucklandCityLbl, PostCode1001Lbl, 210, 231, 410, 43.65854, CreateNZVATPostingGroup.VAT9());
            CreateResource.Marty():
                ValidateRecordFields(Rec, AucklandPostmasterCityLbl, PostCode1030Lbl, 160, 176, 310, 43.22581, CreateNZVATPostingGroup.VAT9());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; PostCode: Code[20]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal; ProfitPercantage: Decimal; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercantage);
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    var
        AucklandPostmasterCityLbl: Label 'Auckland Postmaster', MaxLength = 30, Locked = true;
        AucklandCityLbl: Label 'Auckland', MaxLength = 30, Locked = true;
        PostCode1030Lbl: Label '1030', MaxLength = 20;
        PostCode1001Lbl: Label '1001', MaxLength = 20;
}