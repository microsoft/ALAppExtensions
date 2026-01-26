#pragma warning disable AA0247
codeunit 5214 "Create Sustain. Subcategory"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SustainabilityCategory: Codeunit "Create Sustainability Category";
        ContosoSustainability: Codeunit "Contoso Sustainability";
    begin
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.CompanyCar(), CompanyCarMedium(), CompanyCarMediumLbl, 0.128, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.CompanyCar(), CompanyCarLarge(), CompanyCarLargeLbl, 0.149, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.CompanyCar(), CompanyCarPremium(), CompanyCarPremiumLbl, 0.177, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Fugitive(), Refrigerator(), RefrigeratorLbl, 0.24388, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Fugitive(), AirConditionerSmall(), AirConditionerSmallLbl, 0.8452, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Fugitive(), AirConditionerLarge(), AirConditionerLargeLbl, 1.3217, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Hotel(), Hotel3Star(), Hotel3StarLbl, 15.6, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Hotel(), Hotel4Star(), Hotel4StarLbl, 24.22, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Hotel(), Hotel4StarPlus(), Hotel4StarPlusLbl, 40.21, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), UrbanTruck(), UrbanTruckLbl, 0.307, 0.00039, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), LongHaulTruck(), LongHaulTruckLbl, 0.057, 0.00007, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), Bus(), BusLbl, 1.3, 0.00166, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), Rail(), RailLbl, 0.035, 0.00004, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), AirContinentalEconomy(), AirContinentalEconomyLbl, 0.30038, 0.00037, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), AirContinentalBusiness(), AirContinentalBusinessLbl, 0.44639, 0.00055, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), AirIntercontinentalEconomy(), AirIntercontinentalEconomyLbl, 0.21872, 0.00027, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), AirIntercontinentalPremiumEconomy(), AirIntercontinentalPremiumEconomyLbl, 0.32808, 0.0004, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileDistance(), AirIntercontinentalBusiness(), AirIntercontinentalBusinessLbl, 0.88856, 0.00109, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileFuel(), Tractor(), TractorLbl, 2.6, 0.0032, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileFuel(), Forklift(), ForkliftLbl, 2.64, 0.0032, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.MobileFuel(), Backhoe(), BackhoeLbl, 2.6391, 0.0032, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.PurchaseGoodsGL(), PurchasedGoodsPlastic(), PurchasedGoodsPlasticLbl, 0.3, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.PurchaseGoodsGL(), PurchasedGoodsAluminum(), PurchasedGoodsAluminumLbl, 0.5, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.PurchaseGoodsGL(), PurchasedGoodsSteel(), PurchasedGoodsSteelLbl, 0.2, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.PurchaseGoodsGL(), PurchasedGoodsGlass(), PurchasedGoodsGlassLbl, 0.4, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.PurchaseGoodsGL(), PurchasedServices(), PurchasedServicesLbl, 0.15, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.RentalCar(), RentalCarMedium(), RentalCarMediumLbl, 0.197, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.SoldProductEnd(), SoldProductEnd(), SoldProductEndLbl, 0.25, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.SoldProductProcess(), SoldProductProcess(), SoldProductProcessLbl, 0.28, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.SoldProductUse(), SoldProductUse(), SoldProductUseLbl, 0.31, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Stationary(), Boiler(), BoilerLbl, 7.21616, 0.136, 0.0136, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Stationary(), HeaterSmall(), HeaterSmallLbl, 3.99675, 0.4499, 0.06544, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Stationary(), HeaterMedium(), HeaterMediumLbl, 7.9935, 0.8998, 0.13088, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Stationary(), HeaterLarge(), HeaterLargeLbl, 11.903, 1.3497, 0.19632, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Stationary(), Thermal(), ThermalLbl, 0.17704, 0.01088, 0.00021, true);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.ExternalTransportDistance(), ExternalTransportDistance(), ExternalTransportDistanceLbl, 1.425, 0.00036, 0.00014, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.InternalTransportDistance(), InternalTransportDistance(), InternalTransportDistanceLbl, 0.986, 0.00031, 0.00011, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.UtilityElectric(), ElectricityNuclear(), ElectricityNuclearLbl, 0.087, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.UtilityElectric(), ElectricityCoal(), ElectricityCoalLbl, 0.3834, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.UtilityElectric(), ElectricityGreen(), ElectricityGreenLbl, 0, 0, 0, true);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.UtilityHeat(), Heat(), HeatLbl, 296.85635, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.UtilitySteam(), SteamSupplier(), SteamSupplierLbl, 2488, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Waste(), WasteLandFillOrganic(), WasteLandfillOrganicLbl, 0.47681, 0.05002, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Waste(), WasteLandFillPlastic(), WasteLandfillPlasticLbl, 1.80842, 0.07126, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Waste(), WasteRecycled(), WasteRecycledLbl, 0.28906, 0.02209, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Credit1(), Credit(), CreditLbl, 0, 0, 0, true);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Credit2(), Credit(), CreditLbl, 0, 0, 0, true);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Credit3(), Credit(), CreditLbl, 0, 0, 0, true);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WasteCompostableTok, WasteCompostableLbl, 0, 0, 0, 0, 0.12, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WasteFoodTok, WasteFoodLbl, 0, 0, 0, 0, 0.14, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WastePlasticTok, WastePlasticLbl, 0, 0, 0, 0, 0.99, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WasteRecyclableTok, WasteRecyclableLbl, 0, 0, 0, 0, 0.18, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WasteSteelTok, WasteSteelLbl, 0, 0, 0, 0, 0.34, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.WasteM(), WasteWoodTok, WasteWoodLbl, 0, 0, 0, 0, 0.48, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Water(), WaterBlueTok, WaterBlueLbl, 0, 0, 0, 0.35, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Water(), WaterGreenTok, WaterGreenLbl, 0, 0, 0, 0.8, 0, 0, false);
        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.Water(), WaterGreyTok, WaterGreyLbl, 0, 0, 0, 0.92, 0, 0, false);

        ContosoSustainability.InsertAccountSubcategory(SustainabilityCategory.DischargedWater(), DischargedWaterTok, DischargedWaterLbl, 0, 0, 0, 0, 0, 0.63, false);
    end;

    procedure CompanyCarMedium(): Code[20]
    begin
        exit(CompanyCarMediumTok);
    end;

    procedure CompanyCarLarge(): Code[20]
    begin
        exit(CompanyCarLargeTok);
    end;

    procedure CompanyCarPremium(): Code[20]
    begin
        exit(CompanyCarPremiumTok);
    end;

    procedure Refrigerator(): Code[20]
    begin
        exit(RefrigeratorTok);
    end;

    procedure AirConditionerSmall(): Code[20]
    begin
        exit(AirConditionerSmallTok);
    end;

    procedure AirConditionerLarge(): Code[20]
    begin
        exit(AirConditionerLargeTok);
    end;

    procedure Hotel3Star(): Code[20]
    begin
        exit(Hotel3StarTok);
    end;

    procedure Hotel4Star(): Code[20]
    begin
        exit(Hotel4StarTok);
    end;

    procedure Hotel4StarPlus(): Code[20]
    begin
        exit(Hotel4StarPlusTok);
    end;

    procedure UrbanTruck(): Code[20]
    begin
        exit(UrbanTruckTok);
    end;

    procedure LongHaulTruck(): Code[20]
    begin
        exit(LongHaulTruckTok);
    end;

    procedure Bus(): Code[20]
    begin
        exit(BusTok);
    end;

    procedure Rail(): Code[20]
    begin
        exit(RailTok);
    end;

    procedure AirContinentalEconomy(): Code[20]
    begin
        exit(AirContinentalEconomyTok);
    end;

    procedure AirContinentalBusiness(): Code[20]
    begin
        exit(AirContinentalBusinessTok);
    end;

    procedure AirIntercontinentalEconomy(): Code[20]
    begin
        exit(AirIntercontinentalEconomyTok);
    end;

    procedure AirIntercontinentalPremiumEconomy(): Code[20]
    begin
        exit(AirIntercontinentalPremiumEconomyTok);
    end;

    procedure AirIntercontinentalBusiness(): Code[20]
    begin
        exit(AirIntercontinentalBusinessTok);
    end;

    procedure Tractor(): Code[20]
    begin
        exit(TractorTok);
    end;

    procedure Forklift(): Code[20]
    begin
        exit(ForkliftTok);
    end;

    procedure Backhoe(): Code[20]
    begin
        exit(BackhoeTok);
    end;

    procedure PurchasedGoodsPlastic(): Code[20]
    begin
        exit(PurchasedGoodsPlasticTok);
    end;

    procedure PurchasedGoodsAluminum(): Code[20]
    begin
        exit(PurchasedGoodsAluminumTok);
    end;

    procedure PurchasedGoodsSteel(): Code[20]
    begin
        exit(PurchasedGoodsSteelTok);
    end;

    procedure PurchasedGoodsGlass(): Code[20]
    begin
        exit(PurchasedGoodsGlassTok);
    end;

    procedure PurchasedServices(): Code[20]
    begin
        exit(PurchasedServicesTok);
    end;

    procedure RentalCarMedium(): Code[20]
    begin
        exit(RentalCarMediumTok);
    end;

    procedure SoldProductEnd(): Code[20]
    begin
        exit(SoldProductEndTok);
    end;

    procedure SoldProductProcess(): Code[20]
    begin
        exit(SoldProductProcessTok);
    end;

    procedure SoldProductUse(): Code[20]
    begin
        exit(SoldProductUseTok);
    end;

    procedure Boiler(): Code[20]
    begin
        exit(BoilerTok);
    end;

    procedure HeaterSmall(): Code[20]
    begin
        exit(HeaterSmallTok);
    end;

    procedure HeaterMedium(): Code[20]
    begin
        exit(HeaterMediumTok);
    end;

    procedure HeaterLarge(): Code[20]
    begin
        exit(HeaterLargeTok);
    end;

    procedure Thermal(): Code[20]
    begin
        exit(ThermalTok);
    end;

    procedure ExternalTransportDistance(): Code[20]
    begin
        exit(ExternalTransportDistanceTok);
    end;

    procedure InternalTransportDistance(): Code[20]
    begin
        exit(InternalTransportDistanceTok);
    end;

    procedure ElectricityNuclear(): Code[20]
    begin
        exit(ElectricityNuclearTok);
    end;

    procedure ElectricityCoal(): Code[20]
    begin
        exit(ElectricityCoalTok);
    end;

    procedure ElectricityGreen(): Code[20]
    begin
        exit(ElectricityGreenTok);
    end;

    procedure Heat(): Code[20]
    begin
        exit(HeatTok);
    end;

    procedure SteamSupplier(): Code[20]
    begin
        exit(SteamSupplierTok);
    end;


    procedure WasteLandFillOrganic(): Code[20]
    begin
        exit(WasteLandfillOrganicTok);
    end;

    procedure WasteLandFillPlastic(): Code[20]
    begin
        exit(WasteLandfillPlasticTok);
    end;

    procedure WasteRecycled(): Code[20]
    begin
        exit(WasteRecycledTok);
    end;

    procedure Credit(): Code[20]
    begin
        exit(CreditTok);
    end;

    procedure WasteCompostable(): Code[20]
    begin
        exit(WasteCompostableTok);
    end;

    procedure WasteFood(): Code[20]
    begin
        exit(WasteFoodTok);
    end;

    procedure WastePlastic(): Code[20]
    begin
        exit(WastePlasticTok);
    end;

    procedure WasteRecyclable(): Code[20]
    begin
        exit(WasteRecyclableTok);
    end;

    procedure WasteSteel(): Code[20]
    begin
        exit(WasteSteelTok);
    end;

    procedure WasteWood(): Code[20]
    begin
        exit(WasteWoodTok);
    end;

    procedure WaterBlue(): Code[20]
    begin
        exit(WaterBlueTok);
    end;

    procedure WaterGreen(): Code[20]
    begin
        exit(WaterGreenTok);
    end;

    procedure WaterGrey(): Code[20]
    begin
        exit(WaterGreyTok);
    end;

    procedure DischargedWater(): Code[20]
    begin
        exit(DischargedWaterTok);
    end;

    var
        CompanyCarMediumTok: Label 'COMPCAR-M', MaxLength = 20;
        CompanyCarMediumLbl: Label 'Company Car - Medium', MaxLength = 100;
        CompanyCarLargeTok: Label 'COMPCAR-L', MaxLength = 20;
        CompanyCarLargeLbl: Label 'Company Car - Large', MaxLength = 100;
        CompanyCarPremiumTok: Label 'COMPCAR-P', MaxLength = 20;
        CompanyCarPremiumLbl: Label 'Company Car - Premium', MaxLength = 100;
        RefrigeratorTok: Label 'REFRIG', MaxLength = 20;
        RefrigeratorLbl: Label 'Refrigerators', MaxLength = 100;
        AirConditionerSmallTok: Label 'AIRCS', MaxLength = 20;
        AirConditionerSmallLbl: Label 'Airconditioner 24000BTU/Day', MaxLength = 100;
        AirConditionerLargeTok: Label 'AIRCL', MaxLength = 20;
        AirConditionerLargeLbl: Label 'Airconditioner 36000BTU/Day', MaxLength = 100;
        Hotel3StarTok: Label 'HOTEL3STAR', MaxLength = 20;
        Hotel3StarLbl: Label 'Hotel Stay 3 stars/Day', MaxLength = 100;
        Hotel4StarTok: Label 'HOTEL4STAR', MaxLength = 20;
        Hotel4StarLbl: Label 'Hotel Stay 4 stars/Day', MaxLength = 100;
        Hotel4StarPlusTok: Label 'HOTEL4STAR+', MaxLength = 20;
        Hotel4StarPlusLbl: Label 'Hotel Stay 4 stars Suite/Day', MaxLength = 100;
        UrbanTruckTok: Label 'TRUCK-U', MaxLength = 20;
        UrbanTruckLbl: Label 'Truck Urban /KM/T', MaxLength = 100;
        LongHaulTruckTok: Label 'TRUCK-LH', MaxLength = 20;
        LongHaulTruckLbl: Label 'Truck Long-haul trailer /KM/T', MaxLength = 100;
        BusTok: Label 'BUS', MaxLength = 20;
        BusLbl: Label 'Buses', MaxLength = 100;
        RailTok: Label 'RAIL', MaxLength = 20;
        RailLbl: Label 'Rail', MaxLength = 100;
        AirContinentalEconomyTok: Label 'AIR-CONT-EC', MaxLength = 20;
        AirContinentalEconomyLbl: Label 'Air Continental - Economy Class /KM', MaxLength = 100;
        AirContinentalBusinessTok: Label 'AIR-CONT-BUS', MaxLength = 20;
        AirContinentalBusinessLbl: Label 'Air Continental - Business Class /KM', MaxLength = 100;
        AirIntercontinentalEconomyTok: Label 'AIR-INT-EC', MaxLength = 20;
        AirIntercontinentalEconomyLbl: Label 'Air Intercontinental - Economy Class /KM', MaxLength = 100;
        AirIntercontinentalPremiumEconomyTok: Label 'AIR-INT-PREM', MaxLength = 20;
        AirIntercontinentalPremiumEconomyLbl: Label 'Air Intercontinental - Premium Economy /KM', MaxLength = 100;
        AirIntercontinentalBusinessTok: Label 'AIR-INT-BUS', MaxLength = 20;
        AirIntercontinentalBusinessLbl: Label 'Air Intercontinental - Business Class /KM', MaxLength = 100;
        TractorTok: Label 'TRACTOR', MaxLength = 20;
        TractorLbl: Label 'Tractors /L', MaxLength = 100;
        ForkliftTok: Label 'FORKLIFT', MaxLength = 20;
        ForkliftLbl: Label 'Forklifts /L', MaxLength = 100;
        BackhoeTok: Label 'BACKHOE', MaxLength = 20;
        BackhoeLbl: Label 'Backhoes /L', MaxLength = 100;
        PurchasedGoodsPlasticTok: Label 'PURCHGDS-PL', MaxLength = 20;
        PurchasedGoodsPlasticLbl: Label 'Purchased Goods - Plastic', MaxLength = 100;
        PurchasedGoodsAluminumTok: Label 'PURCHGDS-AL', MaxLength = 20;
        PurchasedGoodsAluminumLbl: Label 'Purchased Goods - Aluminum', MaxLength = 100;
        PurchasedGoodsSteelTok: Label 'PURCHGDS-ST', MaxLength = 20;
        PurchasedGoodsSteelLbl: Label 'Purchased Goods - Steel', MaxLength = 100;
        PurchasedGoodsGlassTok: Label 'PURCHGDS-GL', MaxLength = 20;
        PurchasedGoodsGlassLbl: Label 'Purchased Goods - Glass', MaxLength = 100;
        PurchasedServicesTok: Label 'PURCHSERVC', MaxLength = 20;
        PurchasedServicesLbl: Label 'Purchased Services', MaxLength = 100;
        RentalCarMediumTok: Label 'RENTALCAR-M', MaxLength = 20;
        RentalCarMediumLbl: Label 'Contoso Rental Car - Medium Car', MaxLength = 100;
        SoldProductEndTok: Label 'SOLDPRODEND', MaxLength = 20;
        SoldProductEndLbl: Label 'End of Life Treatment of Sold Products', MaxLength = 100;
        SoldProductProcessTok: Label 'SOLDPRODPROC', MaxLength = 20;
        SoldProductProcessLbl: Label 'Processing of Sold Products', MaxLength = 100;
        SoldProductUseTok: Label 'SOLDPRODUSE', MaxLength = 20;
        SoldProductUseLbl: Label 'Use of Sold Products', MaxLength = 100;
        BoilerTok: Label 'BOILER', MaxLength = 20;
        BoilerLbl: Label 'Boilers', MaxLength = 100;
        HeaterSmallTok: Label 'HEATER12', MaxLength = 20;
        HeaterSmallLbl: Label 'Heaters 12kW', MaxLength = 100;
        HeaterMediumTok: Label 'HEATER24', MaxLength = 20;
        HeaterMediumLbl: Label 'Heaters 24kW', MaxLength = 100;
        HeaterLargeTok: Label 'HEATER36', MaxLength = 20;
        HeaterLargeLbl: Label 'Heaters 36kW', MaxLength = 100;
        ThermalTok: Label 'THERMAL', MaxLength = 20;
        ThermalLbl: Label 'Thermal', MaxLength = 100;
        ExternalTransportDistanceTok: Label 'TRANSP-EXT-DIST', MaxLength = 20;
        ExternalTransportDistanceLbl: Label 'External Transport /KM', MaxLength = 100;
        InternalTransportDistanceTok: Label 'TRANSP-INT-DIST', MaxLength = 20;
        InternalTransportDistanceLbl: Label 'Inrnal Transport /KM', MaxLength = 100;
        ElectricityNuclearTok: Label 'ELECTRIC-NUCL', MaxLength = 20;
        ElectricityNuclearLbl: Label 'Electricity supplier - nuclear', MaxLength = 100;
        ElectricityCoalTok: Label 'ELECTRIC-COAL', MaxLength = 20;
        ElectricityCoalLbl: Label 'Electricity supplier - coal', MaxLength = 100;
        ElectricityGreenTok: Label 'ELECTRIC-GREEN', MaxLength = 20;
        ElectricityGreenLbl: Label 'Electricity supplier - solar/wind', MaxLength = 100;
        HeatTok: Label 'HEAT', MaxLength = 20;
        HeatLbl: Label 'Heat suppliers', MaxLength = 100;
        SteamSupplierTok: Label 'STEAM', MaxLength = 20;
        SteamSupplierLbl: Label 'Steam suppliers', MaxLength = 100;
        WasteLandfillOrganicTok: Label 'WASTE-LFORG', MaxLength = 20;
        WasteLandfillOrganicLbl: Label 'Landfill Organic Waste', MaxLength = 100;
        WasteLandfillPlasticTok: Label 'WASTE-LFPLA', MaxLength = 20;
        WasteLandfillPlasticLbl: Label 'Landfill Plastic Waste', MaxLength = 100;
        WasteRecycledTok: Label 'WASTE-RC', MaxLength = 20;
        WasteRecycledLbl: Label 'Recycled Waste', MaxLength = 100;
        CreditTok: Label 'CREDIT', MaxLength = 20;
        CreditLbl: Label 'Carbon Credit', MaxLength = 100;
        WasteCompostableTok: Label 'WASTE COMP', MaxLength = 20;
        WasteCompostableLbl: Label 'Waste Compostable', MaxLength = 100;
        WasteFoodTok: Label 'WASTE FOOD', MaxLength = 20;
        WasteFoodLbl: Label 'Waste Food', MaxLength = 100;
        WastePlasticTok: Label 'WASTE PLAST', MaxLength = 20;
        WastePlasticLbl: Label 'Waste Plastic', MaxLength = 100;
        WasteRecyclableTok: Label 'WASTE RECYC', MaxLength = 20;
        WasteRecyclableLbl: Label 'Waste Recyclable', MaxLength = 100;
        WasteSteelTok: Label 'WASTE STEEL', MaxLength = 20;
        WasteSteelLbl: Label 'Waste Steel', MaxLength = 100;
        WasteWoodTok: Label 'WASTE WOOD', MaxLength = 20;
        WasteWoodLbl: Label 'Waste Wood', MaxLength = 100;
        WaterBlueTok: Label 'WATER BLUE', MaxLength = 20;
        WaterBlueLbl: Label 'Water Blue', MaxLength = 100;
        WaterGreenTok: Label 'WATER GREEN', MaxLength = 20;
        WaterGreenLbl: Label 'Water Green', MaxLength = 100;
        WaterGreyTok: Label 'WATER GREY', MaxLength = 20;
        WaterGreyLbl: Label 'Water Grey', MaxLength = 100;
        DischargedWaterTok: Label 'WAT-DISCH', MaxLength = 20;
        DischargedWaterLbl: Label 'Discharged Water', MaxLength = 100;
}
