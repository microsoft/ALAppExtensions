namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;
using System.Threading;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Manufacturing.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Common;

codeunit 8105 "Contoso Subscription Billing"
{
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions =
        tabledata "Subscription Contract Type" = rim,
        tabledata "Billing Template" = rim,
        tabledata "Price Update Template" = rim,
        tabledata "General Posting Setup" = rm,
        tabledata "Item Templ." = rim,
        tabledata Item = rim,
        tabledata "Item Vendor" = rim,
        tabledata "Item Reference" = rim,
        tabledata "Sub. Package Line Template" = rim,
        tabledata "Subscription Package" = rim,
        tabledata "Subscription Package Line" = rim,
        tabledata "Item Subscription Package" = rim,
        tabledata "Usage Data Supplier" = rim,
        tabledata "Usage Data Supplier Reference" = rim,
        tabledata "Generic Import Settings" = rim,
        tabledata "Subscription Header" = rim,
        tabledata "Subscription Line" = rimd,
        tabledata "Customer Subscription Contract" = rimd,
        tabledata "Cust. Sub. Contract Line" = rimd,
        tabledata "Vendor Subscription Contract" = rimd,
        tabledata "Vend. Sub. Contract Line" = rimd,
        tabledata "Usage Data Import" = rimd,
        tabledata "Usage Data Blob" = rimd,
        tabledata "Job Queue Entry" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertContractType(Code: Code[10]; Description: Text[50])
    var
        ContractType: Record "Subscription Contract Type";
        Exists: Boolean;
    begin
        if ContractType.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ContractType.Validate(Code, Code);
        ContractType.Validate(Description, Description);

        if Exists then
            ContractType.Modify(true)
        else
            ContractType.Insert(true);
    end;

    procedure InsertBillingTemplate(TemplateCode: Code[20]; Description: Text[80]; ServicePartner: Enum "Service Partner"; ContractTypeCode: Code[10])
    var
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        FilterText: Text;
        Exists: Boolean;
    begin
        if BillingTemplate.Get(TemplateCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BillingTemplate.Validate(Code, TemplateCode);
        BillingTemplate.Validate(Description, Description);
        BillingTemplate.Validate(Partner, ServicePartner);
        BillingTemplate.Validate("Group by", "Contract Billing Grouping"::Contract);

        if Exists then
            BillingTemplate.Modify(true)
        else
            BillingTemplate.Insert(true);

        if ContractTypeCode = '' then
            exit;
        case ServicePartner of
            ServicePartner::Customer:
                begin
                    CustomerContract.SetRange("Contract Type", ContractTypeCode);
                    FilterText := CustomerContract.GetView(false);
                end;
            ServicePartner::Vendor:
                begin
                    VendorContract.SetRange("Contract Type", ContractTypeCode);
                    FilterText := VendorContract.GetView(false);
                end;
        end;
        BillingTemplate.WriteFilter(BillingTemplate.FieldNo(Filter), FilterText);
    end;

    procedure InsertPriceUpdateTemplate(Code: Code[20]; Description: Text[80]; ServicePartner: Enum "Service Partner"; ContractTypeCode: Code[10])
    var
        PriceUpdateTemplate: Record "Price Update Template";
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        FilterText: Text;
        Exists: Boolean;
    begin
        if PriceUpdateTemplate.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PriceUpdateTemplate.Validate(Code, Code);
        PriceUpdateTemplate.Validate(Description, Description);
        PriceUpdateTemplate.Validate(Partner, ServicePartner);
        PriceUpdateTemplate.Validate("Group by", "Contract Billing Grouping"::Contract);

        if Exists then
            PriceUpdateTemplate.Modify(true)
        else
            PriceUpdateTemplate.Insert(true);

        if ContractTypeCode = '' then
            exit;
        case ServicePartner of
            ServicePartner::Customer:
                begin
                    CustomerContract.SetRange("Contract Type", ContractTypeCode);
                    FilterText := CustomerContract.GetView(false);
                end;
            ServicePartner::Vendor:
                begin
                    VendorContract.SetRange("Contract Type", ContractTypeCode);
                    FilterText := VendorContract.GetView(false);
                end;
        end;
        PriceUpdateTemplate.WriteFilter(PriceUpdateTemplate.FieldNo("Subscription Contract Filter"), FilterText);
    end;

    procedure UpdateGeneralPostingSetupWithSubBillingGLAccounts(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; CustomerContractAccount: Code[20]; CustContrDeferralAccount: Code[20]; VendorContractAccount: Code[20]; VendContrDeferralAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not OverwriteData then
            exit;

        GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);

        GeneralPostingSetup.Validate("Cust. Sub. Contract Account", CustomerContractAccount);
        GeneralPostingSetup.Validate("Cust. Sub. Contr. Def Account", CustContrDeferralAccount);

        GeneralPostingSetup.Validate("Vend. Sub. Contract Account", VendorContractAccount);
        GeneralPostingSetup.Validate("Vend. Sub. Contr. Def. Account", VendContrDeferralAccount);

        GeneralPostingSetup.Modify(true);
    end;

    procedure InsertItemTemplateData(TemplateCode: Code[20]; Description: Text[100]; ServiceCommitmentOption: Enum "Item Service Commitment Type"; InventoryPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        ItemTemplate: Record "Item Templ.";
        ContosoInventory: Codeunit "Contoso Inventory";
        CommonUOM: Codeunit "Create Common Unit Of Measure";
        ItemType: Enum "Item Type";
    begin
        if ItemTemplate.Get(TemplateCode) then
            if not OverwriteData then
                exit;
        case ServiceCommitmentOption of
            ServiceCommitmentOption::"Invoicing Item",
            ServiceCommitmentOption::"Service Commitment Item":
                ItemType := Enum::"Item Type"::"Non-Inventory";
            ServiceCommitmentOption::"Sales without Service Commitment",
            ServiceCommitmentOption::"Sales with Service Commitment":
                ItemType := Enum::"Item Type"::"Inventory";
        end;
        ContosoInventory.InsertItemTemplateData(TemplateCode, Description, CommonUOM.Piece(), ItemType, InventoryPostingGroup, GenProdPostingGroup, VATProdPostingGroup, Enum::"Reserve Method"::Never);

        ItemTemplate.Get(TemplateCode);
        ItemTemplate.Validate("Subscription Option", ServiceCommitmentOption);
        ItemTemplate.Modify(true);
    end;

    procedure InsertItem(ItemNo: Code[20]; ItemType: Enum "Item Type"; ServiceCommitmentOption: Enum "Item Service Commitment Type"; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; BaseUnitOfMeasure: code[10]; VendorNo: Code[20])
    var
        Item: Record Item;
        ContosoItem: Codeunit "Contoso Item";
        CommonUOM: Codeunit "Create Common Unit Of Measure";
        Picture: Codeunit "Temp Blob";
    begin
        if Item.Get(ItemNo) then
            if not OverwriteData then
                exit;

        ContosoItem.InsertItem(ItemNo, ItemType, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, Enum::"Costing Method"::FIFO, CommonUOM.Piece(), '', '', 0, '', '', 0,
            Enum::"Replenishment System"::Purchase, 1, VendorNo, '', Enum::"Flushing Method"::"Pick + Manual", Enum::"Reordering Policy"::" ", false, '', Picture, '', LastDirectCost, 0, 0, 0, '');

        Item.Get(ItemNo);
        Item.Validate("Subscription Option", ServiceCommitmentOption);
        Item.Modify(true);
    end;

    procedure InsertBillingServCommTemplate(TemplateCode: Code[20]; Description: Text[100]; InvoicingVia: Enum "Invoicing Via"; InvoicingItemNo: Code[20]; CalculationBaseType: Enum "Calculation Base Type";
        CalculationBasePerc: Decimal; BillingBasePeriod: DateFormula; UsageBasedBilling: Boolean; UsageBasedPricing: Enum "Usage Based Pricing"; PricingUnitCostSurchargePerc: Decimal)
    var
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        Exists: Boolean;
    begin
        if ServiceCommitmentTemplate.Get(TemplateCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceCommitmentTemplate.Validate(Code, TemplateCode);
        ServiceCommitmentTemplate.Validate(Description, Description);
        ServiceCommitmentTemplate.Validate("Invoicing via", InvoicingVia);
        if InvoicingItemNo <> '' then
            ServiceCommitmentTemplate.Validate("Invoicing Item No.", InvoicingItemNo);
        ServiceCommitmentTemplate.Validate("Calculation Base Type", CalculationBaseType);
        ServiceCommitmentTemplate.Validate("Calculation Base %", CalculationBasePerc);
        ServiceCommitmentTemplate.Validate("Billing Base Period", BillingBasePeriod);
        ServiceCommitmentTemplate.Validate("Usage Based Billing", UsageBasedBilling);
        ServiceCommitmentTemplate.Validate("Usage Based Pricing", UsageBasedPricing);
        ServiceCommitmentTemplate.Validate("Pricing Unit Cost Surcharge %", PricingUnitCostSurchargePerc);

        if Exists then
            ServiceCommitmentTemplate.Modify(true)
        else
            ServiceCommitmentTemplate.Insert(true);
    end;


    procedure InsertServiceCommitmentPackage(PackageCode: Code[20]; Description: Text[100])
    var
        ServiceCommitmentPackage: Record "Subscription Package";
        Exists: Boolean;
    begin
        if ServiceCommitmentPackage.Get(PackageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceCommitmentPackage.Validate(Code, PackageCode);
        ServiceCommitmentPackage.Validate(Description, Description);

        if Exists then
            ServiceCommitmentPackage.Modify(true)
        else
            ServiceCommitmentPackage.Insert(true);
    end;

    procedure InsertServiceCommitmentPackageLine(PackageCode: Code[20]; ServicePartner: Enum "Service Partner"; TemplateCode: Code[20]; InvoicingVia: Enum "Invoicing Via"; InvoicingItemNo: Code[20];
        CalculationBaseType: Enum "Calculation Base Type"; CalculationBasePerc: Decimal; BillingBasePeriod: DateFormula; BillingRhythm: DateFormula; InitialTerm: DateFormula;
        UsageBasedBilling: Boolean; UsageBasedPricing: Enum "Usage Based Pricing"; PricingUnitCostSurchargePerc: Decimal)
    var
        ServiceCommPackageLine: Record "Subscription Package Line";
    begin
        ServiceCommPackageLine.SetRange("Subscription Package Code", PackageCode);
        ServiceCommPackageLine.SetRange(Template, TemplateCode);
        ServiceCommPackageLine.SetRange(Partner, ServicePartner);
        if ServiceCommPackageLine.FindFirst() then
            if not OverwriteData then
                exit;

        ServiceCommPackageLine.DeleteAll(true);
        ServiceCommPackageLine.Validate("Subscription Package Code", PackageCode);
        ServiceCommPackageLine.Validate("Line No.", GetNextPackageLineNo(PackageCode));
        ServiceCommPackageLine.Validate(Partner, ServicePartner);
        ServiceCommPackageLine.Validate(Template, TemplateCode);
        ServiceCommPackageLine.Validate("Invoicing via", InvoicingVia);
        if InvoicingItemNo <> '' then
            ServiceCommPackageLine.Validate("Invoicing Item No.", InvoicingItemNo);
        ServiceCommPackageLine.Validate("Calculation Base Type", CalculationBaseType);
        ServiceCommPackageLine.Validate("Calculation Base %", CalculationBasePerc);
        ServiceCommPackageLine.Validate("Billing Base Period", BillingBasePeriod);
        ServiceCommPackageLine.Validate("Billing Rhythm", BillingRhythm);
        ServiceCommPackageLine.Validate("Initial Term", InitialTerm);
        ServiceCommPackageLine.Validate("Usage Based Billing", UsageBasedBilling);
        ServiceCommPackageLine.Validate("Usage Based Pricing", UsageBasedPricing);
        ServiceCommPackageLine.Validate("Pricing Unit Cost Surcharge %", PricingUnitCostSurchargePerc);

        ServiceCommPackageLine.Insert(true);
    end;

    local procedure GetNextPackageLineNo(PackageCode: Code[20]): Integer
    var
        ServiceCommPackageLine: Record "Subscription Package Line";
    begin
        ServiceCommPackageLine.SetRange("Subscription Package Code", PackageCode);

        if ServiceCommPackageLine.FindLast() then
            exit(ServiceCommPackageLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertItemServiceCommitmentPackage(ItemNo: Code[20]; PackageCode: Code[20]; IsStandard: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        Exists: Boolean;
    begin
        if ItemServCommitmentPackage.Get(ItemNo, PackageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemServCommitmentPackage.Validate("Item No.", ItemNo);
        ItemServCommitmentPackage.Validate(Code, PackageCode);
        ItemServCommitmentPackage.Validate(Standard, IsStandard);

        if Exists then
            ItemServCommitmentPackage.Modify(true)
        else
            ItemServCommitmentPackage.Insert(true);
    end;

    procedure InsertUsageDataSupplier(SupplierNo: Code[20]; Description: Text[80]; SupplierType: Enum "Usage Data Supplier Type"; UnitPriceFromImport: Boolean; VendorInvoicePer: Enum "Vendor Invoice Per"; VendorNo: Code[20])
    var
        UsageDataSupplier: Record "Usage Data Supplier";
        Exists: Boolean;
    begin
        if UsageDataSupplier.Get(SupplierNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        UsageDataSupplier.Validate("No.", SupplierNo);
        UsageDataSupplier.Validate(Description, Description);
        UsageDataSupplier.Validate(Type, SupplierType);
        UsageDataSupplier.Validate("Unit Price from Import", UnitPriceFromImport);
        UsageDataSupplier.Validate("Vendor Invoice Per", VendorInvoicePer);
        UsageDataSupplier.Validate("Vendor No.", VendorNo);

        if Exists then
            UsageDataSupplier.Modify(true)
        else
            UsageDataSupplier.Insert(true);
    end;

    procedure InsertUsageDataSupplierReference(SupplierNo: Code[20]; ReferenceType: Enum "Usage Data Reference Type"; SupplierReference: Text[80])
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
    begin
        UsageDataSupplierReference.SetRange("Supplier No.", SupplierNo);
        UsageDataSupplierReference.SetRange("Type", ReferenceType);
        UsageDataSupplierReference.SetRange("Supplier Reference", SupplierReference);
        if UsageDataSupplierReference.FindFirst() then
            if not OverwriteData then
                exit;

        UsageDataSupplierReference.DeleteAll(true);
        UsageDataSupplierReference.Validate("Supplier No.", SupplierNo);
        UsageDataSupplierReference.Validate(Type, ReferenceType);
        UsageDataSupplierReference.Validate("Supplier Reference", SupplierReference);

        UsageDataSupplierReference.Insert(true);
    end;

    procedure InsertItemVendor(ItemNo: Code[20]; VendorNo: Code[20]; SupplierRefEntryNo: Integer)
    var
        ItemVendor: Record "Item Vendor";
        Exists: Boolean;
    begin
        if ItemVendor.Get(ItemNo, VendorNo, '') then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemVendor.Validate("Item No.", ItemNo);
        ItemVendor.Validate("Vendor No.", VendorNo);
        ItemVendor.Validate("Supplier Ref. Entry No.", SupplierRefEntryNo);

        if Exists then
            ItemVendor.Modify(true)
        else
            ItemVendor.Insert(true);
    end;

    procedure InsertItemReference(ItemNo: Code[20]; UnitOfMeasure: Code[10]; VendorNo: Code[20]; SupplierRefEntryNo: Integer)
    var
        ItemReference: Record "Item Reference";
        Exists: Boolean;
    begin
        if ItemReference.Get(ItemNo, '', UnitOfMeasure, "Item Reference Type"::Vendor, VendorNo, '') then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Unit of Measure", UnitOfMeasure);
        ItemReference.Validate(ItemReference."Reference Type", "Item Reference Type"::Vendor);
        ItemReference.Validate(ItemReference."Reference Type No.", VendorNo);
        ItemReference.Validate("Supplier Ref. Entry No.", SupplierRefEntryNo);

        if Exists then
            ItemReference.Modify(true)
        else
            ItemReference.Insert(true);
    end;

    procedure InsertGenericImportSettings(SupplierNo: Code[20]; DataExchangeDefinitionCode: Code[20]; CreateCustomers: Boolean; CreateSubscriptions: Boolean; AdditionalProcessing: Enum "Additional Processing Type"; ProcessWithoutUsageDataBlobs: Boolean)
    var
        GenericImportSettings: Record "Generic Import Settings";
        Exists: Boolean;
    begin
        if GenericImportSettings.Get(SupplierNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenericImportSettings.Validate("Usage Data Supplier No.", SupplierNo);
        if DataExchangeDefinitionCode <> '' then
            GenericImportSettings.Validate("Data Exchange Definition", DataExchangeDefinitionCode);
        GenericImportSettings.Validate("Create Customers", CreateCustomers);
        GenericImportSettings.Validate("Create Supplier Subscriptions", CreateSubscriptions);
        GenericImportSettings.Validate("Additional Processing", AdditionalProcessing);
        GenericImportSettings.Validate("Process without UsageDataBlobs", ProcessWithoutUsageDataBlobs);

        if Exists then
            GenericImportSettings.Modify(true)
        else
            GenericImportSettings.Insert(true);
    end;

    procedure InsertServiceObject(ObjectNo: Code[20]; CustomerNo: Code[20]; ItemNo: Code[20]; ProvisionStartDate: Date; Quantity: Decimal)
    var
        ServiceObject: Record "Subscription Header";
        Exists: Boolean;
    begin
        if ServiceObject.Get(ObjectNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceObject.Validate("No.", ObjectNo);
        if Exists then
            ServiceObject.Modify(true)
        else
            ServiceObject.Insert(true);

        ServiceObject.Validate("End-User Customer No.", CustomerNo);
        ServiceObject.Validate("Provision Start Date", ProvisionStartDate);
        ServiceObject.SkipInsertServiceCommitmentsFromStandardServCommPackages(true);
        ServiceObject.Validate(Type, Enum::"Service Object Type"::Item);
        ServiceObject.Validate("Source No.", ItemNo);
        ServiceObject.Validate(Quantity, Quantity);
        ServiceObject.Modify(true);
    end;

    procedure InsertServiceCommitments(ObjectNo: Code[20]; ServiceAndCalculationStartDate: Date; PackageCode: Code[20])
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ObjectNo);
        ServiceCommitment.SetRange("Subscription Package Code", PackageCode);
        if ServiceCommitment.FindFirst() then
            if not OverwriteData then
                exit;

        ServiceCommitment.DeleteAll(true);
        ServiceObject.Get(ObjectNo);
        ServiceCommitmentPackage.SetRange(Code, PackageCode);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);
    end;

    procedure InsertCustomerContract(ContractNo: Code[20]; Description: Text; CustomerNo: Code[20]; ContractTypeCode: Code[10])
    var
        CustomerContract: Record "Customer Subscription Contract";
        Exists: Boolean;
    begin
        if CustomerContract.Get(ContractNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;


        CustomerContract.Validate("No.", ContractNo);
        CustomerContract.Validate("Sell-to Customer No.", CustomerNo);
        CustomerContract.Validate("Contract Type", ContractTypeCode);
        CustomerContract.Validate("Detail Overview", Enum::"Contract Detail Overview"::Complete);

        if Exists then
            CustomerContract.Modify(true)
        else
            CustomerContract.Insert(true);
        CustomerContract.SetDescription(Description);
    end;

    procedure InsertCustomerContractLine(ContractNo: Code[20]; ObjectNo: Code[20])
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
    begin
        CustomerContractLine.SetRange("Subscription Contract No.", ContractNo);
        if CustomerContractLine.FindFirst() then
            if not OverwriteData then
                exit;

        CustomerContractLine.DeleteAll(true);
        ServiceCommitment.SetRange("Subscription Header No.", ObjectNo);
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Customer);
        ServiceCommitment.FindFirst();
        CustomerContract.Get(ContractNo);
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, ContractNo);
    end;

    procedure InsertVendorContract(ContractNo: Code[20]; Description: Text; VendorNo: Code[20]; ContractTypeCode: Code[10])
    var
        VendorContract: Record "Vendor Subscription Contract";
        Exists: Boolean;
    begin
        if VendorContract.Get(ContractNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;


        VendorContract.Validate("No.", ContractNo);
        VendorContract.Validate("Buy-from Vendor No.", VendorNo);
        VendorContract.Validate("Contract Type", ContractTypeCode);

        if Exists then
            VendorContract.Modify(true)
        else
            VendorContract.Insert(true);
        VendorContract.SetDescription(Description);
    end;

    procedure InsertVendorContractLine(ContractNo: Code[20]; ObjectNo: Code[20])
    var
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
    begin
        VendorContractLine.SetRange("Subscription Contract No.", ContractNo);
        if VendorContractLine.FindFirst() then
            if not OverwriteData then
                exit;

        VendorContractLine.DeleteAll(true);
        ServiceCommitment.SetRange("Subscription Header No.", ObjectNo);
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Vendor);
        ServiceCommitment.FindFirst();
        ServiceCommitment."Subscription Contract No." := ContractNo;
        VendorContract.Get(ContractNo);
        VendorContract.CreateVendorContractLineFromServiceCommitment(ServiceCommitment);
    end;

    procedure InsertUsageDataImport(SupplierNo: Code[20]; Description: Text[80]; UsageData: Text; FileName: Text; ImportDate: Date)
    var
        UsageDataImport: Record "Usage Data Import";
        UsageDataBlob: Record "Usage Data Blob";
        SubBillingModuleSetup: Record "Sub. Billing Module Setup";
        DataOutStream: OutStream;
    begin
        UsageDataImport.SetRange("Supplier No.", SupplierNo);
        UsageDataImport.SetRange(Description, Description);
        if UsageDataImport.FindFirst() then
            if not OverwriteData then
                exit;

        UsageDataImport.DeleteAll(true);
        UsageDataImport.Validate("Supplier No.", SupplierNo);
        UsageDataImport.Validate(Description, Description);
        UsageDataImport.Insert(true);

        SubBillingModuleSetup.Get();
        if SubBillingModuleSetup."Import reconciliation file" then begin
            UsageDataBlob.Init();
            UsageDataBlob.Validate("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            UsageDataBlob.Insert(true);
            if UsageData <> '' then begin
                UsageDataBlob.Data.CreateOutStream(DataOutStream, TextEncoding::UTF8);
                DataOutStream.WriteText(UsageData);
                UsageDataBlob.ComputeHashValue();
                UsageDataBlob.Validate("Source", FileName);
                UsageDataBlob.Validate("Import Date", ImportDate);
                UsageDataBlob.Validate("Import Status", UsageDataBlob."Import Status"::Ok);
                UsageDataBlob.Modify(true);
            end;

            if SubBillingModuleSetup."Import Data Exch. Definition" then begin
                UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Imported Lines");
                UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Imported Lines");
                UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
                UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
            end;
        end;
    end;

    procedure InsertUsageDataSubscription(SupplierNo: Code[20]; CustomerNo: Code[20]; CustomerID: Text[80]; ServiceObjectNo: Code[20]; ProductID: Text[80]; ProductName: Text[100]; Quantity: Decimal; StartDate: Date; EndDate: Date; SupplierReference: Text[80])
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        UsageBasedBillingMgmt: Codeunit "Usage Based Billing Mgmt.";
    begin
        UsageDataSubscription.SetRange("Supplier No.", SupplierNo);
        UsageDataSubscription.SetRange("Customer No.", CustomerNo);
        UsageDataSubscription.SetRange("Subscription Header No.", ServiceObjectNo);
        UsageDataSubscription.SetRange("Supplier Reference", SupplierReference);
        if UsageDataSubscription.FindFirst() then
            if not OverwriteData then
                exit;

        UsageDataSubscription.DeleteAll(true);
        UsageDataSubscription.Validate("Supplier No.", SupplierNo);
        UsageDataSubscription.Validate("Customer No.", CustomerNo);
        UsageDataSubscription.Validate("Customer ID", CustomerID);
        UsageDataSubscription.Validate("Supplier Reference", SupplierReference);
        UsageDataSupplierReference.CreateSupplierReference(SupplierNo, SupplierReference, Enum::"Usage Data Reference Type"::Subscription);
        UsageDataSubscription."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
        UsageDataSubscription.Validate("Product ID", ProductID);
        UsageDataSubscription.Validate("Product Name", ProductName);
        UsageDataSubscription.Validate(Quantity, Quantity);
        UsageDataSubscription.Validate("Start Date", StartDate);
        UsageDataSubscription.Validate("End Date", EndDate);
        UsageDataSubscription.Validate("Connect to Sub. Header No.", ServiceObjectNo);
        UsageBasedBillingMgmt.ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(UsageDataSubscription);
        UsageDataSubscription.Insert(true);
    end;

    procedure InitUpdateServicesDatesJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NextRunDateFormula: DateFormula;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Update Sub. Lines Term. Dates");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"Update Sub. Lines Term. Dates");
        JobQueueEntry.Insert(true);
        if not CanScheduleJob() then
            exit;
        JobQueueEntry.Validate("Earliest Start Date/Time", CurrentDateTime());
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueEntry.Validate("Next Run Date Formula", NextRunDateFormula);
        JobQueueEntry.Validate("Starting Time", 010000T);
        JobQueueEntry.Modify(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;

    local procedure CanScheduleJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        User: Record User;
        EmptyGuid: Guid;
        UserId: Guid;
    begin
        if not (JobQueueEntry.WritePermission() and JobQueueEntry.ReadPermission()) then
            exit(false);
        UserId := UserSecurityId();
        if User.IsEmpty() then
            exit(true);
        if Format(UserId) = Format(EmptyGuid) then
            exit(true);
        if not User.Get(UserId) then
            exit(false);
        if User."License Type" = User."License Type"::"Limited User" then
            exit(false);
        exit(true);
    end;
}