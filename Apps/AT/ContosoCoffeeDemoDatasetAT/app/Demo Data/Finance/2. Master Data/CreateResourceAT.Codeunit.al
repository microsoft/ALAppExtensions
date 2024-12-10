codeunit 11152 "Create Resource AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupAT: Codeunit "Create Vat Posting Group AT";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, WienLbl, 77, 84.7, 45.35484, 155, PostCode1010Lbl, CreateVatPostingGroupAT.Vat10());
            CreateResource.Marty():
                ValidateRecordFields(Rec, WienLbl, 70, 77, 44.60432, 139, PostCode1010Lbl, CreateVatPostingGroupAT.Vat10());
            CreateResource.Lina():
                ValidateRecordFields(Rec, WienLbl, 93, 102.3, 45, 186, PostCode1230Lbl, CreateVatPostingGroupAT.Vat10());
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
        WienLbl: Label 'Wien', MaxLength = 30, Locked = true;
        PostCode1010Lbl: Label '1010', MaxLength = 20;
        PostCode1230Lbl: Label '1230', MaxLength = 20;
}