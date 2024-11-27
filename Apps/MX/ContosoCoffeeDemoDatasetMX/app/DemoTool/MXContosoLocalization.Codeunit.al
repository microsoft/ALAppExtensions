codeunit 14108 "MX Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Information MX");
                    Codeunit.Run(Codeunit::"Create Post Code MX");
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups MX");
                    Codeunit.Run(Codeunit::"Create Posting Groups MX");
                    Codeunit.Run(Codeunit::"Create Data Exchange Def MX");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Bank Ex/Import SetupMX");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line MX");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupMX: Codeunit "Create VAT Posting Groups MX";
        CreatePostingGroupsMX: Codeunit "Create Posting Groups MX";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVatPostingGroupMX.CreateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create General Ledger Setup MX");
                    Codeunit.Run(Codeunit::"Create VATSetupPostingGrp. MX");
                    Codeunit.Run(Codeunit::"Create Column Layout Name MX");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Column Layout MX");
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate MX");
                    Codeunit.Run(Codeunit::"Create VAT Statement MX");
                    CreateMXGLAccounts.AddCategoriesToGLAccounts();
                    CreateMXGLAccounts.UpdateDebitCreditOnGL();
                    CreateMXGLAccounts.UpdateVATProdPostingGroupOnGL();
                    CreatePostingGroupsMX.CreateGenPostingSetup();
                end;
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Ship-to Address MX");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Sales Document MX");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Item Template MX");
                    Codeunit.Run(Codeunit::"Create Location MX");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateCustomerMX: Codeunit "Create Customer MX";
        CreateCurrencyExchRateMX: Codeunit "Create Currency Ex. Rate MX";
        CreateAccScheduleLineMX: Codeunit "Create Acc. Schedule Line MX";
        CreateVATStatementMX: Codeunit "Create VAT Statement MX";
        CreatePostingGroupsMX: Codeunit "Create Posting Groups MX";
        CreateCurrencyMX: Codeunit "Create Currency MX";
        CreateLocationMX: Codeunit "Create Location MX";
        CreateItemMX: Codeunit "Create Item MX";
        CreateBankAccountMX: Codeunit "Create Bank Account MX";
        CreateItemChargeMX: Codeunit "Create Item Charge MX";
        CreateVendorMX: Codeunit "Create Vendor MX";
        CreateResourceMX: Codeunit "Create Resource MX";
        CreateReminderLevelMX: Codeunit "Create Reminder Level MX";
        CreateGenJournalLineMX: Codeunit "Create Gen. Journal Line MX";
        CreateSalesDimValueMX: Codeunit "Create Sales Dim Value MX";
        CreatePurchDimValueMX: Codeunit "Create Purch. Dim. Value MX";
        CreateInvPostingSetupMX: Codeunit "Create Inv. Posting Setup MX";
        CreateItemJournalTemplateMX: Codeunit "Create Item Journal TemplateMX";
        CreateColumnLayoutMX: Codeunit "Create Column Layout MX";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccountMX);
                    BindSubscription(CreateGenJournalLineMX);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemChargeMX);
                    BindSubscription(CreateItemMX);
                    BindSubscription(CreateLocationMX);
                    BindSubscription(CreateInvPostingSetupMX);
                    BindSubscription(CreateItemJournalTemplateMX);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerMX);
                    BindSubscription(CreateReminderLevelMX);
                    BindSubscription(CreateSalesDimValueMX);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorMX);
                    BindSubscription(CreatePurchDimValueMX);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyExchRateMX);
                    BindSubscription(CreatePostingGroupsMX);
                    BindSubscription(CreateResourceMX);
                    BindSubscription(CreateAccScheduleLineMX);
                    BindSubscription(CreateVATStatementMX);
                    BindSubscription(CreateCurrencyMX);
                    BindSubscription(CreateColumnLayoutMX);
                end;
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateCurrencyExchRateMX: Codeunit "Create Currency Ex. Rate MX";
        CreateAccScheduleLineMX: Codeunit "Create Acc. Schedule Line MX";
        CreateVATStatementMX: Codeunit "Create VAT Statement MX";
        CreatePostingGroupsMX: Codeunit "Create Posting Groups MX";
        CreateCurrencyMX: Codeunit "Create Currency MX";
        CreateLocationMX: Codeunit "Create Location MX";
        CreateItemMX: Codeunit "Create Item MX";
        CreateBankAccountMX: Codeunit "Create Bank Account MX";
        CreateItemChargeMX: Codeunit "Create Item Charge MX";
        CreateVendorMX: Codeunit "Create Vendor MX";
        CreateResourceMX: Codeunit "Create Resource MX";
        CreateReminderLevelMX: Codeunit "Create Reminder Level MX";
        CreateGenJournalLineMX: Codeunit "Create Gen. Journal Line MX";
        CreateSalesDimValueMX: Codeunit "Create Sales Dim Value MX";
        CreatePurchDimValueMX: Codeunit "Create Purch. Dim. Value MX";
        CreateInvPostingSetupMX: Codeunit "Create Inv. Posting Setup MX";
        CreateCustomerMX: Codeunit "Create Customer MX";
        CreateItemJournalTemplateMX: Codeunit "Create Item Journal TemplateMX";
        CreateColumnLayoutMX: Codeunit "Create Column Layout MX";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccountMX);
                    UnbindSubscription(CreateGenJournalLineMX);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemChargeMX);
                    UnbindSubscription(CreateItemMX);
                    UnbindSubscription(CreateLocationMX);
                    UnbindSubscription(CreateInvPostingSetupMX);
                    UnbindSubscription(CreateItemJournalTemplateMX);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateReminderLevelMX);
                    UnbindSubscription(CreateSalesDimValueMX);
                    UnbindSubscription(CreateCustomerMX);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorMX);
                    UnbindSubscription(CreatePurchDimValueMX);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateCurrencyExchRateMX);
                    UnbindSubscription(CreatePostingGroupsMX);
                    UnbindSubscription(CreateResourceMX);
                    UnbindSubscription(CreateAccScheduleLineMX);
                    UnbindSubscription(CreateVATStatementMX);
                    UnbindSubscription(CreateCurrencyMX);
                    UnbindSubscription(CreateColumnLayoutMX);
                end;
        end;
    end;
}