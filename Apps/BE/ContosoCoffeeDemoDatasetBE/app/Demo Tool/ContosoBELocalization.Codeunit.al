codeunit 11355 "Contoso BE Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create FA Ins Jnl. Template BE");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Area BE");
                    Codeunit.Run(Codeunit::"Create Post Code BE");
                    Codeunit.Run(Codeunit::"Create Transaction Spec. BE");
                    Codeunit.Run(Codeunit::"Create Company Information BE");
                    Codeunit.Run(Codeunit::"Create No. Series BE");
                    Codeunit.Run(Codeunit::"Create Shipping Data BE");
                    Codeunit.Run(Codeunit::"Create VAT Posting Group BE");
                    Codeunit.Run(Codeunit::"Create Column Layout Name BE");
                    Codeunit.Run(Codeunit::"Create UOM Translation BE");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVATPostingGrp: Codeunit "Create VAT Posting Group BE";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVATPostingGrp.CreateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create Posting Group BE");
                    Codeunit.Run(Codeunit::"Create Gen. Jnl Template BE");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate BE");
                    Codeunit.Run(Codeunit::"Create Gen. Jnl Template BE");
                    Codeunit.Run(Codeunit::"Create Territory BE");
                    Codeunit.Run(Codeunit::"Create Column Layout BE");
                    Codeunit.Run(Codeunit::"Create VAT Statement BE");
                    Codeunit.Run(Codeunit::"Create General Ledger Setup BE");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateGenJnlTemplateBE: Codeunit "Create Gen. Jnl Template BE";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Bank Account BE");
                    CreateGenJnlTemplateBE.UpdateGenJnlTemplate();
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Coda Document");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line BE");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Inv. Setup BE");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Item Template BE");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup BE");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Document BE");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Rec. Setup BE");
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group BE");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Marketing Setup BE");
                    Codeunit.Run(Codeunit::"Create Word Template BE");
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateResourceBE: Codeunit "Create Resource BE";
        CreateCurrencyExcRate: Codeunit "Create Currency Ex. Rate BE";
        CreateAccScheduleLineBE: Codeunit "Create Acc. Schedule Line BE";
        CreateBankAccPostingGrpBE: Codeunit "Create Bank Acc Posting Grp BE";
        CreateBankAccountBE: Codeunit "Create Bank Account BE";
        CreateFAPostingGrpBE: Codeunit "Create FA Posting Grp. BE";
        CreateInvPostingSetupBE: Codeunit "Create Inv. Posting Setup BE";
        CreateItemBE: Codeunit "Create Item BE";
        CreateItemChargeBE: Codeunit "Create Item Charge BE";
        CreateLoactionBE: Codeunit "Create Location BE";
        CreateVendorPostingGrpBE: Codeunit "Create Vendor Posting Grp BE";
        CreatePurchDimValueBE: Codeunit "Create Purch. Dim. Value BE";
        CreateVendorBE: Codeunit "Create Vendor BE";
        CreateVendorTemplateBE: Codeunit "Create Vendor Template BE";
        CreateCustPostingGrpBE: Codeunit "Create Cust. Posting Grp BE";
        CreateReminderLevelBE: Codeunit "Create Reminder Level BE";
        CreateCustomerBE: Codeunit "Create Customer BE";
        CreateSalesDimValueBE: Codeunit "Create Sales Dim Value BE";
        CreateShiptoAddressBE: Codeunit "Create Ship-to Address BE";
        CreateEmployeeBE: Codeunit "Create Employee BE";
        CreateCompanyInformationBE: Codeunit "Create Company Information BE";
        CreateCurrencyBE: Codeunit "Create Currency BE";
        CreateGenJournalLineBE: Codeunit "Create Gen. Journal Line BE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                BindSubscription(CreateCompanyInformationBE);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateResourceBE);
                    BindSubscription(CreateCurrencyExcRate);
                    BindSubscription(CreateAccScheduleLineBE);
                    BindSubscription(CreateCurrencyBE);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccPostingGrpBE);
                    BindSubscription(CreateBankAccountBE);
                    BindSubscription(CreateGenJournalLineBE);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFAPostingGrpBE);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateInvPostingSetupBE);
                    BindSubscription(CreateItemBE);
                    BindSubscription(CreateItemChargeBE);
                    BindSubscription(CreateLoactionBE);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGrpBE);
                    BindSubscription(CreatePurchDimValueBE);
                    BindSubscription(CreateVendorBE);
                    BindSubscription(CreateVendorTemplateBE);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustPostingGrpBE);
                    BindSubscription(CreateReminderLevelBE);
                    BindSubscription(CreateCustomerBE);
                    BindSubscription(CreateSalesDimValueBE);
                    BindSubscription(CreateShiptoAddressBE);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateEmployeeBE);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateResourceBE: Codeunit "Create Resource BE";
        CreateCurrencyExcRate: Codeunit "Create Currency Ex. Rate BE";
        CreateAccScheduleLineBE: Codeunit "Create Acc. Schedule Line BE";
        CreateBankAccPostingGrpBE: Codeunit "Create Bank Acc Posting Grp BE";
        CreateBankAccountBE: Codeunit "Create Bank Account BE";
        CreateFAPostingGrpBE: Codeunit "Create FA Posting Grp. BE";
        CreateInvPostingSetupBE: Codeunit "Create Inv. Posting Setup BE";
        CreateItemBE: Codeunit "Create Item BE";
        CreateItemChargeBE: Codeunit "Create Item Charge BE";
        CreateLoactionBE: Codeunit "Create Location BE";
        CreateVendorPostingGrpBE: Codeunit "Create Vendor Posting Grp BE";
        CreatePurchDimValueBE: Codeunit "Create Purch. Dim. Value BE";
        CreateVendorBE: Codeunit "Create Vendor BE";
        CreateVendorTemplateBE: Codeunit "Create Vendor Template BE";
        CreateCustPostingGrpBE: Codeunit "Create Cust. Posting Grp BE";
        CreateReminderLevelBE: Codeunit "Create Reminder Level BE";
        CreateCustomerBE: Codeunit "Create Customer BE";
        CreateSalesDimValueBE: Codeunit "Create Sales Dim Value BE";
        CreateShiptoAddressBE: Codeunit "Create Ship-to Address BE";
        CreateEmployeeBE: Codeunit "Create Employee BE";
        CreateCompanyInformationBE: Codeunit "Create Company Information BE";
        CreateCurrencyBE: Codeunit "Create Currency BE";
        CreateGenJournalLineBE: Codeunit "Create Gen. Journal Line BE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                UnbindSubscription(CreateCompanyInformationBE);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateResourceBE);
                    UnbindSubscription(CreateCurrencyExcRate);
                    UnbindSubscription(CreateAccScheduleLineBE);
                    UnbindSubscription(CreateCurrencyBE);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccPostingGrpBE);
                    UnbindSubscription(CreateBankAccountBE);
                    UnbindSubscription(CreateGenJournalLineBE);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFAPostingGrpBE);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateInvPostingSetupBE);
                    UnbindSubscription(CreateItemBE);
                    UnbindSubscription(CreateItemChargeBE);
                    UnbindSubscription(CreateLoactionBE);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorPostingGrpBE);
                    UnbindSubscription(CreatePurchDimValueBE);
                    UnbindSubscription(CreateVendorBE);
                    UnbindSubscription(CreateVendorTemplateBE);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustPostingGrpBE);
                    UnbindSubscription(CreateReminderLevelBE);
                    UnbindSubscription(CreateCustomerBE);
                    UnbindSubscription(CreateSalesDimValueBE);
                    UnbindSubscription(CreateShiptoAddressBE);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateEmployeeBE);
        end;
    end;
}