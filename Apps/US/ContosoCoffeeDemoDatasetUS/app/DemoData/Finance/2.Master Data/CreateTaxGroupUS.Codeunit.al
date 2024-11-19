codeunit 11463 "Create Tax Group US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateResource: Codeunit "Create Resource";
        CreateUSGLAccount: Codeunit "Create US GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoTaxUS.InsertTaxGroup(Furniture(), FurnitureLbl);
        ContosoTaxUS.InsertTaxGroup(Labor(), LaborLbl);
        ContosoTaxUS.InsertTaxGroup(Materials(), MaterialsLbl);
        ContosoTaxUS.InsertTaxGroup(NonTaxable(), NonTaxableLbl);
        ContosoTaxUS.InsertTaxGroup(Supplies(), SuppliesLbl);

        UpdateTaxGroupOnResource(CreateResource.Katherine(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Lina(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Marty(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Terry(), Labor());

        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DevelopmentExpenditure(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TenancySiteLeaseHoldandSimilarRights(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Goodwill(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AdvancedPaymentsforIntangibleFixedAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Building(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofImprovementstoLeasedProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Land(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EquipmentsandTools(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Computers(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CarsandOtherTransportEquipments(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LeasedAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccumulatedDepreciation(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LongTermReceivables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ParticipationinGroupCompanies(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LoanstoPartnersorRelatedParties(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DeferredTaxAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherLongTermReceivables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SuppliesandConsumables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RawMaterials(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ProductsinProgress(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FinishedGoods(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.GoodsforResale(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AdvancedPaymentsforGoodsandServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherInventoryItems(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WorkinProgressFinishedGoods(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.WIPJobSales(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.WIPJobCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WIPAccruedCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WIPInvoicedSales(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccountReceivableDomestic(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccountReceivableForeign(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ContractualReceivables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConsignmentReceivables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CreditcardsandVouchersReceivables(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrentReceivablefromEmployees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedincomenotYetInvoiced(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ClearingAccountsforTaxesandCharges(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TaxAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrentReceivablesFromGroupCompanies(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PrepaidRent(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PrepaidInterestExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedRentalIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedInterestIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AssetsInFormOfPrepaidExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherPrepaidExpensesAndAccruedIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Bonds(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConvertibleDebtInstruments(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherShortTermInvestments(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WriteDownofShortTermInvestments(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Cash(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BusinessAccountOperatingDomestic(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BusinessAccountOperatingForeign(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherBankAccounts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CertificateofDeposit(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BondsandDebentureLoans(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConvertiblesLoans(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherLongTermLiabilities(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BankOverdraftFacilities(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccountsPayableDomestic(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccountsPayableForeign(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Advancesfromcustomers(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ChangeinWorkinProgress(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BankOverdraftShortTerm(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OtherLiabilities(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SalesTaxVATLiable(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TaxesLiable(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EstimatedIncomeTax(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EstimatedPayrolltaxonPensionCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EmployeesWithholdingTaxes(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.StatutorySocialsecurityContributions(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ContractualSocialSecurityContributions(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AttachmentsofEarning(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HolidayPayfund(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherSalaryWageDeductions(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ClearingAccountforFactoringCurrentPortion(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrentLiabilitiestoEmployees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ClearingAccountforThirdParty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrentLoans(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LiabilitiesGrantsReceived(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedWagesSalaries(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedHolidayPay(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedPensionCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedInterestExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DeferredIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccruedContractualCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherAccruedExpensesandDeferredIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EquityPartner(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.NetResults(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RestrictedEquity(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ShareCapital(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.NonRestrictedEquity(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ProfitorLossFromthePreviousYear(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ResultsfortheFinancialYear(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DistributionstoShareholders(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SaleofRawMaterials(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SaleofFinishedGoods(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ResaleofGoods(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SaleofResources(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SaleofSubcontracting(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.IncomeFromSecurities(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ManagementFeeRevenue(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.InterestIncome(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrencyGains(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherIncidentalRevenue(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSales(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.JobSalesApplied(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SalesofServiceContracts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SalesofServiceWork(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DiscountsandAllowances(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.InvoiceRounding(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PaymentToleranceandAllowances(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SalesReturns(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofMaterials(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofMaterialsProjects(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofLabor(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofLaborProjects(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofLaborWarrantyContract(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SubcontractedWork(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CostofVariances(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RentLeases(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ElectricityforRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HeatingforRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WaterandSewerageforRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CleaningandWasteforRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RepairsandMaintenanceforRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.InsurancesRental(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherRentalExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SiteFeesLeases(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ElectricityforProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HeatingforProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WaterandSewerageforProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CleaningandWasteforProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RepairsandMaintenanceforProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.InsurancesProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherPropertyExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HireofMachinery(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HireofComputers(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HireofOtherFixedAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PassengerCarCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TruckCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherVehicleExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FreightFeesForGoods(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CustomsandForwarding(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FreightFeesProjects(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Tickets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RentalVehicles(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BoardandLodging(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherTravelExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AdvertisementDevelopment(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OutdoorandTransportationAds(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AdMatterandDirectMailings(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConferenceExhibitionSponsorship(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SamplesContestsGifts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FilmTVRadioInternetAds(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PRandAgencyFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherAdvertisingFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CatalogsPriceLists(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TradePublications(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CreditCardCharges(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BusinessEntertainingDeductible(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BusinessEntertainingNonDeductible(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OfficeSupplies(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PhoneServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DataServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PostalFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConsumableExpensibleHardware(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SoftwareandSubscriptionFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CorporateInsurance(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DamagesPaid(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BadDebtLosses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SecurityServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherRiskExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.RemunerationtoDirectors(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ManagementFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AnnualInterrimReports(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AnnualGeneralMeeting(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AuditandAuditServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TaxAdvisoryServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.BankingFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InterestExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PayableInvoiceRounding(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AccountingServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ITServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.MediaServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.ConsultingServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LegalFeesandAttorneyServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherExternalServices(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LicenseFeesRoyalties(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TrademarksPatents(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.AssociationFees(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.MiscExternalExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PurchaseDiscounts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Salaries(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HourlyWages(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OvertimeWages(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.Bonuses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CommissionsPaid(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PTOAccrued(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.TrainingCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HealthCareContributions(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EntertainmentofPersonnel(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Allowances(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.MandatoryClothingExpenses(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherCashRemunerationBenefits(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.PensionFeesandRecurringCosts(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.EmployerContributions(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.HealthInsurance(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DentalInsurance(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.WorkersCompensation(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.LifeInsurance(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FederalWithholdingExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FICAExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.FUTAExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.MedicareExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.OtherFederalExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.StateWithholdingExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.SUTAExpense(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DepreciationLandandProperty(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.DepreciationFixedAssets(), NonTaxable());
        UpdateTaxGroupOnGLAccount(CreateUSGLAccount.CurrencyLosses(), NonTaxable());
    end;

    local procedure UpdateTaxGroupOnResource(ResourceNo: Code[20]; TaxGroupCode: Code[20])
    var
        Resource: Record Resource;
    begin
        Resource.Get(ResourceNo);

        Resource.Validate("Tax Group Code", TaxGroupCode);
        Resource.Modify(true);
    end;

    local procedure UpdateTaxGroupOnGLAccount(GLAccountNo: Code[20]; TaxGroupCode: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GlAccount.Get(GLAccountNo);

        GLAccount.Validate("Tax Group Code", TaxGroupCode);
        GLAccount.Modify(true);
    end;

    procedure Furniture(): Code[20]
    begin
        exit(FurnitureTok);
    end;

    procedure Labor(): Code[20]
    begin
        exit(LaborTok);
    end;

    procedure Materials(): Code[20]
    begin
        exit(MaterialsTok);
    end;

    procedure NonTaxable(): Code[20]
    begin
        exit(NonTaxableTok);
    end;

    procedure Supplies(): Code[20]
    begin
        exit(SuppliesTok);
    end;

    var
        FurnitureTok: Label 'FURNITURE', MaxLength = 20, Locked = true;
        LaborTok: Label 'LABOR', MaxLength = 20, Locked = true;
        MaterialsTok: Label 'MATERIALS', MaxLength = 20, Locked = true;
        NonTaxableTok: Label 'NONTAXABLE', MaxLength = 20, Locked = true;
        SuppliesTok: Label 'SUPPLIES', MaxLength = 20, Locked = true;
        FurnitureLbl: Label 'Taxable Olympic Furniture', MaxLength = 100;
        LaborLbl: Label 'Labor on Job', MaxLength = 100;
        MaterialsLbl: Label 'Taxable Raw Materials', MaxLength = 100;
        NonTaxableLbl: Label 'Nontaxable', MaxLength = 100;
        SuppliesLbl: Label 'Taxable Olympic Supplies', MaxLength = 100;
}