// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19071 "Create IN Ministry"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertMinistry(Agriculture(), AgricultureLbl, false);
        ContosoINTaxSetup.InsertMinistry(AtomicEnergy(), AtomicEnergyLbl, false);
        ContosoINTaxSetup.InsertMinistry(Fertilizers(), FertilizersLbl, false);
        ContosoINTaxSetup.InsertMinistry(ChemicalsPetrochemicals(), ChemicalsPetrochemicalsLbl, false);
        ContosoINTaxSetup.InsertMinistry(CivilAviationTourism(), CivilAviationTourismLbl, false);
        ContosoINTaxSetup.InsertMinistry(Coal(), CoalLbl, false);
        ContosoINTaxSetup.InsertMinistry(ConsumerAffairsFoodPublicDistribution(), ConsumerAffairsFoodPublicDistributionLbl, false);
        ContosoINTaxSetup.InsertMinistry(CommerceTextiles(), CommerceTextilesLbl, false);
        ContosoINTaxSetup.InsertMinistry(EnvironmentForestsMinistryofEarthScience(), EnvironmentForestsMinistryofEarthScienceLbl, false);
        ContosoINTaxSetup.InsertMinistry(ExternalAffairsOverseasIndianAffairs(), ExternalAffairsOverseasIndianAffairsLbl, false);
        ContosoINTaxSetup.InsertMinistry(Finance(), FinanceLbl, false);
        ContosoINTaxSetup.InsertMinistry(CentralBoardofDirectTaxes(), CentralBoardofDirectTaxesLbl, false);
        ContosoINTaxSetup.InsertMinistry(CentralBoardExciseCustoms(), CentralBoardExciseCustomsLbl, false);
        ContosoINTaxSetup.InsertMinistry(ContollerAidAccountsAudit(), ContollerAidAccountsAuditLbl, false);
        ContosoINTaxSetup.InsertMinistry(CentralPensionAccountingOffice(), CentralPensionAccountingOfficeLbl, false);
        ContosoINTaxSetup.InsertMinistry(FoodProcessingIndustries(), FoodProcessingIndustriesLbl, false);
        ContosoINTaxSetup.InsertMinistry(HealthFamilyWelfare(), HealthFamilyWelfareLbl, false);
        ContosoINTaxSetup.InsertMinistry(HomeAffairsDevelopmentofNorthEasternRegion(), HomeAffairsDevelopmentofNorthEasternRegionLbl, false);
        ContosoINTaxSetup.InsertMinistry(HumanResourceDevelopment(), HumanResourceDevelopmentLbl, false);
        ContosoINTaxSetup.InsertMinistry(Industry(), IndustryLbl, false);
        ContosoINTaxSetup.InsertMinistry(InformationBroadcasting(), InformationBroadcastingLbl, false);
        ContosoINTaxSetup.InsertMinistry(TelecommunicationInformationTechnology(), TelecommunicationInformationTechnologyLbl, false);
        ContosoINTaxSetup.InsertMinistry(Labour(), LabourLbl, false);
        ContosoINTaxSetup.InsertMinistry(LawJusticeCompanyAffairs(), LawJusticeCompanyAffairsLbl, false);
        ContosoINTaxSetup.InsertMinistry(PersonnelPublicGrievancesPesions(), PersonnelPublicGrievancesPesionsLbl, false);
        ContosoINTaxSetup.InsertMinistry(PetroleumNaturalGas(), PetroleumNaturalGasLbl, false);
        ContosoINTaxSetup.InsertMinistry(PlannningStatisticsProgrammeImplementation(), PlannningStatisticsProgrammeImplementationLbl, false);
        ContosoINTaxSetup.InsertMinistry(Power(), PowerLbl, false);
        ContosoINTaxSetup.InsertMinistry(NewRenewableEnergy(), NewRenewableEnergyLbl, false);
        ContosoINTaxSetup.InsertMinistry(RuralDevelopmentPanchayatiRaj(), RuralDevelopmentPanchayatiRajLbl, false);
        ContosoINTaxSetup.InsertMinistry(ScienceTechnology(), ScienceTechnologyLbl, false);
        ContosoINTaxSetup.InsertMinistry(Space(), SpaceLbl, false);
        ContosoINTaxSetup.InsertMinistry(Steel(), SteelLbl, false);
        ContosoINTaxSetup.InsertMinistry(Mines(), MinesLbl, false);
        ContosoINTaxSetup.InsertMinistry(SocialJusticeEmpowerment(), SocialJusticeEmpowermentLbl, false);
        ContosoINTaxSetup.InsertMinistry(TribalAffairs(), TribalAffairsLbl, false);
        ContosoINTaxSetup.InsertMinistry(CommerceSupplyDivision(), CommerceSupplyDivisionLbl, false);
        ContosoINTaxSetup.InsertMinistry(ShippingRoadTransportHighways(), ShippingRoadTransportHighwaysLbl, false);
        ContosoINTaxSetup.InsertMinistry(UrbevelopmentUrbanEmploymentPovertyAlleviation(), UrbevelopmentUrbanEmploymentPovertyAlleviationLbl, false);
        ContosoINTaxSetup.InsertMinistry(WaterResources(), WaterResourcesLbl, false);
        ContosoINTaxSetup.InsertMinistry(PresidentsSecretariat(), PresidentsSecretariatLbl, false);
        ContosoINTaxSetup.InsertMinistry(LokSabhaSecretariat(), LokSabhaSecretariatLbl, false);
        ContosoINTaxSetup.InsertMinistry(RajyaSabhaSecretariat(), RajyaSabhaSecretariatLbl, false);
        ContosoINTaxSetup.InsertMinistry(ElectionCommission(), ElectionCommissionLbl, false);
        ContosoINTaxSetup.InsertMinistry(MinistryofDefence(), MinistryofDefenceLbl, false);
        ContosoINTaxSetup.InsertMinistry(MinistryofRailways(), MinistryofRailwaysLbl, false);
        ContosoINTaxSetup.InsertMinistry(DepartmentofPosts(), DepartmentofPostsLbl, false);
        ContosoINTaxSetup.InsertMinistry(DepartmentofTelecommunications(), DepartmentofTelecommunicationsLbl, false);
        ContosoINTaxSetup.InsertMinistry(AndamanNicobarAdministration(), AndamanNicobarAdministrationLbl, false);
        ContosoINTaxSetup.InsertMinistry(ChandigarhAdministration(), ChandigarhAdministrationLbl, false);
        ContosoINTaxSetup.InsertMinistry(DadraNagarHaveli(), DadraNagarHaveliLbl, false);
        ContosoINTaxSetup.InsertMinistry(GoaDamanDiu(), GoaDamanDiuLbl, false);
        ContosoINTaxSetup.InsertMinistry(Lakshadweep(), LakshadweepLbl, false);
        ContosoINTaxSetup.InsertMinistry(PondicherryAdministration(), PondicherryAdministrationLbl, false);
        ContosoINTaxSetup.InsertMinistry(PayAccountsOfficers(), PayAccountsOfficersLbl, false);
        ContosoINTaxSetup.InsertMinistry(MinistryofNonConventionalEnergySources(), MinistryofNonConventionalEnergySourcesLbl, false);
        ContosoINTaxSetup.InsertMinistry(GovernmentNCTofDelhi(), GovernmentNCTofDelhiLbl, false);
        ContosoINTaxSetup.InsertMinistry(Others(), OthersLbl, true);
    end;

    procedure Agriculture(): Code[3]
    begin
        exit(AgricultureTok);
    end;

    procedure AtomicEnergy(): Code[3]
    begin
        exit(AtomicEnergyTok);
    end;

    procedure Fertilizers(): Code[3]
    begin
        exit(FertilizersTok);
    end;

    procedure ChemicalsPetrochemicals(): Code[3]
    begin
        exit(ChemicalsPetrochemicalsTok);
    end;

    procedure CivilAviationTourism(): Code[3]
    begin
        exit(CivilAviationTourismTok);
    end;

    procedure Coal(): Code[3]
    begin
        exit(CoalTok);
    end;

    procedure ConsumerAffairsFoodPublicDistribution(): Code[3]
    begin
        exit(ConsumerAffairsFoodPublicDistributionTok);
    end;

    procedure CommerceTextiles(): Code[3]
    begin
        exit(CommerceTextilesTok);
    end;

    procedure EnvironmentForestsMinistryofEarthScience(): Code[3]
    begin
        exit(EnvironmentForestsMinistryofEarthScienceTok);
    end;

    procedure ExternalAffairsOverseasIndianAffairs(): Code[3]
    begin
        exit(ExternalAffairsOverseasIndianAffairsTok);
    end;

    procedure Finance(): Code[3]
    begin
        exit(FinanceTok);
    end;

    procedure CentralBoardofDirectTaxes(): Code[3]
    begin
        exit(CentralBoardofDirectTaxesTok);
    end;

    procedure CentralBoardExciseCustoms(): Code[3]
    begin
        exit(CentralBoardExciseCustomsTok);
    end;

    procedure ContollerAidAccountsAudit(): Code[3]
    begin
        exit(ContollerAidAccountsAuditTok);
    end;

    procedure CentralPensionAccountingOffice(): Code[3]
    begin
        exit(CentralPensionAccountingOfficeTok);
    end;

    procedure FoodProcessingIndustries(): Code[3]
    begin
        exit(FoodProcessingIndustriesTok);
    end;

    procedure HealthFamilyWelfare(): Code[3]
    begin
        exit(HealthFamilyWelfareTok);
    end;

    procedure HomeAffairsDevelopmentofNorthEasternRegion(): Code[3]
    begin
        exit(HomeAffairsDevelopmentofNorthEasternRegionTok);
    end;

    procedure HumanResourceDevelopment(): Code[3]
    begin
        exit(HumanResourceDevelopmentTok);
    end;

    procedure Industry(): Code[3]
    begin
        exit(IndustryTok);
    end;

    procedure InformationBroadcasting(): Code[3]
    begin
        exit(InformationBroadcastingTok);
    end;

    procedure TelecommunicationInformationTechnology(): Code[3]
    begin
        exit(TelecommunicationInformationTechnologyTok);
    end;

    procedure Labour(): Code[3]
    begin
        exit(LabourTok);
    end;

    procedure LawJusticeCompanyAffairs(): Code[3]
    begin
        exit(LawJusticeCompanyAffairsTok);
    end;

    procedure PersonnelPublicGrievancesPesions(): Code[3]
    begin
        exit(PersonnelPublicGrievancesPesionsTok);
    end;

    procedure PetroleumNaturalGas(): Code[3]
    begin
        exit(PetroleumNaturalGasTok);
    end;

    procedure PlannningStatisticsProgrammeImplementation(): Code[3]
    begin
        exit(PlannningStatisticsProgrammeImplementationTok);
    end;

    procedure Power(): Code[3]
    begin
        exit(PowerTok);
    end;

    procedure NewRenewableEnergy(): Code[3]
    begin
        exit(NewRenewableEnergyTok);
    end;

    procedure RuralDevelopmentPanchayatiRaj(): Code[3]
    begin
        exit(RuralDevelopmentPanchayatiRajTok);
    end;

    procedure ScienceTechnology(): Code[3]
    begin
        exit(ScienceTechnologyTok);
    end;

    procedure Space(): Code[3]
    begin
        exit(SpaceTok);
    end;

    procedure Steel(): Code[3]
    begin
        exit(SteelTok);
    end;

    procedure Mines(): Code[3]
    begin
        exit(MinesTok);
    end;

    procedure SocialJusticeEmpowerment(): Code[3]
    begin
        exit(SocialJusticeEmpowermentTok);
    end;

    procedure TribalAffairs(): Code[3]
    begin
        exit(TribalAffairsTok);
    end;

    procedure CommerceSupplyDivision(): Code[3]
    begin
        exit(CommerceSupplyDivisionTok);
    end;

    procedure ShippingRoadTransportHighways(): Code[3]
    begin
        exit(ShippingRoadTransportHighwaysTok);
    end;

    procedure UrbevelopmentUrbanEmploymentPovertyAlleviation(): Code[3]
    begin
        exit(UrbevelopmentUrbanEmploymentPovertyAlleviationTok);
    end;

    procedure WaterResources(): Code[3]
    begin
        exit(WaterResourcesTok);
    end;

    procedure PresidentsSecretariat(): Code[3]
    begin
        exit(PresidentsSecretariatTok);
    end;

    procedure LokSabhaSecretariat(): Code[3]
    begin
        exit(LokSabhaSecretariatTok);
    end;

    procedure RajyaSabhaSecretariat(): Code[3]
    begin
        exit(RajyaSabhaSecretariatTok);
    end;

    procedure ElectionCommission(): Code[3]
    begin
        exit(ElectionCommissionTok);
    end;

    procedure MinistryofDefence(): Code[3]
    begin
        exit(MinistryofDefenceTok);
    end;

    procedure MinistryofRailways(): Code[3]
    begin
        exit(MinistryofRailwaysTok);
    end;

    procedure DepartmentofPosts(): Code[3]
    begin
        exit(DepartmentofPostsTok);
    end;

    procedure DepartmentofTelecommunications(): Code[3]
    begin
        exit(DepartmentofTelecommunicationsTok);
    end;

    procedure AndamanNicobarAdministration(): Code[3]
    begin
        exit(AndamanNicobarAdministrationTok);
    end;

    procedure ChandigarhAdministration(): Code[3]
    begin
        exit(ChandigarhAdministrationTok);
    end;

    procedure DadraNagarHaveli(): Code[3]
    begin
        exit(DadraNagarHaveliTok);
    end;

    procedure GoaDamanDiu(): Code[3]
    begin
        exit(GoaDamanDiuTok);
    end;

    procedure Lakshadweep(): Code[3]
    begin
        exit(LakshadweepTok);
    end;

    procedure PondicherryAdministration(): Code[3]
    begin
        exit(PondicherryAdministrationTok);
    end;

    procedure PayAccountsOfficers(): Code[3]
    begin
        exit(PayAccountsOfficersTok);
    end;

    procedure MinistryofNonConventionalEnergySources(): Code[3]
    begin
        exit(MinistryofNonConventionalEnergySourcesTok);
    end;

    procedure GovernmentNCTofDelhi(): Code[3]
    begin
        exit(GovernmentNCTofDelhiTok);
    end;

    procedure Others(): Code[3]
    begin
        exit(OthersTok);
    end;


    var
        AgricultureTok: Label '01', MaxLength = 3;
        AtomicEnergyTok: Label '02', MaxLength = 3;
        FertilizersTok: Label '03', MaxLength = 3;
        ChemicalsPetrochemicalsTok: Label '04', MaxLength = 3;
        CivilAviationTourismTok: Label '05', MaxLength = 3;
        CoalTok: Label '06', MaxLength = 3;
        ConsumerAffairsFoodPublicDistributionTok: Label '07', MaxLength = 3;
        CommerceTextilesTok: Label '08', MaxLength = 3;
        EnvironmentForestsMinistryofEarthScienceTok: Label '09', MaxLength = 3;
        ExternalAffairsOverseasIndianAffairsTok: Label '10', MaxLength = 3;
        FinanceTok: Label '11', MaxLength = 3;
        CentralBoardofDirectTaxesTok: Label '12', MaxLength = 3;
        CentralBoardExciseCustomsTok: Label '13', MaxLength = 3;
        ContollerAidAccountsAuditTok: Label '14', MaxLength = 3;
        CentralPensionAccountingOfficeTok: Label '15', MaxLength = 3;
        FoodProcessingIndustriesTok: Label '16', MaxLength = 3;
        HealthFamilyWelfareTok: Label '17', MaxLength = 3;
        HomeAffairsDevelopmentofNorthEasternRegionTok: Label '18', MaxLength = 3;
        HumanResourceDevelopmentTok: Label '19', MaxLength = 3;
        IndustryTok: Label '20', MaxLength = 3;
        InformationBroadcastingTok: Label '21', MaxLength = 3;
        TelecommunicationInformationTechnologyTok: Label '22', MaxLength = 3;
        LabourTok: Label '23', MaxLength = 3;
        LawJusticeCompanyAffairsTok: Label '24', MaxLength = 3;
        PersonnelPublicGrievancesPesionsTok: Label '25', MaxLength = 3;
        PetroleumNaturalGasTok: Label '26', MaxLength = 3;
        PlannningStatisticsProgrammeImplementationTok: Label '27', MaxLength = 3;
        PowerTok: Label '28', MaxLength = 3;
        NewRenewableEnergyTok: Label '29', MaxLength = 3;
        RuralDevelopmentPanchayatiRajTok: Label '30', MaxLength = 3;
        ScienceTechnologyTok: Label '31', MaxLength = 3;
        SpaceTok: Label '32', MaxLength = 3;
        SteelTok: Label '33', MaxLength = 3;
        MinesTok: Label '34', MaxLength = 3;
        SocialJusticeEmpowermentTok: Label '35', MaxLength = 3;
        TribalAffairsTok: Label '36', MaxLength = 3;
        CommerceSupplyDivisionTok: Label '37', MaxLength = 3;
        ShippingRoadTransportHighwaysTok: Label '38', MaxLength = 3;
        UrbevelopmentUrbanEmploymentPovertyAlleviationTok: Label '39', MaxLength = 3;
        WaterResourcesTok: Label '40', MaxLength = 3;
        PresidentsSecretariatTok: Label '41', MaxLength = 3;
        LokSabhaSecretariatTok: Label '42', MaxLength = 3;
        RajyaSabhaSecretariatTok: Label '43', MaxLength = 3;
        ElectionCommissionTok: Label '44', MaxLength = 3;
        MinistryofDefenceTok: Label '45', MaxLength = 3;
        MinistryofRailwaysTok: Label '46', MaxLength = 3;
        DepartmentofPostsTok: Label '47', MaxLength = 3;
        DepartmentofTelecommunicationsTok: Label '48', MaxLength = 3;
        AndamanNicobarAdministrationTok: Label '49', MaxLength = 3;
        ChandigarhAdministrationTok: Label '50', MaxLength = 3;
        DadraNagarHaveliTok: Label '51', MaxLength = 3;
        GoaDamanDiuTok: Label '52', MaxLength = 3;
        LakshadweepTok: Label '53', MaxLength = 3;
        PondicherryAdministrationTok: Label '54', MaxLength = 3;
        PayAccountsOfficersTok: Label '55', MaxLength = 3;
        MinistryofNonConventionalEnergySourcesTok: Label '56', MaxLength = 3;
        GovernmentNCTofDelhiTok: Label '57', MaxLength = 3;
        OthersTok: Label '99', MaxLength = 3;
        AgricultureLbl: Label 'Agriculture', MaxLength = 150;
        AtomicEnergyLbl: Label 'Atomic Energy', MaxLength = 150;
        FertilizersLbl: Label 'Fertilizers', MaxLength = 150;
        ChemicalsPetrochemicalsLbl: Label 'Chemicals and Petrochemicals', MaxLength = 150;
        CivilAviationTourismLbl: Label 'Civil Aviation and Tourism', MaxLength = 150;
        CoalLbl: Label 'Coal', MaxLength = 150;
        ConsumerAffairsFoodPublicDistributionLbl: Label 'Consumer Affairs, Food and Public Distribution', MaxLength = 150;
        CommerceTextilesLbl: Label 'Commerce and Textiles', MaxLength = 150;
        EnvironmentForestsMinistryofEarthScienceLbl: Label 'Environment and Forests and Ministry of Earth Science', MaxLength = 150;
        ExternalAffairsOverseasIndianAffairsLbl: Label 'External Affairs and Overseas Indian Affairs', MaxLength = 150;
        FinanceLbl: Label 'Finance', MaxLength = 150;
        CentralBoardofDirectTaxesLbl: Label 'Central Board of Direct Taxes', MaxLength = 150;
        CentralBoardExciseCustomsLbl: Label 'Central Board of Excise and Customs', MaxLength = 150;
        ContollerAidAccountsAuditLbl: Label 'Contoller of Aid Accounts and Audit', MaxLength = 150;
        CentralPensionAccountingOfficeLbl: Label 'Central Pension Accounting Office', MaxLength = 150;
        FoodProcessingIndustriesLbl: Label 'Food Processing Industries', MaxLength = 150;
        HealthFamilyWelfareLbl: Label 'Health and Family Welfare', MaxLength = 150;
        HomeAffairsDevelopmentofNorthEasternRegionLbl: Label 'Home Affairs and Development of North Eastern Region', MaxLength = 150;
        HumanResourceDevelopmentLbl: Label 'Human Resource Development', MaxLength = 150;
        IndustryLbl: Label 'Industry', MaxLength = 150;
        InformationBroadcastingLbl: Label 'Information and Broadcasting', MaxLength = 150;
        TelecommunicationInformationTechnologyLbl: Label 'Telecommunication and Information Technology', MaxLength = 150;
        LabourLbl: Label 'Labour', MaxLength = 150;
        LawJusticeCompanyAffairsLbl: Label 'Law and Justice and Company Affairs', MaxLength = 150;
        PersonnelPublicGrievancesPesionsLbl: Label 'Personnel, Public Grievances and Pesions', MaxLength = 150;
        PetroleumNaturalGasLbl: Label 'Petroleum and Natural Gas', MaxLength = 150;
        PlannningStatisticsProgrammeImplementationLbl: Label 'Plannning, Statistics and Programme Implementation', MaxLength = 150;
        PowerLbl: Label 'Power', MaxLength = 150;
        NewRenewableEnergyLbl: Label 'New and Renewable Energy', MaxLength = 150;
        RuralDevelopmentPanchayatiRajLbl: Label 'Rural Development and Panchayati Raj', MaxLength = 150;
        ScienceTechnologyLbl: Label 'Science And Technology', MaxLength = 150;
        SpaceLbl: Label 'Space', MaxLength = 150;
        SteelLbl: Label 'Steel', MaxLength = 150;
        MinesLbl: Label 'Mines', MaxLength = 150;
        SocialJusticeEmpowermentLbl: Label 'Social Justice and Empowerment', MaxLength = 150;
        TribalAffairsLbl: Label 'Tribal Affairs', MaxLength = 150;
        CommerceSupplyDivisionLbl: Label 'D/o Commerce (Supply Division)', MaxLength = 150;
        ShippingRoadTransportHighwaysLbl: Label 'Shipping and Road Transport and Highways', MaxLength = 150;
        UrbevelopmentUrbanEmploymentPovertyAlleviationLbl: Label 'Urban Development, Urban Employment and Poverty Alleviation', MaxLength = 150;
        WaterResourcesLbl: Label 'Water Resources', MaxLength = 150;
        PresidentsSecretariatLbl: Label 'President''s Secretariat', MaxLength = 150;
        LokSabhaSecretariatLbl: Label 'Lok Sabha Secretariat', MaxLength = 150;
        RajyaSabhaSecretariatLbl: Label 'Rajya Sabha secretariat', MaxLength = 150;
        ElectionCommissionLbl: Label 'Election Commission', MaxLength = 150;
        MinistryofDefenceLbl: Label 'Ministry of Defence (Controller General of Defence Accounts)', MaxLength = 150;
        MinistryofRailwaysLbl: Label 'Ministry of Railways', MaxLength = 150;
        DepartmentofPostsLbl: Label 'Department of Posts', MaxLength = 150;
        DepartmentofTelecommunicationsLbl: Label 'Department of Telecommunications', MaxLength = 150;
        AndamanNicobarAdministrationLbl: Label 'Andaman and Nicobar Islands Administration   ', MaxLength = 150;
        ChandigarhAdministrationLbl: Label 'Chandigarh Administration', MaxLength = 150;
        DadraNagarHaveliLbl: Label 'Dadra and Nagar Haveli', MaxLength = 150;
        GoaDamanDiuLbl: Label 'Goa, Daman and Diu', MaxLength = 150;
        LakshadweepLbl: Label 'Lakshadweep', MaxLength = 150;
        PondicherryAdministrationLbl: Label 'Pondicherry Administration', MaxLength = 150;
        PayAccountsOfficersLbl: Label 'Pay and Accounts Officers (Audit)', MaxLength = 150;
        MinistryofNonConventionalEnergySourcesLbl: Label 'Ministry of Non-conventional energy sources ', MaxLength = 150;
        GovernmentNCTofDelhiLbl: Label 'Government Of NCT of Delhi ', MaxLength = 150;
        OthersLbl: Label 'Others', MaxLength = 150;
}
