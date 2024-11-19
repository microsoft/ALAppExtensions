codeunit 11465 "US Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                HumanResourceModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create No. Series US");
                    Codeunit.Run(Codeunit::"Create Post Code US");
                    Codeunit.Run(Codeunit::"Create Company Information US");
                    Codeunit.Run(Codeunit::"Create Job Queue Category US");
                    Codeunit.Run(Codeunit::"Create Data Exchange Def US");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create General Ledger Setup US");
                    Codeunit.Run(Codeunit::"Create Posting Groups US");
                    Codeunit.Run(Codeunit::"Create Acc. Schedule Line US");
                    Codeunit.Run(Codeunit::"Create Column Layout Name US");
                    Codeunit.Run(Codeunit::"Create Currency US");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Column Layout US");
                    Codeunit.Run(Codeunit::"Create Curr Exchange Rate US");
                    Codeunit.Run(Codeunit::"Create Tax Group US");
                    Codeunit.Run(Codeunit::"Create Tax Jurisdiction US");
                    Codeunit.Run(Codeunit::"Create Tax Setup US");
                    Codeunit.Run(Codeunit::"Create Tax Area US");
                    Codeunit.Run(Codeunit::"Create Tax Area Line US");
                    Codeunit.Run(Codeunit::"Create Tax Detail US");
                end;
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Recv. Setup US");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Customer US");
                    Codeunit.Run(Codeunit::"Create Sales Dimension ValueUS");
                    Codeunit.Run(Codeunit::"Create Ship-to Address US");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Sales Document US");
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Bank Ex/Import SetupUS");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup US");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Line US");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Location US");
                    Codeunit.Run(Codeunit::"Create InventoryPostingSetupUS");
                end;
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Employee US");
        end;
    end;

    // Bind subscription for localization events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateCustomerPostingGroupUS: Codeunit "CreateCustomerPostingGroupUS";
        CreateNoSeriesUS: Codeunit "Create No. Series US";
        CreateAccScheduleLineUS: Codeunit "Create Acc. Schedule Line US";
        CreateCurrencyUS: Codeunit "Create Currency US";
        CreateGenJnlTemplateUS: Codeunit "Create Gen. Jnl Template US";
        CreateGenJnlBatchUS: Codeunit "Create Gen. Journal Batch US";
        CreateColumnLayoutUS: Codeunit "Create Column Layout US";
        CreateCurrExchangeRateUS: Codeunit "Create Curr Exchange Rate US";
        CreateBankAccPostingGrpUS: Codeunit "Create Bank Acc. Posting GrpUS";
        CreateBankAccountUS: Codeunit "Create Bank Account US";
        CreateResourceUS: Codeunit "Create Resource US";
        CreateItemJournalTemplateUS: Codeunit "Create Item Journal TemplateUS";
        CreateItemChargeUS: Codeunit "Create Item Charge US";
        CreateItemUS: Codeunit "Create Item US";
        CreateLocationUS: Codeunit "Create Location US";
        CreateVendorPostingGroupUS: Codeunit "Create Vendor Posting Group US";
        CreateVendorUS: Codeunit "Create Vendor US";
        CreateVendorTemplateUS: Codeunit "Create Vendor Template US";
        CreateVendorBankAccountUS: Codeunit "Create Vendor Bank Account US";
        CreateCustomerTemplateUS: Codeunit "Create Customer Template US";
        CreateCustomerUS: Codeunit "Create Customer US";
        CreateEmployeePostingGroupUS: Codeunit "Create Employee PostingGroupUS";
        CreateSalesDimensionValueUS: Codeunit "Create Sales Dimension ValueUS";
        CreatePurchDimValueUS: Codeunit "Create Purch. Dim. Value US";
        CreateReminderLevelUS: Codeunit "Create Reminder Level US";
        CreateFADepreciationBookUS: Codeunit "Create FA Depreciation Book US";
        CreateFAPostingGrpUS: Codeunit "Create FA Posting Grp. US";
        CreateCustBankAccountUS: Codeunit "Create Cust. Bank Account US";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                BindSubscription(CreateNoSeriesUS);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateAccScheduleLineUS);
                    BindSubscription(CreateCurrencyUS);
                    BindSubscription(CreateGenJnlTemplateUS);
                    BindSubscription(CreateGenJnlBatchUS);
                    BindSubscription(CreateColumnLayoutUS);
                    BindSubscription(CreateCurrExchangeRateUS);
                    BindSubscription(CreateResourceUS);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerPostingGroupUS);
                    BindSubscription(CreateReminderLevelUS);
                    BindSubscription(CreateCustomerTemplateUS);
                    BindSubscription(CreateCustomerUS);
                    BindSubscription(CreateSalesDimensionValueUS);
                    BindSubscription(CreateCustBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccPostingGrpUS);
                    BindSubscription(CreateBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemJournalTemplateUS);
                    BindSubscription(CreateItemUS);
                    BindSubscription(CreateItemChargeUS);
                    BindSubscription(CreateLocationUS);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGroupUS);
                    BindSubscription(CreateVendorUS);
                    BindSubscription(CreatePurchDimValueUS);
                    BindSubscription(CreateVendorTemplateUS);
                    BindSubscription(CreateVendorBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateEmployeePostingGroupUS);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFADepreciationBookUS);
                    BindSubscription(CreateFAPostingGrpUS);
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateCustomerPostingGroupUS: Codeunit "CreateCustomerPostingGroupUS";
        CreateNoSeriesUS: Codeunit "Create No. Series US";
        CreateAccScheduleLineUS: Codeunit "Create Acc. Schedule Line US";
        CreateCurrencyUS: Codeunit "Create Currency US";
        CreateGenJnlTemplateUS: Codeunit "Create Gen. Jnl Template US";
        CreateGenJnlBatchUS: Codeunit "Create Gen. Journal Batch US";
        CreateColumnLayoutUS: Codeunit "Create Column Layout US";
        CreateCurrExchangeRateUS: Codeunit "Create Curr Exchange Rate US";
        CreateBankAccPostingGrpUS: Codeunit "Create Bank Acc. Posting GrpUS";
        CreateBankAccountUS: Codeunit "Create Bank Account US";
        CreateResourceUS: Codeunit "Create Resource US";
        CreateItemJournalTemplateUS: Codeunit "Create Item Journal TemplateUS";
        CreateItemChargeUS: Codeunit "Create Item Charge US";
        CreateItemUS: Codeunit "Create Item US";
        CreateLocationUS: Codeunit "Create Location US";
        CreateVendorPostingGroupUS: Codeunit "Create Vendor Posting Group US";
        CreateVendorUS: Codeunit "Create Vendor US";
        CreateVendorTemplateUS: Codeunit "Create Vendor Template US";
        CreateVendorBankAccountUS: Codeunit "Create Vendor Bank Account US";
        CreateCustomerTemplateUS: Codeunit "Create Customer Template US";
        CreateCustomerUS: Codeunit "Create Customer US";
        CreateEmployeePostingGroupUS: Codeunit "Create Employee PostingGroupUS";
        CreateSalesDimensionValueUS: Codeunit "Create Sales Dimension ValueUS";
        CreatePurchDimValueUS: Codeunit "Create Purch. Dim. Value US";
        CreateReminderLevelUS: Codeunit "Create Reminder Level US";
        CreateFADepreciationBookUS: Codeunit "Create FA Depreciation Book US";
        CreateFAPostingGrpUS: Codeunit "Create FA Posting Grp. US";
        CreateCustBankAccountUS: Codeunit "Create Cust. Bank Account US";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                UnbindSubscription(CreateNoSeriesUS);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateAccScheduleLineUS);
                    UnbindSubscription(CreateCurrencyUS);
                    UnbindSubscription(CreateGenJnlTemplateUS);
                    UnbindSubscription(CreateGenJnlBatchUS);
                    UnbindSubscription(CreateColumnLayoutUS);
                    UnbindSubscription(CreateCurrExchangeRateUS);
                    UnbindSubscription(CreateResourceUS);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustomerPostingGroupUS);
                    UnbindSubscription(CreateReminderLevelUS);
                    UnbindSubscription(CreateCustomerTemplateUS);
                    UnbindSubscription(CreateCustomerUS);
                    UnbindSubscription(CreateSalesDimensionValueUS);
                    UnbindSubscription(CreateCustBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccPostingGrpUS);
                    UnbindSubscription(CreateBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemJournalTemplateUS);
                    UnbindSubscription(CreateItemUS);
                    UnbindSubscription(CreateItemChargeUS);
                    UnbindSubscription(CreateLocationUS);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorPostingGroupUS);
                    UnbindSubscription(CreateVendorUS);
                    UnbindSubscription(CreatePurchDimValueUS);
                    UnbindSubscription(CreateVendorTemplateUS);
                    UnbindSubscription(CreateVendorBankAccountUS);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateEmployeePostingGroupUS);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateFADepreciationBookUS);
                    UnbindSubscription(CreateFAPostingGrpUS);
                end;
        end;
    end;
}