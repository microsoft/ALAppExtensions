codeunit 11508 "NL Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            SalesModule(ContosoDemoDataLevel);

        UnbindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Information NL");
                    Codeunit.Run(Codeunit::"Create No. Series NL");
                    Codeunit.Run(Codeunit::"Create Post Code NL");
                    Codeunit.Run(Codeunit::"Create Source Code NL");
                    Codeunit.Run(Codeunit::"Create Data Exchange NL");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create General Ledger Setup NL");
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups NL");
                    Codeunit.Run(Codeunit::"Create Gen. Journal Batch NL");
                    CreateNLGLAccounts.AddCategoriesToGLAccountsForMini();
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Posting Groups NL");
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate NL");
                    Codeunit.Run(Codeunit::"Create Freely Transfer Max. NL");
                    Codeunit.Run(Codeunit::"Create Resource NL");
                    Codeunit.Run(Codeunit::"Create VAT Setup PostingGrp NL");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Bank Ex/Import NL");
                    Codeunit.Run(Codeunit::"Create Bank Posting Grp NL");
                end;
        end;
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Bank Account NL");
                    Codeunit.Run(Codeunit::"Create Imp./Exp. Protocol NL");
                    Codeunit.Run(Codeunit::"Create Gen. Journal Templ. NL");
                end;
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line NL");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Elec Tax Declaration NL");
                    Codeunit.Run(Codeunit::"Create Vat Statement Line NL");
                end;
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create FA Ins Jnl. Template NL");
                    Codeunit.Run(Codeunit::"Create FA No. Series NL");
                end;
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Employee NL");
                    Codeunit.Run(Codeunit::"Create Employee Template NL");
                end;
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Location NL");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Vendor Bank Acount NL");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Document NL");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Customer Bank Acount NL");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationNL: Codeunit "Create Location NL";
        CreateItemNL: Codeunit "Create Item NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
        CreateBankPostingGrpNL: Codeunit "Create Bank Posting Grp NL";
        CreateCustPostingGroupNL: Codeunit "Create Cust. Posting Grp NL";
        CreateReminderLevelNL: Codeunit "Create Reminder Level NL";
        CreateCustomerNL: Codeunit "Create Customer NL";
        CreateSalesDimValueNL: Codeunit "Create Sales Dim Value NL";
        CreateShiptoAddressNL: Codeunit "Create Ship-to Address NL";
        CreateVendorNL: Codeunit "Create Vendor NL";
        CreateVendorPostingGroupNL: Codeunit "Create Vendor Posting Group NL";
        CreatePurchDimValueNL: Codeunit "Create Purch. Dim. Value NL";
        CreateResourceNL: Codeunit "Create Resource NL";
        CreateCurrencyNL: Codeunit "Create Currency NL";
        CreateCurrencyExchRateNL: Codeunit "Create Currency Ex. Rate NL";
        CreateFADepreciationBookNL: Codeunit "Create FA Depreciation Book NL";
        CreateAccScheduleLineNL: Codeunit "Create Acc. Schedule Line NL";
        CreateInvPostingSetupNL: Codeunit "Create Inv. Posting Setup NL";
        CreateFAPostingGrpNL: Codeunit "Create FA Posting Grp. NL";
        CreateGenJournalLineNL: Codeunit "Create Gen. Journal Line NL";
        CreatePaymentMethodNL: Codeunit "Create Payment Method NL";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccountNL);
                    BindSubscription(CreateBankPostingGrpNL);
                    BindSubscription(CreateGenJournalLineNL);
                    BindSubscription(CreatePaymentMethodNL);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyNL);
                    BindSubscription(CreateCurrencyExchRateNL);
                    BindSubscription(CreateResourceNL);
                    BindSubscription(CreateAccScheduleLineNL);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFADepreciationBookNL);
                    BindSubscription(CreateFAPostingGrpNL);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemNL);
                    BindSubscription(CreateLocationNL);
                    BindSubscription(CreateInvPostingSetupNL);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorNL);
                    BindSubscription(CreatePurchDimValueNL);
                    BindSubscription(CreateVendorPostingGroupNL);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerNL);
                    BindSubscription(CreateShiptoAddressNL);
                    BindSubscription(CreateSalesDimValueNL);
                    BindSubscription(CreateReminderLevelNL);
                    BindSubscription(CreateCustPostingGroupNL);
                end;
        end;
    end;

    local procedure UnbindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationNL: Codeunit "Create Location NL";
        CreateItemNL: Codeunit "Create Item NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
        CreateBankPostingGrpNL: Codeunit "Create Bank Posting Grp NL";
        CreateCustPostingGroupNL: Codeunit "Create Cust. Posting Grp NL";
        CreateReminderLevelNL: Codeunit "Create Reminder Level NL";
        CreateCustomerNL: Codeunit "Create Customer NL";
        CreateSalesDimValueNL: Codeunit "Create Sales Dim Value NL";
        CreateShiptoAddressNL: Codeunit "Create Ship-to Address NL";
        CreateVendorNL: Codeunit "Create Vendor NL";
        CreateVendorPostingGroupNL: Codeunit "Create Vendor Posting Group NL";
        CreatePurchDimValueNL: Codeunit "Create Purch. Dim. Value NL";
        CreateResourceNL: Codeunit "Create Resource NL";
        CreateCurrencyNL: Codeunit "Create Currency NL";
        CreateCurrencyExchRateNL: Codeunit "Create Currency Ex. Rate NL";
        CreateFADepreciationBookNL: Codeunit "Create FA Depreciation Book NL";
        CreateAccScheduleLineNL: Codeunit "Create Acc. Schedule Line NL";
        CreateInvPostingSetupNL: Codeunit "Create Inv. Posting Setup NL";
        CreateFAPostingGrpNL: Codeunit "Create FA Posting Grp. NL";
        CreateGenJournalLineNL: Codeunit "Create Gen. Journal Line NL";
        CreatePaymentMethodNL: Codeunit "Create Payment Method NL";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccountNL);
                    UnbindSubscription(CreateBankPostingGrpNL);
                    UnbindSubscription(CreateGenJournalLineNL);
                    UnbindSubscription(CreatePaymentMethodNL);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateFADepreciationBookNL);
                    UnbindSubscription(CreateFAPostingGrpNL);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateCurrencyNL);
                    UnbindSubscription(CreateCurrencyExchRateNL);
                    UnbindSubscription(CreateResourceNL);
                    UnbindSubscription(CreateAccScheduleLineNL);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemNL);
                    UnbindSubscription(CreateLocationNL);
                    UnbindSubscription(CreateInvPostingSetupNL);
                end;

            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorNL);
                    UnbindSubscription(CreatePurchDimValueNL);
                    UnbindSubscription(CreateVendorPostingGroupNL);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustomerNL);
                    UnbindSubscription(CreateShiptoAddressNL);
                    UnbindSubscription(CreateSalesDimValueNL);
                    UnbindSubscription(CreateReminderLevelNL);
                    UnbindSubscription(CreateCustPostingGroupNL);
                end;
        end;
    end;
}