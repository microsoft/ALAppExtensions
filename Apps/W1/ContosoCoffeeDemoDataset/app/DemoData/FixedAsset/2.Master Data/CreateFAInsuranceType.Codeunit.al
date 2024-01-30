codeunit 5156 "Create FA Insurance Type"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertInsuranceType(Vehicle(), VehicleDescriptionLbl);
        ContosoFixedAsset.InsertInsuranceType(Machinery(), MachineryOtherEquipmentLbl);
        ContosoFixedAsset.InsertInsuranceType(Theft(), MachineryOtherEquipmentLbl);
        ContosoFixedAsset.InsertInsuranceType(Fire(), MachineryOtherEquipmentLbl);
    end;

    procedure Vehicle(): Text[10]
    begin
        exit(VehicleTok);
    end;

    procedure Machinery(): Text[10]
    begin
        exit(MachineryTok);
    end;

    procedure Fire(): Text[10]
    begin
        exit(FireTok);
    end;

    procedure Theft(): Text[10]
    begin
        exit(TheftTok);
    end;

    var
        VehicleTok: Label 'VEHICLE', MaxLength = 10;
        VehicleDescriptionLbl: Label 'Vehicle', MaxLength = 100;
        MachineryTok: Label 'MACHINERY', MaxLength = 10;
        MachineryOtherEquipmentLbl: Label 'Machinery/Other Equipment', MaxLength = 100;
        TheftTok: Label 'THEFT', MaxLength = 10;
        FireTok: Label 'FIRE', MaxLength = 10;
}
