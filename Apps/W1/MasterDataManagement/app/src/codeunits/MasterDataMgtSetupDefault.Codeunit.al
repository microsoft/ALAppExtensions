namespace Microsoft.Integration.MDM;

using System.IO;
using Microsoft.Integration.SyncEngine;
using Microsoft.Sales.Customer;
using System.Reflection;
using Microsoft.Purchases.Vendor;
using Microsoft.CRM.Contact;
using Microsoft.Foundation.Address;
using System.Globalization;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Sales.Setup;
using Microsoft.CRM.Setup;
using Microsoft.CRM.Team;
using Microsoft.Purchases.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Shipping;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;
using Microsoft.Utilities;
using Microsoft.CRM.BusinessRelation;
using System.Threading;

codeunit 7230 "Master Data Mgt. Setup Default"
{
    Permissions = tabledata "Config. Template Header" = ri,
                  tabledata "Master Data Mgt. Coupling" = rmd,
                  tabledata "Integration Field Mapping" = rimd,
                  tabledata "Integration Table Mapping" = rimd,
                  tabledata "Integration Synch. Job" = r,
                  tabledata "Job Queue Entry" = rimd,
                  tabledata "Master Data Management Setup" = r,
                  tabledata "Name/Value Buffer" = ri;

    trigger OnRun()
    begin
    end;

    var
        JobQueueCategoryLbl: Label 'MDM INTEG', Locked = true;
        OptionJobQueueCategoryLbl: Label 'MDM INTEG', Locked = true;
        CustomerContactJobQueueCategoryLbl: Label 'MDM INTEG', Locked = true;
        CustomerTableMappingNameTxt: Label 'MDM_CUSTOMER', Locked = true;
        VendorTableMappingNameTxt: Label 'MDM_VENDOR', Locked = true;
        JobQueueEntryNameTok: Label ' %1 - %2 synchronization job.', Comment = '%1 = The Integration Table Name to synchronized (ex. CUSTOMER), %2 = Business Central product name';
        UncoupleJobQueueEntryNameTok: Label ' %1 uncouple job.', Comment = '%1 = Integration mapping description, for example, CUSTOMER <-> CUSTOMER';
        CoupleJobQueueEntryNameTok: Label ' %1 coupling job.', Comment = '%1 = Integration mapping description, for example, CUSTOMER <-> CUSTOMER';
        IntegrationTablePrefixTok: Label 'Business Central', Comment = 'Product name', Locked = true;
        CustomerConfigTemplateCodeTok: Label 'MDMCUST', Comment = 'Customer template code for new customers created from source company data. Max length 10.', Locked = true;
        VendorConfigTemplateCodeTok: Label 'MDMVEND', Comment = 'Vendor template code for new vendors created from source company data. Max length 10.', Locked = true;
        PersonTok: Label 'Person', Comment = 'Non-localized option name for Contact Type Person.', Locked = true;
        CustomerConfigTemplateDescTxt: Label 'New customers were created during synch.', Comment = 'Max. length 50.';
        VendorConfigTemplateDescTxt: Label 'New vendors were created during synch.', Comment = 'Max. length 50.';

    internal procedure ResetConfiguration(var MasterDataManagementSetup: Record "Master Data Management Setup")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetConfiguration(MasterDataManagementSetup, IsHandled);
        if IsHandled then
            exit;

        ResetNumberSeriesMapping('MDM_NUMBERSERIES', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetNumberSeriesLineMapping('MDM_NUMBERSERIESLINE', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetSalesReceivablesSetupMapping('MDM_SALESRECSETUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetMarketingSetupMapping('MDM_MARKETINGSETUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetBusinessRelationMapping('MDM_BUSINESSRELATION', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetPurchasespayablesSetupMapping('MDM_PURCHPAYSETUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetSalesPeopleSystemUserMapping('MDM_SALESPERSON', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetCustomerAccountMapping(CustomerTableMappingNameTxt, (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetVendorAccountMapping(VendorTableMappingNameTxt, (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetContactContactMapping('MDM_CONTACT', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetCountryRegionMapping('MDM_COUNTRYREGION', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetPostCodeMapping('MDM_POSTCODE', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetCurrencyTransactionCurrencyMapping('MDM_CURRENCY', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetCurrencyExchangeRateMapping('MDM_CURRENCYEXCHRATE', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetPaymentTermsMapping('MDM_PAYMENTTERMS');
        ResetShipmentMethodMapping('MDM_SHIPMENTMETHOD');
        ResetShippingAgentMapping('MDM_SHIPPINGAGENT');
        ResetVATBusPostingGroupMapping('MDM_VATBUSPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetVATProdPostingGroupMapping('MDM_VATPRODPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetGenBusPostingGroupMapping('MDM_GENBUSPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetGenProdPostingGroupMapping('MDM_GENPRODPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetCustomerPostingGroupMapping('MDM_CUSTOMERPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetVendorPostingGroupMapping('MDM_VENDORPGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetTaxAreaMapping('MDM_TAXAREA', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetTaxGroupMapping('MDM_TAXGROUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetGLAccountMapping('MDM_GLACCOUNT', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetVATPostingSetupMapping('MDM_VATPOSTINGSETUP', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetTaxJurisdictionMapping('MDM_TAXJURISDICTION', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetDimensionMapping('MDM_DIMENSION', (not MasterDataManagementSetup."Delay Job Scheduling"));
        ResetDimensionValueMapping('MDM_DIMENSIONVALUE', (not MasterDataManagementSetup."Delay Job Scheduling"));

        SetCustomIntegrationsTableMappings(MasterDataManagementSetup);
    end;

    internal procedure ResetSalesPeopleSystemUserMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(SalespersonPurchaser.FieldNo(Code));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo(Name));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo(Image));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo("E-Mail"));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo("Phone No."));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo("Job Title"));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo("Search E-Mail"));
        FieldNumbers.Add(SalespersonPurchaser.FieldNo("E-Mail 2"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Salesperson/Purchaser", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_CURRENCY|MDM_COUNTRYREGION';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetCustomerAccountMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        Customer: Record Customer;
        IntegrationCustomer: Record Customer;
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::Customer);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(Customer.FieldNo(Customer.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(Customer.FieldNo(Customer.SystemId)));
        if TableField.FindSet() then
            repeat
                if not (TableField."No." in [Customer.FieldNo(Customer."Tax Area ID"), Customer.FieldNo(Customer."Contact ID"), Customer.FieldNo(Customer."Contact Graph Id"), Customer.FieldNo(Customer."Search Name"), Customer.FieldNo(Customer.Contact), Customer.FieldNo(Customer."Last Date Modified"), Customer.FieldNo(Customer."Last Modified Date Time")]) then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::Customer, ResetBCAccountConfigTemplate(Database::Customer), true, ShouldRecreateJobQueueEntry);
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(DATABASE::Customer, Customer.TableCaption(), Customer.GetView()));

        IntegrationCustomer.SetRange(Blocked, IntegrationCustomer.Blocked::" ");
        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::Customer, IntegrationCustomer.TableCaption(), IntegrationCustomer.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'MDM_SALESPERSON|MDM_CURRENCY|MDM_SALESRECSETUP';
        IntegrationTableMapping."Dependency Filter" += '|MDM_PAYMENTTERMS|MDM_SHIPMENTMETHOD|MDM_SHIPPINGAGENT|MDM_CUSTOMERPGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        SetIntegrationFieldMappingClearValueOnFailedSync(IntegrationTableMapping, Customer.FieldNo("Primary Contact No."));
        SetIntegrationFieldMappingValidate(IntegrationTableMapping, Customer.FieldNo(Name));
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetVendorAccountMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationVendor: Record Vendor;
        Vendor: Record Vendor;
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::Vendor);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(Vendor.FieldNo(Vendor.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(Vendor.FieldNo(Vendor.SystemId)));
        if TableField.FindSet() then
            repeat
                if not (TableField."No." in [Vendor.FieldNo(Vendor."Search Name"), Vendor.FieldNo(Vendor.Contact), Vendor.FieldNo(Vendor."Last Date Modified"), Vendor.FieldNo(Vendor."Last Modified Date Time")]) then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::Vendor, ResetBCAccountConfigTemplate(Database::Vendor), true, ShouldRecreateJobQueueEntry);
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(DATABASE::Vendor, Vendor.TableCaption(), Vendor.GetView()));

        IntegrationVendor.SetRange(Blocked, Vendor.Blocked::" ");
        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::Vendor, IntegrationVendor.TableCaption(), IntegrationVendor.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'MDM_SALESPERSON|MDM_CURRENCY|MDM_PURCHPAYSETUP|MDM_CUSTOMER';
        IntegrationTableMapping."Dependency Filter" += '|MDM_PAYMENTTERMS|MDM_SHIPMENTMETHOD|MDM_SHIPPINGAGENT|MDM_VENDORPGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        SetIntegrationFieldMappingClearValueOnFailedSync(IntegrationTableMapping, Vendor.FieldNo("Primary Contact No."));
        SetIntegrationFieldMappingValidate(IntegrationTableMapping, Vendor.FieldNo(Name));
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetContactContactMapping(IntegrationTableMappingName: Code[20]; EnqueueJobQueEntry: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationContact: Record Contact;
        Contact: Record Contact;
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::Contact);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(Contact.FieldNo(Contact.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(Contact.FieldNo(Contact.SystemId)));
        if TableField.FindSet() then
            repeat
                if not (TableField."No." in [Contact.FieldNo(Contact."Search Name"), Contact.FieldNo(Contact."Search E-Mail"), Contact.FieldNo(Contact."Xrm Id"), Contact.FieldNo(Contact."Last Date Modified"), Contact.FieldNo(Contact."Lookup Contact No.")]) then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::Contact, '', true, EnqueueJobQueEntry);
        Contact.Reset();
        Contact.SetRange(Type, Contact.Type::Person);
        Contact.SetFilter("Company No.", '<>''''');
        IntegrationTableMapping.SetTableFilter(GetTableFilterFromView(DATABASE::Contact, Contact.TableCaption(), Contact.GetView()));

        IntegrationContact.Reset();
        IntegrationContact.SetRange(Type, Contact.Type::Person);
        IntegrationContact.SetFilter("Company No.", '<>''''');
        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(DATABASE::Contact, IntegrationContact.TableCaption(), IntegrationContact.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'MDM_CUSTOMER|MDM_VENDOR|MDM_MARKETINGSETUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", Contact.FieldNo(Type));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Constant Value" := PersonTok;
            IntegrationFieldMapping.Modify();
        end;

        IntegrationFieldMapping.SetRange("Field No.", Contact.FieldNo("No."));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        SetIntegrationFieldMappingClearValueOnFailedSync(IntegrationTableMapping, Contact.FieldNo(Name));
        SetIntegrationFieldMappingClearValueOnFailedSync(IntegrationTableMapping, Contact.FieldNo("E-Mail"));
        SetIntegrationFieldMappingClearValueOnFailedSync(IntegrationTableMapping, Contact.FieldNo("E-Mail 2"));

        OnAfterResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
    end;

    internal procedure ResetCountryRegionMapping(IntegrationTableMappingName: Code[20]; EnqueueJobQueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        CountryRegion: Record "Country/Region";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(CountryRegion.FieldNo(Code));
        FieldNumbers.Add(CountryRegion.FieldNo(Name));
        FieldNumbers.Add(CountryRegion.FieldNo("ISO Code"));
        FieldNumbers.Add(CountryRegion.FieldNo("ISO Numeric Code"));
        FieldNumbers.Add(CountryRegion.FieldNo("EU Country/Region Code"));
        FieldNumbers.Add(CountryRegion.FieldNo("Intrastat Code"));
        FieldNumbers.Add(CountryRegion.FieldNo("Address Format"));
        FieldNumbers.Add(CountryRegion.FieldNo("Contact Address Format"));
        FieldNumbers.Add(CountryRegion.FieldNo("County Name"));
        FieldNumbers.Add(CountryRegion.FieldNo("VAT Scheme"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Country/Region", '', true, EnqueueJobQueEntry);
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping."Dependency Filter" := 'MDM_NUMBERSERIES|MDM_NUMBERSERIESLINE|MDM_CURRENCY|MDM_CURRENCYEXCHRATE|MDM_GLACCOUNT|MDM_VATPOSTINGSETUP';
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", CountryRegion.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        OnAfterResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
    end;

    internal procedure ResetPostCodeMapping(IntegrationTableMappingName: Code[20]; EnqueueJobQueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        PostCode: Record "Post Code";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(PostCode.FieldNo(Code));
        FieldNumbers.Add(PostCode.FieldNo(City));
        FieldNumbers.Add(PostCode.FieldNo("Search City"));
        FieldNumbers.Add(PostCode.FieldNo("Country/Region Code"));
        FieldNumbers.Add(PostCode.FieldNo(County));
        FieldNumbers.Add(PostCode.FieldNo("Time Zone"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Post Code", '', true, EnqueueJobQueEntry);
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping."Dependency Filter" := 'MDM_COUNTRYREGION|MDM_CURRENCYEXCHRATE|MDM_SALESPERSON';
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", PostCode.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        OnAfterResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
    end;

    internal procedure ResetCurrencyTransactionCurrencyMapping(IntegrationTableMappingName: Code[20]; EnqueueJobQueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        Currency: Record Currency;
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::Currency);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(Currency.FieldNo(Currency.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(Currency.FieldNo(Currency.SystemId)));
        if TableField.FindSet() then
            repeat
                if not (TableField."No." in [Currency.FieldNo(Currency."Last Date Modified"), Currency.FieldNo(Currency."Last Modified Date Time"), Currency.FieldNo(Currency."Last Date Adjusted")]) then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::Currency, '', true, EnqueueJobQueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_NUMBERSERIES|MDM_NUMBERSERIESLINE|MDM_GLACCOUNT';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", Currency.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        OnAfterResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
    end;

    internal procedure ResetCurrencyExchangeRateMapping(IntegrationTableMappingName: Code[20]; EnqueueJobQueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Currency Code"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Starting Date"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Exchange Rate Amount"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Adjustment Exch. Rate Amount"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Relational Currency Code"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Relational Exch. Rate Amount"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Relational Adjmt Exch Rate Amt"));
        FieldNumbers.Add(CurrencyExchangeRate.FieldNo("Fix Exchange Rate Amount"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Currency Exchange Rate", '', true, EnqueueJobQueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_CURRENCY';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", CurrencyExchangeRate.FieldNo("Currency Code"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        IntegrationFieldMapping.SetRange("Field No.", CurrencyExchangeRate.FieldNo("Starting Date"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, EnqueueJobQueEntry, IsHandled);
    end;

    internal procedure ResetPaymentTermsMapping(IntegrationTableMappingName: Code[20])
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataManagementSetup: Record "Master Data Management Setup";
        PaymentTerms: Record "Payment Terms";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
        ShouldRecreateJobQueueEntry: Boolean;
    begin
        IsHandled := false;
        ShouldRecreateJobQueueEntry := true;
        if MasterDataManagementSetup.Get() then
            ShouldRecreateJobQueueEntry := (not MasterDataManagementSetup."Delay Job Scheduling");
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(PaymentTerms.FieldNo(Code));
        FieldNumbers.Add(PaymentTerms.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Payment Terms", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_SALESPERSON|MDM_CURRENCY|MDM_NUMBERSERIESLINE|MDM_POSTCODE';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", PaymentTerms.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetShipmentMethodMapping(IntegrationTableMappingName: Code[20])
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataManagementSetup: Record "Master Data Management Setup";
        ShipmentMethod: Record "Shipment Method";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
        ShouldRecreateJobQueueEntry: Boolean;
    begin
        IsHandled := false;
        ShouldRecreateJobQueueEntry := true;
        if MasterDataManagementSetup.Get() then
            ShouldRecreateJobQueueEntry := (not MasterDataManagementSetup."Delay Job Scheduling");
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(ShipmentMethod.FieldNo(Code));
        FieldNumbers.Add(ShipmentMethod.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Shipment Method", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_SHIPPINGAGENT';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", ShipmentMethod.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetShippingAgentMapping(IntegrationTableMappingName: Code[20])
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataManagementSetup: Record "Master Data Management Setup";
        ShippingAgent: Record "Shipping Agent";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
        ShouldRecreateJobQueueEntry: Boolean;
    begin
        IsHandled := false;
        ShouldRecreateJobQueueEntry := true;
        if MasterDataManagementSetup.Get() then
            ShouldRecreateJobQueueEntry := (not MasterDataManagementSetup."Delay Job Scheduling");
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(ShippingAgent.FieldNo(Code));
        FieldNumbers.Add(ShippingAgent.FieldNo(Name));
        FieldNumbers.Add(ShippingAgent.FieldNo("Internet Address"));
        FieldNumbers.Add(ShippingAgent.FieldNo("Account No."));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Shipping Agent", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_PAYMENTTERMS';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", ShippingAgent.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetSalesReceivablesSetupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        IntegrationTableMapping: Record "Integration Table Mapping";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(SalesReceivablesSetup.FieldNo("Primary Key"));
        FieldNumbers.Add(SalesReceivablesSetup.FieldNo("Customer Nos."));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Sales & Receivables Setup", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_NUMBERSERIESLINE|MDM_CURRENCY';
        IntegrationTableMapping."Update-Conflict Resolution" := "Integration Update Conflict Resolution"::"Get Update from Integration";
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", SalesReceivablesSetup.FieldNo("Primary Key"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetMarketingSetupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean);
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MarketingSetup: Record "Marketing Setup";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(MarketingSetup.FieldNo("Primary Key"));
        FieldNumbers.Add(MarketingSetup.FieldNo("Contact Nos."));
        FieldNumbers.Add(MarketingSetup.FieldNo("Bus. Rel. Code for Customers"));
        FieldNumbers.Add(MarketingSetup.FieldNo("Bus. Rel. Code for Vendors"));
        FieldNumbers.Add(MarketingSetup.FieldNo("Bus. Rel. Code for Bank Accs."));
        FieldNumbers.Add(MarketingSetup.FieldNo("Bus. Rel. Code for Employees"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Marketing Setup", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_PURCHPAYSETUP';
        IntegrationTableMapping."Update-Conflict Resolution" := "Integration Update Conflict Resolution"::"Get Update from Integration";
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", MarketingSetup.FieldNo("Primary Key"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetBusinessRelationMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean);
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        IntegrationTableMapping: Record "Integration Table Mapping";
        BusinessRelation: Record "Business Relation";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(BusinessRelation.FieldNo(Code));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Business Relation", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Update-Conflict Resolution" := "Integration Update Conflict Resolution"::"Get Update from Integration";
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", BusinessRelation.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;

        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetPurchasesPayablesSetupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(PurchasesPayablesSetup.FieldNo("Primary Key"));
        FieldNumbers.Add(PurchasesPayablesSetup.FieldNo("Vendor Nos."));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Purchases & Payables Setup", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_SALESRECSETUP';
        IntegrationTableMapping."Update-Conflict Resolution" := "Integration Update Conflict Resolution"::"Get Update from Integration";
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", PurchasesPayablesSetup.FieldNo("Primary Key"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetNumberSeriesMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        NoSeries: Record "No. Series";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(NoSeries.FieldNo(Code));
        FieldNumbers.Add(NoSeries.FieldNo(Description));
        FieldNumbers.Add(NoSeries.FieldNo("Default Nos."));
        FieldNumbers.Add(NoSeries.FieldNo("Manual Nos."));
        FieldNumbers.Add(NoSeries.FieldNo("Date Order"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"No. Series", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GENBUSPGROUP|MDM_GENPRODPGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", NoSeries.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetNumberSeriesLineMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        NoSeriesLine: Record "No. Series Line";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(NoSeriesLine.FieldNo("Series Code"));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Line No."));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Starting Date"));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Starting No."));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Ending No."));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Warning No."));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Increment-by No."));
        FieldNumbers.Add(NoSeriesLine.FieldNo(Open));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Sequence Name"));
        FieldNumbers.Add(NoSeriesLine.FieldNo("Starting Sequence No."));
#if not CLEAN24
#pragma warning disable AL0432
        FieldNumbers.Add(NoSeriesLine.FieldNo("Allow Gaps in Nos."));
#pragma warning restore AL0432
#endif
        FieldNumbers.Add(NoSeriesLine.FieldNo(Implementation));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"No. Series Line", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_NUMBERSERIES';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", NoSeriesLine.FieldNo("Series Code"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        IntegrationFieldMapping.SetRange("Field No.", NoSeriesLine.FieldNo("Line No."));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetVATBusPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(VATBusinessPostingGroup.FieldNo(Code));
        FieldNumbers.Add(VATBusinessPostingGroup.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"VAT Business Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_DIMENSIONVALUE';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", VATBusinessPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetCustomerPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        CustomerPostingGroup: Record "Customer Posting Group";
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::"Customer Posting Group");
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(CustomerPostingGroup.FieldNo(CustomerPostingGroup.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(CustomerPostingGroup.FieldNo(CustomerPostingGroup.SystemId)));
        if TableField.FindSet() then
            repeat
                FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Customer Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GLACCOUNT';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", CustomerPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetVendorPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        VendorPostingGroup: Record "Vendor Posting Group";
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::"Vendor Posting Group");
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(VendorPostingGroup.FieldNo(VendorPostingGroup.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(VendorPostingGroup.FieldNo(VendorPostingGroup.SystemId)));
        if TableField.FindSet() then
            repeat
                FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Vendor Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GLACCOUNT|MDM_CUSTOMERPGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", VendorPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetGenBusPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(GenBusinessPostingGroup.FieldNo(Code));
        FieldNumbers.Add(GenBusinessPostingGroup.FieldNo(Description));
        FieldNumbers.Add(GenBusinessPostingGroup.FieldNo("Def. VAT Bus. Posting Group"));
        FieldNumbers.Add(GenBusinessPostingGroup.FieldNo("Auto Insert Default"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Gen. Business Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_VATBUSPGROUP|MDM_TAXAREA';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", GenBusinessPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetVATProdPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(VATProductPostingGroup.FieldNo(Code));
        FieldNumbers.Add(VATProductPostingGroup.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"VAT Product Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GENBUSPGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", VATProductPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetGenProdPostingGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(GenProductPostingGroup.FieldNo(Code));
        FieldNumbers.Add(GenProductPostingGroup.FieldNo(Description));
        FieldNumbers.Add(GenProductPostingGroup.FieldNo("Def. VAT Prod. Posting Group"));
        FieldNumbers.Add(GenProductPostingGroup.FieldNo("Auto Insert Default"));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Gen. Product Posting Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_VATPRODPGROUP|MDM_TAXGROUP';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", GenProductPostingGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetTaxAreaMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TaxArea: Record "Tax Area";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(TaxArea.FieldNo(Code));
        FieldNumbers.Add(TaxArea.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Tax Area", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_DIMENSIONVALUE';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", TaxArea.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetTaxGroupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TaxGroup: Record "Tax Group";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(TaxGroup.FieldNo(Code));
        FieldNumbers.Add(TaxGroup.FieldNo(Description));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Tax Group", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_TAXAREA';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", TaxGroup.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetVATPostingSetupMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        VATPostingSetup: Record "VAT Posting Setup";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT Bus. Posting Group"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT Prod. Posting Group"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT Calculation Type"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT %"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Unrealized VAT Type"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Adjust for Payment Discount"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Sales VAT Account"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Sales VAT Unreal. Account"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Purchase VAT Account"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Purch. VAT Unreal. Account"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Reverse Chrg. VAT Acc."));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Reverse Chrg. VAT Unreal. Acc."));
        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT Identifier"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("EU Service"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("VAT Clause Code"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Certificate of Supply Required"));
        FieldNumbers.Add(VATPostingSetup.FieldNo("Tax Category"));
        FieldNumbers.Add(VATPostingSetup.FieldNo(Description));
        FieldNumbers.Add(VATPostingSetup.FieldNo(Blocked));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"VAT Posting Setup", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GLACCOUNT|MDM_TAXJURISDICTION';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", VATPostingSetup.FieldNo("VAT Bus. Posting Group"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        IntegrationFieldMapping.SetRange("Field No.", VATPostingSetup.FieldNo("VAT Prod. Posting Group"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetTaxJurisdictionMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TaxJurisdiction: Record "Tax Jurisdiction";
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FieldNumbers.Add(TaxJurisdiction.FieldNo(Code));
        FieldNumbers.Add(TaxJurisdiction.FieldNo(Description));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Tax Account (Sales)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Tax Account (Purchases)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Report-to Jurisdiction"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Date Filter"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Tax Group Filter"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Unreal. Tax Acc. (Sales)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Unreal. Tax Acc. (Purchases)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Reverse Charge (Purchases)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Unreal. Rev. Charge (Purch.)"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Unrealized VAT Type"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Calculate Tax on Tax"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo("Adjust for Payment Discount"));
        FieldNumbers.Add(TaxJurisdiction.FieldNo(Name));

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Tax Jurisdiction", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GLACCOUNT';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", TaxJurisdiction.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetGLAccountMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        GLAccount: Record "G/L Account";
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::"G/L Account");
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(GLAccount.FieldNo(GLAccount.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(GLAccount.FieldNo(GLAccount.SystemId)));
        if TableField.FindSet() then
            repeat
                if (TableField."No." <> GLAccount.FieldNo(GLAccount."Last Date Modified")) and (TableField."No." <> GLAccount.FieldNo(GLAccount."Last Modified Date Time")) then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"G/L Account", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_GENBUSPGROUP|MDM_GENPRODPGROUP|MDM_NUMBERSERIESLINE';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping."Create New in Case of No Match" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", GLAccount.FieldNo("No."));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetDimensionMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        Dimension: Record Dimension;
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::Dimension);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(Dimension.FieldNo(Dimension.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(Dimension.FieldNo(Dimension.SystemId)));
        if TableField.FindSet() then
            repeat
                FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::Dimension, '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_BUSINESSRELATION';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", Dimension.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure ResetDimensionValueMapping(IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        DimensionValue: Record "Dimension Value";
        TableField: Record Field;
        FieldNumbers: List of [Integer];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        TableField.SetRange(TableNo, Database::"Dimension Value");
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(DimensionValue.FieldNo(DimensionValue.SystemId)));
        TableField.SetFilter(RelationFieldNo, '<' + Format(DimensionValue.FieldNo(DimensionValue.SystemId)));
        if TableField.FindSet() then
            repeat
                if TableField."No." <> DimensionValue.FieldNo(DimensionValue."Dimension Value ID") then
                    FieldNumbers.Add(TableField."No.");
            until TableField.Next() = 0;

        GenerateIntegrationTableMapping(IntegrationTableMapping, FieldNumbers, IntegrationTableMappingName, Database::"Dimension Value", '', true, ShouldRecreateJobQueueEntry);
        IntegrationTableMapping."Dependency Filter" := 'MDM_DIMENSION';
        IntegrationTableMapping."Synch. After Bulk Coupling" := true;
        IntegrationTableMapping.Modify();

        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", DimensionValue.FieldNo("Dimension Code"));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        IntegrationFieldMapping.SetRange("Field No.", DimensionValue.FieldNo(Code));
        if IntegrationFieldMapping.FindFirst() then begin
            IntegrationFieldMapping."Use For Match-Based Coupling" := true;
            IntegrationFieldMapping."Match Priority" := 1;
            IntegrationFieldMapping.Modify();
        end;
        OnAfterResetTableMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
    end;

    internal procedure InsertIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; MappingName: Code[20]; TableNo: Integer; IntegrationTableNo: Integer; IntegrationTableUIDFieldNo: Integer; IntegrationTableModifiedFieldNo: Integer; TableConfigTemplateCode: Code[10]; IntegrationTableConfigTemplateCode: Code[10]; SynchOnlyCoupledRecords: Boolean)
    var
        Direction: Integer;
    begin
        Direction := IntegrationTableMapping.Direction::FromIntegrationTable;
        IntegrationTableMapping.CreateRecord(MappingName, TableNo, IntegrationTableNo, IntegrationTableUIDFieldNo,
          IntegrationTableModifiedFieldNo, TableConfigTemplateCode, IntegrationTableConfigTemplateCode,
          SynchOnlyCoupledRecords, Direction, IntegrationTablePrefixTok,
          Codeunit::"Integration Master Data Synch.", 0);
        IntegrationTableMapping.Type := IntegrationTableMapping.Type::"Master Data Management";
        IntegrationTableMapping."Coupling Codeunit ID" := Codeunit::"Master Data Mgt. Table Couple";
        IntegrationTableMapping."Uncouple Codeunit ID" := Codeunit::"Master Data Mgt. Tbl. Uncouple";
        IntegrationTableMapping."Update-Conflict Resolution" := "Integration Update Conflict Resolution"::"Get Update from Integration";
        IntegrationTableMapping."Table Caption" := GetTableCaption(TableNo);
        IntegrationTableMapping.Modify();
    end;

    procedure GenerateIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; FieldNumbers: List of [Integer]; IntegrationTableMappingName: Code[20]; TableID: Integer; ConfigTemplateCode: Code[10]; SynchOnlyCoupledRecords: Boolean; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TableField: Record Field;
        LocalRecordRef: RecordRef;
    begin
        LocalRecordRef.Open(TableID);
        InsertIntegrationTableMapping(IntegrationTableMapping, IntegrationTableMappingName, TableID, TableID, LocalRecordRef.SystemIdNo(), LocalRecordRef.SystemModifiedAtNo(), ConfigTemplateCode, '', SynchOnlyCoupledRecords);
        TableField.SetRange(TableNo, TableID);
        TableField.SetRange(Class, TableField.Class::Normal);
        TableField.SetRange(ObsoleteState, TableField.ObsoleteState::No);
        TableField.SetFilter("No.", '<' + Format(LocalRecordRef.SystemIdNo));
        TableField.SetFilter(RelationFieldNo, '<' + Format(LocalRecordRef.SystemIdNo));
        if TableField.FindSet() then
            repeat
                Clear(IntegrationFieldMapping);
                InsertIntegrationFieldMapping(IntegrationTableMapping.Name, IntegrationFieldMapping, TableField."No.", TableField."No.", IntegrationFieldMapping.Direction::FromIntegrationTable, '', false, false);
                if not FieldNumbers.Contains(TableField."No.") then begin
                    IntegrationFieldMapping.Status := IntegrationFieldMapping.Status::Disabled;
                    IntegrationFieldMapping.Modify();
                end;
            until TableField.Next() = 0;

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, DefaultNumberOfMinutesBetweenRuns(), ShouldRecreateJobQueueEntry, DefaultInactivityTimeoutPeriod());
        Commit();
    end;

    internal procedure DefaultNumberOfMinutesBetweenRuns(): Integer
    begin
        exit(20 + Random(10))
    end;

    internal procedure DefaultInactivityTimeoutPeriod(): Integer
    begin
        exit(680 + Random(40))
    end;

    internal procedure InsertIntegrationFieldMapping(IntegrationTableMappingName: Code[20]; var IntegrationFieldMapping: Record "Integration Field Mapping"; TableFieldNo: Integer; IntegrationTableFieldNo: Integer; SynchDirection: Option; ConstValue: Text; ValidateField: Boolean; ValidateIntegrationTableField: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        IntegrationFieldMapping.CreateRecord(IntegrationTableMappingName, TableFieldNo, IntegrationTableFieldNo, SynchDirection,
          ConstValue, ValidateField, ValidateIntegrationTableField);

        if IntegrationTableMapping.Get(IntegrationTableMappingName) then begin
            IntegrationFieldMapping."Field Caption" := CopyStr(GetFieldCaption(IntegrationTableMapping."Table ID", IntegrationFieldMapping."Field No."), 1, MaxStrLen(IntegrationFieldMapping."Field Caption"));
            IntegrationFieldMapping.Modify();
        end;
    end;

    internal procedure GetFieldCaption(TableID: Integer; FieldID: Integer): Text
    var
        "Field": Record "Field";
        TypeHelper: Codeunit "Type Helper";
    begin
        if (TableID <> 0) and (FieldID <> 0) then
            if TypeHelper.GetField(TableID, FieldID, Field) then
                exit(Field."Field Caption");
        exit('');
    end;

    internal procedure GetTableCaption(TableID: Integer): Text[250]
    var
        ObjectTranslation: Record "Object Translation";
    begin
        if TableID = 0 then
            exit('');

        exit(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Table, TableID));
    end;

    local procedure SetIntegrationFieldMappingClearValueOnFailedSync(var IntegrationTableMapping: Record "Integration Table Mapping"; FieldNo: Integer)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", FieldNo);
        if not IntegrationFieldMapping.FindFirst() then
            exit;
        IntegrationFieldMapping."Clear Value on Failed Sync" := true;
        IntegrationFieldMapping.Modify();
    end;

    local procedure SetIntegrationFieldMappingValidate(var IntegrationTableMapping: Record "Integration Table Mapping"; FieldNo: Integer)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", FieldNo);
        if not IntegrationFieldMapping.FindFirst() then
            exit;
        IntegrationFieldMapping."Validate Field" := true;
        IntegrationFieldMapping.Modify();
    end;

    internal procedure CreateUncoupleJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Int. Uncouple Job Runner", StrSubstNo(UncoupleJobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription())));
    end;

    internal procedure CreateCoupleJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Int. Coupling Job Runner", StrSubstNo(CoupleJobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription())));
    end;

    internal procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), ProductName.Short())));
    end;

    internal procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"; ServiceName: Text): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Integration Synch. Job Runner", StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), ServiceName)));
    end;

    local procedure CreateJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime() + 1000;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JobCodeunitId);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueCategoryLbl);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.SetFilter("Earliest Start Date/Time", '<=%1', StartTime);
        if not JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.DeleteTasks();
            Commit();
        end;

        JobQueueEntry.Init();
        Clear(JobQueueEntry.ID); // "Job Queue - Enqueue" is to define new ID
        JobQueueEntry."Earliest Start Date/Time" := StartTime;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JobCodeunitId;
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry."Maximum No. of Attempts to Run" := 2;
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry.Description := CopyStr(JobDescription, 1, MaxStrLen(JobQueueEntry.Description));
        exit(Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry))
    end;

    internal procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer)
    begin
        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, IntervalInMinutes, ShouldRecreateJobQueueEntry, InactivityTimeoutPeriod, ProductName.Short(), false);
    end;

    internal procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer; ServiceName: Text; IsOption: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataManagement: Codeunit "Master Data Management";
        SynchronizationTableRecRef: RecordRef;
        IsHandled: Boolean;
    begin
        MasterDataManagement.OnHandleRecreateJobQueueEntryFromIntegrationTableMapping(JobQueueEntry, IntegrationTableMapping, IsHandled);
        if IsHandled then
            exit;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.DeleteTasks();

        JobQueueEntry.InitRecurringJob(IntervalInMinutes);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Integration Synch. Job Runner";
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        if IntegrationTableMapping."Table ID" <> 0 then begin
            SynchronizationTableRecRef.Open(IntegrationTableMapping."Table ID");
            JobQueueEntry.Description := CopyStr(StrSubstNo(JobQueueEntryNameTok, SynchronizationTableRecRef.Caption(), ServiceName), 1, MaxStrLen(JobQueueEntry.Description));
        end else
            JobQueueEntry.Description := CopyStr(StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.Name, ServiceName), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Maximum No. of Attempts to Run" := 10;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry."Inactivity Timeout Period" := InactivityTimeoutPeriod;
        if IsOption then
            JobQueueEntry."Job Queue Category Code" := OptionJobQueueCategoryLbl;
        if IntegrationTableMapping."Table ID" in [Database::Customer, Database::Vendor, Database::Contact] then
            JobQueueEntry."Job Queue Category Code" := CustomerContactJobQueueCategoryLbl
        else
            JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;

        OnBeforeInsertJobQueueEntryForSynchronizationTable(JobQueueEntry, IntegrationTableMapping, ShouldRecreateJobQueueEntry);
        if ShouldRecreateJobQueueEntry then
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry)
        else begin
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
            JobQueueEntry.Insert(true);
        end;
    end;

    local procedure GetTableFilterFromView(TableID: Integer; Caption: Text; View: Text): Text
    var
        FilterBuilder: FilterPageBuilder;
    begin
        FilterBuilder.AddTable(Caption, TableID);
        FilterBuilder.SetView(Caption, View);
        exit(FilterBuilder.GetView(Caption, false));
    end;

    internal procedure GetPrioritizedMappingList(var NameValueBuffer: Record "Name/Value Buffer")
    var
        "Field": Record "Field";
        IntegrationTableMapping: Record "Integration Table Mapping";
        NextPriority: Integer;
    begin
        NextPriority := 1;

        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::"Salesperson/Purchaser");
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::"Payment Terms");
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::"Shipping Agent");
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::"Shipment Method");
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::Currency);
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::Customer);
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::Vendor);
        AddPrioritizedMappingsToList(NameValueBuffer, NextPriority, 0, DATABASE::Contact);

        IntegrationTableMapping.Reset();
        IntegrationTableMapping.SetFilter("Parent Name", '=''''');
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Int. Table UID Field Type", Field.Type::GUID);
        if IntegrationTableMapping.FindSet() then
            repeat
                AddPrioritizedMappingToList(NameValueBuffer, NextPriority, IntegrationTableMapping.Name);
            until IntegrationTableMapping.Next() = 0;
    end;

    local procedure AddPrioritizedMappingsToList(var NameValueBuffer: Record "Name/Value Buffer"; var Priority: Integer; TableID: Integer; IntegrationTableID: Integer)
    var
        "Field": Record "Field";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        with IntegrationTableMapping do begin
            Reset();
            SetRange("Delete After Synchronization", false);
            if TableID > 0 then
                SetRange("Table ID", TableID);
            if IntegrationTableID > 0 then
                SetRange("Integration Table ID", IntegrationTableID);
            SetRange("Int. Table UID Field Type", Field.Type::GUID);
            if FindSet() then
                repeat
                    AddPrioritizedMappingToList(NameValueBuffer, Priority, Name);
                until Next() = 0;
        end;
    end;

    local procedure AddPrioritizedMappingToList(var NameValueBuffer: Record "Name/Value Buffer"; var Priority: Integer; MappingName: Code[20])
    begin
        with NameValueBuffer do begin
            SetRange(Value, MappingName);

            if not FindFirst() then begin
                Init();
                ID := Priority;
                Name := Format(Priority);
                Value := MappingName;
                Insert();
                Priority := Priority + 1;
            end;

            Reset();
        end;
    end;

    local procedure ResetBCAccountConfigTemplate(TableNo: Integer): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        BCAccountConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        BCAccountConfigTemplateLine: Record "Config. Template Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        FoundTemplateCode: Code[10];
        ConfigTemplateCode: Code[10];
        ConfigTemplateDesc: Text;
        CurrencyFieldNo: Integer;
    begin
        case TableNo of
            Database::Customer:
                begin
                    ConfigTemplateCode := CustomerConfigTemplateCodeTok;
                    ConfigTemplateDesc := CustomerConfigTemplateDescTxt;
                    CurrencyFieldNo := Customer.FieldNo("Currency Code");
                end;
            Database::Vendor:
                begin
                    ConfigTemplateCode := VendorConfigTemplateCodeTok;
                    ConfigTemplateDesc := VendorConfigTemplateDescTxt;
                    CurrencyFieldNo := Vendor.FieldNo("Currency Code");
                end;
            else
                exit('');
        end;

        BCAccountConfigTemplateLine.SetRange(
          "Data Template Code", CopyStr(ConfigTemplateCode, 1, MaxStrLen(BCAccountConfigTemplateLine."Data Template Code")));
        BCAccountConfigTemplateLine.DeleteAll();
        BCAccountConfigTemplateHeader.SetRange(
          Code, CopyStr(ConfigTemplateCode, 1, MaxStrLen(BCAccountConfigTemplateHeader.Code)));
        BCAccountConfigTemplateHeader.DeleteAll();

        // Base the customer config template off the first customer template with currency code '' (LCY);
        ConfigTemplateHeader.SetRange("Table ID", TableNo);
        if ConfigTemplateHeader.FindSet() then
            repeat
                ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
                ConfigTemplateLine.SetRange("Field ID", CurrencyFieldNo);
                ConfigTemplateLine.SetFilter("Default Value", '');
                if ConfigTemplateLine.FindFirst() then begin
                    FoundTemplateCode := ConfigTemplateHeader.Code;
                    break;
                end;
            until ConfigTemplateHeader.Next() = 0;

        if FoundTemplateCode = '' then
            exit('');

        BCAccountConfigTemplateHeader.Init();
        BCAccountConfigTemplateHeader.TransferFields(ConfigTemplateHeader, false);
        BCAccountConfigTemplateHeader.Code := CopyStr(ConfigTemplateCode, 1, MaxStrLen(BCAccountConfigTemplateHeader.Code));
        BCAccountConfigTemplateHeader.Description :=
          CopyStr(ConfigTemplateDesc, 1, MaxStrLen(BCAccountConfigTemplateHeader.Description));
        BCAccountConfigTemplateHeader.Insert();

        ConfigTemplateLine.Reset();
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
        ConfigTemplateLine.FindSet();
        repeat
            if not (ConfigTemplateLine."Field ID" = CurrencyFieldNo) then begin
                BCAccountConfigTemplateLine.Init();
                BCAccountConfigTemplateLine.TransferFields(ConfigTemplateLine, true);
                BCAccountConfigTemplateLine."Data Template Code" := BCAccountConfigTemplateHeader.Code;
                BCAccountConfigTemplateLine.Insert();
            end;
        until ConfigTemplateLine.Next() = 0;

        exit(ConfigTemplateCode);
    end;

    [Scope('Cloud')]
    internal procedure GetCustomerTableMappingName(): Text
    begin
        exit(CustomerTableMappingNameTxt);
    end;

    [Scope('Cloud')]
    internal procedure GetVendorTableMappingName(): Text
    begin
        exit(VendorTableMappingNameTxt);
    end;

    internal procedure SetCustomIntegrationsTableMappings(MasterDataManagementSetup: Record "Master Data Management Setup")
    begin
        OnAfterResetConfiguration(MasterDataManagementSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetConfiguration(MasterDataManagementSetup: Record "Master Data Management Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetConfiguration(var MasterDataManagementSetup: Record "Master Data Management Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeResetTableMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetTableMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertJobQueueEntryForSynchronizationTable(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; var ShouldScheduleJobQueueEntry: Boolean);
    begin
    end;
}

