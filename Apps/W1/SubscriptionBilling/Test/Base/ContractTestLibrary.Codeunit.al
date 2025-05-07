namespace Microsoft.SubscriptionBilling;

#region Using

using System.Reflection;
using System.Environment.Configuration;
using System.Globalization;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.BOM;
using Microsoft.CRM.Team;
using Microsoft.CRM.Contact;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.TestLibraries.Foundation.NoSeries;
using System.TestLibraries.Utilities;

#endregion Using

codeunit 139685 "Contract Test Library"
{
    Access = Internal;

    var
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        ContractsAppInitialized: Boolean;
        CustContractDimensionCodeLbl: Label 'CUSTOMERCONTRACT', Locked = true;
        CustContractDimensionDescriptionLbl: Label 'Customer Subscription Contract Dimension', Locked = true;
        PrefixTok: Label 'ZZZ', Locked = true;

    #region General
    procedure EnableNewPricingExperience()
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureKey: Record "Feature Key";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        SalesPricesFeatureKeyLbl: Label 'SalesPrices', Locked = true;
    begin
        if not FeatureKey.Get(SalesPricesFeatureKeyLbl) then
            exit;
        if FeatureKey.Enabled = FeatureKey.Enabled::"All Users" then
            exit;
        FeatureKey.Enabled := FeatureKey.Enabled::"All Users";
        FeatureKey.Modify(true);
        FeatureManagementFacade.AfterValidateEnabled(FeatureKey);
        FeatureDataUpdateStatus.SetRange("Feature Key", SalesPricesFeatureKeyLbl);
        if FeatureDataUpdateStatus.FindFirst() then
            FeatureManagementFacade.UpdateData(FeatureDataUpdateStatus);
    end;

    procedure InitContractsApp()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ServiceContractSetup: Record "Subscription Contract Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if ContractsAppInitialized then
            exit;
        DeleteAllContractRecords();

        if not ServiceContractSetup.Get() then begin
            ServiceContractSetup.Init();
            ServiceContractSetup.Insert();
        end;
        ServiceContractSetup."Default Period Calculation" := ServiceContractSetup."Default Period Calculation"::"Align to End of Month";
        ServiceContractSetup."Cust. Sub. Contract Nos." := LibraryERM.CreateNoSeriesCode();
        ServiceContractSetup."Vend. Sub. Contract Nos." := LibraryERM.CreateNoSeriesCode();
        ServiceContractSetup."Subscription Header No." := LibraryERM.CreateNoSeriesCode();
        if (ServiceContractSetup."Contract Invoice Description" = ServiceContractSetup."Contract Invoice Description"::" ") or
            ((ServiceContractSetup."Contract Invoice Description" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 1" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 2" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 3" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 4" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 5" <> Enum::"Contract Invoice Text Type"::"Billing Period"))
        then
            ServiceContractSetup.ContractTextsCreateDefaults();
        Evaluate(ServiceContractSetup."Default Billing Base Period", '<1M>');
        Evaluate(ServiceContractSetup."Default Billing Rhythm", '<1M>');
        ServiceContractSetup.Modify(false);

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Journal Templ. Name Mandatory" then begin
            LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
            LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
            ServiceContractSetup."Def. Rel. Jnl. Template Name" := GenJournalBatch."Journal Template Name";
            ServiceContractSetup."Def. Rel. Jnl. Batch Name" := GenJournalBatch.Name;
            ServiceContractSetup.Modify(false);
        end;

        SalesSetup.Get();
        SalesSetup."Allow Editing Active Price" := false;
        SalesSetup.Modify(false);

        InitSourceCodeSetup();

        ContractsAppInitialized := true;
    end;

    procedure InitSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup."Sub. Contr. Deferrals Release" := 'CONTDEFREL';
        SourceCodeSetup.Modify(false);
    end;

    procedure DeleteAllContractRecords()
    var
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line";
        CustomerContract: Record "Customer Subscription Contract";
        CustomerDeferrals: Record "Cust. Sub. Contract Deferral";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        PlannedServiceCommitment: Record "Planned Subscription Line";
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
        VendorDeferrals: Record "Vend. Sub. Contract Deferral";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        UsageDataBilling: Record "Usage Data Billing";
    begin
        BillingLine.DeleteAll(false);
        BillingLineArchive.DeleteAll(false);
        ContractPriceUpdateLine.DeleteAll(false);
        CustomerContractLine.DeleteAll(false);
        CustomerContract.DeleteAll(false);
        ServiceObject.DeleteAll(false);
        ServiceCommitment.DeleteAll(false);
        PlannedServiceCommitment.DeleteAll(false);
        ServiceCommitmentArchive.DeleteAll(false);
        SalesLine.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        VendorContractLine.DeleteAll(false);
        VendorContract.DeleteAll(false);
        VendorDeferrals.DeleteAll(false);
        CustomerDeferrals.DeleteAll(false);
        UsageDataBilling.DeleteAll(false);
    end;
    #endregion General

    #region Item
    procedure CreateBasicItem(var Item: Record Item; ItemType: Enum "Item Type"; SNSpecific: Boolean)
    begin
        case ItemType of
            ItemType::Inventory:
                begin
                    LibraryInventory.CreateItem(Item);
                    if SNSpecific then
                        LibraryItemTracking.AddSerialNoTrackingInfo(Item);
                end;
            ItemType::"Non-Inventory":
                LibraryInventory.CreateNonInventoryTypeItem(Item);
            else
                LibraryInventory.CreateServiceTypeItem(Item);
        end;

        Item."Unit Price" := LibraryRandom.RandDec(1000, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(1000, 2);

        OnCreateBasicItemOnBeforeModify(Item);
        Item.Modify(true);
    end;

    procedure CreateInventoryItem(var Item: Record Item)
    begin
        InitContractsApp();
        CreateBasicItem(Item, Enum::"Item Type"::Inventory, false);
    end;

    procedure CreateItemForServiceObjectWithServiceCommitments(var Item: Record Item)
    var
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommitmentPackage: Record "Subscription Package";
    begin
        CreateItemForServiceObject(Item, false);
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    procedure CreateItemWithServiceCommitmentOption(var NewItem: Record Item; ItemServiceCommitmentType: Enum "Item Service Commitment Type")
    begin
        CreateItemForServiceObject(NewItem, false, ItemServiceCommitmentType, Enum::"Item Type"::"Non-Inventory");
    end;

    procedure CreateItemTranslation(var ItemTranslation: Record "Item Translation"; ItemNo: Code[20]; LanguageCode: Code[10])
    var
        Language: Record Language;
    begin
        if LanguageCode = '' then begin
            Language.Code := LibraryUtility.GenerateGUID();
            Language.Insert(true);
            LanguageCode := Language.Code;
        end;

        ItemTranslation.Init();
        ItemTranslation."Item No." := ItemNo;
        ItemTranslation."Language Code" := LanguageCode;
        ItemTranslation.Description := 'Translated Description';
        ItemTranslation.Insert(true);
    end;

    procedure CreateItemForServiceObject(var Item: Record Item; SNSpecificTracking: Boolean)
    begin
        CreateItemForServiceObject(Item, SNSpecificTracking, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Type"::Inventory);
    end;

    procedure CreateItemForServiceObject(var Item: Record Item; SNSpecificTracking: Boolean; ItemServiceCommitmentType: Enum "Item Service Commitment Type"; ItemType: Enum "Item Type")
    begin
        InitContractsApp();
        CreateBasicItem(Item, ItemType, SNSpecificTracking);

        Item.Validate("Subscription Option", ItemServiceCommitmentType);

        OnCreateServiceObjectItemOnBeforeModify(Item);
        Item.Modify(true);
    end;

    #endregion Item

    #region Customer
    procedure CreateCustomer(var Customer: Record Customer; CurrencyCode: Code[10])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ShipToAddress: Record "Ship-to Address";
    begin
        InitContractsApp();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);
        LibrarySales.CreateShipToAddress(ShipToAddress, Customer."No.");
        Customer.Name := CopyStr(Customer.Name + Customer."No.", 1, MaxStrLen(Customer.Name));
        Customer.Validate("Salesperson Code", SalespersonPurchaser.Code);
        Customer.Validate("Currency Code", CurrencyCode);

        OnCreateCustomerOnBeforeModify(Customer);
        Customer.Modify(false);
    end;

    procedure CreateCustomer(var Customer: Record Customer)
    begin
        CreateCustomer(Customer, LibraryERM.CreateCurrencyWithRandomExchRates());
    end;

    procedure CreateCustomerInLCY(var Customer: Record Customer)
    begin
        CreateCustomer(Customer, '');
    end;
    #endregion Customer

    #region Vendor
    procedure CreateVendor(var Vendor: Record Vendor; CurrencyCode: Code[10])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        InitContractsApp();
        LibraryPurchase.CreateVendor(Vendor);
        LibrarySales.CreateSalesperson(SalespersonPurchaser);
        Vendor.Name := CopyStr(Vendor.Name + Vendor."No.", 1, MaxStrLen(Vendor.Name));
        Vendor.Validate("Purchaser Code", SalespersonPurchaser.Code);
        Vendor.Validate("Currency Code", CurrencyCode);

        OnCreateVendorOnBeforeModify(Vendor);
        Vendor.Modify(false);
    end;

    procedure CreateVendor(var Vendor: Record Vendor)
    begin
        CreateVendor(Vendor, LibraryERM.CreateCurrencyWithRandomExchRates());
    end;

    procedure CreateVendorInLCY(var Vendor: Record Vendor)
    begin
        CreateVendor(Vendor, '');
    end;
    #endregion Vendor

    #region Contracts

    procedure AssignServiceObjectForItemToCustomerContract(var CustomerContract: Record "Customer Subscription Contract"; var ServiceObject: Record "Subscription Header"; CreateAdditionalCustomerServCommLine: Boolean)
    var
        Customer: Record Customer;
        Item: Record Item;
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        Customer.Get(CustomerContract."Sell-to Customer No.");
        if ServiceObject."No." = '' then begin
            if CreateAdditionalCustomerServCommLine then
                CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 2, 0)
            else
                CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
            ServiceObject.SetHideValidationDialog(true);
            ServiceObject.Validate("End-User Customer No.", CustomerContract."Sell-to Customer No.");
            ServiceObject.Modify(false);
            SetGeneralPostingSetup(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
        end;
        FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        TempServiceCommitment.FindSet();
        repeat
            if Item.Get(TempServiceCommitment."Invoicing Item No.") then
                SetGeneralPostingSetup(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
        until TempServiceCommitment.Next() = 0;
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    procedure AssignServiceObjectForItemToVendorContract(var VendorContract: Record "Vendor Subscription Contract"; var ServiceObject: Record "Subscription Header"; CreateAdditionalVendorServCommLine: Boolean)
    var
        Item: Record Item;
        TempServiceCommitment: Record "Subscription Line" temporary;
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorContract."Buy-from Vendor No.");
        if ServiceObject."No." = '' then begin
            if CreateAdditionalVendorServCommLine then
                CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 0, 2)
            else
                CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 0, 1);
            SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
        end;
        FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        TempServiceCommitment.FindSet();
        repeat
            if Item.Get(TempServiceCommitment."Invoicing Item No.") then
                SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
        until TempServiceCommitment.Next() = 0;
        CreateVendorContractLinesFromServiceCommitments(VendorContract, TempServiceCommitment);
    end;


    procedure CreateContractType(var ContractType: Record "Subscription Contract Type")
    var
        ContractTypeCode: Code[10];
    begin
        ContractTypeCode := 'CTYPE000';
        repeat
            ContractTypeCode := IncStr(ContractTypeCode);
        until not ContractType.Get(ContractTypeCode);

        ContractType.Init();
        ContractType.Code := ContractTypeCode;
        ContractType.Description := ContractTypeCode;
        ContractType.Insert(true)
    end;

    procedure CreateCustomerContract(var CustomerContract: Record "Customer Subscription Contract"; CustomerNo: Code[20])
    var
        CustomerContractNo: Code[20];
    begin
        CustomerContractNo := PrefixTok + 'CUC000000';
        repeat
            CustomerContractNo := IncStr(CustomerContractNo);
        until not CustomerContract.Get(CustomerContractNo);

        CustomerContract.Init();
        CustomerContract.Validate("No.", CustomerContractNo);
        CustomerContract.Insert(true);
        if CustomerNo <> '' then
            CustomerContract.Validate("Sell-to Customer No.", CustomerNo);

        OnCreateCustomerSubscriptionContractOnBeforeModify(CustomerContract);
        CustomerContract.Modify(true);
    end;

    procedure CreateCustomerContractAndCreateContractLinesForItems(var CustomerContract: Record "Customer Subscription Contract"; var ServiceObject: Record "Subscription Header"; CustomerNo: Code[20])
    begin
        CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, CustomerNo, false);
    end;

    procedure CreateCustomerContractAndCreateContractLinesForItems(var CustomerContract: Record "Customer Subscription Contract"; var ServiceObject: Record "Subscription Header"; CustomerNo: Code[20]; CreateAdditionalCustomerServCommLine: Boolean)
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then begin
            CreateCustomer(Customer);
            CustomerNo := Customer."No.";
        end;
        CreateCustomerContract(CustomerContract, CustomerNo);
        AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, CreateAdditionalCustomerServCommLine);
    end;

    procedure CreateCustomerContractAndCreateContractLinesAndBillingProposal(var CustomerContract: Record "Customer Subscription Contract"; var ServiceObject: Record "Subscription Header"; CustomerNo: Code[20]; var BillingTemplate: Record "Billing Template")
    begin
        CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, CustomerNo);
        CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    procedure CreateCustomerContractWithContractType(var CustomerContract: Record "Customer Subscription Contract"; var ContractType: Record "Subscription Contract Type")
    var
        Customer: Record Customer;
    begin
        CreateCustomer(Customer);
        CreateCustomerContract(CustomerContract, Customer."No.");
        CreateContractType(ContractType);
        CustomerContract."Contract Type" := ContractType.Code;
        CustomerContract.Modify(false);
    end;

    procedure CreateVendorContract(var VendorContract: Record "Vendor Subscription Contract"; VendorNo: Code[20])
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        VendorContractNo: Code[20];
    begin
        // set no. series for vendor contract
        ServiceContractSetup.Get();
        if ServiceContractSetup."Vend. Sub. Contract Nos." = '' then begin
            ServiceContractSetup."Vend. Sub. Contract Nos." := CreateNoSeries();
            ServiceContractSetup.Modify();
        end;

        VendorContractNo := PrefixTok + 'VEC000000';
        repeat
            VendorContractNo := IncStr(VendorContractNo);
        until not VendorContract.Get(VendorContractNo);

        VendorContract.Init();
        VendorContract.Validate("No.", VendorContractNo);
        VendorContract.Insert(true);
        if VendorNo <> '' then
            VendorContract.Validate("Buy-from Vendor No.", VendorNo);

        OnCreateVendorSubscriptionContractOnBeforeModify(VendorContract);
        VendorContract.Modify(true);
    end;

    procedure CreateNoSeries(): Code[20]
    var
        LibraryNoSeries: Codeunit "Library - No. Series";
        Any: Codeunit Any;
        NoSeriesCode: Code[20];
    begin
        Any.SetDefaultSeed();
        NoSeriesCode := CopyStr(Any.AlphabeticText(10), 1, 10);
        LibraryNoSeries.CreateNoSeries(NoSeriesCode, true, true, false);
        exit(NoSeriesCode)
    end;

    procedure CreateVendorContractAndCreateContractLinesForItems(var VendorContract: Record "Vendor Subscription Contract"; var ServiceObject: Record "Subscription Header"; VendorNo: Code[20])
    begin
        CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, VendorNo, false);
    end;

    procedure CreateVendorContractAndCreateContractLinesForItems(var VendorContract: Record "Vendor Subscription Contract"; var ServiceObject: Record "Subscription Header"; VendorNo: Code[20]; CreateAdditionalVendorServCommLine: Boolean)
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then begin
            CreateVendor(Vendor);
            VendorNo := Vendor."No.";
        end;
        CreateVendorContract(VendorContract, VendorNo);
        AssignServiceObjectForItemToVendorContract(VendorContract, ServiceObject, CreateAdditionalVendorServCommLine);
    end;

    procedure CreateVendorContractAndCreateContractLinesAndBillingProposal(var VendorContract: Record "Vendor Subscription Contract"; var ServiceObject: Record "Subscription Header"; VendorNo: Code[20]; var VendorBillingTemplate: Record "Billing Template")
    begin
        CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, VendorNo);
        CreateBillingProposal(VendorBillingTemplate, Enum::"Service Partner"::Vendor);
    end;

    procedure CreateVendorContractWithContractType(var VendorContract: Record "Vendor Subscription Contract"; var ContractType: Record "Subscription Contract Type")
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        CreateVendorContract(VendorContract, Vendor."No.");
        CreateContractType(ContractType);
        VendorContract."Contract Type" := ContractType.Code;
        VendorContract.Modify(false);
    end;

    #endregion Contracts

    #region Service Commitment Template & Package
    procedure CreateServiceCommitmentTemplate(var ServiceCommitmentTemplate: Record "Sub. Package Line Template"; BillingBasePeriod: Text; CalcBasePercent: Decimal; InvoicingVia: Enum "Invoicing Via"; CalculationBaseType: Enum "Calculation Base Type"; Discount: Boolean)
    var
        ServiceCommitmentTemplateCode: Code[20];
    begin

        ServiceCommitmentTemplateCode := 'SCTEMPL000';
        repeat
            ServiceCommitmentTemplateCode := IncStr(ServiceCommitmentTemplateCode);
        until not ServiceCommitmentTemplate.Get(ServiceCommitmentTemplateCode);

        ServiceCommitmentTemplate.Init();
        ServiceCommitmentTemplate.Code := ServiceCommitmentTemplateCode;
        ServiceCommitmentTemplate.Description := ServiceCommitmentTemplateCode;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", BillingBasePeriod);
        ServiceCommitmentTemplate."Calculation Base %" := CalcBasePercent;
        ServiceCommitmentTemplate."Invoicing via" := InvoicingVia;
        ServiceCommitmentTemplate."Calculation Base Type" := CalculationBaseType;
        if Discount then
            ServiceCommitmentTemplate.Discount := true;
        ServiceCommitmentTemplate."Create Contract Deferrals" := ServiceCommitmentTemplate."Create Contract Deferrals"::Yes;

        OnCreateSubPackageLineTemplateOnBeforeInsert(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate.Insert(true)
    end;

    procedure CreateServiceCommitmentTemplate(var ServiceCommitmentTemplate: Record "Sub. Package Line Template")
    begin
        ServiceCommitmentTemplate.Init();
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '', ServiceCommitmentTemplate."Calculation Base %", ServiceCommitmentTemplate."Invoicing via", ServiceCommitmentTemplate."Calculation Base Type", false);
    end;

    procedure CreateServiceCommitmentTemplateWithDiscount(var ServiceCommitmentTemplate: Record "Sub. Package Line Template")
    begin
        ServiceCommitmentTemplate.Init();
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '', ServiceCommitmentTemplate."Calculation Base %", ServiceCommitmentTemplate."Invoicing via", ServiceCommitmentTemplate."Calculation Base Type", true);
    end;

    procedure CreateServiceCommitmentPackage(var ServiceCommitmentPackage: Record "Subscription Package")
    var
        ServiceCommitmentPackageCode: Code[20];
    begin

        ServiceCommitmentPackageCode := 'SCPACK000';
        repeat
            ServiceCommitmentPackageCode := IncStr(ServiceCommitmentPackageCode);
        until not ServiceCommitmentPackage.Get(ServiceCommitmentPackageCode);

        ServiceCommitmentPackage.Init();
        ServiceCommitmentPackage.Code := ServiceCommitmentPackageCode;
        ServiceCommitmentPackage.Description := ServiceCommitmentPackageCode;
        ServiceCommitmentPackage.Insert(true)
    end;

    procedure CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceCommPackageLine: Record "Subscription Package Line")
    begin
        CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplateCode, ServiceCommPackageLine);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Subscription Package Line";
    BillingBasePeriodText: Text; BillingRhythmText: Text; ServicePartner: Enum "Service Partner")
    begin
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine, BillingBasePeriodText, BillingRhythmText, ServicePartner, '');
        OnCreateSubscriptionPackageLineOnBeforeInsert(ServiceCommPackageLine);
        ServiceCommPackageLine.Modify(true);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Subscription Package Line";
    BillingBasePeriodText: Text; BillingRhythmText: Text; ServicePartner: Enum "Service Partner"; PriceBindingPeriod: Text)
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
    begin
        if ServiceCommitmentTemplate."Invoicing via" = ServiceCommitmentTemplate."Invoicing via"::Contract then
            CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine, BillingBasePeriodText,
                                BillingRhythmText, ServicePartner, PriceBindingPeriod, Item."No.");
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Subscription Package Line";
    BillingBasePeriodText: Text; BillingRhythmText: Text; ServicePartner: Enum "Service Partner"; PriceBindingPeriod: Text; InvoicingItemNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        ServiceCommPackageLine.Init();
        ServiceCommPackageLine."Subscription Package Code" := ServiceCommitmentPackageCode;
        RecRef.GetTable(ServiceCommPackageLine);
        ServiceCommPackageLine."Line No." := LibraryUtility.GetNewLineNo(RecRef, ServiceCommPackageLine.FieldNo("Line No."));
        if ServiceCommitmentTemplateCode <> '' then
            ServiceCommPackageLine.Validate(Template, ServiceCommitmentTemplateCode);
        Evaluate(ServiceCommPackageLine."Billing Base Period", BillingBasePeriodText);
        Evaluate(ServiceCommPackageLine."Billing Rhythm", BillingRhythmText);
        ServiceCommPackageLine.Validate(Partner, ServicePartner);
        Evaluate(ServiceCommPackageLine."Price Binding Period", PriceBindingPeriod);
        ServiceCommPackageLine.Validate("Create Contract Deferrals", Enum::"Create Contract Deferrals"::Yes);

        OnCreateSubscriptionPackageLineOnBeforeInsert(ServiceCommPackageLine);
        ServiceCommPackageLine.Insert(false);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Subscription Package Line")
    begin
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine, '<12M>', '<12M>', Enum::"Service Partner"::Customer, '<1M>');
    end;

    procedure UpdateServiceCommitmentPackageLine(var ServiceCommPackageLine: Record "Subscription Package Line"; BillingBasePeriod: Text; CalculationBase: Decimal; BillingRhythm: Text; ExtensionTerm: Text; ServicePartner: Enum "Service Partner"; ItemNo: Code[20])
    begin
        UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, BillingBasePeriod, CalculationBase, ExtensionTerm, ServicePartner, ItemNo, "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', BillingRhythm, false);
    end;

    procedure UpdateServiceCommitmentPackageLine(var ServiceCommPackageLine: Record "Subscription Package Line"; BillingBasePeriod: Text; CalculationBase: Decimal; ExtensionTerm: Text; ServicePartner: Enum "Service Partner"; ItemNo: Code[20]; InvoicingVia: Enum "Invoicing Via"; CalculationBaseType: Enum "Calculation Base Type"; PriceBindingPeriod: Text; CalculationRhythmDateFormulaTxt: Text; CreateDiscountLine: Boolean)
    var
        Item: Record Item;
    begin
        if (InvoicingVia = InvoicingVia::Contract) and (ItemNo = '') then begin
            CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
            ItemNo := Item."No.";
        end;
        ServiceCommPackageLine."Invoicing Item No." := ItemNo;
        ServiceCommPackageLine.Partner := ServicePartner;
        ServiceCommPackageLine."Invoicing via" := InvoicingVia;
        ServiceCommPackageLine."Calculation Base Type" := CalculationBaseType;
        ServiceCommPackageLine."Calculation Base %" := CalculationBase;
        if BillingBasePeriod <> '' then
            Evaluate(ServiceCommPackageLine."Billing Base Period", BillingBasePeriod);
        if ExtensionTerm <> '' then
            Evaluate(ServiceCommPackageLine."Extension Term", ExtensionTerm);
        if PriceBindingPeriod <> '' then
            Evaluate(ServiceCommPackageLine."Price Binding Period", PriceBindingPeriod);
        if CalculationRhythmDateFormulaTxt <> '' then
            Evaluate(ServiceCommPackageLine."Billing Rhythm", CalculationRhythmDateFormulaTxt);
        ServiceCommPackageLine.Discount := CreateDiscountLine;
        ServiceCommPackageLine.Modify(false);
    end;

    procedure InitServiceCommitmentPackageLineFields(var NewServiceCommPackageLine: Record "Subscription Package Line")
    begin
        Evaluate(NewServiceCommPackageLine."Billing Rhythm", '<1M>');
        Evaluate(NewServiceCommPackageLine."Sub. Line Start Formula", '<CY>');
        Evaluate(NewServiceCommPackageLine."Initial Term", '<12M>');
        Evaluate(NewServiceCommPackageLine."Extension Term", '<12M>');
        Evaluate(NewServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(NewServiceCommPackageLine."Price Binding Period", '<1M>');
        NewServiceCommPackageLine.Modify(false);
    end;
    #endregion Service Commitment Template & Package

    #region Service Object
    procedure CreateServiceObject(var ServiceObject: Record "Subscription Header"; SourceType: Enum "Service Object Type"; SourceNo: Code[20]; SNSpecificTracking: Boolean)
    var
        ServiceObjectNo: Code[20];
    begin
        ServiceObjectNo := PrefixTok + 'SOBJ000000';
        repeat
            ServiceObjectNo := IncStr(ServiceObjectNo);
        until not ServiceObject.Get(ServiceObjectNo);

        ServiceObject.Init();
        ServiceObject.Validate("No.", ServiceObjectNo);
        ServiceObject.Insert(true);
        if SourceNo <> '' then begin
            ServiceObject.Type := SourceType;
            ServiceObject.Validate("Source No.", SourceNo);
            if ServiceObject.IsItem() then
                ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages();
        end;
        ServiceObject."Provision Start Date" := WorkDate();
        if ServiceObject.IsItem() then
            if not SNSpecificTracking then
                ServiceObject.Quantity := LibraryRandom.RandDec(10, 2)
            else
                ServiceObject."Serial No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")), 1, MaxStrLen(ServiceObject."Serial No."));

        OnCreateSubscriptionHeaderOnBeforeModify(ServiceObject);
        ServiceObject.Modify(true);
    end;

    procedure CreateServiceObjectForGLAccount(var ServiceObject: Record "Subscription Header"; var GLAccount: Record "G/L Account")
    begin
        if GLAccount."No." = '' then
            LibraryERM.CreateGLAccount(GLAccount);
        CreateServiceObject(ServiceObject, "Service Object Type"::"G/L Account", GLAccount."No.", false);
    end;

    procedure CreateServiceObjectForGLAccountWithServiceCommitments(var ServiceObject: Record "Subscription Header"; var GLAccount: Record "G/L Account";
                                                                  NoOfCustomerServCommLinesToCreate: Integer; NoOfVendorServCommLinesToCreate: Integer; BillingBasePeriodText: Text; BillingRhythmText: Text)
    var
        ServiceCommitment: Record "Subscription Line";
        i: Integer;
    begin
        CreateServiceObjectForGLAccount(ServiceObject, GLAccount);
        for i := 1 to NoOfCustomerServCommLinesToCreate do begin
            ServiceCommitment.Init();
            ServiceCommitment."Subscription Header No." := ServiceObject."No.";
            ServiceCommitment."Entry No." := 0;
            ServiceCommitment.Description := ServiceObject.Description;
            ServiceCommitment."Invoicing via" := ServiceCommitment."Invoicing via"::Contract;
            ServiceCommitment.Partner := ServiceCommitment.Partner::Customer;
            ServiceCommitment.Validate("Subscription Line Start Date", WorkDate());
            Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriodText);
            Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythmText);
            ServiceCommitment.Insert(false);
        end;
        for i := 1 to NoOfVendorServCommLinesToCreate do begin
            ServiceCommitment.Init();
            ServiceCommitment."Subscription Header No." := ServiceObject."No.";
            ServiceCommitment."Entry No." := 0;
            ServiceCommitment.Description := ServiceObject.Description;
            ServiceCommitment."Invoicing via" := ServiceCommitment."Invoicing via"::Contract;
            ServiceCommitment.Partner := ServiceCommitment.Partner::Vendor;
            ServiceCommitment.Validate("Subscription Line Start Date", WorkDate());
            Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriodText);
            Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythmText);
            ServiceCommitment.Insert(false);
        end;
    end;

    procedure CreateServiceObjectForItem(var ServiceObject: Record "Subscription Header"; ItemNo: Code[20])
    begin
        CreateServiceObject(ServiceObject, "Service Object Type"::Item, ItemNo, false);
    end;

    procedure CreateServiceObjectForItem(var ServiceObject: Record "Subscription Header"; var Item: Record Item; SNSpecificTracking: Boolean)
    begin
        if Item."No." = '' then
            CreateItemForServiceObject(Item, SNSpecificTracking);
        CreateServiceObject(ServiceObject, "Service Object Type"::Item, Item."No.", SNSpecificTracking);
    end;

    procedure CreateServiceObjectForItemWithServiceCommitments(var ServiceObject: Record "Subscription Header"; NewInvoicingVia: Enum "Invoicing Via"; SNSpecificTracking: Boolean; var Item: Record Item; NoOfCustomerServCommLinesToCreate: Integer; NoOfVendorServCommLinesToCreate: Integer; BillingBasePeriodText: Text; BillingRhythmText: Text)
    var
        Item2: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        i: Integer;
    begin
        CreateServiceObjectForItem(ServiceObject, Item, SNSpecificTracking);

        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '', LibraryRandom.RandDec(100, 2), NewInvoicingVia, Enum::"Calculation Base Type"::"Item Price", false);

        if ServiceCommitmentTemplate."Invoicing via" = ServiceCommitmentTemplate."Invoicing via"::Contract then begin
            CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Invoicing Item");
            ServiceCommitmentTemplate.Validate("Invoicing Item No.", Item2."No.");
            ServiceCommitmentTemplate.Modify(false);
        end;

        CreateServiceCommitmentPackage(ServiceCommitmentPackage);

        for i := 1 to NoOfCustomerServCommLinesToCreate do
            CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine, BillingBasePeriodText, BillingRhythmText, Enum::"Service Partner"::Customer, '<1M>');

        for i := 1 to NoOfVendorServCommLinesToCreate do
            CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine, BillingBasePeriodText, BillingRhythmText, Enum::"Service Partner"::Vendor, '<1M>');

        AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, GetPackageFilterForItem(ItemServCommitmentPackage, ServiceObject."Source No."));
        InsertServiceCommitmentsFromServCommPackage(ServiceObject, WorkDate(), ServiceCommitmentPackage);
    end;

    procedure CreateServiceObjectForItemWithServiceCommitments(var ServiceObject: Record "Subscription Header"; NewInvoicingVia: Enum "Invoicing Via"; SNSpecificTracking: Boolean; var Item: Record Item; NoOfNewCustomerServCommLines: Integer; NoOfNewVendorServCommLines: Integer)
    begin
        CreateServiceObjectForItemWithServiceCommitments(ServiceObject, NewInvoicingVia, SNSpecificTracking, Item, NoOfNewCustomerServCommLines, NoOfNewVendorServCommLines, '<1Y>', '<1M>');
    end;
    #endregion Service Object

    procedure AppendRandomDimensionValueToDimensionSetID(var DimensionSetID: Integer)
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DimensionMgt: Codeunit "Dimension Mgt.";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionMgt.AppendDimValue(Dimension.Code, DimensionValue.Code, DimensionSetID);
    end;

    procedure AssignItemToServiceCommitmentPackage(Item: Record Item; ItemServCommitmentPackageCode: Code[20])
    begin
        AssignItemToServiceCommitmentPackage(Item, ItemServCommitmentPackageCode, false);
    end;

    procedure AssignItemToServiceCommitmentPackage(Item: Record Item; ItemServCommitmentPackageCode: Code[20]; DeclareAsStandard: Boolean)
    begin
        AssignItemToServiceCommitmentPackage(Item."No.", ItemServCommitmentPackageCode, DeclareAsStandard, false);
    end;

    procedure AssignItemToServiceCommitmentPackage(ItemNo: Code[20]; ItemServCommitmentPackageCode: Code[20]; DeclareAsStandard: Boolean; RunTrigger: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
    begin
        ItemServCommitmentPackage.Init();
        ItemServCommitmentPackage."Item No." := ItemNo;
        ItemServCommitmentPackage.Validate(Code, ItemServCommitmentPackageCode);
        if DeclareAsStandard then
            ItemServCommitmentPackage.Standard := true;

        OnAssignItemToSubscriptionPackage(ItemServCommitmentPackage);

        ItemServCommitmentPackage.Insert(RunTrigger);
    end;

    procedure BillingProposalCreateBillingProposal(BillingProposal: Codeunit "Billing Proposal"; BillingTemplateCode: Code[20]; BillingDate: Date; BillingToDate: Date)
    begin
        BillingProposal.CreateBillingProposal(BillingTemplateCode, BillingDate, BillingToDate);
    end;

    procedure BillingTemplateWriteFilter(var BillingTemplate: Record "Billing Template"; FieldNo: Integer; FilterText: Text)
    begin
        BillingTemplate.WriteFilter(BillingTemplate.FieldNo(Filter), FilterText);
    end;

    procedure CreateBillingProposal(var BillingTemplate: Record "Billing Template"; ServicePartner: Enum "Service Partner")
    begin
        CreateBillingProposal(BillingTemplate, ServicePartner, WorkDate());
    end;

    procedure CreateBillingProposal(var BillingTemplate: Record "Billing Template"; ServicePartner: Enum "Service Partner"; RefBillingDate: Date)
    begin
        CreateBillingProposal(BillingTemplate, ServicePartner, RefBillingDate, RefBillingDate);
    end;

    procedure CreateBillingProposal(var BillingTemplate: Record "Billing Template"; ServicePartner: Enum "Service Partner"; RefBillingDate: Date;
                                                                                                         RefBillingToDate: Date)
    var
        BillingProposal: Codeunit "Billing Proposal";
        BillingDate: Date;
        BillingToDate: Date;
    begin
        if BillingTemplate.Code = '' then
            CreateDefaultRecurringBillingTemplateForServicePartner(BillingTemplate, ServicePartner);
        BillingDate := CalcDate(BillingTemplate."Billing Date Formula", RefBillingDate);
        if RefBillingToDate <> 0D then
            BillingToDate := CalcDate(BillingTemplate."Billing to Date Formula", RefBillingToDate);
        BillingProposalCreateBillingProposal(BillingProposal, BillingTemplate.Code, BillingDate, BillingToDate);
    end;

    procedure CreateBOMComponentForItem(ParentItemNo: Code[20]; ComponentItemNo: Code[20]; QuantityPer: Decimal; UnitOfMeasureCode: Code[10])
    var
        BOMComponent: Record "BOM Component";
    begin
        LibraryInventory.CreateBOMComponent(BOMComponent, ParentItemNo, "BOM Component Type"::Item, ComponentItemNo, QuantityPer, UnitOfMeasureCode);
    end;

    procedure CreateContactsWithCustomerAndGetContactPerson(var Contact: Record Contact; var Customer: Record Customer)
    var
        Contact2: Record Contact;
        Contact3: Record Contact;
    begin
        LibraryMarketing.CreateContactWithCustomer(Contact, Customer);

        LibraryMarketing.CreatePersonContact(Contact2);
        Contact2.Validate("Company No.", Contact."No.");
        Contact2.Modify(false);

        LibraryMarketing.CreatePersonContact(Contact3);
        Contact3.Validate("Company No.", Contact."No.");
        Contact3.Modify(false);

        Contact.Get(Contact3."No.");
    end;

    procedure CreateDefaultDimensionValueForTable(TableID: Integer; No: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        CreateDefaultDimensionValueForTable(DimensionValue, TableID, No);
    end;

    procedure CreateDefaultDimensionValueForTable(var DimensionValue: Record "Dimension Value"; TableID: Integer; No: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, TableID, No, Dimension.Code, DimensionValue.Code);
    end;

    procedure CreateDefaultRecurringBillingTemplateForServicePartner(var BillingTemplate: Record "Billing Template"; ServicePartner: Enum "Service Partner")
    begin
        CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', '', ServicePartner);
    end;

    local procedure CreateDimension(DimensionCode: Code[20]; DimensionName: Text; DimensionCodeCaption: Text; DimensionFilterCaption: Text)
    var
        Dimension: Record Dimension;
    begin
        if Dimension.Get(DimensionCode) then
            exit;

        Dimension.Init();
        Dimension.Validate(Code, DimensionCode);
        Dimension.Name := CopyStr(DimensionName, 1, MaxStrLen(Dimension.Name));
        Dimension."Code Caption" := CopyStr(DimensionCodeCaption, 1, MaxStrLen(Dimension."Code Caption"));
        Dimension."Filter Caption" := CopyStr(DimensionFilterCaption, 1, MaxStrLen(Dimension."Filter Caption"));
        Dimension.Insert(true);
    end;

    procedure CreateRecurringBillingTemplate(var BillingTemplate: Record "Billing Template"; BillingDateFormulaTxt: Text; BillingToDateFormulaTxt: Text; FilterText: Text; ServicePartner: Enum "Service Partner")
    var
        BillingDateFormula: DateFormula;
        BillingToDateFormula: DateFormula;
    begin
        Evaluate(BillingDateFormula, BillingDateFormulaTxt);
        Evaluate(BillingToDateFormula, BillingToDateFormulaTxt);
        BillingTemplate.Init();
        BillingTemplate.Code := CopyStr(LibraryRandom.RandText(MaxStrLen(BillingTemplate.Code)), 1, MaxStrLen(BillingTemplate.Code));
        BillingTemplate.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(BillingTemplate.Description)), 1, MaxStrLen(BillingTemplate.Description));
        BillingTemplate.Partner := ServicePartner;
        if Format(BillingDateFormula) <> '' then
            BillingTemplate."Billing Date Formula" := BillingDateFormula;
        if Format(BillingToDateFormula) <> '' then
            BillingTemplate."Billing to Date Formula" := BillingToDateFormula;
        BillingTemplate.Insert(false);

        if FilterText <> '' then
            BillingTemplateWriteFilter(BillingTemplate, BillingTemplate.FieldNo(Filter), FilterText);
    end;

    procedure CreateTranslationForField(var FieldTranslation: Record "Field Translation"; SourceRecord: Variant; FieldID: Integer; LanguageCode: Code[10])
    var
        FieldRec: Record Field;
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        DataTypeMgt.GetRecordRef(SourceRecord, RecRef);
        FRef := RecRef.Field(RecRef.SystemIdNo());
        FieldRec.Get(RecRef.Number, FieldID);

        FieldTranslation.Init();
        FieldTranslation.Validate("Table ID", RecRef.Number);
        FieldTranslation.Validate("Field No.", FieldID);
        FieldTranslation.Validate("Language Code", LanguageCode);
        FieldTranslation.Validate("Source SystemId", FRef.Value);
        FieldTranslation.Validate(Translation, LibraryRandom.RandText(FieldRec.Len));
        FieldTranslation.Insert(true);
    end;

    procedure CreateVendorContractLinesFromServiceCommitments(var VendorContract: Record "Vendor Subscription Contract"; var TempServiceCommitment: Record "Subscription Line" temporary)
    begin
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    procedure CustomerContractUpdateServicesDates(var CustomerContract: Record "Customer Subscription Contract")
    begin
        CustomerContract.UpdateServicesDates();
    end;

    procedure FillTempServiceCommitment(var TempServiceCommitment: Record "Subscription Line" temporary; ServiceObject: Record "Subscription Header"; CustomerContract: Record "Customer Subscription Contract")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        FilterSubscriptionLinesWithoutContractNo(ServiceCommitment, ServiceObject."No.", Enum::"Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            TempServiceCommitment.TransferFields(ServiceCommitment);
            TempServiceCommitment."Subscription Contract No." := CustomerContract."No.";
            TempServiceCommitment.Insert(false);
        until ServiceCommitment.Next() = 0;
    end;

    procedure FillTempServiceCommitmentForVendor(var TempServiceCommitment: Record "Subscription Line" temporary; ServiceObject: Record "Subscription Header"; VendorContract: Record "Vendor Subscription Contract")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        FilterSubscriptionLinesWithoutContractNo(ServiceCommitment, ServiceObject."No.", Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            TempServiceCommitment.TransferFields(ServiceCommitment);
            TempServiceCommitment."Subscription Contract No." := VendorContract."No.";
            TempServiceCommitment.Insert(false);
        until ServiceCommitment.Next() = 0;
    end;

    procedure FilterBillingLineArchiveOnContractLine(var FilteredBillingLineArchive: Record "Billing Line Archive"; ContractNo: Code[20]; ContractLineNo: Integer; ServicePartner: Enum "Service Partner")
    begin
        FilteredBillingLineArchive.SetRange(Partner, ServicePartner);
        FilteredBillingLineArchive.SetRange("Subscription Contract No.", ContractNo);
        if ContractLineNo <> 0 then
            FilteredBillingLineArchive.SetRange("Subscription Contract Line No.", ContractLineNo);
    end;

    local procedure FilterSubscriptionLinesWithoutContractNo(var ServiceCommitment: Record "Subscription Line"; ServiceObjectNo: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Subscription Contract No.", '');
        case ServicePartner of
            ServicePartner::Customer:
                ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
            ServicePartner::Vendor:
                ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        end;
    end;

    procedure GetPackageFilterForItem(ItemServCommitmentPackage: Record "Item Subscription Package"; ItemNo: Code[20]): Text
    begin
        exit(ItemServCommitmentPackage.GetPackageFilterForItem(ItemNo));
    end;

    procedure InitCustomerContractLine(CustomerContract: Record "Customer Subscription Contract"; var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        CustomerContractLine.Init();
        CustomerContractLine."Line No." := CustomerContractLine.GetNextLineNo(CustomerContract."No.");
        CustomerContractLine."Subscription Contract No." := CustomerContract."No.";
    end;

    procedure InsertCustomerContractCommentLine(CustomerContract: Record "Customer Subscription Contract"; var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        InitCustomerContractLine(CustomerContract, CustomerContractLine);
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Comment;
        CustomerContractLine."Subscription Line Description" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContractLine."Subscription Line Description")), 1, MaxStrLen(CustomerContractLine."Subscription Line Description"));
        CustomerContractLine.Insert(false);
    end;

    procedure InsertCustomerContractItemLine(CustomerContract: Record "Customer Subscription Contract"; var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        Item: Record Item;
    begin
        InitCustomerContractLine(CustomerContract, CustomerContractLine);
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Item;
        CreateItemForServiceObject(Item, false, "Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Type"::"Non-Inventory");
        CustomerContractLine.Validate("No.", Item."No.");
        CustomerContractLine.Insert(false);
    end;

    procedure InsertCustomerContractGLAccountLine(CustomerContract: Record "Customer Subscription Contract"; var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        InitCustomerContractLine(CustomerContract, CustomerContractLine);
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::"G/L Account";
        CustomerContractLine.Validate("No.", LibraryERM.CreateGLAccountWithPurchSetup());
        CustomerContractLine.Insert(false);
    end;

    local procedure InitVendorContractLine(VendorContract: Record "Vendor Subscription Contract"; var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        VendorContractLine.Init();
        VendorContractLine."Line No." := VendorContractLine.GetNextLineNo(VendorContract."No.");
        VendorContractLine."Subscription Contract No." := VendorContract."No.";
    end;


    procedure InsertCustomerContractDimensionCode()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.Get();
        if ServiceContractSetup."Dimension Code Cust. Contr." = '' then begin
            CreateDimension(CustContractDimensionCodeLbl, CustContractDimensionDescriptionLbl, CustContractDimensionDescriptionLbl, CustContractDimensionDescriptionLbl);
            ServiceContractSetup."Dimension Code Cust. Contr." := CustContractDimensionCodeLbl;
            ServiceContractSetup.Modify(false);
        end;
    end;

    procedure InsertServiceCommitmentsFromServCommPackage(var ServiceObject: Record "Subscription Header"; WorkDate: Date; var ServiceCommitmentPackage: Record "Subscription Package")
    begin
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    procedure InsertVendorContractCommentLine(VendorContract: Record "Vendor Subscription Contract"; var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        VendorContractLine.Init();
        VendorContractLine."Line No." := VendorContractLine.GetNextLineNo(VendorContract."No.");
        VendorContractLine."Subscription Contract No." := VendorContract."No.";
        VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::Comment;
        VendorContractLine."Subscription Line Description" := CopyStr(LibraryRandom.RandText(MaxStrLen(VendorContractLine."Subscription Line Description")), 1, MaxStrLen(VendorContractLine."Subscription Line Description"));
        VendorContractLine.Insert(false);
    end;

    procedure InsertVendorContractItemLine(VendorContract: Record "Vendor Subscription Contract"; var VendorContractLine: Record "Vend. Sub. Contract Line")
    var
        Item: Record Item;
    begin
        InitVendorContractLine(VendorContract, VendorContractLine);
        VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::Item;
        CreateItemForServiceObject(Item, false, "Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Type"::"Non-Inventory");
        VendorContractLine.Validate("No.", Item."No.");
        VendorContractLine.Insert(false);
    end;

    procedure InsertVendorContractGLAccountLine(VendorContract: Record "Vendor Subscription Contract"; var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        InitVendorContractLine(VendorContract, VendorContractLine);
        VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::"G/L Account";
        VendorContractLine.Validate("No.", LibraryERM.CreateGLAccountWithPurchSetup());
        VendorContractLine.Insert(false);
    end;

    procedure SetAutomaticDimensions(NewValue: Boolean)
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup."Aut. Insert C. Contr. DimValue" := NewValue;
        ServiceContractSetup.Modify(false);
    end;

    procedure SetGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; EmptyAccount: Boolean; ServicePartner: Enum "Service Partner")
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then begin
            case ServicePartner of
                Enum::"Service Partner"::Customer:
                    if EmptyAccount then begin
                        GeneralPostingSetup."Cust. Sub. Contr. Def Account" := '';
                        GeneralPostingSetup."Cust. Sub. Contract Account" := '';
                    end else begin
                        GeneralPostingSetup."Cust. Sub. Contract Account" := GeneralPostingSetup."Sales Account";
                        LibraryERM.CreateGLAccount(GLAccount);
                        GeneralPostingSetup."Cust. Sub. Contr. Def Account" := GLAccount."No.";
                    end;
                Enum::"Service Partner"::Vendor:
                    if EmptyAccount then begin
                        GeneralPostingSetup."Vend. Sub. Contr. Def. Account" := '';
                        GeneralPostingSetup."Vend. Sub. Contract Account" := '';
                    end else begin
                        GeneralPostingSetup."Vend. Sub. Contract Account" := GeneralPostingSetup."Purch. Account";
                        LibraryERM.CreateGLAccount(GLAccount);
                        GeneralPostingSetup."Vend. Sub. Contr. Def. Account" := GLAccount."No.";
                    end;
            end;
            GeneralPostingSetup.Modify(false);
        end;
    end;

    procedure SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(var NewItem: Record Item; ItemServiceCommitmentType: Enum "Item Service Commitment Type"; ServiceCommitmentPackageCode: Code[20])
    begin
        CreateItemWithServiceCommitmentOption(NewItem, ItemServiceCommitmentType);
        AssignItemToServiceCommitmentPackage(NewItem, ServiceCommitmentPackageCode, true);
    end;

    procedure ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(var ServiceCommitment: Record "Subscription Line"; BillingBasePeriodText: Text; BillingRhythmText: Text)
    begin
        Clear(ServiceCommitment."Billing Base Period");
        Clear(ServiceCommitment."Billing Rhythm");
        Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriodText);
        ServiceCommitment.Validate("Billing Base Period");
        Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythmText);
        ServiceCommitment.Validate("Billing Rhythm");
    end;


    #region Imported Data

    procedure CreateImportedServiceCommitmentCustomer(var ImportedServiceCommitment: Record "Imported Subscription Line"; ImportedServiceObject: Record "Imported Subscription Header"; CustomerContract: Record "Customer Subscription Contract"; NewContractLineType: Enum "Contract Line Type")
    begin
        ImportedServiceObject.TestField("Subscription Header No.");
        CustomerContract.TestField("No.");

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Subscription Header No." := ImportedServiceObject."Subscription Header No.";
        ImportedServiceCommitment.Partner := "Service Partner"::Customer;
        ImportedServiceCommitment."Subscription Contract No." := CustomerContract."No.";
        ImportedServiceCommitment."Sub. Contract Line Type" := NewContractLineType;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := ImportedServiceObject."Item No.";
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ImportedServiceCommitment."Currency Code" := CustomerContract."Currency Code";
        if not ImportedServiceCommitment.IsContractCommentLine() then
            SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);
    end;

    procedure CreateImportedServiceCommitmentVendor(var ImportedServiceCommitment: Record "Imported Subscription Line"; ImportedServiceObject: Record "Imported Subscription Header"; VendorContract: Record "Vendor Subscription Contract"; NewContractLineType: Enum "Contract Line Type")
    begin
        ImportedServiceObject.TestField("Subscription Header No.");
        VendorContract.TestField("No.");

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Subscription Header No." := ImportedServiceObject."Subscription Header No.";
        ImportedServiceCommitment.Partner := "Service Partner"::Vendor;
        ImportedServiceCommitment."Subscription Contract No." := VendorContract."No.";
        ImportedServiceCommitment."Sub. Contract Line Type" := NewContractLineType;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := ImportedServiceObject."Item No.";
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ImportedServiceCommitment."Currency Code" := VendorContract."Currency Code";
        if not ImportedServiceCommitment.IsContractCommentLine() then
            SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);
    end;

    procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Subscription Header"; CustomerNo: Code[20]; ItemNo: Code[20]; UseSerialNo: Boolean)
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        ImportedServiceObject.Init();
        ImportedServiceObject."Entry No." := 0;
        ImportedServiceObject.Insert(false);
        ImportedServiceObject."Subscription Header No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject."Subscription Header No.")), 1, MaxStrLen(ImportedServiceObject."Subscription Header No."));
        if CustomerNo = '' then
            LibrarySales.CreateCustomer(Customer)
        else
            Customer.Get(CustomerNo);
        ImportedServiceObject."End-User Customer No." := Customer."No.";
        ImportedServiceObject."End-User Contact No." := Customer."Primary Contact No.";
        if ItemNo = '' then
            CreateItemWithServiceCommitmentOption(Item, "Item Service Commitment Type"::"Service Commitment Item")
        else
            Item.Get(ItemNo);
        ImportedServiceObject.Validate("Item No.", Item."No.");
        ImportedServiceObject.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject.Description)), 1, MaxStrLen(ImportedServiceObject.Description));
        if UseSerialNo then begin
            ImportedServiceObject."Quantity (Decimal)" := 1;
            ImportedServiceObject."Serial No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject."Serial No.")), 1, MaxStrLen(ImportedServiceObject."Serial No."));
        end else
            ImportedServiceObject."Quantity (Decimal)" := LibraryRandom.RandDecInRange(1, 100, 0);
        ImportedServiceObject."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject."Customer Reference")), 1, MaxStrLen(ImportedServiceObject."Customer Reference"));
        ImportedServiceObject."Unit of Measure" := Item."Base Unit of Measure";
        ImportedServiceObject."Bill-to Customer No." := ImportedServiceObject."End-User Customer No.";
        ImportedServiceObject."Provision Start Date" := WorkDate();
        ImportedServiceObject."Provision End Date" := CalcDate('<+CY>', ImportedServiceObject."Provision Start Date");
        ImportedServiceObject."Key" := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject."Key")), 1, MaxStrLen(ImportedServiceObject."Key"));
        ImportedServiceObject.Version := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject.Version)), 1, MaxStrLen(ImportedServiceObject.Version));
        ImportedServiceObject.Modify(false);
    end;

    procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Subscription Header")
    begin
        CreateImportedServiceObject(ImportedServiceObject, '', '', false);
    end;

    procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Subscription Header"; CustomerNo: Code[20]; ItemNo: Code[20])
    begin
        CreateImportedServiceObject(ImportedServiceObject, CustomerNo, ItemNo, false);
    end;

    procedure SetImportedServiceCommitmentData(var ImportedServiceCommitment: Record "Imported Subscription Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        ImportedServiceCommitment."Calculation Base Amount" := LibraryRandom.RandDecInRange(1, 1000, 2);
        ImportedServiceCommitment."Calculation Base %" := LibraryRandom.RandDecInRange(1, 100, 2);
        SetImportedServiceCommitmentServiceDates(ImportedServiceCommitment);
        SetImportedServiceCommitmentDateFormulas(ImportedServiceCommitment, '<12M>', '<12M>', '<12M>', '<1M>', '<3M>');
        if ImportedServiceCommitment."Currency Code" <> '' then begin
            ImportedServiceCommitment."Currency Factor Date" := WorkDate();
            ImportedServiceCommitment."Currency Factor" := CurrExchRate.ExchangeRate(ImportedServiceCommitment."Currency Factor Date", ImportedServiceCommitment."Currency Code");
        end;
    end;

    procedure SetImportedServiceCommitmentServiceDates(var ImportedServiceCommitment: Record "Imported Subscription Line")
    begin
        ImportedServiceCommitment."Subscription Line Start Date" := CalcDate('<-CY>', WorkDate());
        ImportedServiceCommitment."Subscription Line End Date" := CalcDate('<+CY>', WorkDate());
    end;

    procedure SetImportedServiceCommitmentDateFormulas(var ImportedServiceCommitment: Record "Imported Subscription Line"; NewBillingBasePeriod: Text; NewInitialTerm: Text; NewExtensionTerm: Text; NewBillingRhythm: Text; NewNoticePeriod: Text)
    begin
        Evaluate(ImportedServiceCommitment."Billing Base Period", NewBillingBasePeriod);
        Evaluate(ImportedServiceCommitment."Initial Term", NewInitialTerm);
        Evaluate(ImportedServiceCommitment."Extension Term", NewExtensionTerm);
        Evaluate(ImportedServiceCommitment."Billing Rhythm", NewBillingRhythm);
        Evaluate(ImportedServiceCommitment."Notice Period", NewNoticePeriod);
    end;
    #endregion Imported Data

    #region Attributes

    procedure CreateImportedCustomerContract(var ImportedCustomerContract: Record "Imported Cust. Sub. Contract"; SellToCustomerNo: Code[20]; BillToCustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        ImportedCustomerContract.Init();
        ImportedCustomerContract."Entry No." := 0;
        ImportedCustomerContract.Insert(false);
        ImportedCustomerContract."Subscription Contract No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedCustomerContract."Subscription Contract No.")), 1, MaxStrLen(ImportedCustomerContract."Subscription Contract No."));

        if SellToCustomerNo = '' then
            LibrarySales.CreateCustomer(Customer)
        else
            Customer.Get(SellToCustomerNo);
        ImportedCustomerContract."Sell-to Customer No." := Customer."No.";

        if BillToCustomerNo <> '' then begin
            Customer.Get(BillToCustomerNo);
            ImportedCustomerContract."Bill-to Customer No." := Customer."No.";
        end;
        ImportedCustomerContract.Modify(false);
    end;

    procedure CreateImportedCustomerContract(var ImportedCustomerContract: Record "Imported Cust. Sub. Contract")
    begin
        CreateImportedCustomerContract(ImportedCustomerContract, '', '');
    end;

    procedure CreateItemAttributeValueMapping(TableID: Integer; No: Code[20]; AttributeID: Integer; AttributeValueID: Integer)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        // function duplicated from LibraryInventory to avoid OnInsert trigger
        // because Subscription table does not have Field 1 as PK
        ItemAttributeValueMapping.Validate("Table ID", TableID);
        ItemAttributeValueMapping.Validate("No.", No);
        ItemAttributeValueMapping.Validate("Item Attribute ID", AttributeID);
        ItemAttributeValueMapping.Validate("Item Attribute Value ID", AttributeValueID);
        ItemAttributeValueMapping.Insert(false);
    end;

    procedure CreateMultipleServiceObjectsWithItemSetup(var Customer: Record Customer; var ServiceObject: Record "Subscription Header"; var Item: Record Item; NoOfServiceObjects: Integer)
    var
        i: Integer;
    begin
        CreateCustomer(Customer);
        for i := 1 to NoOfServiceObjects do begin
            CreateServiceObjectForItem(ServiceObject, Item, false);
            ServiceObject.SetHideValidationDialog(true);
            ServiceObject.Validate("End-User Customer Name", Customer.Name);
            ServiceObject.Quantity := LibraryRandom.RandDec(10, 2);
            ServiceObject.Modify(false);
        end;
        UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), false);
    end;

    procedure CreatePriceUpdateTemplate(var PriceUpdateTemplate: Record "Price Update Template"; ServicePartner: Enum "Service Partner"; PriceUpdateMethod: Enum "Price Update Method"; UpdateValuePercentage: Decimal; PerformUpdateOnFormula: Text; InclContrLinesUpToDateFormula: Text; PriceBindingPeriod: Text)
    begin
        PriceUpdateTemplate.Init();
        PriceUpdateTemplate.Code := LibraryUtility.GenerateRandomCode20(PriceUpdateTemplate.FieldNo(Code), Database::"Price Update Template");
        PriceUpdateTemplate.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(PriceUpdateTemplate.Description));
        PriceUpdateTemplate.Partner := ServicePartner;
        PriceUpdateTemplate.Validate("Price Update Method", PriceUpdateMethod);
        PriceUpdateTemplate.Validate("Update Value %", UpdateValuePercentage);
        Evaluate(PriceUpdateTemplate."Perform Update on Formula", PerformUpdateOnFormula);
        Evaluate(PriceUpdateTemplate.InclContrLinesUpToDateFormula, InclContrLinesUpToDateFormula);
        Evaluate(PriceUpdateTemplate."Price Binding Period", PriceBindingPeriod);
        PriceUpdateTemplate.Insert(false);
    end;

    procedure CreateServiceCommitmentTemplateSetup(var ServiceCommitmentTemplate: Record "Sub. Package Line Template"; CalcBasePeriodDateFormulaTxt: Text; InvoicingVia: Enum "Invoicing Via")
    begin
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        if CalcBasePeriodDateFormulaTxt <> '' then
            Evaluate(ServiceCommitmentTemplate."Billing Base Period", CalcBasePeriodDateFormulaTxt);
        ServiceCommitmentTemplate."Invoicing via" := InvoicingVia;
        ServiceCommitmentTemplate.Modify(false);
    end;

    procedure CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceCommPackageLine: Record "Subscription Package Line"; Item: Record Item; CalculationRhythmDateFormulaTxt: Text; PeriodCalculation: Enum "Period Calculation")
    begin
        CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplateCode, ServiceCommitmentPackage, ServiceCommPackageLine);
        UpdateServiceCommitmentPackageLineWithInvoicingItem(ServiceCommPackageLine, '');
        ServiceCommPackageLine."Period Calculation" := PeriodCalculation;
        ServiceCommPackageLine."Invoicing Item No." := Item."No.";
        if CalculationRhythmDateFormulaTxt <> '' then begin
            Evaluate(ServiceCommPackageLine."Billing Rhythm", CalculationRhythmDateFormulaTxt);
            ServiceCommPackageLine.Modify(false);
        end;
        AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        Evaluate(ServiceCommPackageLine."Price Binding Period", '<1M>');
        ServiceCommPackageLine.Modify(false);
    end;

    procedure CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceCommPackageLine: Record "Subscription Package Line"; Item: Record Item; CalculationRhythmDateFormulaTxt: Text)
    begin
        CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode, ServiceCommitmentPackage, ServiceCommPackageLine, Item, CalculationRhythmDateFormulaTxt, "Period Calculation"::"Align to Start of Month");
    end;

    procedure CreateItemAttributeMappedToServiceObject(ServiceObjectNo: Code[20]; var ItemAttribute: Record "Item Attribute"; var ItemAttributeValue: Record "Item Attribute Value"; NewPrimary: Boolean)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        LibraryInventory.CreateItemAttribute(ItemAttribute, ItemAttribute.Type::Text, '');
        LibraryInventory.CreateItemAttributeValue(
            ItemAttributeValue, ItemAttribute.ID,
            CopyStr(LibraryUtility.GenerateRandomText(MaxStrLen(ItemAttributeValue.Value)), 1, MaxStrLen(ItemAttributeValue.Value)));
        CreateItemAttributeValueMapping(Database::"Subscription Header", ServiceObjectNo, ItemAttribute.ID, ItemAttributeValue.ID);
        if NewPrimary then begin
            FilterItemAttributeValueMapping(ItemAttributeValueMapping, Database::"Subscription Header", ServiceObjectNo, ItemAttribute.ID, ItemAttributeValue.ID);
            if ItemAttributeValueMapping.FindFirst() then begin
                ItemAttributeValueMapping.Primary := NewPrimary;
                ItemAttributeValueMapping.Modify(false);
            end;
        end;
    end;

    procedure FilterItemAttributeValueMapping(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; TableID: Integer; No: Code[20]; AttributeID: Integer; AttributeValueID: Integer)
    begin
        ItemAttributeValueMapping.SetRange("Table ID", TableID);
        ItemAttributeValueMapping.SetRange("No.", No);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", AttributeID);
        ItemAttributeValueMapping.SetRange("Item Attribute Value ID", AttributeValueID);
    end;

    procedure InsertDocumentAttachment(TableId: Integer; RecNo: Code[20])
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.Validate("Table ID", TableId);
        DocumentAttachment.Validate("No.", RecNo);
        DocumentAttachment.Insert(false);
    end;

    procedure InsertServiceCommitmentFromServiceCommPackageSetup(var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceObject: Record "Subscription Header"; ServiceAndCalculationStartDate: Date)
    begin
        ServiceCommitmentPackage.SetRecFilter();
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);
    end;

    procedure InsertServiceCommitmentFromServiceCommPackageSetup(var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceObject: Record "Subscription Header")
    begin
        InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject, 0D);
    end;

    procedure TestServiceCommitmentAgainstImportedServiceCommitment(var ServiceCommitment: Record "Subscription Line"; var ImportedServiceCommitment: Record "Imported Subscription Line")
    begin
        ServiceCommitment.TestField("Invoicing via", ImportedServiceCommitment."Invoicing via");
        ServiceCommitment.TestField("Invoicing Item No.", ImportedServiceCommitment."Invoicing Item No.");
        ServiceCommitment.TestField(Template, ImportedServiceCommitment."Template Code");
        ServiceCommitment.TestField(Description, ImportedServiceCommitment.Description);
        ServiceCommitment.TestField("Extension Term", ImportedServiceCommitment."Extension Term");
        ServiceCommitment.TestField("Notice Period", ImportedServiceCommitment."Notice Period");
        ServiceCommitment.TestField("Initial Term", ImportedServiceCommitment."Initial Term");
        ServiceCommitment.TestField("Subscription Line Start Date", ImportedServiceCommitment."Subscription Line Start Date");
        ServiceCommitment.TestField("Subscription Line End Date", ImportedServiceCommitment."Subscription Line End Date");
        if ImportedServiceCommitment."Next Billing Date" = 0D then
            ServiceCommitment.TestField("Next Billing Date", ImportedServiceCommitment."Subscription Line Start Date")
        else
            ServiceCommitment.TestField("Next Billing Date", ImportedServiceCommitment."Next Billing Date");
        ServiceCommitment.TestField("Currency Factor", ImportedServiceCommitment."Currency Factor");
        ServiceCommitment.TestField("Currency Factor Date", ImportedServiceCommitment."Currency Factor Date");
        ServiceCommitment.TestField("Currency Code", ImportedServiceCommitment."Currency Code");
        ServiceCommitment.TestField("Calculation Base Amount", ImportedServiceCommitment."Calculation Base Amount");
        ServiceCommitment.TestField("Calculation Base %", ImportedServiceCommitment."Calculation Base %");
        ServiceCommitment.TestField("Billing Base Period", ImportedServiceCommitment."Billing Base Period");
        ServiceCommitment.TestField("Billing Rhythm", ImportedServiceCommitment."Billing Rhythm");

        if ImportedServiceCommitment."Discount %" <> 0 then
            ServiceCommitment.TestField("Discount %", ImportedServiceCommitment."Discount %");
        if ImportedServiceCommitment."Discount Amount" <> 0 then
            ServiceCommitment.TestField("Discount Amount", ImportedServiceCommitment."Discount Amount");
        if ImportedServiceCommitment.Amount <> 0 then
            ServiceCommitment.TestField(Amount, ImportedServiceCommitment.Amount);
        if ImportedServiceCommitment."Discount Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Discount Amount (LCY)", ImportedServiceCommitment."Discount Amount (LCY)");
        if ImportedServiceCommitment."Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Amount (LCY)", ImportedServiceCommitment."Amount (LCY)");
        if ImportedServiceCommitment."Calculation Base Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Calculation Base Amount (LCY)", ImportedServiceCommitment."Calculation Base Amount (LCY)");
    end;

    procedure UpdateServiceCommitmentPackageLineWithInvoicingItem(var ServiceCommPackageLine: Record "Subscription Package Line"; ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if ItemNo <> '' then
            ServiceCommPackageLine."Invoicing Item No." := ItemNo
        else begin
            CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
            ServiceCommPackageLine."Invoicing Item No." := Item."No.";
        end;
        ServiceCommPackageLine.Modify(false);
    end;

    procedure UpdateServiceCommitmentPackageWithPriceGroup(var ServiceCommitmentPackage: Record "Subscription Package"; NewPriceGroupCode: Code[10])
    var
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        if NewPriceGroupCode = '' then begin
            LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
            NewPriceGroupCode := CustomerPriceGroup.Code;
        end;
        ServiceCommitmentPackage.Validate("Price Group", NewPriceGroupCode);
        ServiceCommitmentPackage.Modify(false);
    end;

    procedure UpdateItemUnitCostAndPrice(var Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal; RunOnModifyTrigger: Boolean)
    begin
        Item."Unit Price" := UnitPrice;
        Item."Unit Cost" := UnitCost;
        Item.Modify(RunOnModifyTrigger);
    end;
    #endregion Attributes

    #region Publishers

    [InternalEvent(false, false)]
    local procedure OnAssignItemToSubscriptionPackage(var ItemSubscriptionPackage: Record "Item Subscription Package")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateBasicItemOnBeforeModify(var Item: Record Item)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateCustomerSubscriptionContractOnBeforeModify(var CustomerSubscriptionContract: Record "Customer Subscription Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateCustomerOnBeforeModify(var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateSubscriptionPackageLineOnBeforeInsert(var SubscriptionPackageLine: Record "Subscription Package Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateSubPackageLineTemplateOnBeforeInsert(var SubPackageLineTemplate: Record "Sub. Package Line Template")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateServiceObjectItemOnBeforeModify(var Item: Record Item)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateSubscriptionHeaderOnBeforeModify(var SubscriptionHeader: Record "Subscription Header")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateVendorOnBeforeModify(var Vendor: Record Vendor)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateVendorSubscriptionContractOnBeforeModify(var VendorSubscriptionContract: Record "Vendor Subscription Contract")
    begin
    end;

    #endregion Publishers
}
