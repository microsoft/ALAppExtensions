codeunit 13712 "Create Resource DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupsDK: Codeunit "Create Vat Posting Groups DK";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, CopenhagenLbl, 430, 473, 45, 860, PostCode1152Lbl, CreateVatPostingGroupsDK.Vat25Serv());
            CreateResource.Marty():
                ValidateRecordFields(Rec, CopenhagenLbl, 390, 429, 44.28571, 770, PostCode1152Lbl, CreateVatPostingGroupsDK.Vat25Serv());
            CreateResource.Lina():
                ValidateRecordFields(Rec, HorsholmLbl, 510, 561, 45.53398, 1030, PostCode2970Lbl, CreateVatPostingGroupsDK.Vat25Serv());
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
        CopenhagenLbl: Label 'Copenhagen K', MaxLength = 30, Locked = true;
        HorsholmLbl: Label 'Horsholm', Locked = true;
        PostCode1152Lbl: Label '1152', MaxLength = 20;
        PostCode2970Lbl: Label '2970', MaxLength = 20;
}