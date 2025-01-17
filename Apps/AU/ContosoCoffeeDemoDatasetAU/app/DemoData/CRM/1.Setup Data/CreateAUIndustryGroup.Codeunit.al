codeunit 17127 "Create AU Industry Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.SetOverwriteData(true);
        ContosoCRM.InsertIndustryGroup(A1(), AgricultureLbl);
        ContosoCRM.InsertIndustryGroup(A11(), HorticultureAndFruitGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A111(), PlantNurseriesLbl);
        ContosoCRM.InsertIndustryGroup(A113(), VegetableGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A114(), GrapeGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A115(), AppleAndPearGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A116(), StoneFruitGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A117(), KiwiFruitGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A119(), FruitGrowingNecLbl);
        ContosoCRM.InsertIndustryGroup(A121(), GrainGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A123(), SheepBeefCattleFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A124(), SheepFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A125(), BeefCattleFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A13(), DairyCattleFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A130(), DairyCattleFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A14(), PoultryFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A141(), PoultryFarmingMeatLbl);
        ContosoCRM.InsertIndustryGroup(A142(), PoultryFarmingEggsLbl);
        ContosoCRM.InsertIndustryGroup(A15(), OtherLivestockFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A151(), PigFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A152(), HorseFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A153(), DeerFarmingLbl);
        ContosoCRM.InsertIndustryGroup(A159(), LivestockFarmingNecLbl);
        ContosoCRM.InsertIndustryGroup(A16(), OtherCropGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A161(), SugarCaneGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A162(), CottonGrowingLbl);
        ContosoCRM.InsertIndustryGroup(A169(), CropAndPlantGrowingNecLbl);
        ContosoCRM.InsertIndustryGroup(A21(), ServicesToAgricultureLbl);
        ContosoCRM.InsertIndustryGroup(A211(), CottonGinningLbl);
        ContosoCRM.InsertIndustryGroup(A212(), ShearingServicesLbl);
        ContosoCRM.InsertIndustryGroup(A213(), AerialAgriculturalServicesLbl);
        ContosoCRM.InsertIndustryGroup(A219(), ServicesToAgricultureNecLbl);
        ContosoCRM.InsertIndustryGroup(A22(), HuntingAndTrappingLbl);
        ContosoCRM.InsertIndustryGroup(A220(), HuntingAndTrappingLbl);
        ContosoCRM.InsertIndustryGroup(A3(), ForestryAndLoggingLbl);
        ContosoCRM.InsertIndustryGroup(A30(), ForestryAndLoggingLbl);
        ContosoCRM.InsertIndustryGroup(A301(), ForestryLbl);
        ContosoCRM.InsertIndustryGroup(A302(), LoggingLbl);
        ContosoCRM.InsertIndustryGroup(A303(), ServicesToForestryLbl);
        ContosoCRM.InsertIndustryGroup(A4(), CommercialFishingLbl);
        ContosoCRM.InsertIndustryGroup(A41(), MarineFishingLbl);
        ContosoCRM.InsertIndustryGroup(A411(), RockLobsterFishingLbl);
        ContosoCRM.InsertIndustryGroup(A412(), PrawnFishingLbl);
        ContosoCRM.InsertIndustryGroup(A413(), FinfishTrawlingLbl);
        ContosoCRM.InsertIndustryGroup(A414(), SquidJiggingLbl);
        ContosoCRM.InsertIndustryGroup(A415(), LineFishingLbl);
        ContosoCRM.InsertIndustryGroup(A419(), MarineFishingNecLbl);
        ContosoCRM.InsertIndustryGroup(A42(), AquacultureLbl);
        ContosoCRM.InsertIndustryGroup(A420(), AquacultureLbl);
        ContosoCRM.InsertIndustryGroup(B(), MiningLbl);
        ContosoCRM.InsertIndustryGroup(B11(), CoalMiningLbl);
        ContosoCRM.InsertIndustryGroup(B110(), CoalMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1101(), BlackCoalMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1102(), BrownCoalMiningLbl);
        ContosoCRM.InsertIndustryGroup(B12(), OilAndGasExtractionLbl);
        ContosoCRM.InsertIndustryGroup(B120(), OilAndGasExtractionLbl);
        ContosoCRM.InsertIndustryGroup(B1200(), OilAndGasExtractionLbl);
        ContosoCRM.InsertIndustryGroup(B13(), MetalOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B131(), MetalOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1311(), IronOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1312(), BauxiteMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1313(), CopperOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1314(), GoldOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1315(), MineralSandMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1316(), NickelOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1317(), SilverLeadZincOreMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1319(), MetalOreMiningNecLbl);
        ContosoCRM.InsertIndustryGroup(B14(), OtherMiningLbl);
        ContosoCRM.InsertIndustryGroup(B141(), ConstructionMaterialMiningLbl);
        ContosoCRM.InsertIndustryGroup(B1411(), GravelAndSandQuarryingLbl);
        ContosoCRM.InsertIndustryGroup(B142(), MiningNecLbl);
        ContosoCRM.InsertIndustryGroup(B1420(), MiningNecLbl);
        ContosoCRM.InsertIndustryGroup(B15(), ServicesToMiningLbl);
        ContosoCRM.InsertIndustryGroup(B151(), ExplorationLbl);
        ContosoCRM.InsertIndustryGroup(B1512(), PetroleumExplorationServicesLbl);
        ContosoCRM.InsertIndustryGroup(B1514(), MineralExplorationServicesLbl);
        ContosoCRM.InsertIndustryGroup(B152(), OtherMiningServicesLbl);
        ContosoCRM.InsertIndustryGroup(B1520(), OtherMiningServicesLbl);
        ContosoCRM.InsertIndustryGroup(C(), ManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C21(), FoodBeverageAndTobaccoLbl);
        ContosoCRM.InsertIndustryGroup(C2111(), MeatProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C2112(), PoultryProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C212(), DairyProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2121(), MilkAndCreamProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C2122(), IceCreamManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C213(), FruitAndVegetableProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C2130(), FruitAndVegetableProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C214(), OilAndFatManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2140(), OilAndFatManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C216(), BakeryProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2161(), BreadManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2162(), CakeAndPastryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2163(), BiscuitManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C217(), OtherFoodManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2171(), SugarManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2172(), ConfectioneryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2173(), SeafoodProcessingLbl);
        ContosoCRM.InsertIndustryGroup(C2179(), FoodManufacturingNecLbl);
        ContosoCRM.InsertIndustryGroup(C2182(), BeerAndMaltManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2183(), WineManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2184(), SpiritManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C219(), TobaccoProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2190(), TobaccoProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2211(), WoolScouringLbl);
        ContosoCRM.InsertIndustryGroup(C2213(), CottonTextileManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2214(), WoolTextileManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2215(), TextileFinishingLbl);
        ContosoCRM.InsertIndustryGroup(C222(), TextileProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C223(), KnittingMillsLbl);
        ContosoCRM.InsertIndustryGroup(C2231(), HosieryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C224(), ClothingManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2249(), ClothingManufacturingNecLbl);
        ContosoCRM.InsertIndustryGroup(C225(), FootwearManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2250(), FootwearManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2311(), LogSawmillingLbl);
        ContosoCRM.InsertIndustryGroup(C2312(), WoodChippingLbl);
        ContosoCRM.InsertIndustryGroup(C2313(), TimberResawingAndDressingLbl);
        ContosoCRM.InsertIndustryGroup(C2322(), FabricatedWoodManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2329(), WoodProductManufacturingNecLbl);
        ContosoCRM.InsertIndustryGroup(C2411(), PaperStationeryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2412(), PrintingLbl);
        ContosoCRM.InsertIndustryGroup(C2413(), ServicesToPrintingLbl);
        ContosoCRM.InsertIndustryGroup(C242(), PublishingLbl);
        ContosoCRM.InsertIndustryGroup(C2422(), OtherPeriodicalPublishingLbl);
        ContosoCRM.InsertIndustryGroup(C2423(), BookAndOtherPublishingLbl);
        ContosoCRM.InsertIndustryGroup(C251(), PetroleumRefiningLbl);
        ContosoCRM.InsertIndustryGroup(C2510(), PetroleumRefiningLbl);
        ContosoCRM.InsertIndustryGroup(C253(), BasicChemicalManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2531(), FertiliserManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2532(), IndustrialGasManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2533(), SyntheticResinManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2541(), ExplosiveManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2542(), PaintManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2544(), PesticideManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2547(), InkManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C255(), RubberProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2551(), RubberTyreManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C256(), PlasticProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C262(), CeramicManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2621(), ClayBrickManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2622(), CeramicProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2631(), CementAndLimeManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2632(), PlasterProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2633(), ConcreteSlurryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C27(), MetalProductManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C271(), IronAndSteelManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2721(), AluminaProductionLbl);
        ContosoCRM.InsertIndustryGroup(C2722(), AluminiumSmeltingLbl);
        ContosoCRM.InsertIndustryGroup(C2733(), NonFerrousMetalCastingLbl);
        ContosoCRM.InsertIndustryGroup(C2741(), StructuralSteelFabricatingLbl);
        ContosoCRM.InsertIndustryGroup(C2751(), MetalContainerManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2764(), MetalCoatingAndFinishingLbl);
        ContosoCRM.InsertIndustryGroup(C2811(), MotorVehicleManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2821(), ShipbuildingLbl);
        ContosoCRM.InsertIndustryGroup(C2822(), BoatbuildingLbl);
        ContosoCRM.InsertIndustryGroup(C2824(), AircraftManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2853(), BatteryManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C29(), OtherManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C292(), FurnitureManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2929(), FurnitureManufacturingNecLbl);
        ContosoCRM.InsertIndustryGroup(C294(), OtherManufacturingLbl);
        ContosoCRM.InsertIndustryGroup(C2949(), ManufacturingNecLbl);
        ContosoCRM.InsertIndustryGroup(D36(), ElectricityAndGasSupplyLbl);
        ContosoCRM.InsertIndustryGroup(D361(), ElectricitySupplyLbl);
        ContosoCRM.InsertIndustryGroup(D3610(), ElectricitySupplyLbl);
        ContosoCRM.InsertIndustryGroup(D362(), GasSupplyLbl);
        ContosoCRM.InsertIndustryGroup(D3620(), GasSupplyLbl);
        ContosoCRM.InsertIndustryGroup(D3701(), WaterSupplyLbl);
        ContosoCRM.InsertIndustryGroup(D3702(), SewerageAndDrainageServicesLbl);
        ContosoCRM.InsertIndustryGroup(E(), ConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E41(), GeneralConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E411(), BuildingConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E4111(), HouseConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E412(), NonBuildingConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E4121(), RoadAndBridgeConstructionLbl);
        ContosoCRM.InsertIndustryGroup(E4122(), NonBuildingConstructionNecLbl);
        ContosoCRM.InsertIndustryGroup(E42(), ConstructionTradeServicesLbl);
        ContosoCRM.InsertIndustryGroup(E421(), SitePreparationServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4210(), SitePreparationServicesLbl);
        ContosoCRM.InsertIndustryGroup(E422(), BuildingStructureServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4221(), ConcretingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4222(), BricklayingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4223(), RoofingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E423(), InstallationTradeServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4231(), PlumbingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4232(), ElectricalServicesLbl);
        ContosoCRM.InsertIndustryGroup(E424(), BuildingCompletionServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4242(), CarpentryServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4243(), TilingAndCarpetingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4245(), GlazingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E425(), OtherConstructionServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4251(), LandscapingServicesLbl);
        ContosoCRM.InsertIndustryGroup(E4259(), ConstructionServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(F(), WholesaleTradeLbl);
        ContosoCRM.InsertIndustryGroup(F45(), BasicMaterialWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F451(), FarmProduceWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4511(), WoolWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4512(), CerealGrainWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4521(), PetroleumProductWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4522(), MetalAndMineralWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4523(), ChemicalWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F453(), BuildersSuppliesWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4531(), TimberWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4613(), ComputerWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F462(), MotorVehicleWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4621(), CarWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4622(), CommercialVehicleWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4623(), MotorVehicleNewPartDealingLbl);
        ContosoCRM.InsertIndustryGroup(F4711(), MeatWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4713(), DairyProduceWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4714(), FishWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4717(), LiquorWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4718(), TobaccoProductWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4719(), GroceryWholesalingNecLbl);
        ContosoCRM.InsertIndustryGroup(F4721(), TextileProductWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4722(), ClothingWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4723(), FootwearWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F473(), HouseholdGoodWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4732(), FurnitureWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4733(), FloorCoveringWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4739(), HouseholdGoodWholesalingNecLbl);
        ContosoCRM.InsertIndustryGroup(F479(), OtherWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4794(), BookAndMagazineWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4795(), PaperProductWholesalingLbl);
        ContosoCRM.InsertIndustryGroup(F4799(), WholesalingNecLbl);
        ContosoCRM.InsertIndustryGroup(G(), RetailTradeLbl);
        ContosoCRM.InsertIndustryGroup(G51(), FoodRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G511(), SupermarketAndGroceryStoresLbl);
        ContosoCRM.InsertIndustryGroup(G5110(), SupermarketAndGroceryStoresLbl);
        ContosoCRM.InsertIndustryGroup(G512(), SpecialisedFoodRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5122(), FruitAndVegetableRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5123(), LiquorRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5124(), BreadAndCakeRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5125(), TakeawayFoodRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5126(), MilkVendingLbl);
        ContosoCRM.InsertIndustryGroup(G5129(), SpecialisedFoodRetailingNecLbl);
        ContosoCRM.InsertIndustryGroup(G521(), DepartmentStoresLbl);
        ContosoCRM.InsertIndustryGroup(G5210(), DepartmentStoresLbl);
        ContosoCRM.InsertIndustryGroup(G5221(), ClothingRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5222(), FootwearRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5231(), FurnitureRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5232(), FloorCoveringRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5234(), DomesticApplianceRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5235(), RecordedMusicRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G524(), RecreationalGoodRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5242(), ToyAndGameRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5245(), MarineEquipmentRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5253(), GardenSuppliesRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5254(), FlowerRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5255(), WatchAndJewelleryRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5259(), RetailingNecLbl);
        ContosoCRM.InsertIndustryGroup(G531(), MotorVehicleRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5311(), CarRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5312(), MotorCycleDealingLbl);
        ContosoCRM.InsertIndustryGroup(G5313(), TrailerAndCaravanDealingLbl);
        ContosoCRM.InsertIndustryGroup(G532(), MotorVehicleServicesLbl);
        ContosoCRM.InsertIndustryGroup(G5321(), AutomotiveFuelRetailingLbl);
        ContosoCRM.InsertIndustryGroup(G5322(), AutomotiveElectricalServicesLbl);
        ContosoCRM.InsertIndustryGroup(G5323(), SmashRepairingLbl);
        ContosoCRM.InsertIndustryGroup(G5324(), TyreRetailingLbl);
        ContosoCRM.InsertIndustryGroup(H571(), AccommodationLbl);
        ContosoCRM.InsertIndustryGroup(H5710(), AccommodationLbl);
        ContosoCRM.InsertIndustryGroup(H572(), PubsTavernsAndBarsLbl);
        ContosoCRM.InsertIndustryGroup(H5720(), PubsTavernsAndBarsLbl);
        ContosoCRM.InsertIndustryGroup(H573(), CafesAndRestaurantsLbl);
        ContosoCRM.InsertIndustryGroup(H5730(), CafesAndRestaurantsLbl);
        ContosoCRM.InsertIndustryGroup(H574(), ClubsHospitalityLbl);
        ContosoCRM.InsertIndustryGroup(H5740(), ClubsHospitalityLbl);
        ContosoCRM.InsertIndustryGroup(I(), TransportAndStorageLbl);
        ContosoCRM.InsertIndustryGroup(I61(), RoadTransportLbl);
        ContosoCRM.InsertIndustryGroup(I611(), RoadFreightTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6110(), RoadFreightTransportLbl);
        ContosoCRM.InsertIndustryGroup(I612(), RoadPassengerTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6121(), LongDistanceBusTransportLbl);
        ContosoCRM.InsertIndustryGroup(I62(), RailTransportLbl);
        ContosoCRM.InsertIndustryGroup(I620(), RailTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6200(), RailTransportLbl);
        ContosoCRM.InsertIndustryGroup(I63(), WaterTransportLbl);
        ContosoCRM.InsertIndustryGroup(I630(), WaterTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6301(), InternationalSeaTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6302(), CoastalWaterTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6303(), InlandWaterTransportLbl);
        ContosoCRM.InsertIndustryGroup(I64(), AirAndSpaceTransportLbl);
        ContosoCRM.InsertIndustryGroup(I640(), AirAndSpaceTransportLbl);
        ContosoCRM.InsertIndustryGroup(I65(), OtherTransportLbl);
        ContosoCRM.InsertIndustryGroup(I650(), OtherTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6501(), PipelineTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6509(), TransportNecLbl);
        ContosoCRM.InsertIndustryGroup(I66(), ServicesToTransportLbl);
        ContosoCRM.InsertIndustryGroup(I661(), ServicesToRoadTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6611(), ParkingServicesLbl);
        ContosoCRM.InsertIndustryGroup(I6619(), ServicesToRoadTransportNecLbl);
        ContosoCRM.InsertIndustryGroup(I662(), ServicesToWaterTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6621(), StevedoringLbl);
        ContosoCRM.InsertIndustryGroup(I6622(), WaterTransportTerminalsLbl);
        ContosoCRM.InsertIndustryGroup(I6623(), PortOperatorsLbl);
        ContosoCRM.InsertIndustryGroup(I663(), ServicesToAirTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6630(), ServicesToAirTransportLbl);
        ContosoCRM.InsertIndustryGroup(I664(), OtherServicesToTransportLbl);
        ContosoCRM.InsertIndustryGroup(I6641(), TravelAgencyServicesLbl);
        ContosoCRM.InsertIndustryGroup(I6642(), RoadFreightForwardingLbl);
        ContosoCRM.InsertIndustryGroup(I6644(), CustomsAgencyServicesLbl);
        ContosoCRM.InsertIndustryGroup(I6649(), ServicesToTransportNecLbl);
        ContosoCRM.InsertIndustryGroup(I67(), StorageLbl);
        ContosoCRM.InsertIndustryGroup(I670(), StorageLbl);
        ContosoCRM.InsertIndustryGroup(I6701(), GrainStorageLbl);
        ContosoCRM.InsertIndustryGroup(I6709(), StorageNecLbl);
        ContosoCRM.InsertIndustryGroup(J(), CommunicationServicesLbl);
        ContosoCRM.InsertIndustryGroup(J71(), CommunicationServicesLbl);
        ContosoCRM.InsertIndustryGroup(J711(), PostalAndCourierServicesLbl);
        ContosoCRM.InsertIndustryGroup(J7111(), PostalServicesLbl);
        ContosoCRM.InsertIndustryGroup(J7112(), CourierServicesLbl);
        ContosoCRM.InsertIndustryGroup(J712(), TelecommunicationServicesLbl);
        ContosoCRM.InsertIndustryGroup(J7120(), TelecommunicationServicesLbl);
        ContosoCRM.InsertIndustryGroup(K(), FinanceAndInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K73(), FinanceLbl);
        ContosoCRM.InsertIndustryGroup(K731(), CentralBankLbl);
        ContosoCRM.InsertIndustryGroup(K7310(), CentralBankLbl);
        ContosoCRM.InsertIndustryGroup(K732(), DepositTakingFinanciersLbl);
        ContosoCRM.InsertIndustryGroup(K7321(), BanksLbl);
        ContosoCRM.InsertIndustryGroup(K7322(), BuildingSocietiesLbl);
        ContosoCRM.InsertIndustryGroup(K7323(), CreditUnionsLbl);
        ContosoCRM.InsertIndustryGroup(K7324(), MoneyMarketDealersLbl);
        ContosoCRM.InsertIndustryGroup(K7329(), DepositTakingFinanciersNecLbl);
        ContosoCRM.InsertIndustryGroup(K733(), OtherFinanciersLbl);
        ContosoCRM.InsertIndustryGroup(K7330(), OtherFinanciersLbl);
        ContosoCRM.InsertIndustryGroup(K734(), FinancialAssetInvestorsLbl);
        ContosoCRM.InsertIndustryGroup(K7340(), FinancialAssetInvestorsLbl);
        ContosoCRM.InsertIndustryGroup(K74(), InsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K7411(), LifeInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K7412(), SuperannuationFundsLbl);
        ContosoCRM.InsertIndustryGroup(K742(), OtherInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K7421(), HealthInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K7422(), GeneralInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K752(), ServicesToInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(K7520(), ServicesToInsuranceLbl);
        ContosoCRM.InsertIndustryGroup(L(), PropertyAndBusinessServicesLbl);
        ContosoCRM.InsertIndustryGroup(L77(), PropertyServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7711(), ResidentialPropertyOperatorsLbl);
        ContosoCRM.InsertIndustryGroup(L772(), RealEstateAgentsLbl);
        ContosoCRM.InsertIndustryGroup(L7720(), RealEstateAgentsLbl);
        ContosoCRM.InsertIndustryGroup(L773(), NonFinancialAssetInvestorsLbl);
        ContosoCRM.InsertIndustryGroup(L7730(), NonFinancialAssetInvestorsLbl);
        ContosoCRM.InsertIndustryGroup(L7741(), MotorVehicleHiringLbl);
        ContosoCRM.InsertIndustryGroup(L7743(), PlantHiringOrLeasingLbl);
        ContosoCRM.InsertIndustryGroup(L78(), BusinessServicesLbl);
        ContosoCRM.InsertIndustryGroup(L781(), ScientificResearchLbl);
        ContosoCRM.InsertIndustryGroup(L7810(), ScientificResearchLbl);
        ContosoCRM.InsertIndustryGroup(L782(), TechnicalServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7821(), ArchitecturalServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7822(), SurveyingServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7829(), TechnicalServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(L783(), ComputerServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7831(), DataProcessingServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7833(), ComputerMaintenanceServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7834(), ComputerConsultancyServicesLbl);
        ContosoCRM.InsertIndustryGroup(L784(), LegalAndAccountingServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7841(), LegalServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7842(), AccountingServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7851(), AdvertisingServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7853(), MarketResearchServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7855(), BusinessManagementServicesLbl);
        ContosoCRM.InsertIndustryGroup(L786(), OtherBusinessServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7861(), EmploymentPlacementServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7862(), ContractStaffServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7863(), SecretarialServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7865(), PestControlServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7866(), CleaningServicesLbl);
        ContosoCRM.InsertIndustryGroup(L7867(), ContractPackingServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(L7869(), BusinessServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(M81(), GovernmentAdministrationLbl);
        ContosoCRM.InsertIndustryGroup(M811(), GovernmentAdministrationLbl);
        ContosoCRM.InsertIndustryGroup(M812(), JusticeLbl);
        ContosoCRM.InsertIndustryGroup(M8120(), JusticeLbl);
        ContosoCRM.InsertIndustryGroup(M82(), DefenceLbl);
        ContosoCRM.InsertIndustryGroup(M820(), DefenceLbl);
        ContosoCRM.InsertIndustryGroup(M8200(), DefenceLbl);
        ContosoCRM.InsertIndustryGroup(N(), EducationLbl);
        ContosoCRM.InsertIndustryGroup(N84(), EducationLbl);
        ContosoCRM.InsertIndustryGroup(N841(), PreschoolEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8410(), PreschoolEducationLbl);
        ContosoCRM.InsertIndustryGroup(N842(), SchoolEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8421(), PrimaryEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8422(), SecondaryEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8424(), SpecialSchoolEducationLbl);
        ContosoCRM.InsertIndustryGroup(N843(), PostSchoolEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8431(), HigherEducationLbl);
        ContosoCRM.InsertIndustryGroup(N844(), OtherEducationLbl);
        ContosoCRM.InsertIndustryGroup(N8440(), OtherEducationLbl);
        ContosoCRM.InsertIndustryGroup(O(), HealthAndCommunityServicesLbl);
        ContosoCRM.InsertIndustryGroup(O86(), HealthServicesLbl);
        ContosoCRM.InsertIndustryGroup(O861(), HospitalsAndNursingHomesLbl);
        ContosoCRM.InsertIndustryGroup(O8612(), PsychiatricHospitalsLbl);
        ContosoCRM.InsertIndustryGroup(O8613(), NursingHomesLbl);
        ContosoCRM.InsertIndustryGroup(O862(), MedicalAndDentalServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8622(), SpecialistMedicalServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8623(), DentalServicesLbl);
        ContosoCRM.InsertIndustryGroup(O863(), OtherHealthServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8631(), PathologyServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8633(), AmbulanceServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8634(), CommunityHealthCentresLbl);
        ContosoCRM.InsertIndustryGroup(O8635(), PhysiotherapyServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8636(), ChiropracticServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8639(), HealthServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(O864(), VeterinaryServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8640(), VeterinaryServicesLbl);
        ContosoCRM.InsertIndustryGroup(O87(), CommunityServicesLbl);
        ContosoCRM.InsertIndustryGroup(O871(), ChildCareServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8710(), ChildCareServicesLbl);
        ContosoCRM.InsertIndustryGroup(O872(), CommunityCareServicesLbl);
        ContosoCRM.InsertIndustryGroup(O8721(), AccommodationForTheAgedLbl);
        ContosoCRM.InsertIndustryGroup(O8722(), ResidentialCareServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(P911(), FilmAndVideoServicesLbl);
        ContosoCRM.InsertIndustryGroup(P9111(), FilmAndVideoProductionLbl);
        ContosoCRM.InsertIndustryGroup(P9112(), FilmAndVideoDistributionLbl);
        ContosoCRM.InsertIndustryGroup(P9113(), MotionPictureExhibitionLbl);
        ContosoCRM.InsertIndustryGroup(P912(), RadioAndTelevisionServicesLbl);
        ContosoCRM.InsertIndustryGroup(P9121(), RadioServicesLbl);
        ContosoCRM.InsertIndustryGroup(P9122(), TelevisionServicesLbl);
        ContosoCRM.InsertIndustryGroup(P921(), LibrariesLbl);
        ContosoCRM.InsertIndustryGroup(P9210(), LibrariesLbl);
        ContosoCRM.InsertIndustryGroup(P922(), MuseumsLbl);
        ContosoCRM.InsertIndustryGroup(P9220(), MuseumsLbl);
        ContosoCRM.InsertIndustryGroup(P923(), ParksAndGardensLbl);
        ContosoCRM.InsertIndustryGroup(P9231(), ZoologicalAndBotanicGardensLbl);
        ContosoCRM.InsertIndustryGroup(P9239(), RecreationalParksAndGardensLbl);
        ContosoCRM.InsertIndustryGroup(P924(), ArtsLbl);
        ContosoCRM.InsertIndustryGroup(P9241(), MusicAndTheatreProductionsLbl);
        ContosoCRM.InsertIndustryGroup(P9242(), CreativeArtsLbl);
        ContosoCRM.InsertIndustryGroup(P925(), ServicesToTheArtsLbl);
        ContosoCRM.InsertIndustryGroup(P9251(), SoundRecordingStudiosLbl);
        ContosoCRM.InsertIndustryGroup(P9252(), PerformingArtsVenuesLbl);
        ContosoCRM.InsertIndustryGroup(P9259(), ServicesToTheArtsNecLbl);
        ContosoCRM.InsertIndustryGroup(P93(), SportAndRecreationLbl);
        ContosoCRM.InsertIndustryGroup(P931(), SportLbl);
        ContosoCRM.InsertIndustryGroup(P9311(), HorseAndDogRacingLbl);
        ContosoCRM.InsertIndustryGroup(P932(), GamblingServicesLbl);
        ContosoCRM.InsertIndustryGroup(P9321(), LotteriesLbl);
        ContosoCRM.InsertIndustryGroup(P9322(), CasinosLbl);
        ContosoCRM.InsertIndustryGroup(P9329(), GamblingServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(P933(), OtherRecreationServicesLbl);
        ContosoCRM.InsertIndustryGroup(P9330(), OtherRecreationServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q(), PersonalAndOtherServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q95(), PersonalServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q9511(), VideoHireOutletsLbl);
        ContosoCRM.InsertIndustryGroup(Q952(), OtherPersonalServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q9521(), LaundriesAndDryCleanersLbl);
        ContosoCRM.InsertIndustryGroup(Q9522(), PhotographicFilmProcessingLbl);
        ContosoCRM.InsertIndustryGroup(Q9523(), PhotographicStudiosLbl);
        ContosoCRM.InsertIndustryGroup(Q9525(), GardeningServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q9526(), HairdressingAndBeautySalonsLbl);
        ContosoCRM.InsertIndustryGroup(Q9529(), PersonalServicesNecLbl);
        ContosoCRM.InsertIndustryGroup(Q96(), OtherServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q961(), ReligiousOrganisationsLbl);
        ContosoCRM.InsertIndustryGroup(Q9610(), ReligiousOrganisationsLbl);
        ContosoCRM.InsertIndustryGroup(Q962(), InterestGroupsLbl);
        ContosoCRM.InsertIndustryGroup(Q9622(), LabourAssociationsLbl);
        ContosoCRM.InsertIndustryGroup(Q9629(), InterestGroupsNecLbl);
        ContosoCRM.InsertIndustryGroup(Q9631(), PoliceServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q9632(), CorrectiveCentresLbl);
        ContosoCRM.InsertIndustryGroup(Q9633(), FireBrigadeServicesLbl);
        ContosoCRM.InsertIndustryGroup(Q9634(), WasteDisposalServicesLbl);
        ContosoCRM.SetOverwriteData(false);
    end;

    procedure A1(): Code[10]
    begin
        exit(A1Tok);
    end;

    procedure A11(): Code[10]
    begin
        exit(A11Tok);
    end;

    procedure A111(): Code[10]
    begin
        exit(A111Tok);
    end;

    procedure A113(): Code[10]
    begin
        exit(A113Tok);
    end;

    procedure A114(): Code[10]
    begin
        exit(A114Tok);
    end;

    procedure A115(): Code[10]
    begin
        exit(A115Tok);
    end;

    procedure A116(): Code[10]
    begin
        exit(A116Tok);
    end;

    procedure A117(): Code[10]
    begin
        exit(A117Tok);
    end;

    procedure A119(): Code[10]
    begin
        exit(A119Tok);
    end;

    procedure A121(): Code[10]
    begin
        exit(A121Tok);
    end;

    procedure A123(): Code[10]
    begin
        exit(A123Tok);
    end;

    procedure A124(): Code[10]
    begin
        exit(A124Tok);
    end;

    procedure A125(): Code[10]
    begin
        exit(A125Tok);
    end;

    procedure A13(): Code[10]
    begin
        exit(A13Tok);
    end;

    procedure A130(): Code[10]
    begin
        exit(A130Tok);
    end;

    procedure A14(): Code[10]
    begin
        exit(A14Tok);
    end;

    procedure A141(): Code[10]
    begin
        exit(A141Tok);
    end;

    procedure A142(): Code[10]
    begin
        exit(A142Tok);
    end;

    procedure A15(): Code[10]
    begin
        exit(A15Tok);
    end;

    procedure A151(): Code[10]
    begin
        exit(A151Tok);
    end;

    procedure A152(): Code[10]
    begin
        exit(A152Tok);
    end;

    procedure A153(): Code[10]
    begin
        exit(A153Tok);
    end;

    procedure A159(): Code[10]
    begin
        exit(A159Tok);
    end;

    procedure A16(): Code[10]
    begin
        exit(A16Tok);
    end;

    procedure A161(): Code[10]
    begin
        exit(A161Tok);
    end;

    procedure A162(): Code[10]
    begin
        exit(A162Tok);
    end;

    procedure A169(): Code[10]
    begin
        exit(A169Tok);
    end;

    procedure A21(): Code[10]
    begin
        exit(A21Tok);
    end;

    procedure A211(): Code[10]
    begin
        exit(A211Tok);
    end;

    procedure A212(): Code[10]
    begin
        exit(A212Tok);
    end;

    procedure A213(): Code[10]
    begin
        exit(A213Tok);
    end;

    procedure A219(): Code[10]
    begin
        exit(A219Tok);
    end;

    procedure A22(): Code[10]
    begin
        exit(A22Tok);
    end;

    procedure A220(): Code[10]
    begin
        exit(A220Tok);
    end;

    procedure A3(): Code[10]
    begin
        exit(A3Tok);
    end;

    procedure A30(): Code[10]
    begin
        exit(A30Tok);
    end;

    procedure A301(): Code[10]
    begin
        exit(A301Tok);
    end;

    procedure A302(): Code[10]
    begin
        exit(A302Tok);
    end;

    procedure A303(): Code[10]
    begin
        exit(A303Tok);
    end;

    procedure A4(): Code[10]
    begin
        exit(A4Tok);
    end;

    procedure A41(): Code[10]
    begin
        exit(A41Tok);
    end;

    procedure A411(): Code[10]
    begin
        exit(A411Tok);
    end;

    procedure A412(): Code[10]
    begin
        exit(A412Tok);
    end;

    procedure A413(): Code[10]
    begin
        exit(A413Tok);
    end;

    procedure A414(): Code[10]
    begin
        exit(A414Tok);
    end;

    procedure A415(): Code[10]
    begin
        exit(A415Tok);
    end;

    procedure A419(): Code[10]
    begin
        exit(A419Tok);
    end;

    procedure A42(): Code[10]
    begin
        exit(A42Tok);
    end;

    procedure A420(): Code[10]
    begin
        exit(A420Tok);
    end;

    procedure B(): Code[10]
    begin
        exit(BTok);
    end;

    procedure B11(): Code[10]
    begin
        exit(B11Tok);
    end;

    procedure B110(): Code[10]
    begin
        exit(B110Tok);
    end;

    procedure B1101(): Code[10]
    begin
        exit(B1101Tok);
    end;

    procedure B1102(): Code[10]
    begin
        exit(B1102Tok);
    end;

    procedure B12(): Code[10]
    begin
        exit(B12Tok);
    end;

    procedure B120(): Code[10]
    begin
        exit(B120Tok);
    end;

    procedure B1200(): Code[10]
    begin
        exit(B1200Tok);
    end;

    procedure B13(): Code[10]
    begin
        exit(B13Tok);
    end;

    procedure B131(): Code[10]
    begin
        exit(B131Tok);
    end;

    procedure B1311(): Code[10]
    begin
        exit(B1311Tok);
    end;

    procedure B1312(): Code[10]
    begin
        exit(B1312Tok);
    end;

    procedure B1313(): Code[10]
    begin
        exit(B1313Tok);
    end;

    procedure B1314(): Code[10]
    begin
        exit(B1314Tok);
    end;

    procedure B1315(): Code[10]
    begin
        exit(B1315Tok);
    end;

    procedure B1316(): Code[10]
    begin
        exit(B1316Tok);
    end;

    procedure B1317(): Code[10]
    begin
        exit(B1317Tok);
    end;

    procedure B1319(): Code[10]
    begin
        exit(B1319Tok);
    end;

    procedure B14(): Code[10]
    begin
        exit(B14Tok);
    end;

    procedure B141(): Code[10]
    begin
        exit(B141Tok);
    end;

    procedure B1411(): Code[10]
    begin
        exit(B1411Tok);
    end;

    procedure B142(): Code[10]
    begin
        exit(B142Tok);
    end;

    procedure B1420(): Code[10]
    begin
        exit(B1420Tok);
    end;

    procedure B15(): Code[10]
    begin
        exit(B15Tok);
    end;

    procedure B151(): Code[10]
    begin
        exit(B151Tok);
    end;

    procedure B1512(): Code[10]
    begin
        exit(B1512Tok);
    end;

    procedure B1514(): Code[10]
    begin
        exit(B1514Tok);
    end;

    procedure B152(): Code[10]
    begin
        exit(B152Tok);
    end;

    procedure B1520(): Code[10]
    begin
        exit(B1520Tok);
    end;

    procedure C(): Code[10]
    begin
        exit(CTok);
    end;

    procedure C21(): Code[10]
    begin
        exit(C21Tok);
    end;

    procedure C2111(): Code[10]
    begin
        exit(C2111Tok);
    end;

    procedure C2112(): Code[10]
    begin
        exit(C2112Tok);
    end;

    procedure C212(): Code[10]
    begin
        exit(C212Tok);
    end;

    procedure C2121(): Code[10]
    begin
        exit(C2121Tok);
    end;

    procedure C2122(): Code[10]
    begin
        exit(C2122Tok);
    end;

    procedure C213(): Code[10]
    begin
        exit(C213Tok);
    end;

    procedure C2130(): Code[10]
    begin
        exit(C2130Tok);
    end;

    procedure C214(): Code[10]
    begin
        exit(C214Tok);
    end;

    procedure C2140(): Code[10]
    begin
        exit(C2140Tok);
    end;

    procedure C216(): Code[10]
    begin
        exit(C216Tok);
    end;

    procedure C2161(): Code[10]
    begin
        exit(C2161Tok);
    end;

    procedure C2162(): Code[10]
    begin
        exit(C2162Tok);
    end;

    procedure C2163(): Code[10]
    begin
        exit(C2163Tok);
    end;

    procedure C217(): Code[10]
    begin
        exit(C217Tok);
    end;

    procedure C2171(): Code[10]
    begin
        exit(C2171Tok);
    end;

    procedure C2172(): Code[10]
    begin
        exit(C2172Tok);
    end;

    procedure C2173(): Code[10]
    begin
        exit(C2173Tok);
    end;

    procedure C2179(): Code[10]
    begin
        exit(C2179Tok);
    end;

    procedure C2182(): Code[10]
    begin
        exit(C2182Tok);
    end;

    procedure C2183(): Code[10]
    begin
        exit(C2183Tok);
    end;

    procedure C2184(): Code[10]
    begin
        exit(C2184Tok);
    end;

    procedure C219(): Code[10]
    begin
        exit(C219Tok);
    end;

    procedure C2190(): Code[10]
    begin
        exit(C2190Tok);
    end;

    procedure C2211(): Code[10]
    begin
        exit(C2211Tok);
    end;

    procedure C2213(): Code[10]
    begin
        exit(C2213Tok);
    end;

    procedure C2214(): Code[10]
    begin
        exit(C2214Tok);
    end;

    procedure C2215(): Code[10]
    begin
        exit(C2215Tok);
    end;

    procedure C222(): Code[10]
    begin
        exit(C222Tok);
    end;

    procedure C223(): Code[10]
    begin
        exit(C223Tok);
    end;

    procedure C2231(): Code[10]
    begin
        exit(C2231Tok);
    end;

    procedure C224(): Code[10]
    begin
        exit(C224Tok);
    end;

    procedure C2249(): Code[10]
    begin
        exit(C2249Tok);
    end;

    procedure C225(): Code[10]
    begin
        exit(C225Tok);
    end;

    procedure C2250(): Code[10]
    begin
        exit(C2250Tok);
    end;

    procedure C2311(): Code[10]
    begin
        exit(C2311Tok);
    end;

    procedure C2312(): Code[10]
    begin
        exit(C2312Tok);
    end;

    procedure C2313(): Code[10]
    begin
        exit(C2313Tok);
    end;

    procedure C2322(): Code[10]
    begin
        exit(C2322Tok);
    end;

    procedure C2329(): Code[10]
    begin
        exit(C2329Tok);
    end;

    procedure C2411(): Code[10]
    begin
        exit(C2411Tok);
    end;

    procedure C2412(): Code[10]
    begin
        exit(C2412Tok);
    end;

    procedure C2413(): Code[10]
    begin
        exit(C2413Tok);
    end;

    procedure C242(): Code[10]
    begin
        exit(C242Tok);
    end;

    procedure C2422(): Code[10]
    begin
        exit(C2422Tok);
    end;

    procedure C2423(): Code[10]
    begin
        exit(C2423Tok);
    end;

    procedure C251(): Code[10]
    begin
        exit(C251Tok);
    end;

    procedure C2510(): Code[10]
    begin
        exit(C2510Tok);
    end;

    procedure C253(): Code[10]
    begin
        exit(C253Tok);
    end;

    procedure C2531(): Code[10]
    begin
        exit(C2531Tok);
    end;

    procedure C2532(): Code[10]
    begin
        exit(C2532Tok);
    end;

    procedure C2533(): Code[10]
    begin
        exit(C2533Tok);
    end;

    procedure C2541(): Code[10]
    begin
        exit(C2541Tok);
    end;

    procedure C2542(): Code[10]
    begin
        exit(C2542Tok);
    end;

    procedure C2544(): Code[10]
    begin
        exit(C2544Tok);
    end;

    procedure C2547(): Code[10]
    begin
        exit(C2547Tok);
    end;

    procedure C255(): Code[10]
    begin
        exit(C255Tok);
    end;

    procedure C2551(): Code[10]
    begin
        exit(C2551Tok);
    end;

    procedure C256(): Code[10]
    begin
        exit(C256Tok);
    end;

    procedure C262(): Code[10]
    begin
        exit(C262Tok);
    end;

    procedure C2621(): Code[10]
    begin
        exit(C2621Tok);
    end;

    procedure C2622(): Code[10]
    begin
        exit(C2622Tok);
    end;

    procedure C2631(): Code[10]
    begin
        exit(C2631Tok);
    end;

    procedure C2632(): Code[10]
    begin
        exit(C2632Tok);
    end;

    procedure C2633(): Code[10]
    begin
        exit(C2633Tok);
    end;

    procedure C27(): Code[10]
    begin
        exit(C27Tok);
    end;

    procedure C271(): Code[10]
    begin
        exit(C271Tok);
    end;

    procedure C2721(): Code[10]
    begin
        exit(C2721Tok);
    end;

    procedure C2722(): Code[10]
    begin
        exit(C2722Tok);
    end;

    procedure C2733(): Code[10]
    begin
        exit(C2733Tok);
    end;

    procedure C2741(): Code[10]
    begin
        exit(C2741Tok);
    end;

    procedure C2751(): Code[10]
    begin
        exit(C2751Tok);
    end;

    procedure C2764(): Code[10]
    begin
        exit(C2764Tok);
    end;

    procedure C2811(): Code[10]
    begin
        exit(C2811Tok);
    end;

    procedure C2821(): Code[10]
    begin
        exit(C2821Tok);
    end;

    procedure C2822(): Code[10]
    begin
        exit(C2822Tok);
    end;

    procedure C2824(): Code[10]
    begin
        exit(C2824Tok);
    end;

    procedure C2853(): Code[10]
    begin
        exit(C2853Tok);
    end;

    procedure C29(): Code[10]
    begin
        exit(C29Tok);
    end;

    procedure C292(): Code[10]
    begin
        exit(C292Tok);
    end;

    procedure C2929(): Code[10]
    begin
        exit(C2929Tok);
    end;

    procedure C294(): Code[10]
    begin
        exit(C294Tok);
    end;

    procedure C2949(): Code[10]
    begin
        exit(C2949Tok);
    end;

    procedure D36(): Code[10]
    begin
        exit(D36Tok);
    end;

    procedure D361(): Code[10]
    begin
        exit(D361Tok);
    end;

    procedure D3610(): Code[10]
    begin
        exit(D3610Tok);
    end;

    procedure D362(): Code[10]
    begin
        exit(D362Tok);
    end;

    procedure D3620(): Code[10]
    begin
        exit(D3620Tok);
    end;

    procedure D3701(): Code[10]
    begin
        exit(D3701Tok);
    end;

    procedure D3702(): Code[10]
    begin
        exit(D3702Tok);
    end;

    procedure E(): Code[10]
    begin
        exit(ETok);
    end;

    procedure E41(): Code[10]
    begin
        exit(E41Tok);
    end;

    procedure E411(): Code[10]
    begin
        exit(E411Tok);
    end;

    procedure E4111(): Code[10]
    begin
        exit(E4111Tok);
    end;

    procedure E412(): Code[10]
    begin
        exit(E412Tok);
    end;

    procedure E4121(): Code[10]
    begin
        exit(E4121Tok);
    end;

    procedure E4122(): Code[10]
    begin
        exit(E4122Tok);
    end;

    procedure E42(): Code[10]
    begin
        exit(E42Tok);
    end;

    procedure E421(): Code[10]
    begin
        exit(E421Tok);
    end;

    procedure E4210(): Code[10]
    begin
        exit(E4210Tok);
    end;

    procedure E422(): Code[10]
    begin
        exit(E422Tok);
    end;

    procedure E4221(): Code[10]
    begin
        exit(E4221Tok);
    end;

    procedure E4222(): Code[10]
    begin
        exit(E4222Tok);
    end;

    procedure E4223(): Code[10]
    begin
        exit(E4223Tok);
    end;

    procedure E423(): Code[10]
    begin
        exit(E423Tok);
    end;

    procedure E4231(): Code[10]
    begin
        exit(E4231Tok);
    end;

    procedure E4232(): Code[10]
    begin
        exit(E4232Tok);
    end;

    procedure E424(): Code[10]
    begin
        exit(E424Tok);
    end;

    procedure E4242(): Code[10]
    begin
        exit(E4242Tok);
    end;

    procedure E4243(): Code[10]
    begin
        exit(E4243Tok);
    end;

    procedure E4245(): Code[10]
    begin
        exit(E4245Tok);
    end;

    procedure E425(): Code[10]
    begin
        exit(E425Tok);
    end;

    procedure E4251(): Code[10]
    begin
        exit(E4251Tok);
    end;

    procedure E4259(): Code[10]
    begin
        exit(E4259Tok);
    end;

    procedure F(): Code[10]
    begin
        exit(FTok);
    end;

    procedure F45(): Code[10]
    begin
        exit(F45Tok);
    end;

    procedure F451(): Code[10]
    begin
        exit(F451Tok);
    end;

    procedure F4511(): Code[10]
    begin
        exit(F4511Tok);
    end;

    procedure F4512(): Code[10]
    begin
        exit(F4512Tok);
    end;

    procedure F4521(): Code[10]
    begin
        exit(F4521Tok);
    end;

    procedure F4522(): Code[10]
    begin
        exit(F4522Tok);
    end;

    procedure F4523(): Code[10]
    begin
        exit(F4523Tok);
    end;

    procedure F453(): Code[10]
    begin
        exit(F453Tok);
    end;

    procedure F4531(): Code[10]
    begin
        exit(F4531Tok);
    end;

    procedure F4613(): Code[10]
    begin
        exit(F4613Tok);
    end;

    procedure F462(): Code[10]
    begin
        exit(F462Tok);
    end;

    procedure F4621(): Code[10]
    begin
        exit(F4621Tok);
    end;

    procedure F4622(): Code[10]
    begin
        exit(F4622Tok);
    end;

    procedure F4623(): Code[10]
    begin
        exit(F4623Tok);
    end;

    procedure F4711(): Code[10]
    begin
        exit(F4711Tok);
    end;

    procedure F4713(): Code[10]
    begin
        exit(F4713Tok);
    end;

    procedure F4714(): Code[10]
    begin
        exit(F4714Tok);
    end;

    procedure F4717(): Code[10]
    begin
        exit(F4717Tok);
    end;

    procedure F4718(): Code[10]
    begin
        exit(F4718Tok);
    end;

    procedure F4719(): Code[10]
    begin
        exit(F4719Tok);
    end;

    procedure F4721(): Code[10]
    begin
        exit(F4721Tok);
    end;

    procedure F4722(): Code[10]
    begin
        exit(F4722Tok);
    end;

    procedure F4723(): Code[10]
    begin
        exit(F4723Tok);
    end;

    procedure F473(): Code[10]
    begin
        exit(F473Tok);
    end;

    procedure F4732(): Code[10]
    begin
        exit(F4732Tok);
    end;

    procedure F4733(): Code[10]
    begin
        exit(F4733Tok);
    end;

    procedure F4739(): Code[10]
    begin
        exit(F4739Tok);
    end;

    procedure F479(): Code[10]
    begin
        exit(F479Tok);
    end;

    procedure F4794(): Code[10]
    begin
        exit(F4794Tok);
    end;

    procedure F4795(): Code[10]
    begin
        exit(F4795Tok);
    end;

    procedure F4799(): Code[10]
    begin
        exit(F4799Tok);
    end;

    procedure G(): Code[10]
    begin
        exit(GTok);
    end;

    procedure G51(): Code[10]
    begin
        exit(G51Tok);
    end;

    procedure G511(): Code[10]
    begin
        exit(G511Tok);
    end;

    procedure G5110(): Code[10]
    begin
        exit(G5110Tok);
    end;

    procedure G512(): Code[10]
    begin
        exit(G512Tok);
    end;

    procedure G5122(): Code[10]
    begin
        exit(G5122Tok);
    end;

    procedure G5123(): Code[10]
    begin
        exit(G5123Tok);
    end;

    procedure G5124(): Code[10]
    begin
        exit(G5124Tok);
    end;

    procedure G5125(): Code[10]
    begin
        exit(G5125Tok);
    end;

    procedure G5126(): Code[10]
    begin
        exit(G5126Tok);
    end;

    procedure G5129(): Code[10]
    begin
        exit(G5129Tok);
    end;

    procedure G521(): Code[10]
    begin
        exit(G521Tok);
    end;

    procedure G5210(): Code[10]
    begin
        exit(G5210Tok);
    end;

    procedure G5221(): Code[10]
    begin
        exit(G5221Tok);
    end;

    procedure G5222(): Code[10]
    begin
        exit(G5222Tok);
    end;

    procedure G5231(): Code[10]
    begin
        exit(G5231Tok);
    end;

    procedure G5232(): Code[10]
    begin
        exit(G5232Tok);
    end;

    procedure G5234(): Code[10]
    begin
        exit(G5234Tok);
    end;

    procedure G5235(): Code[10]
    begin
        exit(G5235Tok);
    end;

    procedure G524(): Code[10]
    begin
        exit(G524Tok);
    end;

    procedure G5242(): Code[10]
    begin
        exit(G5242Tok);
    end;

    procedure G5245(): Code[10]
    begin
        exit(G5245Tok);
    end;

    procedure G5253(): Code[10]
    begin
        exit(G5253Tok);
    end;

    procedure G5254(): Code[10]
    begin
        exit(G5254Tok);
    end;

    procedure G5255(): Code[10]
    begin
        exit(G5255Tok);
    end;

    procedure G5259(): Code[10]
    begin
        exit(G5259Tok);
    end;

    procedure G531(): Code[10]
    begin
        exit(G531Tok);
    end;

    procedure G5311(): Code[10]
    begin
        exit(G5311Tok);
    end;

    procedure G5312(): Code[10]
    begin
        exit(G5312Tok);
    end;

    procedure G5313(): Code[10]
    begin
        exit(G5313Tok);
    end;

    procedure G532(): Code[10]
    begin
        exit(G532Tok);
    end;

    procedure G5321(): Code[10]
    begin
        exit(G5321Tok);
    end;

    procedure G5322(): Code[10]
    begin
        exit(G5322Tok);
    end;

    procedure G5323(): Code[10]
    begin
        exit(G5323Tok);
    end;

    procedure G5324(): Code[10]
    begin
        exit(G5324Tok);
    end;

    procedure H571(): Code[10]
    begin
        exit(H571Tok);
    end;

    procedure H5710(): Code[10]
    begin
        exit(H5710Tok);
    end;

    procedure H572(): Code[10]
    begin
        exit(H572Tok);
    end;

    procedure H5720(): Code[10]
    begin
        exit(H5720Tok);
    end;

    procedure H573(): Code[10]
    begin
        exit(H573Tok);
    end;

    procedure H5730(): Code[10]
    begin
        exit(H5730Tok);
    end;

    procedure H574(): Code[10]
    begin
        exit(H574Tok);
    end;

    procedure H5740(): Code[10]
    begin
        exit(H5740Tok);
    end;

    procedure I(): Code[10]
    begin
        exit(ITok);
    end;

    procedure I61(): Code[10]
    begin
        exit(I61Tok);
    end;

    procedure I611(): Code[10]
    begin
        exit(I611Tok);
    end;

    procedure I6110(): Code[10]
    begin
        exit(I6110Tok);
    end;

    procedure I612(): Code[10]
    begin
        exit(I612Tok);
    end;

    procedure I6121(): Code[10]
    begin
        exit(I6121Tok);
    end;

    procedure I62(): Code[10]
    begin
        exit(I62Tok);
    end;

    procedure I620(): Code[10]
    begin
        exit(I620Tok);
    end;

    procedure I6200(): Code[10]
    begin
        exit(I6200Tok);
    end;

    procedure I63(): Code[10]
    begin
        exit(I63Tok);
    end;

    procedure I630(): Code[10]
    begin
        exit(I630Tok);
    end;

    procedure I6301(): Code[10]
    begin
        exit(I6301Tok);
    end;

    procedure I6302(): Code[10]
    begin
        exit(I6302Tok);
    end;

    procedure I6303(): Code[10]
    begin
        exit(I6303Tok);
    end;

    procedure I64(): Code[10]
    begin
        exit(I64Tok);
    end;

    procedure I640(): Code[10]
    begin
        exit(I640Tok);
    end;

    procedure I65(): Code[10]
    begin
        exit(I65Tok);
    end;

    procedure I650(): Code[10]
    begin
        exit(I650Tok);
    end;

    procedure I6501(): Code[10]
    begin
        exit(I6501Tok);
    end;

    procedure I6509(): Code[10]
    begin
        exit(I6509Tok);
    end;

    procedure I66(): Code[10]
    begin
        exit(I66Tok);
    end;

    procedure I661(): Code[10]
    begin
        exit(I661Tok);
    end;

    procedure I6611(): Code[10]
    begin
        exit(I6611Tok);
    end;

    procedure I6619(): Code[10]
    begin
        exit(I6619Tok);
    end;

    procedure I662(): Code[10]
    begin
        exit(I662Tok);
    end;

    procedure I6621(): Code[10]
    begin
        exit(I6621Tok);
    end;

    procedure I6622(): Code[10]
    begin
        exit(I6622Tok);
    end;

    procedure I6623(): Code[10]
    begin
        exit(I6623Tok);
    end;

    procedure I663(): Code[10]
    begin
        exit(I663Tok);
    end;

    procedure I6630(): Code[10]
    begin
        exit(I6630Tok);
    end;

    procedure I664(): Code[10]
    begin
        exit(I664Tok);
    end;

    procedure I6641(): Code[10]
    begin
        exit(I6641Tok);
    end;

    procedure I6642(): Code[10]
    begin
        exit(I6642Tok);
    end;

    procedure I6644(): Code[10]
    begin
        exit(I6644Tok);
    end;

    procedure I6649(): Code[10]
    begin
        exit(I6649Tok);
    end;

    procedure I67(): Code[10]
    begin
        exit(I67Tok);
    end;

    procedure I670(): Code[10]
    begin
        exit(I670Tok);
    end;

    procedure I6701(): Code[10]
    begin
        exit(I6701Tok);
    end;

    procedure I6709(): Code[10]
    begin
        exit(I6709Tok);
    end;

    procedure J(): Code[10]
    begin
        exit(JTok);
    end;

    procedure J71(): Code[10]
    begin
        exit(J71Tok);
    end;

    procedure J711(): Code[10]
    begin
        exit(J711Tok);
    end;

    procedure J7111(): Code[10]
    begin
        exit(J7111Tok);
    end;

    procedure J7112(): Code[10]
    begin
        exit(J7112Tok);
    end;

    procedure J712(): Code[10]
    begin
        exit(J712Tok);
    end;

    procedure J7120(): Code[10]
    begin
        exit(J7120Tok);
    end;

    procedure K(): Code[10]
    begin
        exit(KTok);
    end;

    procedure K73(): Code[10]
    begin
        exit(K73Tok);
    end;

    procedure K731(): Code[10]
    begin
        exit(K731Tok);
    end;

    procedure K7310(): Code[10]
    begin
        exit(K7310Tok);
    end;

    procedure K732(): Code[10]
    begin
        exit(K732Tok);
    end;

    procedure K7321(): Code[10]
    begin
        exit(K7321Tok);
    end;

    procedure K7322(): Code[10]
    begin
        exit(K7322Tok);
    end;

    procedure K7323(): Code[10]
    begin
        exit(K7323Tok);
    end;

    procedure K7324(): Code[10]
    begin
        exit(K7324Tok);
    end;

    procedure K7329(): Code[10]
    begin
        exit(K7329Tok);
    end;

    procedure K733(): Code[10]
    begin
        exit(K733Tok);
    end;

    procedure K7330(): Code[10]
    begin
        exit(K7330Tok);
    end;

    procedure K734(): Code[10]
    begin
        exit(K734Tok);
    end;

    procedure K7340(): Code[10]
    begin
        exit(K7340Tok);
    end;

    procedure K74(): Code[10]
    begin
        exit(K74Tok);
    end;

    procedure K7411(): Code[10]
    begin
        exit(K7411Tok);
    end;

    procedure K7412(): Code[10]
    begin
        exit(K7412Tok);
    end;

    procedure K742(): Code[10]
    begin
        exit(K742Tok);
    end;

    procedure K7421(): Code[10]
    begin
        exit(K7421Tok);
    end;

    procedure K7422(): Code[10]
    begin
        exit(K7422Tok);
    end;

    procedure K752(): Code[10]
    begin
        exit(K752Tok);
    end;

    procedure K7520(): Code[10]
    begin
        exit(K7520Tok);
    end;

    procedure L(): Code[10]
    begin
        exit(LTok);
    end;

    procedure L77(): Code[10]
    begin
        exit(L77Tok);
    end;

    procedure L7711(): Code[10]
    begin
        exit(L7711Tok);
    end;

    procedure L772(): Code[10]
    begin
        exit(L772Tok);
    end;

    procedure L7720(): Code[10]
    begin
        exit(L7720Tok);
    end;

    procedure L773(): Code[10]
    begin
        exit(L773Tok);
    end;

    procedure L7730(): Code[10]
    begin
        exit(L7730Tok);
    end;

    procedure L7741(): Code[10]
    begin
        exit(L7741Tok);
    end;

    procedure L7743(): Code[10]
    begin
        exit(L7743Tok);
    end;

    procedure L78(): Code[10]
    begin
        exit(L78Tok);
    end;

    procedure L781(): Code[10]
    begin
        exit(L781Tok);
    end;

    procedure L7810(): Code[10]
    begin
        exit(L7810Tok);
    end;

    procedure L782(): Code[10]
    begin
        exit(L782Tok);
    end;

    procedure L7821(): Code[10]
    begin
        exit(L7821Tok);
    end;

    procedure L7822(): Code[10]
    begin
        exit(L7822Tok);
    end;

    procedure L7829(): Code[10]
    begin
        exit(L7829Tok);
    end;

    procedure L783(): Code[10]
    begin
        exit(L783Tok);
    end;

    procedure L7831(): Code[10]
    begin
        exit(L7831Tok);
    end;

    procedure L7833(): Code[10]
    begin
        exit(L7833Tok);
    end;

    procedure L7834(): Code[10]
    begin
        exit(L7834Tok);
    end;

    procedure L784(): Code[10]
    begin
        exit(L784Tok);
    end;

    procedure L7841(): Code[10]
    begin
        exit(L7841Tok);
    end;

    procedure L7842(): Code[10]
    begin
        exit(L7842Tok);
    end;

    procedure L7851(): Code[10]
    begin
        exit(L7851Tok);
    end;

    procedure L7853(): Code[10]
    begin
        exit(L7853Tok);
    end;

    procedure L7855(): Code[10]
    begin
        exit(L7855Tok);
    end;

    procedure L786(): Code[10]
    begin
        exit(L786Tok);
    end;

    procedure L7861(): Code[10]
    begin
        exit(L7861Tok);
    end;

    procedure L7862(): Code[10]
    begin
        exit(L7862Tok);
    end;

    procedure L7863(): Code[10]
    begin
        exit(L7863Tok);
    end;

    procedure L7865(): Code[10]
    begin
        exit(L7865Tok);
    end;

    procedure L7866(): Code[10]
    begin
        exit(L7866Tok);
    end;

    procedure L7867(): Code[10]
    begin
        exit(L7867Tok);
    end;

    procedure L7869(): Code[10]
    begin
        exit(L7869Tok);
    end;

    procedure M81(): Code[10]
    begin
        exit(M81Tok);
    end;

    procedure M811(): Code[10]
    begin
        exit(M811Tok);
    end;

    procedure M812(): Code[10]
    begin
        exit(M812Tok);
    end;

    procedure M8120(): Code[10]
    begin
        exit(M8120Tok);
    end;

    procedure M82(): Code[10]
    begin
        exit(M82Tok);
    end;

    procedure M820(): Code[10]
    begin
        exit(M820Tok);
    end;

    procedure M8200(): Code[10]
    begin
        exit(M8200Tok);
    end;

    procedure N(): Code[10]
    begin
        exit(NTok);
    end;

    procedure N84(): Code[10]
    begin
        exit(N84Tok);
    end;

    procedure N841(): Code[10]
    begin
        exit(N841Tok);
    end;

    procedure N8410(): Code[10]
    begin
        exit(N8410Tok);
    end;

    procedure N842(): Code[10]
    begin
        exit(N842Tok);
    end;

    procedure N8421(): Code[10]
    begin
        exit(N8421Tok);
    end;

    procedure N8422(): Code[10]
    begin
        exit(N8422Tok);
    end;

    procedure N8424(): Code[10]
    begin
        exit(N8424Tok);
    end;

    procedure N843(): Code[10]
    begin
        exit(N843Tok);
    end;

    procedure N8431(): Code[10]
    begin
        exit(N8431Tok);
    end;

    procedure N844(): Code[10]
    begin
        exit(N844Tok);
    end;

    procedure N8440(): Code[10]
    begin
        exit(N8440Tok);
    end;

    procedure O(): Code[10]
    begin
        exit(OTok);
    end;

    procedure O86(): Code[10]
    begin
        exit(O86Tok);
    end;

    procedure O861(): Code[10]
    begin
        exit(O861Tok);
    end;

    procedure O8612(): Code[10]
    begin
        exit(O8612Tok);
    end;

    procedure O8613(): Code[10]
    begin
        exit(O8613Tok);
    end;

    procedure O862(): Code[10]
    begin
        exit(O862Tok);
    end;

    procedure O8622(): Code[10]
    begin
        exit(O8622Tok);
    end;

    procedure O8623(): Code[10]
    begin
        exit(O8623Tok);
    end;

    procedure O863(): Code[10]
    begin
        exit(O863Tok);
    end;

    procedure O8631(): Code[10]
    begin
        exit(O8631Tok);
    end;

    procedure O8633(): Code[10]
    begin
        exit(O8633Tok);
    end;

    procedure O8634(): Code[10]
    begin
        exit(O8634Tok);
    end;

    procedure O8635(): Code[10]
    begin
        exit(O8635Tok);
    end;

    procedure O8636(): Code[10]
    begin
        exit(O8636Tok);
    end;

    procedure O8639(): Code[10]
    begin
        exit(O8639Tok);
    end;

    procedure O864(): Code[10]
    begin
        exit(O864Tok);
    end;

    procedure O8640(): Code[10]
    begin
        exit(O8640Tok);
    end;

    procedure O87(): Code[10]
    begin
        exit(O87Tok);
    end;

    procedure O871(): Code[10]
    begin
        exit(O871Tok);
    end;

    procedure O8710(): Code[10]
    begin
        exit(O8710Tok);
    end;

    procedure O872(): Code[10]
    begin
        exit(O872Tok);
    end;

    procedure O8721(): Code[10]
    begin
        exit(O8721Tok);
    end;

    procedure O8722(): Code[10]
    begin
        exit(O8722Tok);
    end;

    procedure P911(): Code[10]
    begin
        exit(P911Tok);
    end;

    procedure P9111(): Code[10]
    begin
        exit(P9111Tok);
    end;

    procedure P9112(): Code[10]
    begin
        exit(P9112Tok);
    end;

    procedure P9113(): Code[10]
    begin
        exit(P9113Tok);
    end;

    procedure P912(): Code[10]
    begin
        exit(P912Tok);
    end;

    procedure P9121(): Code[10]
    begin
        exit(P9121Tok);
    end;

    procedure P9122(): Code[10]
    begin
        exit(P9122Tok);
    end;

    procedure P921(): Code[10]
    begin
        exit(P921Tok);
    end;

    procedure P9210(): Code[10]
    begin
        exit(P9210Tok);
    end;

    procedure P922(): Code[10]
    begin
        exit(P922Tok);
    end;

    procedure P9220(): Code[10]
    begin
        exit(P9220Tok);
    end;

    procedure P923(): Code[10]
    begin
        exit(P923Tok);
    end;

    procedure P9231(): Code[10]
    begin
        exit(P9231Tok);
    end;

    procedure P9239(): Code[10]
    begin
        exit(P9239Tok);
    end;

    procedure P924(): Code[10]
    begin
        exit(P924Tok);
    end;

    procedure P9241(): Code[10]
    begin
        exit(P9241Tok);
    end;

    procedure P9242(): Code[10]
    begin
        exit(P9242Tok);
    end;

    procedure P925(): Code[10]
    begin
        exit(P925Tok);
    end;

    procedure P9251(): Code[10]
    begin
        exit(P9251Tok);
    end;

    procedure P9252(): Code[10]
    begin
        exit(P9252Tok);
    end;

    procedure P9259(): Code[10]
    begin
        exit(P9259Tok);
    end;

    procedure P93(): Code[10]
    begin
        exit(P93Tok);
    end;

    procedure P931(): Code[10]
    begin
        exit(P931Tok);
    end;

    procedure P9311(): Code[10]
    begin
        exit(P9311Tok);
    end;

    procedure P932(): Code[10]
    begin
        exit(P932Tok);
    end;

    procedure P9321(): Code[10]
    begin
        exit(P9321Tok);
    end;

    procedure P9322(): Code[10]
    begin
        exit(P9322Tok);
    end;

    procedure P9329(): Code[10]
    begin
        exit(P9329Tok);
    end;

    procedure P933(): Code[10]
    begin
        exit(P933Tok);
    end;

    procedure P9330(): Code[10]
    begin
        exit(P9330Tok);
    end;

    procedure Q(): Code[10]
    begin
        exit(QTok);
    end;

    procedure Q95(): Code[10]
    begin
        exit(Q95Tok);
    end;

    procedure Q9511(): Code[10]
    begin
        exit(Q9511Tok);
    end;

    procedure Q952(): Code[10]
    begin
        exit(Q952Tok);
    end;

    procedure Q9521(): Code[10]
    begin
        exit(Q9521Tok);
    end;

    procedure Q9522(): Code[10]
    begin
        exit(Q9522Tok);
    end;

    procedure Q9523(): Code[10]
    begin
        exit(Q9523Tok);
    end;

    procedure Q9525(): Code[10]
    begin
        exit(Q9525Tok);
    end;

    procedure Q9526(): Code[10]
    begin
        exit(Q9526Tok);
    end;

    procedure Q9529(): Code[10]
    begin
        exit(Q9529Tok);
    end;

    procedure Q96(): Code[10]
    begin
        exit(Q96Tok);
    end;

    procedure Q961(): Code[10]
    begin
        exit(Q961Tok);
    end;

    procedure Q9610(): Code[10]
    begin
        exit(Q9610Tok);
    end;

    procedure Q962(): Code[10]
    begin
        exit(Q962Tok);
    end;

    procedure Q9622(): Code[10]
    begin
        exit(Q9622Tok);
    end;

    procedure Q9629(): Code[10]
    begin
        exit(Q9629Tok);
    end;

    procedure Q9631(): Code[10]
    begin
        exit(Q9631Tok);
    end;

    procedure Q9632(): Code[10]
    begin
        exit(Q9632Tok);
    end;

    procedure Q9633(): Code[10]
    begin
        exit(Q9633Tok);
    end;

    procedure Q9634(): Code[10]
    begin
        exit(Q9634Tok);
    end;

    var
        A1Tok: Label 'A1', MaxLength = 10;
        A11Tok: Label 'A11', MaxLength = 10;
        A111Tok: Label 'A111', MaxLength = 10;
        A113Tok: Label 'A113', MaxLength = 10;
        A114Tok: Label 'A114', MaxLength = 10;
        A115Tok: Label 'A115', MaxLength = 10;
        A116Tok: Label 'A116', MaxLength = 10;
        A117Tok: Label 'A117', MaxLength = 10;
        A119Tok: Label 'A119', MaxLength = 10;
        A121Tok: Label 'A121', MaxLength = 10;
        A123Tok: Label 'A123', MaxLength = 10;
        A124Tok: Label 'A124', MaxLength = 10;
        A125Tok: Label 'A125', MaxLength = 10;
        A13Tok: Label 'A13', MaxLength = 10;
        A130Tok: Label 'A130', MaxLength = 10;
        A14Tok: Label 'A14', MaxLength = 10;
        A141Tok: Label 'A141', MaxLength = 10;
        A142Tok: Label 'A142', MaxLength = 10;
        A15Tok: Label 'A15', MaxLength = 10;
        A151Tok: Label 'A151', MaxLength = 10;
        A152Tok: Label 'A152', MaxLength = 10;
        A153Tok: Label 'A153', MaxLength = 10;
        A159Tok: Label 'A159', MaxLength = 10;
        A16Tok: Label 'A16', MaxLength = 10;
        A161Tok: Label 'A161', MaxLength = 10;
        A162Tok: Label 'A162', MaxLength = 10;
        A169Tok: Label 'A169', MaxLength = 10;
        A21Tok: Label 'A21', MaxLength = 10;
        A211Tok: Label 'A211', MaxLength = 10;
        A212Tok: Label 'A212', MaxLength = 10;
        A213Tok: Label 'A213', MaxLength = 10;
        A219Tok: Label 'A219', MaxLength = 10;
        A22Tok: Label 'A22', MaxLength = 10;
        A220Tok: Label 'A220', MaxLength = 10;
        A3Tok: Label 'A3', MaxLength = 10;
        A30Tok: Label 'A30', MaxLength = 10;
        A301Tok: Label 'A301', MaxLength = 10;
        A302Tok: Label 'A302', MaxLength = 10;
        A303Tok: Label 'A303', MaxLength = 10;
        A4Tok: Label 'A4', MaxLength = 10;
        A41Tok: Label 'A41', MaxLength = 10;
        A411Tok: Label 'A411', MaxLength = 10;
        A412Tok: Label 'A412', MaxLength = 10;
        A413Tok: Label 'A413', MaxLength = 10;
        A414Tok: Label 'A414', MaxLength = 10;
        A415Tok: Label 'A415', MaxLength = 10;
        A419Tok: Label 'A419', MaxLength = 10;
        A42Tok: Label 'A42', MaxLength = 10;
        A420Tok: Label 'A420', MaxLength = 10;
        BTok: Label 'B', MaxLength = 10;
        B11Tok: Label 'B11', MaxLength = 10;
        B110Tok: Label 'B110', MaxLength = 10;
        B1101Tok: Label 'B1101', MaxLength = 10;
        B1102Tok: Label 'B1102', MaxLength = 10;
        B12Tok: Label 'B12', MaxLength = 10;
        B120Tok: Label 'B120', MaxLength = 10;
        B1200Tok: Label 'B1200', MaxLength = 10;
        B13Tok: Label 'B13', MaxLength = 10;
        B131Tok: Label 'B131', MaxLength = 10;
        B1311Tok: Label 'B1311', MaxLength = 10;
        B1312Tok: Label 'B1312', MaxLength = 10;
        B1313Tok: Label 'B1313', MaxLength = 10;
        B1314Tok: Label 'B1314', MaxLength = 10;
        B1315Tok: Label 'B1315', MaxLength = 10;
        B1316Tok: Label 'B1316', MaxLength = 10;
        B1317Tok: Label 'B1317', MaxLength = 10;
        B1319Tok: Label 'B1319', MaxLength = 10;
        B14Tok: Label 'B14', MaxLength = 10;
        B141Tok: Label 'B141', MaxLength = 10;
        B1411Tok: Label 'B1411', MaxLength = 10;
        B142Tok: Label 'B142', MaxLength = 10;
        B1420Tok: Label 'B1420', MaxLength = 10;
        B15Tok: Label 'B15', MaxLength = 10;
        B151Tok: Label 'B151', MaxLength = 10;
        B1512Tok: Label 'B1512', MaxLength = 10;
        B1514Tok: Label 'B1514', MaxLength = 10;
        B152Tok: Label 'B152', MaxLength = 10;
        B1520Tok: Label 'B1520', MaxLength = 10;
        CTok: Label 'C', MaxLength = 10;
        C21Tok: Label 'C21', MaxLength = 10;
        C2111Tok: Label 'C2111', MaxLength = 10;
        C2112Tok: Label 'C2112', MaxLength = 10;
        C212Tok: Label 'C212', MaxLength = 10;
        C2121Tok: Label 'C2121', MaxLength = 10;
        C2122Tok: Label 'C2122', MaxLength = 10;
        C213Tok: Label 'C213', MaxLength = 10;
        C2130Tok: Label 'C2130', MaxLength = 10;
        C214Tok: Label 'C214', MaxLength = 10;
        C2140Tok: Label 'C2140', MaxLength = 10;
        C216Tok: Label 'C216', MaxLength = 10;
        C2161Tok: Label 'C2161', MaxLength = 10;
        C2162Tok: Label 'C2162', MaxLength = 10;
        C2163Tok: Label 'C2163', MaxLength = 10;
        C217Tok: Label 'C217', MaxLength = 10;
        C2171Tok: Label 'C2171', MaxLength = 10;
        C2172Tok: Label 'C2172', MaxLength = 10;
        C2173Tok: Label 'C2173', MaxLength = 10;
        C2179Tok: Label 'C2179', MaxLength = 10;
        C2182Tok: Label 'C2182', MaxLength = 10;
        C2183Tok: Label 'C2183', MaxLength = 10;
        C2184Tok: Label 'C2184', MaxLength = 10;
        C219Tok: Label 'C219', MaxLength = 10;
        C2190Tok: Label 'C2190', MaxLength = 10;
        C2211Tok: Label 'C2211', MaxLength = 10;
        C2213Tok: Label 'C2213', MaxLength = 10;
        C2214Tok: Label 'C2214', MaxLength = 10;
        C2215Tok: Label 'C2215', MaxLength = 10;
        C222Tok: Label 'C222', MaxLength = 10;
        C223Tok: Label 'C223', MaxLength = 10;
        C2231Tok: Label 'C2231', MaxLength = 10;
        C224Tok: Label 'C224', MaxLength = 10;
        C2249Tok: Label 'C2249', MaxLength = 10;
        C225Tok: Label 'C225', MaxLength = 10;
        C2250Tok: Label 'C2250', MaxLength = 10;
        C2311Tok: Label 'C2311', MaxLength = 10;
        C2312Tok: Label 'C2312', MaxLength = 10;
        C2313Tok: Label 'C2313', MaxLength = 10;
        C2322Tok: Label 'C2322', MaxLength = 10;
        C2329Tok: Label 'C2329', MaxLength = 10;
        C2411Tok: Label 'C2411', MaxLength = 10;
        C2412Tok: Label 'C2412', MaxLength = 10;
        C2413Tok: Label 'C2413', MaxLength = 10;
        C242Tok: Label 'C242', MaxLength = 10;
        C2422Tok: Label 'C2422', MaxLength = 10;
        C2423Tok: Label 'C2423', MaxLength = 10;
        C251Tok: Label 'C251', MaxLength = 10;
        C2510Tok: Label 'C2510', MaxLength = 10;
        C253Tok: Label 'C253', MaxLength = 10;
        C2531Tok: Label 'C2531', MaxLength = 10;
        C2532Tok: Label 'C2532', MaxLength = 10;
        C2533Tok: Label 'C2533', MaxLength = 10;
        C2541Tok: Label 'C2541', MaxLength = 10;
        C2542Tok: Label 'C2542', MaxLength = 10;
        C2544Tok: Label 'C2544', MaxLength = 10;
        C2547Tok: Label 'C2547', MaxLength = 10;
        C255Tok: Label 'C255', MaxLength = 10;
        C2551Tok: Label 'C2551', MaxLength = 10;
        C256Tok: Label 'C256', MaxLength = 10;
        C262Tok: Label 'C262', MaxLength = 10;
        C2621Tok: Label 'C2621', MaxLength = 10;
        C2622Tok: Label 'C2622', MaxLength = 10;
        C2631Tok: Label 'C2631', MaxLength = 10;
        C2632Tok: Label 'C2632', MaxLength = 10;
        C2633Tok: Label 'C2633', MaxLength = 10;
        C27Tok: Label 'C27', MaxLength = 10;
        C271Tok: Label 'C271', MaxLength = 10;
        C2721Tok: Label 'C2721', MaxLength = 10;
        C2722Tok: Label 'C2722', MaxLength = 10;
        C2733Tok: Label 'C2733', MaxLength = 10;
        C2741Tok: Label 'C2741', MaxLength = 10;
        C2751Tok: Label 'C2751', MaxLength = 10;
        C2764Tok: Label 'C2764', MaxLength = 10;
        C2811Tok: Label 'C2811', MaxLength = 10;
        C2821Tok: Label 'C2821', MaxLength = 10;
        C2822Tok: Label 'C2822', MaxLength = 10;
        C2824Tok: Label 'C2824', MaxLength = 10;
        C2853Tok: Label 'C2853', MaxLength = 10;
        C29Tok: Label 'C29', MaxLength = 10;
        C292Tok: Label 'C292', MaxLength = 10;
        C2929Tok: Label 'C2929', MaxLength = 10;
        C294Tok: Label 'C294', MaxLength = 10;
        C2949Tok: Label 'C2949', MaxLength = 10;
        D36Tok: Label 'D36', MaxLength = 10;
        D361Tok: Label 'D361', MaxLength = 10;
        D3610Tok: Label 'D3610', MaxLength = 10;
        D362Tok: Label 'D362', MaxLength = 10;
        D3620Tok: Label 'D3620', MaxLength = 10;
        D3701Tok: Label 'D3701', MaxLength = 10;
        D3702Tok: Label 'D3702', MaxLength = 10;
        ETok: Label 'E', MaxLength = 10;
        E41Tok: Label 'E41', MaxLength = 10;
        E411Tok: Label 'E411', MaxLength = 10;
        E4111Tok: Label 'E4111', MaxLength = 10;
        E412Tok: Label 'E412', MaxLength = 10;
        E4121Tok: Label 'E4121', MaxLength = 10;
        E4122Tok: Label 'E4122', MaxLength = 10;
        E42Tok: Label 'E42', MaxLength = 10;
        E421Tok: Label 'E421', MaxLength = 10;
        E4210Tok: Label 'E4210', MaxLength = 10;
        E422Tok: Label 'E422', MaxLength = 10;
        E4221Tok: Label 'E4221', MaxLength = 10;
        E4222Tok: Label 'E4222', MaxLength = 10;
        E4223Tok: Label 'E4223', MaxLength = 10;
        E423Tok: Label 'E423', MaxLength = 10;
        E4231Tok: Label 'E4231', MaxLength = 10;
        E4232Tok: Label 'E4232', MaxLength = 10;
        E424Tok: Label 'E424', MaxLength = 10;
        E4242Tok: Label 'E4242', MaxLength = 10;
        E4243Tok: Label 'E4243', MaxLength = 10;
        E4245Tok: Label 'E4245', MaxLength = 10;
        E425Tok: Label 'E425', MaxLength = 10;
        E4251Tok: Label 'E4251', MaxLength = 10;
        E4259Tok: Label 'E4259', MaxLength = 10;
        FTok: Label 'F', MaxLength = 10;
        F45Tok: Label 'F45', MaxLength = 10;
        F451Tok: Label 'F451', MaxLength = 10;
        F4511Tok: Label 'F4511', MaxLength = 10;
        F4512Tok: Label 'F4512', MaxLength = 10;
        F4521Tok: Label 'F4521', MaxLength = 10;
        F4522Tok: Label 'F4522', MaxLength = 10;
        F4523Tok: Label 'F4523', MaxLength = 10;
        F453Tok: Label 'F453', MaxLength = 10;
        F4531Tok: Label 'F4531', MaxLength = 10;
        F4613Tok: Label 'F4613', MaxLength = 10;
        F462Tok: Label 'F462', MaxLength = 10;
        F4621Tok: Label 'F4621', MaxLength = 10;
        F4622Tok: Label 'F4622', MaxLength = 10;
        F4623Tok: Label 'F4623', MaxLength = 10;
        F4711Tok: Label 'F4711', MaxLength = 10;
        F4713Tok: Label 'F4713', MaxLength = 10;
        F4714Tok: Label 'F4714', MaxLength = 10;
        F4717Tok: Label 'F4717', MaxLength = 10;
        F4718Tok: Label 'F4718', MaxLength = 10;
        F4719Tok: Label 'F4719', MaxLength = 10;
        F4721Tok: Label 'F4721', MaxLength = 10;
        F4722Tok: Label 'F4722', MaxLength = 10;
        F4723Tok: Label 'F4723', MaxLength = 10;
        F473Tok: Label 'F473', MaxLength = 10;
        F4732Tok: Label 'F4732', MaxLength = 10;
        F4733Tok: Label 'F4733', MaxLength = 10;
        F4739Tok: Label 'F4739', MaxLength = 10;
        F479Tok: Label 'F479', MaxLength = 10;
        F4794Tok: Label 'F4794', MaxLength = 10;
        F4795Tok: Label 'F4795', MaxLength = 10;
        F4799Tok: Label 'F4799', MaxLength = 10;
        GTok: Label 'G', MaxLength = 10;
        G51Tok: Label 'G51', MaxLength = 10;
        G511Tok: Label 'G511', MaxLength = 10;
        G5110Tok: Label 'G5110', MaxLength = 10;
        G512Tok: Label 'G512', MaxLength = 10;
        G5122Tok: Label 'G5122', MaxLength = 10;
        G5123Tok: Label 'G5123', MaxLength = 10;
        G5124Tok: Label 'G5124', MaxLength = 10;
        G5125Tok: Label 'G5125', MaxLength = 10;
        G5126Tok: Label 'G5126', MaxLength = 10;
        G5129Tok: Label 'G5129', MaxLength = 10;
        G521Tok: Label 'G521', MaxLength = 10;
        G5210Tok: Label 'G5210', MaxLength = 10;
        G5221Tok: Label 'G5221', MaxLength = 10;
        G5222Tok: Label 'G5222', MaxLength = 10;
        G5231Tok: Label 'G5231', MaxLength = 10;
        G5232Tok: Label 'G5232', MaxLength = 10;
        G5234Tok: Label 'G5234', MaxLength = 10;
        G5235Tok: Label 'G5235', MaxLength = 10;
        G524Tok: Label 'G524', MaxLength = 10;
        G5242Tok: Label 'G5242', MaxLength = 10;
        G5245Tok: Label 'G5245', MaxLength = 10;
        G5253Tok: Label 'G5253', MaxLength = 10;
        G5254Tok: Label 'G5254', MaxLength = 10;
        G5255Tok: Label 'G5255', MaxLength = 10;
        G5259Tok: Label 'G5259', MaxLength = 10;
        G531Tok: Label 'G531', MaxLength = 10;
        G5311Tok: Label 'G5311', MaxLength = 10;
        G5312Tok: Label 'G5312', MaxLength = 10;
        G5313Tok: Label 'G5313', MaxLength = 10;
        G532Tok: Label 'G532', MaxLength = 10;
        G5321Tok: Label 'G5321', MaxLength = 10;
        G5322Tok: Label 'G5322', MaxLength = 10;
        G5323Tok: Label 'G5323', MaxLength = 10;
        G5324Tok: Label 'G5324', MaxLength = 10;
        H571Tok: Label 'H571', MaxLength = 10;
        H5710Tok: Label 'H5710', MaxLength = 10;
        H572Tok: Label 'H572', MaxLength = 10;
        H5720Tok: Label 'H5720', MaxLength = 10;
        H573Tok: Label 'H573', MaxLength = 10;
        H5730Tok: Label 'H5730', MaxLength = 10;
        H574Tok: Label 'H574', MaxLength = 10;
        H5740Tok: Label 'H5740', MaxLength = 10;
        ITok: Label 'I', MaxLength = 10;
        I61Tok: Label 'I61', MaxLength = 10;
        I611Tok: Label 'I611', MaxLength = 10;
        I6110Tok: Label 'I6110', MaxLength = 10;
        I612Tok: Label 'I612', MaxLength = 10;
        I6121Tok: Label 'I6121', MaxLength = 10;
        I62Tok: Label 'I62', MaxLength = 10;
        I620Tok: Label 'I620', MaxLength = 10;
        I6200Tok: Label 'I6200', MaxLength = 10;
        I63Tok: Label 'I63', MaxLength = 10;
        I630Tok: Label 'I630', MaxLength = 10;
        I6301Tok: Label 'I6301', MaxLength = 10;
        I6302Tok: Label 'I6302', MaxLength = 10;
        I6303Tok: Label 'I6303', MaxLength = 10;
        I64Tok: Label 'I64', MaxLength = 10;
        I640Tok: Label 'I640', MaxLength = 10;
        I65Tok: Label 'I65', MaxLength = 10;
        I650Tok: Label 'I650', MaxLength = 10;
        I6501Tok: Label 'I6501', MaxLength = 10;
        I6509Tok: Label 'I6509', MaxLength = 10;
        I66Tok: Label 'I66', MaxLength = 10;
        I661Tok: Label 'I661', MaxLength = 10;
        I6611Tok: Label 'I6611', MaxLength = 10;
        I6619Tok: Label 'I6619', MaxLength = 10;
        I662Tok: Label 'I662', MaxLength = 10;
        I6621Tok: Label 'I6621', MaxLength = 10;
        I6622Tok: Label 'I6622', MaxLength = 10;
        I6623Tok: Label 'I6623', MaxLength = 10;
        I663Tok: Label 'I663', MaxLength = 10;
        I6630Tok: Label 'I6630', MaxLength = 10;
        I664Tok: Label 'I664', MaxLength = 10;
        I6641Tok: Label 'I6641', MaxLength = 10;
        I6642Tok: Label 'I6642', MaxLength = 10;
        I6644Tok: Label 'I6644', MaxLength = 10;
        I6649Tok: Label 'I6649', MaxLength = 10;
        I67Tok: Label 'I67', MaxLength = 10;
        I670Tok: Label 'I670', MaxLength = 10;
        I6701Tok: Label 'I6701', MaxLength = 10;
        I6709Tok: Label 'I6709', MaxLength = 10;
        JTok: Label 'J', MaxLength = 10;
        J71Tok: Label 'J71', MaxLength = 10;
        J711Tok: Label 'J711', MaxLength = 10;
        J7111Tok: Label 'J7111', MaxLength = 10;
        J7112Tok: Label 'J7112', MaxLength = 10;
        J712Tok: Label 'J712', MaxLength = 10;
        J7120Tok: Label 'J7120', MaxLength = 10;
        KTok: Label 'K', MaxLength = 10;
        K73Tok: Label 'K73', MaxLength = 10;
        K731Tok: Label 'K731', MaxLength = 10;
        K7310Tok: Label 'K7310', MaxLength = 10;
        K732Tok: Label 'K732', MaxLength = 10;
        K7321Tok: Label 'K7321', MaxLength = 10;
        K7322Tok: Label 'K7322', MaxLength = 10;
        K7323Tok: Label 'K7323', MaxLength = 10;
        K7324Tok: Label 'K7324', MaxLength = 10;
        K7329Tok: Label 'K7329', MaxLength = 10;
        K733Tok: Label 'K733', MaxLength = 10;
        K7330Tok: Label 'K7330', MaxLength = 10;
        K734Tok: Label 'K734', MaxLength = 10;
        K7340Tok: Label 'K7340', MaxLength = 10;
        K74Tok: Label 'K74', MaxLength = 10;
        K7411Tok: Label 'K7411', MaxLength = 10;
        K7412Tok: Label 'K7412', MaxLength = 10;
        K742Tok: Label 'K742', MaxLength = 10;
        K7421Tok: Label 'K7421', MaxLength = 10;
        K7422Tok: Label 'K7422', MaxLength = 10;
        K752Tok: Label 'K752', MaxLength = 10;
        K7520Tok: Label 'K7520', MaxLength = 10;
        LTok: Label 'L', MaxLength = 10;
        L77Tok: Label 'L77', MaxLength = 10;
        L7711Tok: Label 'L7711', MaxLength = 10;
        L772Tok: Label 'L772', MaxLength = 10;
        L7720Tok: Label 'L7720', MaxLength = 10;
        L773Tok: Label 'L773', MaxLength = 10;
        L7730Tok: Label 'L7730', MaxLength = 10;
        L7741Tok: Label 'L7741', MaxLength = 10;
        L7743Tok: Label 'L7743', MaxLength = 10;
        L78Tok: Label 'L78', MaxLength = 10;
        L781Tok: Label 'L781', MaxLength = 10;
        L7810Tok: Label 'L7810', MaxLength = 10;
        L782Tok: Label 'L782', MaxLength = 10;
        L7821Tok: Label 'L7821', MaxLength = 10;
        L7822Tok: Label 'L7822', MaxLength = 10;
        L7829Tok: Label 'L7829', MaxLength = 10;
        L783Tok: Label 'L783', MaxLength = 10;
        L7831Tok: Label 'L7831', MaxLength = 10;
        L7833Tok: Label 'L7833', MaxLength = 10;
        L7834Tok: Label 'L7834', MaxLength = 10;
        L784Tok: Label 'L784', MaxLength = 10;
        L7841Tok: Label 'L7841', MaxLength = 10;
        L7842Tok: Label 'L7842', MaxLength = 10;
        L7851Tok: Label 'L7851', MaxLength = 10;
        L7853Tok: Label 'L7853', MaxLength = 10;
        L7855Tok: Label 'L7855', MaxLength = 10;
        L786Tok: Label 'L786', MaxLength = 10;
        L7861Tok: Label 'L7861', MaxLength = 10;
        L7862Tok: Label 'L7862', MaxLength = 10;
        L7863Tok: Label 'L7863', MaxLength = 10;
        L7865Tok: Label 'L7865', MaxLength = 10;
        L7866Tok: Label 'L7866', MaxLength = 10;
        L7867Tok: Label 'L7867', MaxLength = 10;
        L7869Tok: Label 'L7869', MaxLength = 10;
        M81Tok: Label 'M81', MaxLength = 10;
        M811Tok: Label 'M811', MaxLength = 10;
        M812Tok: Label 'M812', MaxLength = 10;
        M8120Tok: Label 'M8120', MaxLength = 10;
        M82Tok: Label 'M82', MaxLength = 10;
        M820Tok: Label 'M820', MaxLength = 10;
        M8200Tok: Label 'M8200', MaxLength = 10;
        NTok: Label 'N', MaxLength = 10;
        N84Tok: Label 'N84', MaxLength = 10;
        N841Tok: Label 'N841', MaxLength = 10;
        N8410Tok: Label 'N8410', MaxLength = 10;
        N842Tok: Label 'N842', MaxLength = 10;
        N8421Tok: Label 'N8421', MaxLength = 10;
        N8422Tok: Label 'N8422', MaxLength = 10;
        N8424Tok: Label 'N8424', MaxLength = 10;
        N843Tok: Label 'N843', MaxLength = 10;
        N8431Tok: Label 'N8431', MaxLength = 10;
        N844Tok: Label 'N844', MaxLength = 10;
        N8440Tok: Label 'N8440', MaxLength = 10;
        OTok: Label 'O', MaxLength = 10;
        O86Tok: Label 'O86', MaxLength = 10;
        O861Tok: Label 'O861', MaxLength = 10;
        O8612Tok: Label 'O8612', MaxLength = 10;
        O8613Tok: Label 'O8613', MaxLength = 10;
        O862Tok: Label 'O862', MaxLength = 10;
        O8622Tok: Label 'O8622', MaxLength = 10;
        O8623Tok: Label 'O8623', MaxLength = 10;
        O863Tok: Label 'O863', MaxLength = 10;
        O8631Tok: Label 'O8631', MaxLength = 10;
        O8633Tok: Label 'O8633', MaxLength = 10;
        O8634Tok: Label 'O8634', MaxLength = 10;
        O8635Tok: Label 'O8635', MaxLength = 10;
        O8636Tok: Label 'O8636', MaxLength = 10;
        O8639Tok: Label 'O8639', MaxLength = 10;
        O864Tok: Label 'O864', MaxLength = 10;
        O8640Tok: Label 'O8640', MaxLength = 10;
        O87Tok: Label 'O87', MaxLength = 10;
        O871Tok: Label 'O871', MaxLength = 10;
        O8710Tok: Label 'O8710', MaxLength = 10;
        O872Tok: Label 'O872', MaxLength = 10;
        O8721Tok: Label 'O8721', MaxLength = 10;
        O8722Tok: Label 'O8722', MaxLength = 10;
        P911Tok: Label 'P911', MaxLength = 10;
        P9111Tok: Label 'P9111', MaxLength = 10;
        P9112Tok: Label 'P9112', MaxLength = 10;
        P9113Tok: Label 'P9113', MaxLength = 10;
        P912Tok: Label 'P912', MaxLength = 10;
        P9121Tok: Label 'P9121', MaxLength = 10;
        P9122Tok: Label 'P9122', MaxLength = 10;
        P921Tok: Label 'P921', MaxLength = 10;
        P9210Tok: Label 'P9210', MaxLength = 10;
        P922Tok: Label 'P922', MaxLength = 10;
        P9220Tok: Label 'P9220', MaxLength = 10;
        P923Tok: Label 'P923', MaxLength = 10;
        P9231Tok: Label 'P9231', MaxLength = 10;
        P9239Tok: Label 'P9239', MaxLength = 10;
        P924Tok: Label 'P924', MaxLength = 10;
        P9241Tok: Label 'P9241', MaxLength = 10;
        P9242Tok: Label 'P9242', MaxLength = 10;
        P925Tok: Label 'P925', MaxLength = 10;
        P9251Tok: Label 'P9251', MaxLength = 10;
        P9252Tok: Label 'P9252', MaxLength = 10;
        P9259Tok: Label 'P9259', MaxLength = 10;
        P93Tok: Label 'P93', MaxLength = 10;
        P931Tok: Label 'P931', MaxLength = 10;
        P9311Tok: Label 'P9311', MaxLength = 10;
        P932Tok: Label 'P932', MaxLength = 10;
        P9321Tok: Label 'P9321', MaxLength = 10;
        P9322Tok: Label 'P9322', MaxLength = 10;
        P9329Tok: Label 'P9329', MaxLength = 10;
        P933Tok: Label 'P933', MaxLength = 10;
        P9330Tok: Label 'P9330', MaxLength = 10;
        QTok: Label 'Q', MaxLength = 10;
        Q95Tok: Label 'Q95', MaxLength = 10;
        Q9511Tok: Label 'Q9511', MaxLength = 10;
        Q952Tok: Label 'Q952', MaxLength = 10;
        Q9521Tok: Label 'Q9521', MaxLength = 10;
        Q9522Tok: Label 'Q9522', MaxLength = 10;
        Q9523Tok: Label 'Q9523', MaxLength = 10;
        Q9525Tok: Label 'Q9525', MaxLength = 10;
        Q9526Tok: Label 'Q9526', MaxLength = 10;
        Q9529Tok: Label 'Q9529', MaxLength = 10;
        Q96Tok: Label 'Q96', MaxLength = 10;
        Q961Tok: Label 'Q961', MaxLength = 10;
        Q9610Tok: Label 'Q9610', MaxLength = 10;
        Q962Tok: Label 'Q962', MaxLength = 10;
        Q9622Tok: Label 'Q9622', MaxLength = 10;
        Q9629Tok: Label 'Q9629', MaxLength = 10;
        Q9631Tok: Label 'Q9631', MaxLength = 10;
        Q9632Tok: Label 'Q9632', MaxLength = 10;
        Q9633Tok: Label 'Q9633', MaxLength = 10;
        Q9634Tok: Label 'Q9634', MaxLength = 10;
        AgricultureLbl: Label 'Agriculture', MaxLength = 100;
        HorticultureAndFruitGrowingLbl: Label 'Horticulture and Fruit Growing', MaxLength = 100;
        PlantNurseriesLbl: Label 'Plant Nurseries', MaxLength = 100;
        VegetableGrowingLbl: Label 'Vegetable Growing', MaxLength = 100;
        GrapeGrowingLbl: Label 'Grape Growing', MaxLength = 100;
        AppleAndPearGrowingLbl: Label 'Apple and Pear Growing', MaxLength = 100;
        StoneFruitGrowingLbl: Label 'Stone Fruit Growing', MaxLength = 100;
        KiwiFruitGrowingLbl: Label 'Kiwi Fruit Growing', MaxLength = 100;
        FruitGrowingNecLbl: Label 'Fruit Growing NEC', MaxLength = 100;
        GrainGrowingLbl: Label 'Grain Growing', MaxLength = 100;
        SheepBeefCattleFarmingLbl: Label 'Sheep-Beef Cattle Farming', MaxLength = 100;
        SheepFarmingLbl: Label 'Sheep Farming', MaxLength = 100;
        BeefCattleFarmingLbl: Label 'Beef Cattle Farming', MaxLength = 100;
        DairyCattleFarmingLbl: Label 'Dairy Cattle Farming', MaxLength = 100;
        PoultryFarmingLbl: Label 'Poultry Farming', MaxLength = 100;
        PoultryFarmingMeatLbl: Label 'Poultry Farming (Meat)', MaxLength = 100;
        PoultryFarmingEggsLbl: Label 'Poultry Farming (Eggs)', MaxLength = 100;
        OtherLivestockFarmingLbl: Label 'Other Livestock Farming', MaxLength = 100;
        PigFarmingLbl: Label 'Pig Farming', MaxLength = 100;
        HorseFarmingLbl: Label 'Horse Farming', MaxLength = 100;
        DeerFarmingLbl: Label 'Deer Farming', MaxLength = 100;
        LivestockFarmingNecLbl: Label 'Livestock Farming NEC', MaxLength = 100;
        OtherCropGrowingLbl: Label 'Other Crop Growing', MaxLength = 100;
        SugarCaneGrowingLbl: Label 'Sugar Cane Growing', MaxLength = 100;
        CottonGrowingLbl: Label 'Cotton Growing', MaxLength = 100;
        CropAndPlantGrowingNecLbl: Label 'Crop and Plant Growing NEC', MaxLength = 100;
        ServicesToAgricultureLbl: Label 'Services to Agriculture', MaxLength = 100;
        CottonGinningLbl: Label 'Cotton Ginning', MaxLength = 100;
        ShearingServicesLbl: Label 'Shearing Services', MaxLength = 100;
        AerialAgriculturalServicesLbl: Label 'Aerial Agricultural Services', MaxLength = 100;
        ServicesToAgricultureNecLbl: Label 'Services to Agriculture NEC', MaxLength = 100;
        HuntingAndTrappingLbl: Label 'Hunting and Trapping', MaxLength = 100;
        ForestryAndLoggingLbl: Label 'Forestry and Logging', MaxLength = 100;
        ForestryLbl: Label 'Forestry', MaxLength = 100;
        LoggingLbl: Label 'Logging', MaxLength = 100;
        ServicesToForestryLbl: Label 'Services to Forestry', MaxLength = 100;
        CommercialFishingLbl: Label 'Commercial Fishing', MaxLength = 100;
        MarineFishingLbl: Label 'Marine Fishing', MaxLength = 100;
        RockLobsterFishingLbl: Label 'Rock Lobster Fishing', MaxLength = 100;
        PrawnFishingLbl: Label 'Prawn Fishing', MaxLength = 100;
        FinfishTrawlingLbl: Label 'Finfish Trawling', MaxLength = 100;
        SquidJiggingLbl: Label 'Squid Jigging', MaxLength = 100;
        LineFishingLbl: Label 'Line Fishing', MaxLength = 100;
        MarineFishingNecLbl: Label 'Marine Fishing NEC', MaxLength = 100;
        AquacultureLbl: Label 'Aquaculture', MaxLength = 100;
        MiningLbl: Label 'Mining', MaxLength = 100;
        CoalMiningLbl: Label 'Coal Mining', MaxLength = 100;
        BlackCoalMiningLbl: Label 'Black Coal Mining', MaxLength = 100;
        BrownCoalMiningLbl: Label 'Brown Coal Mining', MaxLength = 100;
        OilAndGasExtractionLbl: Label 'Oil and Gas Extraction', MaxLength = 100;
        MetalOreMiningLbl: Label 'Metal Ore Mining', MaxLength = 100;
        IronOreMiningLbl: Label 'Iron Ore Mining', MaxLength = 100;
        BauxiteMiningLbl: Label 'Bauxite Mining', MaxLength = 100;
        CopperOreMiningLbl: Label 'Copper Ore Mining', MaxLength = 100;
        GoldOreMiningLbl: Label 'Gold Ore Mining', MaxLength = 100;
        MineralSandMiningLbl: Label 'Mineral Sand Mining', MaxLength = 100;
        NickelOreMiningLbl: Label 'Nickel Ore Mining', MaxLength = 100;
        SilverLeadZincOreMiningLbl: Label 'Silver-Lead-Zinc Ore Mining', MaxLength = 100;
        MetalOreMiningNecLbl: Label 'Metal Ore Mining NEC', MaxLength = 100;
        OtherMiningLbl: Label 'Other Mining', MaxLength = 100;
        ConstructionMaterialMiningLbl: Label 'Construction Material Mining', MaxLength = 100;
        GravelAndSandQuarryingLbl: Label 'Gravel and Sand Quarrying', MaxLength = 100;
        MiningNecLbl: Label 'Mining NEC', MaxLength = 100;
        ServicesToMiningLbl: Label 'Services to Mining', MaxLength = 100;
        ExplorationLbl: Label 'Exploration', MaxLength = 100;
        PetroleumExplorationServicesLbl: Label 'Petroleum Exploration Services', MaxLength = 100;
        MineralExplorationServicesLbl: Label 'Mineral Exploration Services', MaxLength = 100;
        OtherMiningServicesLbl: Label 'Other Mining Services', MaxLength = 100;
        ManufacturingLbl: Label 'Manufacturing', MaxLength = 100;
        FoodBeverageAndTobaccoLbl: Label 'Food - Beverage and Tobacco', MaxLength = 100;
        MeatProcessingLbl: Label 'Meat Processing', MaxLength = 100;
        PoultryProcessingLbl: Label 'Poultry Processing', MaxLength = 100;
        DairyProductManufacturingLbl: Label 'Dairy Product Manufacturing', MaxLength = 100;
        MilkAndCreamProcessingLbl: Label 'Milk and Cream Processing', MaxLength = 100;
        IceCreamManufacturingLbl: Label 'Ice Cream Manufacturing', MaxLength = 100;
        FruitAndVegetableProcessingLbl: Label 'Fruit and Vegetable Processing', MaxLength = 100;
        OilAndFatManufacturingLbl: Label 'Oil and Fat Manufacturing', MaxLength = 100;
        BakeryProductManufacturingLbl: Label 'Bakery Product Manufacturing', MaxLength = 100;
        BreadManufacturingLbl: Label 'Bread Manufacturing', MaxLength = 100;
        CakeAndPastryManufacturingLbl: Label 'Cake and Pastry Manufacturing', MaxLength = 100;
        BiscuitManufacturingLbl: Label 'Biscuit Manufacturing', MaxLength = 100;
        OtherFoodManufacturingLbl: Label 'Other Food Manufacturing', MaxLength = 100;
        SugarManufacturingLbl: Label 'Sugar Manufacturing', MaxLength = 100;
        ConfectioneryManufacturingLbl: Label 'Confectionery Manufacturing', MaxLength = 100;
        SeafoodProcessingLbl: Label 'Seafood Processing', MaxLength = 100;
        FoodManufacturingNecLbl: Label 'Food Manufacturing NEC', MaxLength = 100;
        BeerAndMaltManufacturingLbl: Label 'Beer and Malt Manufacturing', MaxLength = 100;
        WineManufacturingLbl: Label 'Wine Manufacturing', MaxLength = 100;
        SpiritManufacturingLbl: Label 'Spirit Manufacturing', MaxLength = 100;
        TobaccoProductManufacturingLbl: Label 'Tobacco Product Manufacturing', MaxLength = 100;
        WoolScouringLbl: Label 'Wool Scouring', MaxLength = 100;
        CottonTextileManufacturingLbl: Label 'Cotton Textile Manufacturing', MaxLength = 100;
        WoolTextileManufacturingLbl: Label 'Wool Textile Manufacturing', MaxLength = 100;
        TextileFinishingLbl: Label 'Textile Finishing', MaxLength = 100;
        TextileProductManufacturingLbl: Label 'Textile Product Manufacturing', MaxLength = 100;
        KnittingMillsLbl: Label 'Knitting Mills', MaxLength = 100;
        HosieryManufacturingLbl: Label 'Hosiery Manufacturing', MaxLength = 100;
        ClothingManufacturingLbl: Label 'Clothing Manufacturing', MaxLength = 100;
        ClothingManufacturingNecLbl: Label 'Clothing Manufacturing NEC', MaxLength = 100;
        FootwearManufacturingLbl: Label 'Footwear Manufacturing', MaxLength = 100;
        LogSawmillingLbl: Label 'Log Sawmilling', MaxLength = 100;
        WoodChippingLbl: Label 'Wood Chipping', MaxLength = 100;
        TimberResawingAndDressingLbl: Label 'Timber Resawing and Dressing', MaxLength = 100;
        FabricatedWoodManufacturingLbl: Label 'Fabricated Wood Manufacturing', MaxLength = 100;
        WoodProductManufacturingNecLbl: Label 'Wood Product Manufacturing NEC', MaxLength = 100;
        PaperStationeryManufacturingLbl: Label 'Paper Stationery Manufacturing', MaxLength = 100;
        PrintingLbl: Label 'Printing', MaxLength = 100;
        ServicesToPrintingLbl: Label 'Services to Printing', MaxLength = 100;
        PublishingLbl: Label 'Publishing', MaxLength = 100;
        OtherPeriodicalPublishingLbl: Label 'Other Periodical Publishing', MaxLength = 100;
        BookAndOtherPublishingLbl: Label 'Book and Other Publishing', MaxLength = 100;
        PetroleumRefiningLbl: Label 'Petroleum Refining', MaxLength = 100;
        BasicChemicalManufacturingLbl: Label 'Basic Chemical Manufacturing', MaxLength = 100;
        FertiliserManufacturingLbl: Label 'Fertiliser Manufacturing', MaxLength = 100;
        IndustrialGasManufacturingLbl: Label 'Industrial Gas Manufacturing', MaxLength = 100;
        SyntheticResinManufacturingLbl: Label 'Synthetic Resin Manufacturing', MaxLength = 100;
        ExplosiveManufacturingLbl: Label 'Explosive Manufacturing', MaxLength = 100;
        PaintManufacturingLbl: Label 'Paint Manufacturing', MaxLength = 100;
        PesticideManufacturingLbl: Label 'Pesticide Manufacturing', MaxLength = 100;
        InkManufacturingLbl: Label 'Ink Manufacturing', MaxLength = 100;
        RubberProductManufacturingLbl: Label 'Rubber Product Manufacturing', MaxLength = 100;
        RubberTyreManufacturingLbl: Label 'Rubber Tyre Manufacturing', MaxLength = 100;
        PlasticProductManufacturingLbl: Label 'Plastic Product Manufacturing', MaxLength = 100;
        CeramicManufacturingLbl: Label 'Ceramic Manufacturing', MaxLength = 100;
        ClayBrickManufacturingLbl: Label 'Clay Brick Manufacturing', MaxLength = 100;
        CeramicProductManufacturingLbl: Label 'Ceramic Product Manufacturing', MaxLength = 100;
        CementAndLimeManufacturingLbl: Label 'Cement and Lime Manufacturing', MaxLength = 100;
        PlasterProductManufacturingLbl: Label 'Plaster Product Manufacturing', MaxLength = 100;
        ConcreteSlurryManufacturingLbl: Label 'Concrete Slurry Manufacturing', MaxLength = 100;
        MetalProductManufacturingLbl: Label 'Metal Product Manufacturing', MaxLength = 100;
        IronAndSteelManufacturingLbl: Label 'Iron and Steel Manufacturing', MaxLength = 100;
        AluminaProductionLbl: Label 'Alumina Production', MaxLength = 100;
        AluminiumSmeltingLbl: Label 'Aluminium Smelting', MaxLength = 100;
        NonFerrousMetalCastingLbl: Label 'Non-Ferrous Metal Casting', MaxLength = 100;
        StructuralSteelFabricatingLbl: Label 'Structural Steel Fabricating', MaxLength = 100;
        MetalContainerManufacturingLbl: Label 'Metal Container Manufacturing', MaxLength = 100;
        MetalCoatingAndFinishingLbl: Label 'Metal Coating and Finishing', MaxLength = 100;
        MotorVehicleManufacturingLbl: Label 'Motor Vehicle Manufacturing', MaxLength = 100;
        ShipbuildingLbl: Label 'Shipbuilding', MaxLength = 100;
        BoatbuildingLbl: Label 'Boatbuilding', MaxLength = 100;
        AircraftManufacturingLbl: Label 'Aircraft Manufacturing', MaxLength = 100;
        BatteryManufacturingLbl: Label 'Battery Manufacturing', MaxLength = 100;
        OtherManufacturingLbl: Label 'Other Manufacturing', MaxLength = 100;
        FurnitureManufacturingLbl: Label 'Furniture Manufacturing', MaxLength = 100;
        FurnitureManufacturingNecLbl: Label 'Furniture Manufacturing NEC', MaxLength = 100;
        ManufacturingNecLbl: Label 'Manufacturing NEC', MaxLength = 100;
        ElectricityAndGasSupplyLbl: Label 'Electricity and Gas Supply', MaxLength = 100;
        ElectricitySupplyLbl: Label 'Electricity Supply', MaxLength = 100;
        GasSupplyLbl: Label 'Gas Supply', MaxLength = 100;
        WaterSupplyLbl: Label 'Water Supply', MaxLength = 100;
        SewerageAndDrainageServicesLbl: Label 'Sewerage and Drainage Services', MaxLength = 100;
        ConstructionLbl: Label 'Construction', MaxLength = 100;
        GeneralConstructionLbl: Label 'General Construction', MaxLength = 100;
        BuildingConstructionLbl: Label 'Building Construction', MaxLength = 100;
        HouseConstructionLbl: Label 'House Construction', MaxLength = 100;
        NonBuildingConstructionLbl: Label 'Non-Building Construction', MaxLength = 100;
        RoadAndBridgeConstructionLbl: Label 'Road and Bridge Construction', MaxLength = 100;
        NonBuildingConstructionNecLbl: Label 'Non-Building Construction NEC', MaxLength = 100;
        ConstructionTradeServicesLbl: Label 'Construction Trade Services', MaxLength = 100;
        SitePreparationServicesLbl: Label 'Site Preparation Services', MaxLength = 100;
        BuildingStructureServicesLbl: Label 'Building Structure Services', MaxLength = 100;
        ConcretingServicesLbl: Label 'Concreting Services', MaxLength = 100;
        BricklayingServicesLbl: Label 'Bricklaying Services', MaxLength = 100;
        RoofingServicesLbl: Label 'Roofing Services', MaxLength = 100;
        InstallationTradeServicesLbl: Label 'Installation Trade Services', MaxLength = 100;
        PlumbingServicesLbl: Label 'Plumbing Services', MaxLength = 100;
        ElectricalServicesLbl: Label 'Electrical Services', MaxLength = 100;
        BuildingCompletionServicesLbl: Label 'Building Completion Services', MaxLength = 100;
        CarpentryServicesLbl: Label 'Carpentry Services', MaxLength = 100;
        TilingAndCarpetingServicesLbl: Label 'Tiling and Carpeting Services', MaxLength = 100;
        GlazingServicesLbl: Label 'Glazing Services', MaxLength = 100;
        OtherConstructionServicesLbl: Label 'Other Construction Services', MaxLength = 100;
        LandscapingServicesLbl: Label 'Landscaping Services', MaxLength = 100;
        ConstructionServicesNecLbl: Label 'Construction Services NEC', MaxLength = 100;
        WholesaleTradeLbl: Label 'Wholesale Trade', MaxLength = 100;
        BasicMaterialWholesalingLbl: Label 'Basic Material Wholesaling', MaxLength = 100;
        FarmProduceWholesalingLbl: Label 'Farm Produce Wholesaling', MaxLength = 100;
        WoolWholesalingLbl: Label 'Wool Wholesaling', MaxLength = 100;
        CerealGrainWholesalingLbl: Label 'Cereal Grain Wholesaling', MaxLength = 100;
        PetroleumProductWholesalingLbl: Label 'Petroleum Product Wholesaling', MaxLength = 100;
        MetalAndMineralWholesalingLbl: Label 'Metal and Mineral Wholesaling', MaxLength = 100;
        ChemicalWholesalingLbl: Label 'Chemical Wholesaling', MaxLength = 100;
        BuildersSuppliesWholesalingLbl: Label 'Builders Supplies Wholesaling', MaxLength = 100;
        TimberWholesalingLbl: Label 'Timber Wholesaling', MaxLength = 100;
        ComputerWholesalingLbl: Label 'Computer Wholesaling', MaxLength = 100;
        MotorVehicleWholesalingLbl: Label 'Motor Vehicle Wholesaling', MaxLength = 100;
        CarWholesalingLbl: Label 'Car Wholesaling', MaxLength = 100;
        CommercialVehicleWholesalingLbl: Label 'Commercial Vehicle Wholesaling', MaxLength = 100;
        MotorVehicleNewPartDealingLbl: Label 'Motor Vehicle New Part Dealing', MaxLength = 100;
        MeatWholesalingLbl: Label 'Meat Wholesaling', MaxLength = 100;
        DairyProduceWholesalingLbl: Label 'Dairy Produce Wholesaling', MaxLength = 100;
        FishWholesalingLbl: Label 'Fish Wholesaling', MaxLength = 100;
        LiquorWholesalingLbl: Label 'Liquor Wholesaling', MaxLength = 100;
        TobaccoProductWholesalingLbl: Label 'Tobacco Product Wholesaling', MaxLength = 100;
        GroceryWholesalingNecLbl: Label 'Grocery Wholesaling NEC', MaxLength = 100;
        TextileProductWholesalingLbl: Label 'Textile Product Wholesaling', MaxLength = 100;
        ClothingWholesalingLbl: Label 'Clothing Wholesaling', MaxLength = 100;
        FootwearWholesalingLbl: Label 'Footwear Wholesaling', MaxLength = 100;
        HouseholdGoodWholesalingLbl: Label 'Household Good Wholesaling', MaxLength = 100;
        FurnitureWholesalingLbl: Label 'Furniture Wholesaling', MaxLength = 100;
        FloorCoveringWholesalingLbl: Label 'Floor Covering Wholesaling', MaxLength = 100;
        HouseholdGoodWholesalingNecLbl: Label 'Household Good Wholesaling NEC', MaxLength = 100;
        OtherWholesalingLbl: Label 'Other Wholesaling', MaxLength = 100;
        BookAndMagazineWholesalingLbl: Label 'Book and Magazine Wholesaling', MaxLength = 100;
        PaperProductWholesalingLbl: Label 'Paper Product Wholesaling', MaxLength = 100;
        WholesalingNecLbl: Label 'Wholesaling NEC', MaxLength = 100;
        RetailTradeLbl: Label 'Retail Trade', MaxLength = 100;
        FoodRetailingLbl: Label 'Food Retailing', MaxLength = 100;
        SupermarketAndGroceryStoresLbl: Label 'Supermarket and Grocery Stores', MaxLength = 100;
        SpecialisedFoodRetailingLbl: Label 'Specialised Food Retailing', MaxLength = 100;
        FruitAndVegetableRetailingLbl: Label 'Fruit and Vegetable Retailing', MaxLength = 100;
        LiquorRetailingLbl: Label 'Liquor Retailing', MaxLength = 100;
        BreadAndCakeRetailingLbl: Label 'Bread and Cake Retailing', MaxLength = 100;
        TakeawayFoodRetailingLbl: Label 'Takeaway Food Retailing', MaxLength = 100;
        MilkVendingLbl: Label 'Milk Vending', MaxLength = 100;
        SpecialisedFoodRetailingNecLbl: Label 'Specialised Food Retailing NEC', MaxLength = 100;
        DepartmentStoresLbl: Label 'Department Stores', MaxLength = 100;
        ClothingRetailingLbl: Label 'Clothing Retailing', MaxLength = 100;
        FootwearRetailingLbl: Label 'Footwear Retailing', MaxLength = 100;
        FurnitureRetailingLbl: Label 'Furniture Retailing', MaxLength = 100;
        FloorCoveringRetailingLbl: Label 'Floor Covering Retailing', MaxLength = 100;
        DomesticApplianceRetailingLbl: Label 'Domestic Appliance Retailing', MaxLength = 100;
        RecordedMusicRetailingLbl: Label 'Recorded Music Retailing', MaxLength = 100;
        RecreationalGoodRetailingLbl: Label 'Recreational Good Retailing', MaxLength = 100;
        ToyAndGameRetailingLbl: Label 'Toy and Game Retailing', MaxLength = 100;
        MarineEquipmentRetailingLbl: Label 'Marine Equipment Retailing', MaxLength = 100;
        GardenSuppliesRetailingLbl: Label 'Garden Supplies Retailing', MaxLength = 100;
        FlowerRetailingLbl: Label 'Flower Retailing', MaxLength = 100;
        WatchAndJewelleryRetailingLbl: Label 'Watch and Jewellery Retailing', MaxLength = 100;
        RetailingNecLbl: Label 'Retailing NEC', MaxLength = 100;
        MotorVehicleRetailingLbl: Label 'Motor Vehicle Retailing', MaxLength = 100;
        CarRetailingLbl: Label 'Car Retailing', MaxLength = 100;
        MotorCycleDealingLbl: Label 'Motor Cycle Dealing', MaxLength = 100;
        TrailerAndCaravanDealingLbl: Label 'Trailer and Caravan Dealing', MaxLength = 100;
        MotorVehicleServicesLbl: Label 'Motor Vehicle Services', MaxLength = 100;
        AutomotiveFuelRetailingLbl: Label 'Automotive Fuel Retailing', MaxLength = 100;
        AutomotiveElectricalServicesLbl: Label 'Automotive Electrical Services', MaxLength = 100;
        SmashRepairingLbl: Label 'Smash Repairing', MaxLength = 100;
        TyreRetailingLbl: Label 'Tyre Retailing', MaxLength = 100;
        AccommodationLbl: Label 'Accommodation', MaxLength = 100;
        PubsTavernsAndBarsLbl: Label 'Pubs - Taverns and Bars', MaxLength = 100;
        CafesAndRestaurantsLbl: Label 'Cafes and Restaurants', MaxLength = 100;
        ClubsHospitalityLbl: Label 'Clubs (Hospitality)', MaxLength = 100;
        TransportAndStorageLbl: Label 'Transport and Storage', MaxLength = 100;
        RoadTransportLbl: Label 'Road Transport', MaxLength = 100;
        RoadFreightTransportLbl: Label 'Road Freight Transport', MaxLength = 100;
        RoadPassengerTransportLbl: Label 'Road Passenger Transport', MaxLength = 100;
        LongDistanceBusTransportLbl: Label 'Long Distance Bus Transport', MaxLength = 100;
        RailTransportLbl: Label 'Rail Transport', MaxLength = 100;
        WaterTransportLbl: Label 'Water Transport', MaxLength = 100;
        InternationalSeaTransportLbl: Label 'International Sea Transport', MaxLength = 100;
        CoastalWaterTransportLbl: Label 'Coastal Water Transport', MaxLength = 100;
        InlandWaterTransportLbl: Label 'Inland Water Transport', MaxLength = 100;
        AirAndSpaceTransportLbl: Label 'Air and Space Transport', MaxLength = 100;
        OtherTransportLbl: Label 'Other Transport', MaxLength = 100;
        PipelineTransportLbl: Label 'Pipeline Transport', MaxLength = 100;
        TransportNecLbl: Label 'Transport NEC', MaxLength = 100;
        ServicesToTransportLbl: Label 'Services to Transport', MaxLength = 100;
        ServicesToRoadTransportLbl: Label 'Services to Road Transport', MaxLength = 100;
        ParkingServicesLbl: Label 'Parking Services', MaxLength = 100;
        ServicesToRoadTransportNecLbl: Label 'Services to Road Transport NEC', MaxLength = 100;
        ServicesToWaterTransportLbl: Label 'Services to Water Transport', MaxLength = 100;
        StevedoringLbl: Label 'Stevedoring', MaxLength = 100;
        WaterTransportTerminalsLbl: Label 'Water Transport Terminals', MaxLength = 100;
        PortOperatorsLbl: Label 'Port Operators', MaxLength = 100;
        ServicesToAirTransportLbl: Label 'Services to Air Transport', MaxLength = 100;
        OtherServicesToTransportLbl: Label 'Other Services to Transport', MaxLength = 100;
        TravelAgencyServicesLbl: Label 'Travel Agency Services', MaxLength = 100;
        RoadFreightForwardingLbl: Label 'Road Freight Forwarding', MaxLength = 100;
        CustomsAgencyServicesLbl: Label 'Customs Agency Services', MaxLength = 100;
        ServicesToTransportNecLbl: Label 'Services to Transport NEC', MaxLength = 100;
        StorageLbl: Label 'Storage', MaxLength = 100;
        GrainStorageLbl: Label 'Grain Storage', MaxLength = 100;
        StorageNecLbl: Label 'Storage NEC', MaxLength = 100;
        CommunicationServicesLbl: Label 'Communication Services', MaxLength = 100;
        PostalAndCourierServicesLbl: Label 'Postal and Courier Services', MaxLength = 100;
        PostalServicesLbl: Label 'Postal Services', MaxLength = 100;
        CourierServicesLbl: Label 'Courier Services', MaxLength = 100;
        TelecommunicationServicesLbl: Label 'Telecommunication Services', MaxLength = 100;
        FinanceAndInsuranceLbl: Label 'Finance and Insurance', MaxLength = 100;
        FinanceLbl: Label 'Finance', MaxLength = 100;
        CentralBankLbl: Label 'Central Bank', MaxLength = 100;
        DepositTakingFinanciersLbl: Label 'Deposit Taking Financiers', MaxLength = 100;
        BanksLbl: Label 'Banks', MaxLength = 100;
        BuildingSocietiesLbl: Label 'Building Societies', MaxLength = 100;
        CreditUnionsLbl: Label 'Credit Unions', MaxLength = 100;
        MoneyMarketDealersLbl: Label 'Money Market Dealers', MaxLength = 100;
        DepositTakingFinanciersNecLbl: Label 'Deposit Taking Financiers NEC', MaxLength = 100;
        OtherFinanciersLbl: Label 'Other Financiers', MaxLength = 100;
        FinancialAssetInvestorsLbl: Label 'Financial Asset Investors', MaxLength = 100;
        InsuranceLbl: Label 'Insurance', MaxLength = 100;
        LifeInsuranceLbl: Label 'Life  Insurance', MaxLength = 100;
        SuperannuationFundsLbl: Label 'Superannuation  Funds', MaxLength = 100;
        OtherInsuranceLbl: Label 'Other Insurance', MaxLength = 100;
        HealthInsuranceLbl: Label 'Health  Insurance', MaxLength = 100;
        GeneralInsuranceLbl: Label 'General  Insurance', MaxLength = 100;
        ServicesToInsuranceLbl: Label 'Services to Insurance', MaxLength = 100;
        PropertyAndBusinessServicesLbl: Label 'Property and Business Services', MaxLength = 100;
        PropertyServicesLbl: Label 'Property Services', MaxLength = 100;
        ResidentialPropertyOperatorsLbl: Label 'Residential Property Operators', MaxLength = 100;
        RealEstateAgentsLbl: Label 'Real Estate Agents', MaxLength = 100;
        NonFinancialAssetInvestorsLbl: Label 'Non-Financial Asset Investors', MaxLength = 100;
        MotorVehicleHiringLbl: Label 'Motor Vehicle Hiring', MaxLength = 100;
        PlantHiringOrLeasingLbl: Label 'Plant Hiring or Leasing', MaxLength = 100;
        BusinessServicesLbl: Label 'Business Services', MaxLength = 100;
        ScientificResearchLbl: Label 'Scientific Research', MaxLength = 100;
        TechnicalServicesLbl: Label 'Technical Services', MaxLength = 100;
        ArchitecturalServicesLbl: Label 'Architectural Services', MaxLength = 100;
        SurveyingServicesLbl: Label 'Surveying Services', MaxLength = 100;
        TechnicalServicesNecLbl: Label 'Technical Services NEC', MaxLength = 100;
        ComputerServicesLbl: Label 'Computer Services', MaxLength = 100;
        DataProcessingServicesLbl: Label 'Data Processing Services', MaxLength = 100;
        ComputerMaintenanceServicesLbl: Label 'Computer Maintenance Services', MaxLength = 100;
        ComputerConsultancyServicesLbl: Label 'Computer Consultancy Services', MaxLength = 100;
        LegalAndAccountingServicesLbl: Label 'Legal and Accounting Services', MaxLength = 100;
        LegalServicesLbl: Label 'Legal Services', MaxLength = 100;
        AccountingServicesLbl: Label 'Accounting Services', MaxLength = 100;
        AdvertisingServicesLbl: Label 'Advertising Services', MaxLength = 100;
        MarketResearchServicesLbl: Label 'Market Research Services', MaxLength = 100;
        BusinessManagementServicesLbl: Label 'Business Management Services', MaxLength = 100;
        OtherBusinessServicesLbl: Label 'Other Business Services', MaxLength = 100;
        EmploymentPlacementServicesLbl: Label 'Employment Placement Services', MaxLength = 100;
        ContractStaffServicesLbl: Label 'Contract Staff Services', MaxLength = 100;
        SecretarialServicesLbl: Label 'Secretarial Services', MaxLength = 100;
        PestControlServicesLbl: Label 'Pest Control Services', MaxLength = 100;
        CleaningServicesLbl: Label 'Cleaning Services', MaxLength = 100;
        ContractPackingServicesNecLbl: Label 'Contract Packing Services NEC', MaxLength = 100;
        BusinessServicesNecLbl: Label 'Business Services NEC', MaxLength = 100;
        GovernmentAdministrationLbl: Label 'Government Administration', MaxLength = 100;
        JusticeLbl: Label 'Justice', MaxLength = 100;
        DefenceLbl: Label 'Defence', MaxLength = 100;
        EducationLbl: Label 'Education', MaxLength = 100;
        PreschoolEducationLbl: Label 'Preschool Education', MaxLength = 100;
        SchoolEducationLbl: Label 'School Education', MaxLength = 100;
        PrimaryEducationLbl: Label 'Primary Education', MaxLength = 100;
        SecondaryEducationLbl: Label 'Secondary Education', MaxLength = 100;
        SpecialSchoolEducationLbl: Label 'Special School Education', MaxLength = 100;
        PostSchoolEducationLbl: Label 'Post School Education', MaxLength = 100;
        HigherEducationLbl: Label 'Higher Education', MaxLength = 100;
        OtherEducationLbl: Label 'Other Education', MaxLength = 100;
        HealthAndCommunityServicesLbl: Label 'Health and Community Services', MaxLength = 100;
        HealthServicesLbl: Label 'Health Services', MaxLength = 100;
        HospitalsAndNursingHomesLbl: Label 'Hospitals and Nursing Homes', MaxLength = 100;
        PsychiatricHospitalsLbl: Label 'Psychiatric Hospitals', MaxLength = 100;
        NursingHomesLbl: Label 'Nursing Homes', MaxLength = 100;
        MedicalAndDentalServicesLbl: Label 'Medical and Dental Services', MaxLength = 100;
        SpecialistMedicalServicesLbl: Label 'Specialist Medical Services', MaxLength = 100;
        DentalServicesLbl: Label 'Dental Services', MaxLength = 100;
        OtherHealthServicesLbl: Label 'Other Health Services', MaxLength = 100;
        PathologyServicesLbl: Label 'Pathology Services', MaxLength = 100;
        AmbulanceServicesLbl: Label 'Ambulance Services', MaxLength = 100;
        CommunityHealthCentresLbl: Label 'Community Health Centres', MaxLength = 100;
        PhysiotherapyServicesLbl: Label 'Physiotherapy Services', MaxLength = 100;
        ChiropracticServicesLbl: Label 'Chiropractic Services', MaxLength = 100;
        HealthServicesNecLbl: Label 'Health Services NEC', MaxLength = 100;
        VeterinaryServicesLbl: Label 'Veterinary Services', MaxLength = 100;
        CommunityServicesLbl: Label 'Community Services', MaxLength = 100;
        ChildCareServicesLbl: Label 'Child Care Services', MaxLength = 100;
        CommunityCareServicesLbl: Label 'Community Care Services', MaxLength = 100;
        AccommodationForTheAgedLbl: Label 'Accommodation for the Aged', MaxLength = 100;
        ResidentialCareServicesNecLbl: Label 'Residential Care Services NEC', MaxLength = 100;
        FilmAndVideoServicesLbl: Label 'Film and Video Services', MaxLength = 100;
        FilmAndVideoProductionLbl: Label 'Film and Video Production', MaxLength = 100;
        FilmAndVideoDistributionLbl: Label 'Film and Video Distribution', MaxLength = 100;
        MotionPictureExhibitionLbl: Label 'Motion Picture Exhibition', MaxLength = 100;
        RadioAndTelevisionServicesLbl: Label 'Radio and Television Services', MaxLength = 100;
        RadioServicesLbl: Label 'Radio Services', MaxLength = 100;
        TelevisionServicesLbl: Label 'Television Services', MaxLength = 100;
        LibrariesLbl: Label 'Libraries', MaxLength = 100;
        MuseumsLbl: Label 'Museums', MaxLength = 100;
        ParksAndGardensLbl: Label 'Parks and Gardens', MaxLength = 100;
        ZoologicalAndBotanicGardensLbl: Label 'Zoological and Botanic Gardens', MaxLength = 100;
        RecreationalParksAndGardensLbl: Label 'Recreational Parks and Gardens', MaxLength = 100;
        ArtsLbl: Label 'Arts', MaxLength = 100;
        MusicAndTheatreProductionsLbl: Label 'Music and Theatre Productions', MaxLength = 100;
        CreativeArtsLbl: Label 'Creative Arts', MaxLength = 100;
        ServicesToTheArtsLbl: Label 'Services to the Arts', MaxLength = 100;
        SoundRecordingStudiosLbl: Label 'Sound Recording Studios', MaxLength = 100;
        PerformingArtsVenuesLbl: Label 'Performing Arts Venues', MaxLength = 100;
        ServicesToTheArtsNecLbl: Label 'Services to the Arts NEC', MaxLength = 100;
        SportAndRecreationLbl: Label 'Sport and Recreation', MaxLength = 100;
        SportLbl: Label 'Sport', MaxLength = 100;
        HorseAndDogRacingLbl: Label 'Horse and Dog Racing', MaxLength = 100;
        GamblingServicesLbl: Label 'Gambling Services', MaxLength = 100;
        LotteriesLbl: Label 'Lotteries', MaxLength = 100;
        CasinosLbl: Label 'Casinos', MaxLength = 100;
        GamblingServicesNecLbl: Label 'Gambling Services NEC', MaxLength = 100;
        OtherRecreationServicesLbl: Label 'Other Recreation Services', MaxLength = 100;
        PersonalAndOtherServicesLbl: Label 'Personal and Other Services', MaxLength = 100;
        PersonalServicesLbl: Label 'Personal Services', MaxLength = 100;
        VideoHireOutletsLbl: Label 'Video Hire Outlets', MaxLength = 100;
        OtherPersonalServicesLbl: Label 'Other Personal Services', MaxLength = 100;
        LaundriesAndDryCleanersLbl: Label 'Laundries and Dry-Cleaners', MaxLength = 100;
        PhotographicFilmProcessingLbl: Label 'Photographic Film Processing', MaxLength = 100;
        PhotographicStudiosLbl: Label 'Photographic Studios', MaxLength = 100;
        GardeningServicesLbl: Label 'Gardening Services', MaxLength = 100;
        HairdressingAndBeautySalonsLbl: Label 'Hairdressing and Beauty Salons', MaxLength = 100;
        PersonalServicesNecLbl: Label 'Personal Services NEC', MaxLength = 100;
        OtherServicesLbl: Label 'Other Services', MaxLength = 100;
        ReligiousOrganisationsLbl: Label 'Religious Organisations', MaxLength = 100;
        InterestGroupsLbl: Label 'Interest Groups', MaxLength = 100;
        LabourAssociationsLbl: Label 'Labour Associations', MaxLength = 100;
        InterestGroupsNecLbl: Label 'Interest Groups NEC', MaxLength = 100;
        PoliceServicesLbl: Label 'Police Services', MaxLength = 100;
        CorrectiveCentresLbl: Label 'Corrective Centres', MaxLength = 100;
        FireBrigadeServicesLbl: Label 'Fire Brigade Services', MaxLength = 100;
        WasteDisposalServicesLbl: Label 'Waste Disposal Services', MaxLength = 100;
}