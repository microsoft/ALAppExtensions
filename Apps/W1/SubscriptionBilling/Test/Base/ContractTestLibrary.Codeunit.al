namespace Microsoft.SubscriptionBilling;

using System.Reflection;
using System.Environment.Configuration;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
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

codeunit 139685 "Contract Test Library"
{
    Access = Internal;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryUtility: Codeunit "Library - Utility";
        ContractsAppInitialized: Boolean;
        PrefixLbl: Label 'ZZZ', Locked = true;

    #Region General
    procedure EnableNewPricingExperience()
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
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
        SalesSetup: Record "Sales & Receivables Setup";
        SubBillingInstallation: Codeunit "Sub. Billing Installation";
    begin
        if ContractsAppInitialized then
            exit;
        ResetContractRecords();
        SubBillingInstallation.InitializeSetupTables();
        SalesSetup.Get();
        SalesSetup."Allow Editing Active Price" := false;
        SalesSetup.Modify(false);
        ContractsAppInitialized := true;
    end;

    procedure ResetContractRecords()
    var
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        VendorContract: Record "Vendor Contract";
        VendorContractLine: Record "Vendor Contract Line";
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        CustomerDeferrals: Record "Customer Contract Deferral";
        VendorDeferrals: Record "Vendor Contract Deferral";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ContractPriceUpdateLine: Record "Contract Price Update Line";
        PlannedServiceCommitment: Record "Planned Service Commitment";
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
    end;
    #EndRegion General

    #Region Item
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
                LibraryInventory.CreateItem(Item);
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

    procedure CreateServiceObjectItem(var Item: Record Item; SNSpecificTracking: Boolean)
    begin
        CreateServiceObjectItem(Item, SNSpecificTracking, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Type"::Inventory);
    end;

    procedure CreateServiceObjectItem(var Item: Record Item; SNSpecificTracking: Boolean; ItemServiceCommitmentType: Enum "Item Service Commitment Type"; ItemType: Enum "Item Type")
    begin
        InitContractsApp();
        CreateBasicItem(Item, ItemType, SNSpecificTracking);

        Item.Validate("Service Commitment Option", ItemServiceCommitmentType);

        OnCreateServiceObjectItemOnBeforeModify(Item);
        Item.Modify(true);
    end;

    procedure CreateItemWithServiceCommitmentOption(var NewItem: Record Item; ItemServiceCommitmentType: Enum "Item Service Commitment Type")
    begin
        CreateServiceObjectItem(NewItem, false, ItemServiceCommitmentType, Enum::"Item Type"::"Non-Inventory");
    end;
    #EndRegion Item

    #Region Customer
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
    #EndRegion Customer

    #Region Vendor
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
    #EndRegion Vendor

    #Region Contracts
    procedure CreateCustomerContract(var CustomerContract: Record "Customer Contract"; CustomerNo: Code[20])
    var
        CustomerContractNo: Code[20];
    begin
        CustomerContractNo := PrefixLbl + 'CUC000000';
        repeat
            CustomerContractNo := IncStr(CustomerContractNo);
        until not CustomerContract.Get(CustomerContractNo);

        CustomerContract.Init();
        CustomerContract.Validate("No.", CustomerContractNo);
        CustomerContract.Insert(true);
        if CustomerNo <> '' then
            CustomerContract.Validate("Sell-to Customer No.", CustomerNo);

        OnCreateCustomerContractOnBeforeModify(CustomerContract);
        CustomerContract.Modify(true);
    end;

    procedure CreateVendorContract(var VendorContract: Record "Vendor Contract"; VendorNo: Code[20])
    var
        VendorContractNo: Code[20];
    begin
        VendorContractNo := PrefixLbl + 'VEC000000';
        repeat
            VendorContractNo := IncStr(VendorContractNo);
        until not VendorContract.Get(VendorContractNo);

        VendorContract.Init();
        VendorContract.Validate("No.", VendorContractNo);
        VendorContract.Insert(true);
        if VendorNo <> '' then
            VendorContract.Validate("Buy-from Vendor No.", VendorNo);

        OnCreateVendorContractOnBeforeModify(VendorContract);
        VendorContract.Modify(true);
    end;

    procedure CreateCustomerContractWithContractType(var CustomerContract: Record "Customer Contract"; var ContractType: Record "Contract Type")
    var
        Customer: Record Customer;
    begin
        CreateCustomer(Customer);
        CreateCustomerContract(CustomerContract, Customer."No.");
        CreateContractType(ContractType);
        CustomerContract."Contract Type" := ContractType.Code;
        CustomerContract.Modify(false);
    end;

    procedure CreateVendorContractWithContractType(var VendorContract: Record "Vendor Contract"; var ContractType: Record "Contract Type")
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        CreateVendorContract(VendorContract, Vendor."No.");
        CreateContractType(ContractType);
        VendorContract."Contract Type" := ContractType.Code;
        VendorContract.Modify(false);
    end;

    procedure CreateCustomerContractAndCreateContractLinesAndBillingProposal(var CustomerContract: Record "Customer Contract"; var ServiceObject: Record "Service Object"; CustomerNo: Code[20]; var BillingTemplate: Record "Billing Template")
    begin
        CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, CustomerNo);
        CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    procedure CreateVendorContractAndCreateContractLinesAndBillingProposal(var VendorContract: Record "Vendor Contract"; var ServiceObject: Record "Service Object"; VendorNo: Code[20]; var VendorBillingTemplate: Record "Billing Template")
    begin
        CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, VendorNo);
        CreateBillingProposal(VendorBillingTemplate, Enum::"Service Partner"::Vendor);
    end;

    procedure CreateCustomerContractAndCreateContractLines(var CustomerContract: Record "Customer Contract"; var ServiceObject: Record "Service Object"; CustomerNo: Code[20])
    begin
        CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, CustomerNo, false);
    end;

    procedure CreateVendorContractAndCreateContractLines(var VendorContract: Record "Vendor Contract"; var ServiceObject: Record "Service Object"; VendorNo: Code[20])
    begin
        CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, VendorNo, false);
    end;

    procedure CreateCustomerContractAndCreateContractLines(var CustomerContract: Record "Customer Contract"; var ServiceObject: Record "Service Object"; CustomerNo: Code[20]; CreateAdditionalCustomerServCommLine: Boolean)
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then begin
            CreateCustomer(Customer);
            CustomerNo := Customer."No.";
        end;
        CreateCustomerContract(CustomerContract, CustomerNo);
        AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, CreateAdditionalCustomerServCommLine);
    end;

    procedure AssignServiceObjectToCustomerContract(var CustomerContract: Record "Customer Contract"; var ServiceObject: Record "Service Object"; CreateAdditionalCustomerServCommLine: Boolean)
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        Customer: Record Customer;
        Item: Record Item;
    begin
        Customer.Get(CustomerContract."Sell-to Customer No.");
        if ServiceObject."No." = '' then begin
            if CreateAdditionalCustomerServCommLine then
                CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 2, 0)
            else
                CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
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

    procedure CreateVendorContractAndCreateContractLines(var VendorContract: Record "Vendor Contract"; var ServiceObject: Record "Service Object"; VendorNo: Code[20]; CreateAdditionalVendorServCommLine: Boolean)
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then begin
            CreateVendor(Vendor);
            VendorNo := Vendor."No.";
        end;
        CreateVendorContract(VendorContract, VendorNo);
        AssignServiceObjectToVendorContract(VendorContract, ServiceObject, CreateAdditionalVendorServCommLine);
    end;

    procedure AssignServiceObjectToVendorContract(var VendorContract: Record "Vendor Contract"; var ServiceObject: Record "Service Object"; CreateAdditionalVendorServCommLine: Boolean)
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        Vendor.Get(VendorContract."Buy-from Vendor No.");
        if ServiceObject."No." = '' then begin
            if CreateAdditionalVendorServCommLine then
                CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 0, 2)
            else
                CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 0, 1);
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

    procedure CreateContractType(var ContractType: Record "Contract Type")
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
    #EndRegion Contracts

    #Region Service Commitment Template & Package
    procedure CreateServiceCommitmentTemplate(var ServiceCommitmentTemplate: Record "Service Commitment Template"; BillingBasePeriod: Text; CalcBasePercent: Decimal; InvoicingVia: Enum "Invoicing Via"; CalculationBaseType: Enum "Calculation Base Type")
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

        OnCreateServiceCommitmentTemplateOnBeforeInsert(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate.Insert(true)
    end;

    procedure CreateServiceCommitmentTemplate(var ServiceCommitmentTemplate: Record "Service Commitment Template")
    begin
        ServiceCommitmentTemplate.Init();
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '', ServiceCommitmentTemplate."Calculation Base %", ServiceCommitmentTemplate."Invoicing via", ServiceCommitmentTemplate."Calculation Base Type");
    end;

    procedure CreateServiceCommitmentPackage(var ServiceCommitmentPackage: Record "Service Commitment Package")
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

    procedure CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Service Commitment Package"; var ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplateCode, ServiceCommPackageLine);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Service Comm. Package Line";
    BillingBasePeriodText: Text; BillingRhythmText: Text; ServicePartner: Enum "Service Partner")
    begin
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine, BillingBasePeriodText, BillingRhythmText, ServicePartner, '');
        OnCreateServiceCommitmentPackageLineOnBeforeInsert(ServiceCommPackageLine);
        ServiceCommPackageLine.Modify(true);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Service Comm. Package Line";
    BillingBasePeriodText: Text; BillingRhythmText: Text; ServicePartner: Enum "Service Partner"; PriceBindingPeriod: Text)
    var
        ServiceCommPackageLine2: Record "Service Comm. Package Line";
        NextLineNo: Integer;
    begin
        ServiceCommPackageLine2.SetRange("Package Code", ServiceCommitmentPackageCode);
        if ServiceCommPackageLine2.FindLast() then
            NextLineNo := ServiceCommPackageLine2."Line No.";
        NextLineNo += 10000;
        ServiceCommPackageLine.Init();
        ServiceCommPackageLine."Package Code" := ServiceCommitmentPackageCode;
        ServiceCommPackageLine."Line No." := NextLineNo;
        if ServiceCommitmentTemplateCode <> '' then
            ServiceCommPackageLine.Validate(Template, ServiceCommitmentTemplateCode);
        Evaluate(ServiceCommPackageLine."Billing Base Period", BillingBasePeriodText);
        Evaluate(ServiceCommPackageLine."Billing Rhythm", BillingRhythmText);
        ServiceCommPackageLine.Validate(Partner, ServicePartner);
        Evaluate(ServiceCommPackageLine."Price Binding Period", PriceBindingPeriod);

        OnCreateServiceCommitmentPackageLineOnBeforeInsert(ServiceCommPackageLine);
        ServiceCommPackageLine.Insert(true);
    end;

    procedure CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode: Code[20]; ServiceCommitmentTemplateCode: Code[20]; var ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine, '<12M>', '<12M>', Enum::"Service Partner"::Customer, '<1M>');
    end;

    procedure UpdateServiceCommitmentPackageLine(var ServiceCommPackageLine: Record "Service Comm. Package Line"; BillingBasePeriod: Text; CalculationBase: Decimal; BillingRhytm: Text; ExtensionTerm: Text; ServicePartner: Enum "Service Partner"; ItemNo: Code[20])
    begin
        UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, BillingBasePeriod, CalculationBase, ExtensionTerm, ServicePartner, ItemNo, "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', BillingRhytm, false);
    end;

    internal procedure UpdateServiceCommitmentPackageLine(var ServiceCommPackageLine: Record "Service Comm. Package Line"; BillingBasePeriod: Text; CalculationBase: Decimal; ExtensionTerm: Text; ServicePartner: Enum "Service Partner"; ItemNo: Code[20]; InvoicingVia: Enum "Invoicing Via"; CalculationBaseType: Enum "Calculation Base Type"; PriceBindingPeriod: Text; CalculationRhythmDateFormulaTxt: Text; CreateDiscountLine: Boolean)
    begin
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

    internal procedure InitServiceCommitmentPackageLineFields(var NewServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        Evaluate(NewServiceCommPackageLine."Billing Rhythm", '<1M>');
        Evaluate(NewServiceCommPackageLine."Service Comm. Start Formula", '<CY>');
        Evaluate(NewServiceCommPackageLine."Initial Term", '<12M>');
        Evaluate(NewServiceCommPackageLine."Extension Term", '<12M>');
        Evaluate(NewServiceCommPackageLine."Notice Period", '<1M>');
        NewServiceCommPackageLine.Modify(false);
    end;
    #EndRegion Service Commitment Template & Package

    #Region Service Object
    procedure CreateServiceObjectItemWithServiceCommitments(var Item: Record Item)
    var
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
    begin
        CreateServiceObjectItem(Item, false);
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    procedure CreateServiceObject(var ServiceObject: Record "Service Object"; ItemNo: Code[20]; SNSpecificTracking: Boolean)
    var
        ServiceObjectNo: Code[20];
    begin
        ServiceObjectNo := PrefixLbl + 'SOBJ000000';
        repeat
            ServiceObjectNo := IncStr(ServiceObjectNo);
        until not ServiceObject.Get(ServiceObjectNo);

        ServiceObject.Init();
        ServiceObject.Validate("No.", ServiceObjectNo);
        ServiceObject.Insert(true);
        if ItemNo <> '' then
            ServiceObject.Validate("Item No.", ItemNo);
        if not SNSpecificTracking then
            ServiceObject."Quantity Decimal" := LibraryRandom.RandDec(10, 2)
        else
            ServiceObject."Serial No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")), 1, MaxStrLen(ServiceObject."Serial No."));

        OnCreateServiceObjectOnBeforeModify(ServiceObject);
        ServiceObject.Modify(true);
    end;

    procedure CreateServiceObject(var ServiceObject: Record "Service Object"; ItemNo: Code[20])
    begin
        CreateServiceObject(ServiceObject, ItemNo, false);
    end;

    procedure CreateServiceObjectWithItem(var ServiceObject: Record "Service Object"; var Item: Record Item; SNSpecificTracking: Boolean)
    begin
        if Item."No." = '' then
            CreateServiceObjectItem(Item, SNSpecificTracking);
        CreateServiceObject(ServiceObject, Item."No.", SNSpecificTracking);
    end;

    procedure CreateServiceObjectWithItemAndWithServiceCommitment(var ServiceObject: Record "Service Object"; NewInvocingVia: Enum "Invoicing Via"; SNSpecificTracking: Boolean; var Item: Record Item;
                                                                    NoOfCustomerServCommLinesToCreate: Integer; NoOfVendorServCommLinesToCreate: Integer; BillingBasePeriodText: Text; BillingRhythmText: Text)
    var
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        Item2: Record Item;
        i: Integer;
    begin
        CreateServiceObjectWithItem(ServiceObject, Item, SNSpecificTracking);

        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '', LibraryRandom.RandDec(100, 2), NewInvocingVia, Enum::"Calculation Base Type"::"Item Price");

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
        ServiceCommitmentPackage.SetFilter(Code, GetPackageFilterForItem(ItemServCommitmentPackage, ServiceObject."Item No."));
        InsertServiceCommitmentsFromServCommPackage(ServiceObject, WorkDate(), ServiceCommitmentPackage);
    end;

    procedure CreateServiceObjectWithItemAndWithServiceCommitment(var ServiceObject: Record "Service Object"; NewInvocingVia: Enum "Invoicing Via"; SNSpecificTracking: Boolean; var Item: Record Item;
                                                                    NoOfNewCustomerServCommLines: Integer; NoOfNewVendorServCommLines: Integer)
    begin
        CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, NewInvocingVia, SNSpecificTracking, Item, NoOfNewCustomerServCommLines, NoOfNewVendorServCommLines, '<1Y>', '<1M>');
    end;
    #EndRegion Service Object

    procedure ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(var ServiceCommitment: Record "Service Commitment"; BillingBasePeriodText: Text; BillingRhythmText: Text)
    begin
        Clear(ServiceCommitment."Billing Base Period");
        Clear(ServiceCommitment."Billing Rhythm");
        Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriodText);
        ServiceCommitment.Validate("Billing Base Period");
        Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythmText);
        ServiceCommitment.Validate("Billing Rhythm");
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

    procedure AssignItemToServiceCommitmentPackage(Item: Record Item; ItemServCommitmentPackageCode: Code[20])
    begin
        AssignItemToServiceCommitmentPackage(Item, ItemServCommitmentPackageCode, false);
    end;

    procedure AssignItemToServiceCommitmentPackage(Item: Record Item; ItemServCommitmentPackageCode: Code[20]; DeclareAsStandard: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        ItemServCommitmentPackage.Init();
        ItemServCommitmentPackage."Item No." := Item."No.";
        ItemServCommitmentPackage.Validate(Code, ItemServCommitmentPackageCode);
        if DeclareAsStandard then
            ItemServCommitmentPackage.Standard := true;

        OnAssignItemToServiceCommitmentPackage(ItemServCommitmentPackage);

        ItemServCommitmentPackage.Insert(false);
    end;

    procedure CreateDefaultRecurringBillingTemplateForServicePartner(var BillingTemplate: Record "Billing Template"; ServicePartner: Enum "Service Partner")
    begin
        CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', '', ServicePartner);
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

    procedure FillTempServiceCommitment(var TempServiceCommitment: Record "Service Commitment" temporary; ServiceObject: Record "Service Object"; CustomerContract: Record "Customer Contract")
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        FilterNonContractRelatedServiceCommitment(ServiceCommitment, ServiceObject, Enum::"Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            TempServiceCommitment.TransferFields(ServiceCommitment);
            TempServiceCommitment."Contract No." := CustomerContract."No.";
            TempServiceCommitment.Insert(false);
        until ServiceCommitment.Next() = 0;
    end;

    procedure FillTempServiceCommitmentForVendor(var TempServiceCommitment: Record "Service Commitment" temporary; ServiceObject: Record "Service Object"; VendorContract: Record "Vendor Contract")
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        FilterNonContractRelatedServiceCommitment(ServiceCommitment, ServiceObject, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            TempServiceCommitment.TransferFields(ServiceCommitment);
            TempServiceCommitment."Contract No." := VendorContract."No.";
            TempServiceCommitment.Insert(false);
        until ServiceCommitment.Next() = 0;
    end;

    local procedure FilterNonContractRelatedServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ServiceObject: Record "Service Object"; ServicePartner: Enum "Service Partner")
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Contract No.", '');
        case ServicePartner of
            ServicePartner::Customer:
                ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
            ServicePartner::Vendor:
                ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        end;
    end;

    procedure SetGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; EmptyAccount: Boolean; ServicePartner: Enum "Service Partner")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then begin
            case ServicePartner of
                Enum::"Service Partner"::Customer:
                    if EmptyAccount then begin
                        GeneralPostingSetup."Cust. Contr. Deferral Account" := '';
                        GeneralPostingSetup."Customer Contract Account" := '';
                    end else begin
                        GeneralPostingSetup."Customer Contract Account" := GeneralPostingSetup."Sales Account";
                        LibraryERM.CreateGLAccount(GLAccount);
                        GeneralPostingSetup."Cust. Contr. Deferral Account" := GLAccount."No.";
                    end;
                Enum::"Service Partner"::Vendor:
                    if EmptyAccount then begin
                        GeneralPostingSetup."Vend. Contr. Deferral Account" := '';
                        GeneralPostingSetup."Vendor Contract Account" := '';
                    end else begin
                        GeneralPostingSetup."Vendor Contract Account" := GeneralPostingSetup."Purch. Account";
                        LibraryERM.CreateGLAccount(GLAccount);
                        GeneralPostingSetup."Vend. Contr. Deferral Account" := GLAccount."No.";
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

    procedure CreateDefaultDimensionValueForTable(TableID: Integer; No: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        CreateDefaultDimensionValueForTable(DimensionValue, TableID, No);
    end;

    procedure CreateDefaultDimensionValueForTable(var DimensionValue: Record "Dimension Value"; TableID: Integer; No: Code[20])
    var
        Dimension: Record Dimension;
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, TableID, No, Dimension.Code, DimensionValue.Code);
    end;

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

    internal procedure FilterBillingLineArchiveOnContractLine(var FilteredBillingLineArchive: Record "Billing Line Archive"; ContractNo: Code[20]; ContractLineNo: Integer; ServicePartner: Enum "Service Partner")
    begin
        FilteredBillingLineArchive.SetRange(Partner, ServicePartner);
        FilteredBillingLineArchive.SetRange("Contract No.", ContractNo);
        if ContractLineNo <> 0 then
            FilteredBillingLineArchive.SetRange("Contract Line No.", ContractLineNo);
    end;

    procedure InsertCustomerContractCommentLine(CustomerContract: Record "Customer Contract"; var CustomerContractLine: Record "Customer Contract Line")
    begin
        CustomerContractLine.Init();
        CustomerContractLine."Contract No." := CustomerContract."No.";
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Comment;
        CustomerContractLine."Service Commitment Description" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContractLine."Service Commitment Description")), 1, MaxStrLen(CustomerContractLine."Service Commitment Description"));
        CustomerContractLine.Insert(false);
    end;

    procedure InsertVendorContractCommentLine(VendorContract: Record "Vendor Contract"; var VendorContractLine: Record "Vendor Contract Line")
    begin
        VendorContractLine.Init();
        VendorContractLine."Contract No." := VendorContract."No.";
        VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::Comment;
        VendorContractLine."Service Commitment Description" := CopyStr(LibraryRandom.RandText(MaxStrLen(VendorContractLine."Service Commitment Description")), 1, MaxStrLen(VendorContractLine."Service Commitment Description"));
        VendorContractLine.Insert(false);
    end;

    #Region Make local / internal functions public for external test apps
    procedure CreateVendorContractLinesFromServiceCommitments(var VendorContract: Record "Vendor Contract"; var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    procedure GetPackageFilterForItem(ItemServCommitmentPackage: Record "Item Serv. Commitment Package"; ItemNo: Code[20]): Text
    begin
        exit(ItemServCommitmentPackage.GetPackageFilterForItem(ItemNo));
    end;

    procedure InsertServiceCommitmentsFromServCommPackage(var ServiceObject: Record "Service Object"; WorkDate: Date; var ServiceCommitmentPackage: Record "Service Commitment Package")
    begin
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    procedure BillingTemplateWriteFilter(var BillingTemplate: Record "Billing Template"; FieldNo: Integer; FilterText: Text)
    begin
        BillingTemplate.WriteFilter(BillingTemplate.FieldNo(Filter), FilterText);
    end;

    procedure BillingProposalCreateBillingProposal(BillingProposal: Codeunit "Billing Proposal"; BillingTemplateCode: Code[20]; BillingDate: Date; BillingToDate: Date)
    begin
        BillingProposal.CreateBillingProposal(BillingTemplateCode, BillingDate, BillingToDate);
    end;

    procedure CustomerContractUpdateServicesDates(var CustomerContract: Record "Customer Contract")
    begin
        CustomerContract.UpdateServicesDates();
    end;

    procedure ServiceCommitmentIsClosed(var ServiceCommitment: Record "Service Commitment"): Boolean
    begin
        exit(ServiceCommitment.IsClosed());
    end;
    #EndRegion Make local / internal functions public for external test apps

    procedure CreateTranslationForField(var FieldTranslation: Record "Field Translation"; SourceRecord: Variant; FieldID: Integer; LanguageCode: Code[10])
    var
        tblField: Record Field;
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        DataTypeMgt.GetRecordRef(SourceRecord, RecRef);
        FRef := RecRef.Field(RecRef.SystemIdNo());
        tblField.Get(RecRef.Number, FieldID);

        FieldTranslation.Init();
        FieldTranslation.Validate("Table ID", RecRef.Number);
        FieldTranslation.Validate("Field No.", FieldID);
        FieldTranslation.Validate("Language Code", LanguageCode);
        FieldTranslation.Validate("Source SystemId", FRef.Value);
        FieldTranslation.Validate(Translation, LibraryRandom.RandText(tblField.Len));
        FieldTranslation.Insert(true);
    end;

    #Region Imported Data
    internal procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Service Object"; CustomerNo: Code[20]; ItemNo: Code[20]; UseSerialNo: Boolean)
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        ImportedServiceObject.Init();
        ImportedServiceObject."Entry No." := 0;
        ImportedServiceObject.Insert(false);
        ImportedServiceObject."Service Object No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceObject."Service Object No.")), 1, MaxStrLen(ImportedServiceObject."Service Object No."));
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

    internal procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Service Object")
    begin
        CreateImportedServiceObject(ImportedServiceObject, '', '', false);
    end;

    internal procedure CreateImportedServiceObject(var ImportedServiceObject: Record "Imported Service Object"; CustomerNo: Code[20]; ItemNo: Code[20])
    begin
        CreateImportedServiceObject(ImportedServiceObject, CustomerNo, ItemNo, false);
    end;

    internal procedure CreateImportedServiceCommitmentCustomer(var ImportedServiceCommitment: Record "Imported Service Commitment"; ImportedServiceObject: Record "Imported Service Object"; CustomerContract: Record "Customer Contract"; NewContractLineType: Enum "Contract Line Type")
    begin
        ImportedServiceObject.TestField("Service Object No.");
        CustomerContract.TestField("No.");

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Service Object No." := ImportedServiceObject."Service Object No.";
        ImportedServiceCommitment.Partner := "Service Partner"::Customer;
        ImportedServiceCommitment."Contract No." := CustomerContract."No.";
        ImportedServiceCommitment."Contract Line Type" := NewContractLineType;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := ImportedServiceObject."Item No.";
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ImportedServiceCommitment."Currency Code" := CustomerContract."Currency Code";
        if not ImportedServiceCommitment.IsContractCommentLine() then
            SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);
    end;

    internal procedure CreateImportedServiceCommitmentVendor(var ImportedServiceCommitment: Record "Imported Service Commitment"; ImportedServiceObject: Record "Imported Service Object"; VendorContract: Record "Vendor Contract"; NewContractLineType: Enum "Contract Line Type")
    begin
        ImportedServiceObject.TestField("Service Object No.");
        VendorContract.TestField("No.");

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Service Object No." := ImportedServiceObject."Service Object No.";
        ImportedServiceCommitment.Partner := "Service Partner"::Vendor;
        ImportedServiceCommitment."Contract No." := VendorContract."No.";
        ImportedServiceCommitment."Contract Line Type" := NewContractLineType;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := ImportedServiceObject."Item No.";
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ImportedServiceCommitment."Currency Code" := VendorContract."Currency Code";
        if not ImportedServiceCommitment.IsContractCommentLine() then
            SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);
    end;

    local procedure SetImportedServiceCommitmentData(var ImportedServiceCommitment: Record "Imported Service Commitment")
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

    internal procedure SetImportedServiceCommitmentServiceDates(var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
        ImportedServiceCommitment."Service Start Date" := CalcDate('<-CY>', WorkDate());
        ImportedServiceCommitment."Service End Date" := CalcDate('<+CY>', WorkDate());
    end;

    internal procedure SetImportedServiceCommitmentDateFormulas(var ImportedServiceCommitment: Record "Imported Service Commitment"; NewBillingBasePeriod: Text; NewInitialTerm: Text; NewExtensionTerm: Text; NewBillingRhythm: Text; NewNoticePeriod: Text)
    begin
        Evaluate(ImportedServiceCommitment."Billing Base Period", NewBillingBasePeriod);
        Evaluate(ImportedServiceCommitment."Initial Term", NewInitialTerm);
        Evaluate(ImportedServiceCommitment."Extension Term", NewExtensionTerm);
        Evaluate(ImportedServiceCommitment."Billing Rhythm", NewBillingRhythm);
        Evaluate(ImportedServiceCommitment."Notice Period", NewNoticePeriod);
    end;
    #EndRegion Imported Data

    #Region Attributes
    internal procedure CreateServiceObjectAttributeMappedToServiceObject(ServiceObjectNo: Code[20]; var ItemAttribute: Record "Item Attribute";
                                                                                                    var ItemAttributeValue: Record "Item Attribute Value";
                                                                                                    NewPrimary: Boolean)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        LibraryInventory.CreateItemAttribute(ItemAttribute, ItemAttribute.Type::Text, '');
        LibraryInventory.CreateItemAttributeValue(
            ItemAttributeValue, ItemAttribute.ID,
            CopyStr(LibraryUtility.GenerateRandomText(MaxStrLen(ItemAttributeValue.Value)), 1, MaxStrLen(ItemAttributeValue.Value)));
        CreateItemAttributeValueMapping(Database::"Service Object", ServiceObjectNo, ItemAttribute.ID, ItemAttributeValue.ID);
        if NewPrimary then begin
            FilterItemAttributeValueMapping(ItemAttributeValueMapping, Database::"Service Object", ServiceObjectNo, ItemAttribute.ID, ItemAttributeValue.ID);
            if ItemAttributeValueMapping.FindFirst() then begin
                ItemAttributeValueMapping.Primary := NewPrimary;
                ItemAttributeValueMapping.Modify(false);
            end;
        end;
    end;

    internal procedure CreateItemAttributeValueMapping(TableID: Integer; No: Code[20]; AttributeID: Integer; AttributeValueID: Integer)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        // function duplicated from LibraryInventory to avoid OnInsert trigger
        // because Service Object table does not have Field 1 as PK
        ItemAttributeValueMapping.Validate("Table ID", TableID);
        ItemAttributeValueMapping.Validate("No.", No);
        ItemAttributeValueMapping.Validate("Item Attribute ID", AttributeID);
        ItemAttributeValueMapping.Validate("Item Attribute Value ID", AttributeValueID);
        ItemAttributeValueMapping.Insert(false);
    end;

    internal procedure FilterItemAttributeValueMapping(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; TableID: Integer; No: Code[20]; AttributeID: Integer; AttributeValueID: Integer)
    begin
        ItemAttributeValueMapping.SetRange("Table ID", TableID);
        ItemAttributeValueMapping.SetRange("No.", No);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", AttributeID);
        ItemAttributeValueMapping.SetRange("Item Attribute Value ID", AttributeValueID);
    end;

    internal procedure TestServiceCommitmentAgainstImportedServiceCommitment(var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
        ServiceCommitment.TestField("Invoicing via", ImportedServiceCommitment."Invoicing via");
        ServiceCommitment.TestField("Invoicing Item No.", ImportedServiceCommitment."Invoicing Item No.");
        ServiceCommitment.TestField(Template, ImportedServiceCommitment."Template Code");
        ServiceCommitment.TestField(Description, ImportedServiceCommitment.Description);
        ServiceCommitment.TestField("Extension Term", ImportedServiceCommitment."Extension Term");
        ServiceCommitment.TestField("Notice Period", ImportedServiceCommitment."Notice Period");
        ServiceCommitment.TestField("Initial Term", ImportedServiceCommitment."Initial Term");
        ServiceCommitment.TestField("Service Start Date", ImportedServiceCommitment."Service Start Date");
        ServiceCommitment.TestField("Service End Date", ImportedServiceCommitment."Service End Date");
        if ImportedServiceCommitment."Next Billing Date" = 0D then
            ServiceCommitment.TestField("Next Billing Date", ImportedServiceCommitment."Service Start Date")
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
        if ImportedServiceCommitment."Service Amount" <> 0 then
            ServiceCommitment.TestField("Service Amount", ImportedServiceCommitment."Service Amount");
        if ImportedServiceCommitment."Discount Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Discount Amount (LCY)", ImportedServiceCommitment."Discount Amount (LCY)");
        if ImportedServiceCommitment."Service Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Service Amount (LCY)", ImportedServiceCommitment."Service Amount (LCY)");
        if ImportedServiceCommitment."Calculation Base Amount (LCY)" <> 0 then
            ServiceCommitment.TestField("Calculation Base Amount (LCY)", ImportedServiceCommitment."Calculation Base Amount (LCY)");
    end;

    internal procedure InsertDocumentAttachment(TableId: Integer; RecNo: Code[20])
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.Validate("Table ID", TableId);
        DocumentAttachment.Validate("No.", RecNo);
        DocumentAttachment.Insert(false);
    end;

    internal procedure CreateImportedCustomerContract(var ImportedCustomerContract: Record "Imported Customer Contract"; SellToCustomerNo: Code[20]; BillToCustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        ImportedCustomerContract.Init();
        ImportedCustomerContract."Entry No." := 0;
        ImportedCustomerContract.Insert(false);
        ImportedCustomerContract."Contract No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedCustomerContract."Contract No.")), 1, MaxStrLen(ImportedCustomerContract."Contract No."));

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

    internal procedure CreateImportedCustomerContract(var ImportedCustomerContract: Record "Imported Customer Contract")
    begin
        CreateImportedCustomerContract(ImportedCustomerContract, '', '');
    end;

    internal procedure UpdateServiceCommitmentPackageWithPriceGroup(var ServiceCommitmentPackage: Record "Service Commitment Package"; NewPriceGroupCode: Code[10])
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

    internal procedure CreatePriceUpdateTemplate(var PriceUpdateTemplate: Record "Price Update Template"; ServicePartner: Enum "Service Partner"; PriceUpdateMethod: Enum "Price Update Method";
                                                                                                                                 UpdateValuePerc: Decimal;
                                                                                                                                 PerformUpdateOnFormula: Text;
                                                                                                                                 InclContrLinesUpToDateFormula: Text;
                                                                                                                                 PriceBindingPeriod: Text)
    begin
        PriceUpdateTemplate.Init();
        PriceUpdateTemplate.Code := LibraryUtility.GenerateRandomCode20(PriceUpdateTemplate.FieldNo(Code), Database::"Price Update Template");
        PriceUpdateTemplate.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(PriceUpdateTemplate.Description));
        PriceUpdateTemplate.Partner := ServicePartner;
        PriceUpdateTemplate.Validate("Price Update Method", PriceUpdateMethod);
        PriceUpdateTemplate.Validate("Update Value %", UpdateValuePerc);
        Evaluate(PriceUpdateTemplate."Perform Update on Formula", PerformUpdateOnFormula);
        Evaluate(PriceUpdateTemplate.InclContrLinesUpToDateFormula, InclContrLinesUpToDateFormula);
        Evaluate(PriceUpdateTemplate."Price Binding Period", PriceBindingPeriod);
        PriceUpdateTemplate.Insert(false);
    end;

    internal procedure CreateMultipleServiceObjectsWithItemSetup(var Customer: Record Customer; var ServiceObject: Record "Service Object"; var Item: Record Item; NoOfServiceObjects: Integer)
    var
        i: Integer;
    begin
        CreateCustomer(Customer);
        for i := 1 to NoOfServiceObjects do begin
            CreateServiceObjectWithItem(ServiceObject, Item, false);
            ServiceObject.SetHideValidationDialog(true);
            ServiceObject.Validate("End-User Customer Name", Customer.Name);
            ServiceObject."Quantity Decimal" := LibraryRandom.RandDec(10, 2);
            ServiceObject.Modify(false);
        end;
        UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), false);
    end;

    internal procedure UpdateItemUnitCostAndPrice(var Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal; RunOnModifyTrigger: Boolean)
    begin
        Item."Unit Price" := UnitPrice;
        Item."Unit Cost" := UnitCost;
        Item.Modify(RunOnModifyTrigger);
    end;

    internal procedure CreateServiceCommitmentTemplateSetup(var ServiceCommitmentTemplate: Record "Service Commitment Template"; CalcBasePeriodDateFormulaTxt: Text; InvoicingVia: Enum "Invoicing Via")
    begin
        CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        if CalcBasePeriodDateFormulaTxt <> '' then
            Evaluate(ServiceCommitmentTemplate."Billing Base Period", CalcBasePeriodDateFormulaTxt);
        ServiceCommitmentTemplate."Invoicing via" := InvoicingVia;
        ServiceCommitmentTemplate.Modify(false);
    end;

    internal procedure CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Service Commitment Package"; var ServiceCommPackageLine: Record "Service Comm. Package Line"; Item: Record Item; CalculationRhythmDateFormulaTxt: Text; PeriodCalculation: Enum "Period Calculation")
    begin
        CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplateCode, ServiceCommitmentPackage, ServiceCommPackageLine);
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

    internal procedure CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode: Code[20]; var ServiceCommitmentPackage: Record "Service Commitment Package"; var ServiceCommPackageLine: Record "Service Comm. Package Line"; Item: Record Item; CalculationRhythmDateFormulaTxt: Text)
    begin
        CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplateCode, ServiceCommitmentPackage, ServiceCommPackageLine, Item, CalculationRhythmDateFormulaTxt, "Period Calculation"::"Align to Start of Month");
    end;

    internal procedure InsertServiceCommitmentFromServiceCommPackageSetup(var ServiceCommitmentPackage: Record "Service Commitment Package"; var ServiceObject: Record "Service Object"; ServiceAndCalculationStartDate: Date)
    begin
        ServiceCommitmentPackage.SetRecFilter();
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);
    end;

    internal procedure InsertServiceCommitmentFromServiceCommPackageSetup(var ServiceCommitmentPackage: Record "Service Commitment Package"; var ServiceObject: Record "Service Object")
    begin
        InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject, 0D);
    end;
    #EndRegion Attributes

    #Region Publisher
    [InternalEvent(false, false)]
    local procedure OnCreateBasicItemOnBeforeModify(var Item: Record Item)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateServiceObjectItemOnBeforeModify(var Item: Record Item)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateServiceObjectOnBeforeModify(var ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateCustomerOnBeforeModify(var Customer: Record Customer)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateVendorOnBeforeModify(var Vendor: Record Vendor)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateCustomerContractOnBeforeModify(var CustomerContract: Record "Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateVendorContractOnBeforeModify(var VendorContract: Record "Vendor Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAssignItemToServiceCommitmentPackage(var ItemServCommitmentPackage: Record "Item Serv. Commitment Package")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateServiceCommitmentPackageLineOnBeforeInsert(var ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateServiceCommitmentTemplateOnBeforeInsert(var ServiceCommitmentTemplate: Record "Service Commitment Template")
    begin
    end;
    #EndRegion Publisher
}
