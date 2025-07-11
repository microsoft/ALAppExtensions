codeunit 131107 "Library - Application Area DK"
{
    var
        AppAreaNotSupportedErr: Label 'Application area Basic %1 is not supported.', Comment = '%1 = application area';

    procedure GetApplicationAreaCache(var Cache: Dictionary of [Text, Text])
    var
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryApplicationArea.GetApplicationAreaCache(Cache);
    end;

    procedure ClearApplicationAreaCache()
    var
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryApplicationArea.ClearApplicationAreaCache()
    end;

    procedure EnableFoundationSetup()
    begin
        DisableApplicationAreaSetup();
        EnableFoundationSetupForCurrentCompany();
    end;

    procedure EnableFoundationSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateFoundationSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableFoundationSetupForCurrentProfile()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateFoundationSetupForCurrentProfile(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableFoundationSetupForCurrentUser()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateFoundationSetupForCurrentUser(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure CreateFoundationSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Validate("Basic EU", true);
        ApplicationAreaSetup.Validate("Basic DK", true);
        ApplicationAreaSetup.Validate(VAT, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateFoundationSetupForCurrentProfile(var ApplicationAreaSetup: Record "Application Area Setup")
    var
        AllProfile: Record "All Profile";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        ConfPersonalizationMgt.GetCurrentProfileNoError(AllProfile);
        ApplicationAreaSetup.Validate("Profile ID", AllProfile."Profile ID");
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Validate("Basic EU", true);
        ApplicationAreaSetup.Validate("Basic DK", true);
        ApplicationAreaSetup.Validate(VAT, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateFoundationSetupForCurrentUser(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup."User ID" := COPYSTR(UserId, 1, 50);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Validate("Basic EU", true);
        ApplicationAreaSetup.Validate("Basic DK", true);
        ApplicationAreaSetup.Validate(VAT, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure EnablAdvancedSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateAdvancedSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableBasicSetup()
    begin
        DisableApplicationAreaSetup();
        EnableBasicSetupForCurrentCompany();
    end;

    procedure EnableBasicSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateBasicSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableCommentsSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateCommentsSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableEssentialSetup()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        DisableApplicationAreaSetup();
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(Essential));
    end;

    procedure EnablePremiumSetup()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        DisableApplicationAreaSetup();
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(Premium));
    end;

    procedure EnableJobsSetup()
    begin
        DisableApplicationAreaSetup();
        EnableJobsSetupForCurrentCompany();
    end;

    procedure EnableJobsAndSuiteSetup()
    begin
        DisableApplicationAreaSetup();
        EnableJobsAndSuiteSetupForCurrentCompany();
    end;

    procedure EnableLocationsSetup()
    begin
        DisableApplicationAreaSetup();
        EnableLocationsSetupForCurrentCompany();
    end;

    procedure EnableItemChargeSetup()
    begin
        DisableApplicationAreaSetup();
        EnableItemChargeSetupForCurrentCompany();
    end;

    procedure EnableSalesAnalysisSetup()
    begin
        DisableApplicationAreaSetup();
        EnableSalesAnalysisSetupForCurrentCompany();
    end;

    procedure EnablePurchaseAnalysisSetup()
    begin
        DisableApplicationAreaSetup();
        EnablePurchaseAnalysisSetupForCurrentCompany();
    end;

    procedure EnableInventoryAnalysisSetup()
    begin
        DisableApplicationAreaSetup();
        EnableInventoryAnalysisSetupForCurrentCompany();
    end;

    procedure EnableCostAccountingSetup()
    begin
        DisableApplicationAreaSetup();
        EnableCostAccountingSetupForCurrentCompany();
    end;

    procedure EnableSalesBudgetSetup()
    begin
        DisableApplicationAreaSetup();
        EnableSalesBudgetSetupForCurrentCompany();
    end;

    procedure EnablePurchaseBudgetSetup()
    begin
        DisableApplicationAreaSetup();
        EnablePurchaseBudgetSetupForCurrentCompany();
    end;

    procedure EnableItemBudgetSetup()
    begin
        DisableApplicationAreaSetup();
        EnableItemBudgetSetupForCurrentCompany();
    end;

    procedure EnableJobsSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateJobsSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableJobsAndSuiteSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateJobsAndSuiteSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableFixedAssetsSetup()
    begin
        DisableApplicationAreaSetup();
        EnableFixedAssetsSetupForCurrentCompany();
    end;

    procedure EnableFixedAssetsSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateFixedAssetsSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableLocationsSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateLocationsSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableItemChargeSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateItemChargeSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableSalesAnalysisSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateSalesAnalysisSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnablePurchaseAnalysisSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreatePurchaseAnalysisSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableInventoryAnalysisSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateInventoryAnalysisSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableCostAccountingSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateCostAccountingSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableSalesBudgetSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateSalesBudgetSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnablePurchaseBudgetSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreatePurchaseBudgetSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableItemBudgetSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateItemBudgetSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableReservationSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateReservationSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableReservationSetup()
    begin
        DisableApplicationAreaSetup();
        EnableReservationSetupForCurrentCompany();
    end;

    procedure EnableBasicHRSetup()
    begin
        DisableApplicationAreaSetup();
        EnableBasicHRSetupForCurrentCompany();
    end;

    procedure EnableBasicHRSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateBasicHRSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableAssemblySetup()
    begin
        DisableApplicationAreaSetup();
        EnableAssemblySetupForCurrentCompany();
    end;

    procedure EnableAssemblySetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateAssemblySetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableSalesReturnOrderSetup()
    begin
        DisableApplicationAreaSetup();
        EnableSalesReturnOrderSetupForCurrentCompany();
    end;

    procedure EnableSalesReturnOrderSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateSalesReturnOrderSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnablePurchaseReturnOrderSetup()
    begin
        DisableApplicationAreaSetup();
        EnablePurchaseReturnOrderSetupForCurrentCompany();
    end;

    procedure EnablePurchaseReturnOrderSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreatePurchaseReturnOrderSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableReturnOrderSetup()
    begin
        DisableApplicationAreaSetup();
        EnableReturnOrderSetupForCurrentCompany();
    end;

    procedure EnableReturnOrderSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateReturnOrderSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnablePrepaymentsSetup()
    begin
        DisableApplicationAreaSetup();
        EnablePrepaymentsSetupForCurrentCompany();
    end;

    procedure EnablePrepaymentsSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreatePrepaymentsSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableItemTrackingSetup()
    begin
        DisableApplicationAreaSetup();
        EnableItemTrackingSetupForCurrentCompany();
    end;

    procedure EnableItemTrackingSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateItemTrackingSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableVATSetup()
    begin
        DisableApplicationAreaSetup();
        EnableVATSetupForCurrentCompany();
    end;

    procedure EnableVATSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateVATSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableBasicCountrySetup(CountryCode: Code[10])
    begin
        DisableApplicationAreaSetup();
        EnableBasicCountrySetupForCurrentCompany(CountryCode);
    end;

    procedure EnableBasicCountrySetupForCurrentCompany(CountryCode: Code[10])
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateBasicCountrySetupForCurrentCompany(ApplicationAreaSetup, CountryCode);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure EnableSalesTaxSetup()
    begin
        DisableApplicationAreaSetup();
        EnableSalesTaxSetupForCurrentCompany();
    end;

    procedure EnableSalesTaxSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateSalesTaxSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure CreateAdvancedSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Advanced, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateBasicSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateCommentsSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Comments, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateJobsSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Jobs, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateJobsAndSuiteSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Jobs, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateFixedAssetsSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Fixed Assets", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateLocationsSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Location, true);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateItemChargeSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Item Charges", true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateSalesAnalysisSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Sales Analysis", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreatePurchaseAnalysisSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Purchase Analysis", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateInventoryAnalysisSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Inventory Analysis", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateCostAccountingSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Cost Accounting", true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateSalesBudgetSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Sales Budget", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreatePurchaseBudgetSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Purchase Budget", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateItemBudgetSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Item Budget", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateBasicHRSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(BasicHR, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateAssemblySetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Assembly, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateSalesReturnOrderSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Sales Return Order", true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreatePurchaseReturnOrderSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Purch Return Order", true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateReturnOrderSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Sales Return Order", true);
        ApplicationAreaSetup.Validate("Purch Return Order", true);
        ApplicationAreaSetup.Validate("Item Charges", true);
        ApplicationAreaSetup.Validate("Fixed Assets", true);
        ApplicationAreaSetup.Validate(Jobs, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreatePrepaymentsSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Prepayments, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreateServiceManagementSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Service, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateReservationSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(Reservation, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateItemTrackingSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Item Tracking", true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateBasicCountrySetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup"; CountryCode: Code[10])
    var
        IsHandled: Boolean;
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Basic EU", true);
        ApplicationAreaSetup.Validate(Basic, true);
        case CountryCode of
            // used for functinality specific to all EU countries
            'EU':
                ApplicationAreaSetup.Validate("Basic EU", true);
            // used for country specific functionality
            'AU':
                ApplicationAreaSetup.Validate("Basic AU", true);
            'AT':
                ApplicationAreaSetup.Validate("Basic AT", true);
            'CH':
                ApplicationAreaSetup.Validate("Basic CH", true);
            'DE':
                ApplicationAreaSetup.Validate("Basic DE", true);
            'BE':
                ApplicationAreaSetup.Validate("Basic BE", true);
            'CA':
                ApplicationAreaSetup.Validate("Basic CA", true);
            'CZ':
                ApplicationAreaSetup.Validate("Basic CZ", true);
            'DK':
                ApplicationAreaSetup.Validate("Basic DK", true);
            'ES':
                ApplicationAreaSetup.Validate("Basic ES", true);
            'FI':
                ApplicationAreaSetup.Validate("Basic FI", true);
            'FR':
                ApplicationAreaSetup.Validate("Basic FR", true);
            'GB':
                ApplicationAreaSetup.Validate("Basic GB", true);
            'IS':
                ApplicationAreaSetup.Validate("Basic IS", true);
            'IT':
                ApplicationAreaSetup.Validate("Basic IT", true);
            'MX':
                ApplicationAreaSetup.Validate("Basic MX", true);
            'NL':
                ApplicationAreaSetup.Validate("Basic NL", true);
            'NO':
                ApplicationAreaSetup.Validate("Basic NO", true);
            'NZ':
                ApplicationAreaSetup.Validate("Basic NZ", true);
            'RU':
                ApplicationAreaSetup.Validate("Basic RU", true);
            'SE':
                ApplicationAreaSetup.Validate("Basic SE", true);
            'US':
                ApplicationAreaSetup.Validate("Basic US", true);
            else begin
                IsHandled := false;
                OnCreateBasicCountrySetupForCurrentCompany(ApplicationAreaSetup, CountryCode, IsHandled);
                if not IsHandled then
                    Error(AppAreaNotSupportedErr, CountryCode);
            end;
        end;

        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateVATSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate(VAT, true);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure CreateSalesTaxSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Sales Tax", true);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure EnableRelationshipMgtSetup()
    begin
        DisableApplicationAreaSetup();
        EnableRelationshipMgtSetupForCurrentCompany();
    end;

    procedure EnableRelationshipMgtSetupForCurrentCompany()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateRelationshipMgtSetupForCurrentCompany(ApplicationAreaSetup);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure CreateRelationshipMgtSetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup")
    begin
        ApplicationAreaSetup.Validate("Company Name", CompanyName);
        ApplicationAreaSetup.Validate("Relationship Mgmt", true);
        ApplicationAreaSetup.Validate(Basic, true);
        ApplicationAreaSetup.Validate(Suite, true);
        ApplicationAreaSetup.Insert(true);
    end;

    procedure FoundationSetupExists(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.SetRange(Suite, true);
        exit(not ApplicationAreaSetup.IsEmpty());
    end;

    procedure DisableApplicationAreaSetup()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaSetup.IsEmpty() then
            ClearApplicationAreaCache()
        else
            ApplicationAreaSetup.DeleteAll(true);
        ApplicationAreaMgmtFacade.SetupApplicationArea();
    end;

    procedure DeleteExistingFoundationSetup()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.SetRange(Suite, true);
        ApplicationAreaSetup.DeleteAll(true);
    end;

    procedure VerifyApplicationAreaBasicExperience(ApplicationAreaSetup: Record "Application Area Setup")
    begin
        VerifyApplicationAreaBasicGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaEssentialGroup(ApplicationAreaSetup, false);
        VerifyApplicationAreaPremiumGroup(ApplicationAreaSetup, false);
        VerifyApplicationAreaAdvancedGroup(ApplicationAreaSetup, false);
    end;

    procedure VerifyApplicationAreaFullExperience(ApplicationAreaSetup: Record "Application Area Setup")
    begin
        VerifyApplicationAreaBasicGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaEssentialGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaPremiumGroup(ApplicationAreaSetup, false);
        VerifyApplicationAreaAdvancedGroup(ApplicationAreaSetup, false);
    end;

    [Scope('OnPrem')]
    procedure VerifyApplicationAreaPremiumExperience(ApplicationAreaSetup: Record "Application Area Setup")
    begin
        VerifyApplicationAreaBasicGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaEssentialGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaPremiumGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaAdvancedGroup(ApplicationAreaSetup, false);
    end;

    procedure VerifyApplicationAreaEssentialExperience(ApplicationAreaSetup: Record "Application Area Setup")
    begin
        VerifyApplicationAreaBasicGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaEssentialGroup(ApplicationAreaSetup, true);
        VerifyApplicationAreaPremiumGroup(ApplicationAreaSetup, false);
        VerifyApplicationAreaAdvancedGroup(ApplicationAreaSetup, false);
    end;

    local procedure VerifyApplicationAreaBasicGroup(ApplicationAreaSetup: Record "Application Area Setup"; Value: Boolean)
    begin
        ApplicationAreaSetup.TestField(Basic, Value);
        ApplicationAreaSetup.TestField("Relationship Mgmt", Value);
        ApplicationAreaSetup.TestField("Record Links", Value);
        ApplicationAreaSetup.TestField(Notes, Value);
    end;

    local procedure VerifyApplicationAreaEssentialGroup(ApplicationAreaSetup: Record "Application Area Setup"; Value: Boolean)
    begin
        ApplicationAreaSetup.TestField(Suite, Value);
        ApplicationAreaSetup.TestField(Jobs, Value);
        ApplicationAreaSetup.TestField("Fixed Assets", Value);
        ApplicationAreaSetup.TestField(Location, Value);
        ApplicationAreaSetup.TestField(BasicHR, Value);
        ApplicationAreaSetup.TestField(Assembly, Value);
        ApplicationAreaSetup.TestField("Item Charges", Value);
        ApplicationAreaSetup.TestField(Intercompany, Value);
        ApplicationAreaSetup.TestField("Sales Return Order", Value);
        ApplicationAreaSetup.TestField("Purch Return Order", Value);
        ApplicationAreaSetup.TestField(Prepayments, Value);
        ApplicationAreaSetup.TestField("Sales Analysis", Value);
        ApplicationAreaSetup.TestField("Purchase Analysis", Value);
        ApplicationAreaSetup.TestField("Inventory Analysis", Value);
        ApplicationAreaSetup.TestField("Cost Accounting", Value);
        ApplicationAreaSetup.TestField("Sales Budget", Value);
        ApplicationAreaSetup.TestField("Purchase Budget", Value);
        ApplicationAreaSetup.TestField("Item Budget", Value);
        ApplicationAreaSetup.TestField("Item Tracking", Value);
        ApplicationAreaSetup.TestField(Warehouse, Value);
        ApplicationAreaSetup.TestField(Dimensions, Value);
        ApplicationAreaSetup.TestField("Order Promising", Value);
        ApplicationAreaSetup.TestField(Reservation, Value);
        ApplicationAreaSetup.TestField(ADCS, Value);
        ApplicationAreaSetup.TestField(Planning, Value);
        ApplicationAreaSetup.TestField(Comments, Value);
    end;

    local procedure VerifyApplicationAreaPremiumGroup(ApplicationAreaSetup: Record "Application Area Setup"; Value: Boolean)
    begin
        ApplicationAreaSetup.TestField(Service, Value);
        ApplicationAreaSetup.TestField(Manufacturing, Value);
    end;

    local procedure VerifyApplicationAreaAdvancedGroup(ApplicationAreaSetup: Record "Application Area Setup"; Value: Boolean)
    begin
        ApplicationAreaSetup.TestField(Advanced, Value);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateBasicCountrySetupForCurrentCompany(var ApplicationAreaSetup: Record "Application Area Setup"; CountryCode: Code[10]; var IsHandled: Boolean)
    begin
    end;
}

