codeunit 5115 "Create FA Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFAGlAccount: Codeunit "Create FA GL Account";
    begin
        ContosoFixedAsset.InsertFAPostingGroup(Equipment(), CreateFAGlAccount.IncreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.DecreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.Miscellaneous(), CreateFAGlAccount.DepreciationEquipment(), CreateFAGlAccount.IncreasesDuringTheYear());
        ContosoFixedAsset.InsertFAPostingGroup(Goodwill(), CreateFAGlAccount.IncreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.DecreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.Miscellaneous(), CreateFAGlAccount.DepreciationEquipment(), CreateFAGlAccount.IncreasesDuringTheYear());
        ContosoFixedAsset.InsertFAPostingGroup(Plant(), CreateFAGlAccount.IncreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.DecreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.Miscellaneous(), CreateFAGlAccount.DepreciationEquipment(), CreateFAGlAccount.IncreasesDuringTheYear());
        ContosoFixedAsset.InsertFAPostingGroup(Property(), CreateFAGlAccount.IncreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.DecreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.Miscellaneous(), CreateFAGlAccount.DepreciationEquipment(), CreateFAGlAccount.IncreasesDuringTheYear());
        ContosoFixedAsset.InsertFAPostingGroup(Vehicles(), CreateFAGlAccount.IncreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.DecreasesDuringTheYear(), CreateFAGlAccount.AccumDepreciationBuildings(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.GainsAndLosses(), CreateFAGlAccount.Miscellaneous(), CreateFAGlAccount.DepreciationEquipment(), CreateFAGlAccount.IncreasesDuringTheYear());
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(GoodwillTok);
    end;

    procedure Equipment(): Code[20]
    begin
        exit(EquipmentTok);
    end;

    procedure Plant(): Code[20]
    begin
        exit(PlantTok);
    end;

    procedure Property(): Code[20]
    begin
        exit(PropertyTok);
    end;

    procedure Vehicles(): Code[20]
    begin
        exit(VehiclesTok);
    end;

    var
        GoodwillTok: Label 'GOODWILL', MaxLength = 20;
        EquipmentTok: Label 'EQUIPMENT', MaxLength = 20;
        PlantTok: Label 'PLANT', MaxLength = 20;
        PropertyTok: Label 'PROPERTY', MaxLength = 20;
        VehiclesTok: Label 'VEHICLES', MaxLength = 20;
}