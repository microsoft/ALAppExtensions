codeunit 11369 "Create Resource BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupBE: Codeunit "Create Vat Posting Group BE";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, BrusselLbl, 77, 84.7, 45.35484, 155, PostCode1000Lbl, CreateVatPostingGroupBE.S3());
            CreateResource.Marty():
                ValidateRecordFields(Rec, BrusselLbl, 70, 77, 44.60432, 139, PostCode1000Lbl, CreateVatPostingGroupBE.S3());
            CreateResource.Lina():
                ValidateRecordFields(Rec, BrusselLbl, 93, 102.3, 45, 186, PostCode1000Lbl, CreateVatPostingGroupBE.S3());
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
        BrusselLbl: Label 'BRUSSEL', MaxLength = 30, Locked = true;
        PostCode1000Lbl: Label '1000', MaxLength = 20;
}