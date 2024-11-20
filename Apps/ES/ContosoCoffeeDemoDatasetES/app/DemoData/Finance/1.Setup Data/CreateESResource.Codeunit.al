codeunit 10815 "Create ES Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateESVatPostingGroups: Codeunit "Create ES Vat Posting Groups";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, MadridLbl, 77, 84.7, 45.35484, 155, PostCode28001Lbl, CreateESVatPostingGroups.Vat7());
            CreateResource.Lina():
                ValidateRecordFields(Rec, MadridLbl, 93, 102.3, 45, 186, PostCode28023Lbl, CreateESVatPostingGroups.Vat7());
            CreateResource.Marty():
                ValidateRecordFields(Rec, MadridLbl, 70, 77, 44.60432, 139, PostCode28001Lbl, CreateESVatPostingGroups.Vat7());
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
        Resource.Validate(County, '');
    end;

    var
        MadridLbl: Label 'Madrid', MaxLength = 30, Locked = true;
        PostCode28001Lbl: Label '28001', MaxLength = 20;
        PostCode28023Lbl: Label '28023', MaxLength = 20;
}