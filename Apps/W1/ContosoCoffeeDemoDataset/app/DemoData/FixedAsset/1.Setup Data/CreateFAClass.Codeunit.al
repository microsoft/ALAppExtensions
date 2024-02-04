codeunit 5113 "Create FA Class"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertFAClass(TangibleClass(), TangibleLbl);
        ContosoFixedAsset.InsertFAClass(InTangibleClass(), InTangibleLbl);
        ContosoFixedAsset.InsertFAClass(FinancialClass(), FinancialLbl);

        ContosoFixedAsset.InsertFASubClass(GoodwillSubClass(), GoodwillLbl, InTangibleClass(), CreateFAPostingGroup.Goodwill());
        ContosoFixedAsset.InsertFASubClass(EquipmentSubClass(), EquipmentLbl, TangibleClass(), CreateFAPostingGroup.Equipment());
        ContosoFixedAsset.InsertFASubClass(PlantSubClass(), PlantLbl, TangibleClass(), CreateFAPostingGroup.Plant());
        ContosoFixedAsset.InsertFASubClass(PropertySubClass(), PropertyLbl, TangibleClass(), CreateFAPostingGroup.Property());
        ContosoFixedAsset.InsertFASubClass(VehiclesSubClass(), VehiclesLbl, TangibleClass(), CreateFAPostingGroup.Vehicles());
    end;

    procedure TangibleClass(): Code[10]
    begin
        exit(TangibleTok);
    end;

    procedure InTangibleClass(): Code[10]
    begin
        exit(InTangibleTok);
    end;

    procedure FinancialClass(): Code[10]
    begin
        exit(FinancialTok);
    end;

    procedure GoodwillSubClass(): Code[10]
    begin
        exit(GoodwillTok);
    end;

    procedure EquipmentSubClass(): Code[10]
    begin
        exit(EquipmentTok);
    end;

    procedure PlantSubClass(): Code[10]
    begin
        exit(PlantTok);
    end;

    procedure PropertySubClass(): Code[10]
    begin
        exit(PropertyTok);
    end;

    procedure VehiclesSubClass(): Code[10]
    begin
        exit(VehiclesTok);
    end;

    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        TangibleTok: Label 'TANGIBLE', MaxLength = 10;
        InTangibleTok: Label 'INTANGIBLE', MaxLength = 10;
        FinancialTok: Label 'FINANCIAL', MaxLength = 10;
        TangibleLbl: Label 'Tangible', MaxLength = 50;
        InTangibleLbl: Label 'InTangible', MaxLength = 50;
        FinancialLbl: Label 'Financial', MaxLength = 50;
        GoodwillTok: Label 'GOODWILL', MaxLength = 10;
        EquipmentTok: Label 'EQUIPMENT', MaxLength = 10;
        PlantTok: Label 'PLANT', MaxLength = 10;
        PropertyTok: Label 'PROPERTY', MaxLength = 10;
        VehiclesTok: Label 'VEHICLES', MaxLength = 10;
        GoodwillLbl: Label 'Goodwill', MaxLength = 50;
        EquipmentLbl: Label 'Equipment', MaxLength = 50;
        PlantLbl: Label 'Plants/Buildings', MaxLength = 50;
        PropertyLbl: Label 'Property/Land', MaxLength = 50;
        VehiclesLbl: Label 'Vehicles', MaxLength = 50;
}