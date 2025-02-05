codeunit 17154 "Create AU Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateAUVatPostingGroups: Codeunit "Create AU Vat Posting Groups";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, CanberraLbl, 150, 165, 43.10345, 290, PostCode2600Lbl, CreateAUVatPostingGroups.Vat10());
            CreateResource.Marty():
                ValidateRecordFields(Rec, CanberraLbl, 130, 143, 45, 260, PostCode2600Lbl, CreateAUVatPostingGroups.Vat10());
            CreateResource.Lina():
                ValidateRecordFields(Rec, CanberraLbl, 170, 187, 46.57143, 350, PostCode2600Lbl, CreateAUVatPostingGroups.Vat10());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20]; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    var
        CanberraLbl: Label 'CANBERRA', MaxLength = 30, Locked = true;
        PostCode2600Lbl: Label '2600', MaxLength = 20;
}