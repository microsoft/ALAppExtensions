codeunit 11084 "Create DE Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGrp: Codeunit "Create DE VAT Posting Groups";
    begin
        case Rec."No." of
            CreateResource.Katherine():
                begin
                    Rec.Validate("Employment Date", 20050525D);
                    ValidateResource(Rec, DiepholzLbl, 77, 84.7, 45.35484, 155, '49293', CreateVatPostingGrp.VAT7());
                end;
            CreateResource.Lina():
                ValidateResource(Rec, HamburgLbl, 93, 102.3, 45, 186, '20203', CreateVatPostingGrp.VAT7());
            CreateResource.Marty():
                ValidateResource(Rec, DiepholzLbl, 70, 77, 44.60432, 139, '49293', CreateVatPostingGrp.VAT7());
            CreateResource.Terry():
                ValidateResource(Rec, DiepholzLbl, 77, 84.7, 45.35484, 155, '49293', CreateVatPostingGrp.VAT7());
        end;
    end;

    local procedure ValidateResource(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercent: Decimal; UnitPrice: Decimal; PostCode: Code[20]; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercent);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    var
        DiepholzLbl: Label 'Diepholz', MaxLength = 30;
        HamburgLbl: Label 'Hamburg', MaxLength = 30;
}