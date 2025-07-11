#pragma warning disable AA0247
codeunit 5213 "Create Sustainability Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
    begin
        ContosoSustainability.InsertAccountCategory(CompanyCar(), CompanyCarLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Distance, true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(Fugitive(), FugitiveLbl, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::Installations, true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(Hotel(), HotelLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'NIGHT', false);
        ContosoSustainability.InsertAccountCategory(MobileDistance(), MobileDistanceLbl, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::Distance, true, true, false, '', false);
        ContosoSustainability.InsertAccountCategory(MobileFuel(), MobileFuelLbl, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity", true, true, false, '', false);
        ContosoSustainability.InsertAccountCategory(PurchaseGoodsGL(), PurchaseGoodsGLLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'GL', true);
        ContosoSustainability.InsertAccountCategory(RentalCar(), RentalCarLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::"Fuel/Electricity", true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(SoldProductEnd(), SoldProductEndOfLifeTreatmentLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'GL', true);
        ContosoSustainability.InsertAccountCategory(SoldProductProcess(), SoldProductProccessingLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'GL', true);
        ContosoSustainability.InsertAccountCategory(SoldProductUse(), SoldProductUseLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'GL', true);
        ContosoSustainability.InsertAccountCategory(Stationary(), StationaryLbl, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false);
        ContosoSustainability.InsertAccountCategory(ExternalTransportDistance(), ExternalTransportDistanceLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Distance, true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(InternalTransportDistance(), InternalTransportDistanceLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Distance, true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(UtilityElectric(), UtilityElectricLbl, Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::"Fuel/Electricity", true, false, false, '', false);
        ContosoSustainability.InsertAccountCategory(UtilityHeat(), UtilityHeatLbl, Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::Custom, true, false, false, 'THERMAL UNIT', false);
        ContosoSustainability.InsertAccountCategory(UtilitySteam(), UtilitySteamLbl, Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::Custom, true, false, false, 'TON/HOUR', false);
        ContosoSustainability.InsertAccountCategory(Waste(), WasteLbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, true, false, 'WASTE TON', false);
        ContosoSustainability.InsertAccountCategory(Credit1(), Credit1Lbl, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::Custom, true, false, false, 'WASTE TON', false);
        ContosoSustainability.InsertAccountCategory(Credit2(), Credit2Lbl, Enum::"Emission Scope"::"Scope 2", Enum::"Calculation Foundation"::Custom, true, false, false, 'WASTE TON', false);
        ContosoSustainability.InsertAccountCategory(Credit3(), Credit3Lbl, Enum::"Emission Scope"::"Scope 3", Enum::"Calculation Foundation"::Custom, true, false, false, 'WASTE TON', false);
        ContosoSustainability.InsertAccountCategory(WasteM(), WasteLbl, Enum::"Emission Scope"::"Water/Waste", Enum::"Calculation Foundation"::Custom, false, false, false, false, true, false, 'KG', false);
        ContosoSustainability.InsertAccountCategory(Water(), WaterLbl, Enum::"Emission Scope"::"Water/Waste", Enum::"Calculation Foundation"::Custom, false, false, false, true, false, false, 'M3', false);
        ContosoSustainability.InsertAccountCategory(DischargedWater(), DischargedWaterLbl, Enum::"Emission Scope"::"Water/Waste", Enum::"Calculation Foundation"::Custom, false, false, false, false, false, true, 'M3', false);
    end;

    procedure CompanyCar(): Code[20]
    begin
        exit(CompanyCarTok);
    end;

    procedure Fugitive(): Code[20]
    begin
        exit(FugitiveTok);
    end;

    procedure Hotel(): Code[20]
    begin
        exit(HotelTok);
    end;

    procedure MobileDistance(): Code[20]
    begin
        exit(MobileDistanceTok);
    end;

    procedure MobileFuel(): Code[20]
    begin
        exit(MobileFuelTok);
    end;

    procedure PurchaseGoodsGL(): Code[20]
    begin
        exit(PurchaseGoodsGLTok);
    end;

    procedure RentalCar(): Code[20]
    begin
        exit(RentalCarTok);
    end;

    procedure SoldProductEnd(): Code[20]
    begin
        exit(SoldProductEndOfLifeTreatmentTok);
    end;

    procedure SoldProductProcess(): Code[20]
    begin
        exit(SoldProductProcessingTok);
    end;

    procedure SoldProductUse(): Code[20]
    begin
        exit(SoldProductUseTok);
    end;

    procedure Stationary(): Code[20]
    begin
        exit(StationaryTok);
    end;

    procedure ExternalTransportDistance(): Code[20]
    begin
        exit(ExternalTransportDistanceTok);
    end;

    procedure InternalTransportDistance(): Code[20]
    begin
        exit(InternalTransportDistanceTok);
    end;


    procedure UtilityElectric(): Code[20]
    begin
        exit(UtilityElectricTok);
    end;

    procedure UtilityHeat(): Code[20]
    begin
        exit(UtilityHeatTok);
    end;

    procedure UtilitySteam(): Code[20]
    begin
        exit(UtilitySteamTok);
    end;

    procedure Waste(): Code[20]
    begin
        exit(WasteTok);
    end;

    procedure Credit1(): Code[20]
    begin
        exit(Credit1Tok);
    end;

    procedure Credit2(): Code[20]
    begin
        exit(Credit2Tok);
    end;

    procedure Credit3(): Code[20]
    begin
        exit(Credit3Tok);
    end;

    procedure WasteM(): Code[20]
    begin
        exit(WasteMTok);
    end;

    procedure Water(): Code[20]
    begin
        exit(WaterTok);
    end;

    procedure DischargedWater(): Code[20]
    begin
        exit(DischargedWaterTok);
    end;

    var
        CompanyCarTok: Label 'COMPCAR', MaxLength = 20;
        CompanyCarLbl: Label 'Company Cars', MaxLength = 100;
        FugitiveTok: Label 'FUGITIVE', MaxLength = 20;
        FugitiveLbl: Label 'Fugitive Emissions', MaxLength = 100;
        HotelTok: Label 'HOTEL', MaxLength = 20;
        HotelLbl: Label 'Hotel Night Stays', MaxLength = 100;
        MobileDistanceTok: Label 'MOBILE-DISTANCE', MaxLength = 20;
        MobileDistanceLbl: Label 'Mobile Combustion - Distance Calculation', MaxLength = 100;
        MobileFuelTok: Label 'MOBILE-FUEL', MaxLength = 20;
        MobileFuelLbl: Label 'Mobile Combustion - Fuel Calculation', MaxLength = 100;
        PurchaseGoodsGLTok: Label 'PURCHGOODS-GL', MaxLength = 20;
        PurchaseGoodsGLLbl: Label 'Purchased Goods - GL Based Calculation', MaxLength = 100;
        RentalCarTok: Label 'RENTALCAR', MaxLength = 20;
        RentalCarLbl: Label 'Rental Car Usage', MaxLength = 100;
        SoldProductEndOfLifeTreatmentTok: Label 'SOLDPRODEND-GL', MaxLength = 20;
        SoldProductEndOfLifeTreatmentLbl: Label 'End of Life Treatment of Sold Products', MaxLength = 100;
        SoldProductProcessingTok: Label 'SOLDPRODPROC-GL', MaxLength = 20;
        SoldProductProccessingLbl: Label 'Processing of Sold Products', MaxLength = 100;
        SoldProductUseTok: Label 'SOLDPRODUSE-GL', MaxLength = 20;
        SoldProductUseLbl: Label 'Use of Sold Products', MaxLength = 100;
        StationaryTok: Label 'STATIONARY', MaxLength = 20;
        StationaryLbl: Label 'Stationary Combustion', MaxLength = 100;
        ExternalTransportDistanceTok: Label 'TRANSP-EXT-DIST', MaxLength = 20;
        ExternalTransportDistanceLbl: Label 'External Transport - Distance Calculation', MaxLength = 100;
        InternalTransportDistanceTok: Label 'TRANSP-INT-DIST', MaxLength = 20;
        InternalTransportDistanceLbl: Label 'Internal Transport - Distance Calculation', MaxLength = 100;
        UtilityElectricTok: Label 'UTILITY-ELECTRIC', MaxLength = 20;
        UtilityElectricLbl: Label 'Utility Providers - Electricity', MaxLength = 100;
        UtilityHeatTok: Label 'UTILITY-HEAT', MaxLength = 20;
        UtilityHeatLbl: Label 'Utility Providers - Heating', MaxLength = 100;
        UtilitySteamTok: Label 'UTILITY-STEAM', MaxLength = 20;
        UtilitySteamLbl: Label 'Utility Providers - Steam', MaxLength = 100;
        WasteTok: Label 'WASTE', MaxLength = 20;
        WasteLbl: Label 'Waste Generated', MaxLength = 100;
        Credit1Tok: Label 'CREDIT1', MaxLength = 20;
        Credit1Lbl: Label 'Carbon Credit Scope 1', MaxLength = 100;
        Credit2Tok: Label 'CREDIT2', MaxLength = 20;
        Credit2Lbl: Label 'Carbon Credit Scope 2', MaxLength = 100;
        Credit3Tok: Label 'CREDIT3', MaxLength = 20;
        Credit3Lbl: Label 'Carbon Credit Scope 3', MaxLength = 100;
        WasteMTok: Label 'WASTEM', MaxLength = 20;
        WaterTok: Label 'WATER', MaxLength = 20;
        WaterLbl: Label 'Water Generated', MaxLength = 100;
        DischargedWaterTok: Label 'WAT-DISCH', MaxLength = 20;
        DischargedWaterLbl: Label 'Discharged Water', MaxLength = 100;
}
