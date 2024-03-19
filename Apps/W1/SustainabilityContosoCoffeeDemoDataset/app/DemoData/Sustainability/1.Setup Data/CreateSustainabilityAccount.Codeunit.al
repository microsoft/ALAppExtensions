codeunit 5215 "Create Sustainability Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SustainCategory: Codeunit "Create Sustainability Category";
        SustainSubcategory: Codeunit "Create Sustain. Subcategory";
        ContosoSustainability: Codeunit "Contoso Sustainability";
        SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
    begin
        ContosoSustainability.InsertSustainabilityAccount(GasEmissions(), GasEmissionsLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(Scope1(), Scope1BeginTotalLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(StationaryCombustion(), StationaryCombustionLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(Boilers(), BoilersLbl, SustainCategory.Stationary(), SustainSubcategory.Boiler(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(HeatersSmall(), HeatersSmallLbl, SustainCategory.Stationary(), SustainSubcategory.HeaterSmall(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(HeatersMedium(), HeatersMediumLbl, SustainCategory.Stationary(), SustainSubcategory.HeaterMedium(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(HeatersLarge(), HeatersLargeLbl, SustainCategory.Stationary(), SustainSubcategory.HeaterLarge(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(ThermalOxidizers(), ThermalOxidizersLbl, SustainCategory.Stationary(), SustainSubcategory.Thermal(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalStationaryCombustion(), TotalStationaryCombustionLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", StationaryCombustion() + '..' + TotalStationaryCombustion(), false);

        ContosoSustainability.InsertSustainabilityAccount(MobileCombustion(), MobileCombustionLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(OnRoadVehicleUrbanTrucks(), OnRoadVehiclesUrbanLbl, SustainCategory.MobileDistance(), SustainSubcategory.UrbanTruck(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(OnRoadVehiclesLongHaulTrucks(), OnRoadVehiclesLongHaulLbl, SustainCategory.MobileDistance(), SustainSubcategory.LongHaulTruck(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(OnRoadVehiclesBuses(), OnRoadVehiclesBusesLbl, SustainCategory.MobileDistance(), SustainSubcategory.Bus(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(NonRoadVehiclesTractors(), NonRoadVehiclesTractorsLbl, SustainCategory.MobileFuel(), SustainSubcategory.Tractor(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(NonRoadVehiclesForklifts(), NonRoadVehiclesForkliftsLbl, SustainCategory.MobileFuel(), SustainSubcategory.Forklift(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(NonRoadVehiclesBackhoes(), NonRoadVehiclesBackhoesLbl, SustainCategory.MobileFuel(), SustainSubcategory.Backhoe(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(Rail(), RailLbl, SustainCategory.MobileDistance(), SustainSubcategory.Rail(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirContinentalEconomy(), AirContinentalEconomyLbl, SustainCategory.MobileDistance(), SustainSubcategory.AirContinentalEconomy(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirContinentalBusiness(), AirContinentalBusinessLbl, SustainCategory.MobileDistance(), SustainSubcategory.AirContinentalBusiness(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirIntercontinentalEconomy(), AirIntercontinentalEconomyLbl, SustainCategory.MobileDistance(), SustainSubcategory.AirIntercontinentalEconomy(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirIntercontinentalPremiumEconomy(), AirIntercontinentalPremiumEconomyLbl, SustainCategory.MobileDistance(), SustainSubcategory.AirIntercontinentalPremiumEconomy(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirIntercontinentalBusiness(), AirIntercontinentalBusinessLbl, SustainCategory.MobileDistance(), SustainSubcategory.AirIntercontinentalBusiness(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalMobileCombustion(), TotalMobileCombustionLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", MobileCombustion() + '..' + TotalMobileCombustion(), false);

        ContosoSustainability.InsertSustainabilityAccount(FugitiveEmission(), FugitiveEmissionsLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(Refrigerators(), RefrigeratorsLbl, SustainCategory.Fugitive(), SustainSubcategory.Refrigerator(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirConditionEquipments24kW(), AirConditionEquipments24kWLbl, SustainCategory.Fugitive(), SustainSubcategory.AirConditionerSmall(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(AirConditionEquipments36kW(), AirConditionEquipments36kWLbl, SustainCategory.Fugitive(), SustainSubcategory.AirConditionerLarge(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalFugitiveEmissions(), TotalFugitiveEmissionsLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", FugitiveEmission() + '..' + TotalFugitiveEmissions(), false);

        ContosoSustainability.InsertSustainabilityAccount(TotalScope1(), TotalScope1DirectEmissionLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", Scope1() + '..' + TotalScope1(), false);

        ContosoSustainability.InsertSustainabilityAccount(Scope2(), Scope2BeginTotalLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(UpstreamActivityScope2(), UpstreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedElectricityContosoPowerPlant(), PurchasedElectricityContosoPowerPlantLbl, SustainCategory.UtilityElectric(), SustainSubcategory.ElectricityNuclear(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedElectricityWideWorldImporters(), PurchasedElectricityWideWorldImportersLbl, SustainCategory.UtilityElectric(), SustainSubcategory.ElectricityCoal(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedElectricityGreenTariffEnergy(), PurchasedElectricityGreenTariffEnergyLbl, SustainCategory.UtilityElectric(), SustainSubcategory.ElectricityGreen(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(SteamFabrikamInc(), SteamFabrikamIncLbl, SustainCategory.UtilitySteam(), SustainSubcategory.SteamSupplier(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(HeatingFabrikamInc(), HeatingFabrikamIncLbl, SustainCategory.UtilityHeat(), SustainSubcategory.Heat(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalUpStreamActivityScope2(), TotalUpStreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", UpstreamActivityScope2() + '..' + TotalUpStreamActivityScope2(), false);
        ContosoSustainability.InsertSustainabilityAccount(TotalScope2(), TotalScope2IndirectEmissionLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", Scope2() + '..' + TotalScope2(), false);

        ContosoSustainability.InsertSustainabilityAccount(Scope3(), Scope3BeginTotalLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(UpstreamActivityScope3(), UpstreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedGoodsPlastic(), PurchasedGoodsPlasticLbl, SustainCategory.PurchaseGoodsGL(), SustainSubcategory.PurchasedGoodsPlastic(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedGoodsAluminum(), PurchasedGoodsAluminumLbl, SustainCategory.PurchaseGoodsGL(), SustainSubcategory.PurchasedGoodsAluminum(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedGoodsSteel(), PurchasedGoodsSteelLbl, SustainCategory.PurchaseGoodsGL(), SustainSubcategory.PurchasedGoodsSteel(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedGoodsGlass(), PurchasedGoodsGlassLbl, SustainCategory.PurchaseGoodsGL(), SustainSubcategory.PurchasedGoodsGlass(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(PurchasedServices(), PurchasedServicesLbl, SustainCategory.PurchaseGoodsGL(), SustainSubcategory.PurchasedServices(), Enum::"Sustainability Account Type"::Posting, '', true);

        ContosoSustainability.InsertSustainabilityAccount(ExternalTransportation(), ExternalTransportationLbl, SustainCategory.ExternalTransportDistance(), SustainSubcategory.ExternalTransportDistance(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TransportationWithOwnTrucks(), TransportationWithOwnTrucksLbl, SustainCategory.InternalTransportDistance(), SustainSubcategory.InternalTransportDistance(), Enum::"Sustainability Account Type"::Posting, '', true);

        ContosoSustainability.InsertSustainabilityAccount(WastePlasticGeneratedInOperation(), WastePlasticGeneratedInOperationLbl, SustainCategory.Waste(), SustainSubcategory.WasteLandFillOrganic(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(WasteOrganicGeneratedInOperation(), WasteOrganicGeneratedInOperationLbl, SustainCategory.Waste(), SustainSubcategory.WasteLandFillPlastic(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(RecycledWasteGeneratedInOperation(), RecycledWasteGeneratedInOperationLbl, SustainCategory.Waste(), SustainSubcategory.WasteRecycled(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalUpstreamActivityScope3(), TotalUpstreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", UpstreamActivityScope3() + '..' + TotalUpstreamActivityScope3(), false);

        ContosoSustainability.InsertSustainabilityAccount(DownstreamActivityScope3(), DownStreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(ProcessingOfSoldProducts(), ProcessingOfSoldProductsLbl, SustainCategory.SoldProductProcess(), SustainSubcategory.SoldProductProcess(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(UseOfSoldProducts(), UseOfSoldProductsLbl, SustainCategory.SoldProductUse(), SustainSubcategory.SoldProductUse(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(EndOfLifeTreatmentOfSoldProducts(), EndOfLifeTreatmentOfSoldProductsLbl, SustainCategory.SoldProductEnd(), SustainSubcategory.SoldProductEnd(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(ExternalTransportationScope3(), ExternalTransportationLbl, SustainCategory.ExternalTransportDistance(), SustainSubcategory.ExternalTransportDistance(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TransportationWithOwnTrucksScope3(), TransportationWithOwnTrucksLbl, SustainCategory.InternalTransportDistance(), SustainSubcategory.InternalTransportDistance(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalDownstreamActivityScope3(), TotalDownstreamActivitiesLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", DownstreamActivityScope3() + '..' + TotalDownstreamActivityScope3(), false);

        ContosoSustainability.InsertSustainabilityAccount(BusinessTravelAndEmployeeCommuting(), BusinessTravelAndEmployeeCommutingLbl, '', '', Enum::"Sustainability Account Type"::"Begin-Total", '', false);
        ContosoSustainability.InsertSustainabilityAccount(ContosoHotel3Stars(), ContosoHotel3StarsLbl, SustainCategory.Hotel(), SustainSubcategory.Hotel3Star(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(ContosoHotel4Stars(), ContosoHotel4StarsLbl, SustainCategory.Hotel(), SustainSubcategory.Hotel4Star(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(ContosoHotel4StarsJuniorSuite(), ContosoHotel4StarsJuniorSuiteLbl, SustainCategory.Hotel(), SustainSubcategory.Hotel4StarPlus(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(ContosoRentalCar(), ContosoRentalCarLbl, SustainCategory.RentalCar(), SustainSubcategory.RentalCarMedium(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(CompanyCarMediumSize(), CompanyCarMediumSizeLbl, SustainCategory.CompanyCar(), SustainSubcategory.CompanyCarMedium(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(CompanyCarLargeSize(), CompanyCarLargeSizeLbl, SustainCategory.CompanyCar(), SustainSubcategory.CompanyCarLarge(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(CompanyCarPremiumSize(), CompanyCarPremiumSizeLbl, SustainCategory.CompanyCar(), SustainSubcategory.CompanyCarPremium(), Enum::"Sustainability Account Type"::Posting, '', true);
        ContosoSustainability.InsertSustainabilityAccount(TotalBusinessTravelAndEmployeeCommuting(), TotalBusinessTravelAndEmployeeCommutingLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", BusinessTravelAndEmployeeCommuting() + '..' + TotalBusinessTravelAndEmployeeCommuting(), false);
        ContosoSustainability.InsertSustainabilityAccount(TotalScope3(), TotalScope3IndirectEmissionLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", Scope3() + '..' + TotalScope3(), false);
        ContosoSustainability.InsertSustainabilityAccount(TotalGasEmissions(), TotalGasEmissionsLbl, '', '', Enum::"Sustainability Account Type"::"End-Total", GasEmissions() + '..' + TotalGasEmissions(), false);

        SustainabilityAccountMgt.IndentChartOfSustainabilityAccounts(true);
    end;

    procedure GasEmissions(): Code[20]
    begin
        exit('10000');
    end;

    procedure Scope1(): Code[20]
    begin
        exit('11000');
    end;

    procedure StationaryCombustion(): Code[20]
    begin
        exit('11100');
    end;

    procedure Boilers(): Code[20]
    begin
        exit('11101');
    end;

    procedure HeatersSmall(): Code[20]
    begin
        exit('11102');
    end;

    procedure HeatersMedium(): Code[20]
    begin
        exit('11103');
    end;

    procedure HeatersLarge(): Code[20]
    begin
        exit('11104');
    end;

    procedure ThermalOxidizers(): Code[20]
    begin
        exit('11105');
    end;

    procedure TotalStationaryCombustion(): Code[20]
    begin
        exit('11199');
    end;

    procedure MobileCombustion(): Code[20]
    begin
        exit('11200');
    end;

    procedure OnRoadVehicleUrbanTrucks(): Code[20]
    begin
        exit('11201');
    end;

    procedure OnRoadVehiclesLongHaulTrucks(): Code[20]
    begin
        exit('11202');
    end;

    procedure OnRoadVehiclesBuses(): Code[20]
    begin
        exit('11203');
    end;

    procedure NonRoadVehiclesTractors(): Code[20]
    begin
        exit('11204');
    end;

    procedure NonRoadVehiclesForklifts(): Code[20]
    begin
        exit('11205');
    end;

    procedure NonRoadVehiclesBackhoes(): Code[20]
    begin
        exit('11206');
    end;

    procedure Rail(): Code[20]
    begin
        exit('11207');
    end;

    procedure AirContinentalEconomy(): Code[20]
    begin
        exit('11210');
    end;

    procedure AirContinentalBusiness(): Code[20]
    begin
        exit('11211');
    end;

    procedure AirIntercontinentalEconomy(): Code[20]
    begin
        exit('11212');
    end;

    procedure AirIntercontinentalPremiumEconomy(): Code[20]
    begin
        exit('11213');
    end;

    procedure AirIntercontinentalBusiness(): Code[20]
    begin
        exit('11214');
    end;

    procedure TotalMobileCombustion(): Code[20]
    begin
        exit('11299');
    end;

    procedure FugitiveEmission(): Code[20]
    begin
        exit('11300');
    end;

    procedure Refrigerators(): Code[20]
    begin
        exit('11301');
    end;

    procedure AirConditionEquipments24kW(): Code[20]
    begin
        exit('11302');
    end;

    procedure AirConditionEquipments36kW(): Code[20]
    begin
        exit('11303');
    end;

    procedure TotalFugitiveEmissions(): Code[20]
    begin
        exit('11399');
    end;

    procedure TotalScope1(): Code[20]
    begin
        exit('11999');
    end;

    procedure Scope2(): Code[20]
    begin
        exit('12000');
    end;

    procedure UpstreamActivityScope2(): Code[20]
    begin
        exit('12100');
    end;

    procedure PurchasedElectricityContosoPowerPlant(): Code[20]
    begin
        exit('12101');
    end;

    procedure PurchasedElectricityWideWorldImporters(): Code[20]
    begin
        exit('12102');
    end;

    procedure PurchasedElectricityGreenTariffEnergy(): Code[20]
    begin
        exit('12103');
    end;

    procedure SteamFabrikamInc(): Code[20]
    begin
        exit('12104');
    end;

    procedure HeatingFabrikamInc(): Code[20]
    begin
        exit('12105');
    end;

    procedure TotalUpStreamActivityScope2(): Code[20]
    begin
        exit('12199');
    end;

    procedure TotalScope2(): Code[20]
    begin
        exit('12999');
    end;

    procedure Scope3(): Code[20]
    begin
        exit('13000');
    end;

    procedure UpstreamActivityScope3(): Code[20]
    begin
        exit('13100');
    end;

    procedure PurchasedGoodsPlastic(): Code[20]
    begin
        exit('13101');
    end;

    procedure PurchasedGoodsAluminum(): Code[20]
    begin
        exit('13102');
    end;

    procedure PurchasedGoodsSteel(): Code[20]
    begin
        exit('13103');
    end;

    procedure PurchasedGoodsGlass(): Code[20]
    begin
        exit('13104');
    end;

    procedure PurchasedServices(): Code[20]
    begin
        exit('13151');
    end;

    procedure ExternalTransportation(): Code[20]
    begin
        exit('13171');
    end;

    procedure TransportationWithOwnTrucks(): Code[20]
    begin
        exit('13172');
    end;

    procedure WastePlasticGeneratedInOperation(): Code[20]
    begin
        exit('13181');
    end;

    procedure WasteOrganicGeneratedInOperation(): Code[20]
    begin
        exit('13182');
    end;

    procedure RecycledWasteGeneratedInOperation(): Code[20]
    begin
        exit('13183');
    end;

    procedure TotalUpstreamActivityScope3(): Code[20]
    begin
        exit('13199');
    end;

    procedure DownstreamActivityScope3(): Code[20]
    begin
        exit('13200');
    end;

    procedure ProcessingOfSoldProducts(): Code[20]
    begin
        exit('13201');
    end;

    procedure UseOfSoldProducts(): Code[20]
    begin
        exit('13202');
    end;

    procedure EndOfLifeTreatmentOfSoldProducts(): Code[20]
    begin
        exit('13203');
    end;

    procedure ExternalTransportationScope3(): Code[20]
    begin
        exit('13211');
    end;

    procedure TransportationWithOwnTrucksScope3(): Code[20]
    begin
        exit('13212');
    end;

    procedure TotalDownstreamActivityScope3(): Code[20]
    begin
        exit('13299');
    end;

    procedure BusinessTravelAndEmployeeCommuting(): Code[20]
    begin
        exit('13300');
    end;

    procedure ContosoHotel3Stars(): Code[20]
    begin
        exit('13301');
    end;

    procedure ContosoHotel4Stars(): Code[20]
    begin
        exit('13302');
    end;

    procedure ContosoHotel4StarsJuniorSuite(): Code[20]
    begin
        exit('13303');
    end;

    procedure ContosoRentalCar(): Code[20]
    begin
        exit('13311');
    end;

    procedure CompanyCarMediumSize(): Code[20]
    begin
        exit('13321');
    end;

    procedure CompanyCarLargeSize(): Code[20]
    begin
        exit('13322');
    end;

    procedure CompanyCarPremiumSize(): Code[20]
    begin
        exit('13323');
    end;

    procedure TotalBusinessTravelAndEmployeeCommuting(): Code[20]
    begin
        exit('13399');
    end;

    procedure TotalScope3(): Code[20]
    begin
        exit('13999');
    end;

    procedure TotalGasEmissions(): Code[20]
    begin
        exit('19999');
    end;

    var
        GasEmissionsLbl: Label 'Gas Emissions', MaxLength = 100;
        Scope1BeginTotalLbl: Label 'Scope 1 - Direct Emission', MaxLength = 100;
        StationaryCombustionLbl: Label 'Stationary Combustion', MaxLength = 100;
        BoilersLbl: Label 'Boilers', MaxLength = 100;
        HeatersSmallLbl: Label 'Heaters 12kW', MaxLength = 100;
        HeatersMediumLbl: Label 'Heaters 24kW', MaxLength = 100;
        HeatersLargeLbl: Label 'Heaters 36kW', MaxLength = 100;
        ThermalOxidizersLbl: Label 'Thermal Oxidizers', MaxLength = 100;
        TotalStationaryCombustionLbl: Label 'Total, Stationary Combustion', MaxLength = 100;
        MobileCombustionLbl: Label 'Mobile Combustion', MaxLength = 100;
        OnRoadVehiclesUrbanLbl: Label 'OnRoad Vehicles (Trucks: urban)', MaxLength = 100;
        OnRoadVehiclesLongHaulLbl: Label 'OnRoad Vehicles (Trucks: long-haul trailer)', MaxLength = 100;
        OnRoadVehiclesBusesLbl: Label 'OnRoad Vehicles (Buses)', MaxLength = 100;
        NonRoadVehiclesTractorsLbl: Label 'NonRoad Vehicles (Tractors)', MaxLength = 100;
        NonRoadVehiclesForkliftsLbl: Label 'NonRoad Vehicles (Forklifts)', MaxLength = 100;
        NonRoadVehiclesBackhoesLbl: Label 'NonRoad Vehicles (Backhoes)', MaxLength = 100;
        RailLbl: Label 'Rail', MaxLength = 100;
        AirContinentalEconomyLbl: Label 'Air Continental - Economy Class', MaxLength = 100;
        AirContinentalBusinessLbl: Label 'Air Continental - Business Class', MaxLength = 100;
        AirIntercontinentalEconomyLbl: Label 'Air Intercontinental - Economy Class', MaxLength = 100;
        AirIntercontinentalPremiumEconomyLbl: Label 'Air Intercontinental - Premium Economy', MaxLength = 100;
        AirIntercontinentalBusinessLbl: Label 'Air Intercontinental - Business Class', MaxLength = 100;
        TotalMobileCombustionLbl: Label 'Total, Mobile Combustion', MaxLength = 100;
        FugitiveEmissionsLbl: Label 'Fugitive Emissions', MaxLength = 100;
        RefrigeratorsLbl: Label 'Refrigerators', MaxLength = 100;
        AirConditionEquipments24kWLbl: Label 'Air-Condition Equipments 24,000 BTU', MaxLength = 100;
        AirConditionEquipments36kWLbl: Label 'Air-Condition Equipments 36,000 BTU', MaxLength = 100;
        TotalFugitiveEmissionsLbl: Label 'Total, Fugitive Emissions', MaxLength = 100;
        TotalScope1DirectEmissionLbl: Label 'TOTAL SCOPE 1 - DIRECT EMISSION', MaxLength = 100;
        Scope2BeginTotalLbl: Label 'Scope 2 - Indirect Emission', MaxLength = 100;
        UpstreamActivitiesLbl: Label 'Upstream Activities', MaxLength = 100;
        PurchasedElectricityContosoPowerPlantLbl: Label 'Purchased electricity - Contoso PowerPlant', MaxLength = 100;
        PurchasedElectricityWideWorldImportersLbl: Label 'Purchased electricity - Wide World Importers', MaxLength = 100;
        PurchasedElectricityGreenTariffEnergyLbl: Label 'Purchased electricity - Green Tariff Energy', MaxLength = 100;
        SteamFabrikamIncLbl: Label 'Steam - Fabrikam, Inc.', MaxLength = 100;
        HeatingFabrikamIncLbl: Label 'Heating - Fabrikam, Inc.', MaxLength = 100;
        TotalScope2IndirectEmissionLbl: Label 'TOTAL SCOPE 2 - INDIRECT EMISSION', MaxLength = 100;
        Scope3BeginTotalLbl: Label 'Scope 3 - Indirect Emission', MaxLength = 100;
        PurchasedGoodsPlasticLbl: Label 'Purchased Goods - Plastic', MaxLength = 100;
        PurchasedGoodsAluminumLbl: Label 'Purchased Goods - Aluminum', MaxLength = 100;
        PurchasedGoodsSteelLbl: Label 'Purchased Goods - Steel', MaxLength = 100;
        PurchasedGoodsGlassLbl: Label 'Purchased Goods - Glass', MaxLength = 100;
        PurchasedServicesLbl: Label 'Purchased Services', MaxLength = 100;
        ExternalTransportationLbl: Label 'External Transportation', MaxLength = 100;
        TransportationWithOwnTrucksLbl: Label 'Transportation with Own Trucks', MaxLength = 100;
        WastePlasticGeneratedInOperationLbl: Label 'Waste (plastic) Generated in Operation', MaxLength = 100;
        WasteOrganicGeneratedInOperationLbl: Label 'Waste (organic) Generated in Operation', MaxLength = 100;
        RecycledWasteGeneratedInOperationLbl: Label 'Recycled Waste Generated in Operation', MaxLength = 100;
        TotalUpstreamActivitiesLbl: Label 'Total, Upstream Activities', MaxLength = 100;
        DownStreamActivitiesLbl: Label 'DownStream Activities', MaxLength = 100;
        ProcessingOfSoldProductsLbl: Label 'Processing of Sold Products', MaxLength = 100;
        UseOfSoldProductsLbl: Label 'Use of Sold Products', MaxLength = 100;
        EndOfLifeTreatmentOfSoldProductsLbl: Label 'End of Life Treatment of Sold Products', MaxLength = 100;
        TotalDownstreamActivitiesLbl: Label 'Total, Downstream Activities', MaxLength = 100;
        BusinessTravelAndEmployeeCommutingLbl: Label 'Business Travel and Employee Commuting', MaxLength = 100;
        ContosoHotel3StarsLbl: Label 'Contoso Hotel - 3 stars', MaxLength = 100;
        ContosoHotel4StarsLbl: Label 'Contoso Hotel - 4 stars', MaxLength = 100;
        ContosoHotel4StarsJuniorSuiteLbl: Label 'Contoso Hotel - 4 stars Junior Suite', MaxLength = 100;
        ContosoRentalCarLbl: Label 'Contoso Rental Car', MaxLength = 100;
        CompanyCarMediumSizeLbl: Label 'Company Car - Medium size', MaxLength = 100;
        CompanyCarLargeSizeLbl: Label 'Company Car - Large size', MaxLength = 100;
        CompanyCarPremiumSizeLbl: Label 'Company Car - Premium size', MaxLength = 100;
        TotalBusinessTravelAndEmployeeCommutingLbl: Label 'Total, Business Travel and Employee Commuting', MaxLength = 100;
        TotalScope3IndirectEmissionLbl: Label 'TOTAL SCOPE 3 - INDIRECT EMISSION', MaxLength = 100;
        TotalGasEmissionsLbl: Label 'TOTAL GAS EMISSIONS', MaxLength = 100;
}