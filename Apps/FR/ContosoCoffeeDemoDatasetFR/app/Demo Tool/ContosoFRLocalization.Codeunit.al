codeunit 10864 "Contoso FR Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Post Code FR");
                    Codeunit.Run(Codeunit::"Create Company Information FR");
                    Codeunit.Run(Codeunit::"Create Source Code FR");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line FR");
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create FA Depreciation Book FR");
                    Codeunit.Run(Codeunit::"Create FA Jnl. Setup FR");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVATPostingGrpFR: Codeunit "Create VAT Posting Grp FR";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create General Ledger Setup FR");
                    CreateVATPostingGrpFR.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create Posting Group FR");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Exc. Rate FR");
                    Codeunit.Run(Codeunit::"Create Column Layout FR");
                    Codeunit.Run(Codeunit::"Create VAT Statement FR");
                end;
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Inv. Posting Setup FR");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Item FR");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Vendor Posting Grp FR");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Cust. Posting Grp FR");
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group FR");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateResourceFR: Codeunit "Create Resource FR";
        CreateVATPostingGrpFR: Codeunit "Create VAT Posting Grp FR";
        CreateCurrencyExcRateFR: Codeunit "Create Currency Exc. Rate FR";
        CreateAccScheduleLineFR: Codeunit "Create Acc. Schedule Line FR";
        CreateBankAccPostingGrpFR: Codeunit "Create Bank Acc. Post. Grp FR";
        CreateBankAccountFR: Codeunit "Create Bank Account FR";
        CreateGenJournalLineFR: Codeunit "Create Gen. Journal Line FR";
        CreateFAPostingGrpFR: Codeunit "Create FA Posting Grp. FR";
        CreateItemFR: Codeunit "Create Item FR";
        CreateLoactionFR: Codeunit "Create Location FR";
        CreateVendorPostingGrpFR: Codeunit "Create Vendor Posting Grp FR";
        CreatePurchDimValueFR: Codeunit "Create Purch. Dim. Value FR";
        CreateVendorFR: Codeunit "Create Vendor FR";
        CreateCustPostingGrpFR: Codeunit "Create Cust. Posting Grp FR";
        CreateReminderLevelFR: Codeunit "Create Reminder Level FR";
        CreateCustomerFR: Codeunit "Create Customer FR";
        CreateSalesDimValueFR: Codeunit "Create Sales Dim Value FR";
        CreateShiptoAddressFR: Codeunit "Create Ship-to Address FR";
        CreateCurrencyFR: Codeunit "Create Currency FR";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateResourceFR);
                    BindSubscription(CreateCurrencyExcRateFR);
                    BindSubscription(CreateAccScheduleLineFR);
                    BindSubscription(CreateVATPostingGrpFR);
                    BindSubscription(CreateCurrencyFR);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccPostingGrpFR);
                    BindSubscription(CreateBankAccountFR);
                    BindSubscription(CreateGenJournalLineFR);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFAPostingGrpFR);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemFR);
                    BindSubscription(CreateLoactionFR);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGrpFR);
                    BindSubscription(CreatePurchDimValueFR);
                    BindSubscription(CreateVendorFR);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustPostingGrpFR);
                    BindSubscription(CreateReminderLevelFR);
                    BindSubscription(CreateCustomerFR);
                    BindSubscription(CreateSalesDimValueFR);
                    BindSubscription(CreateShiptoAddressFR);
                end;
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateResourceFR: Codeunit "Create Resource FR";
        CreateVATPostingGrpFR: Codeunit "Create VAT Posting Grp FR";
        CreateCurrencyExcRateFR: Codeunit "Create Currency Exc. Rate FR";
        CreateAccScheduleLineFR: Codeunit "Create Acc. Schedule Line FR";
        CreateBankAccPostingGrpFR: Codeunit "Create Bank Acc. Post. Grp FR";
        CreateBankAccountFR: Codeunit "Create Bank Account FR";
        CreateGenJournalLineFR: Codeunit "Create Gen. Journal Line FR";
        CreateFAPostingGrpFR: Codeunit "Create FA Posting Grp. FR";
        CreateItemFR: Codeunit "Create Item FR";
        CreateLoactionFR: Codeunit "Create Location FR";
        CreateVendorPostingGrpFR: Codeunit "Create Vendor Posting Grp FR";
        CreatePurchDimValueFR: Codeunit "Create Purch. Dim. Value FR";
        CreateVendorFR: Codeunit "Create Vendor FR";
        CreateCustPostingGrpFR: Codeunit "Create Cust. Posting Grp FR";
        CreateReminderLevelFR: Codeunit "Create Reminder Level FR";
        CreateCustomerFR: Codeunit "Create Customer FR";
        CreateSalesDimValueFR: Codeunit "Create Sales Dim Value FR";
        CreateShiptoAddressFR: Codeunit "Create Ship-to Address FR";
        CreateCurrencyFR: Codeunit "Create Currency FR";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateResourceFR);
                    UnbindSubscription(CreateCurrencyExcRateFR);
                    UnbindSubscription(CreateAccScheduleLineFR);
                    UnbindSubscription(CreateVATPostingGrpFR);
                    UnbindSubscription(CreateCurrencyFR);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccPostingGrpFR);
                    UnbindSubscription(CreateBankAccountFR);
                    UnbindSubscription(CreateGenJournalLineFR);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFAPostingGrpFR);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemFR);
                    UnbindSubscription(CreateLoactionFR);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorPostingGrpFR);
                    UnbindSubscription(CreatePurchDimValueFR);
                    UnbindSubscription(CreateVendorFR);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustPostingGrpFR);
                    UnbindSubscription(CreateReminderLevelFR);
                    UnbindSubscription(CreateCustomerFR);
                    UnbindSubscription(CreateSalesDimValueFR);
                    UnbindSubscription(CreateShiptoAddressFR);
                end;
        end;
    end;
}