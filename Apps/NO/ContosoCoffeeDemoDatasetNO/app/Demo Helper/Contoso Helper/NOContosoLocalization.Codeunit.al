codeunit 10669 "NO Contoso Localization"
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
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Post Code NO");
                    Codeunit.Run(Codeunit::"Create Company Information NO");
                    Codeunit.Run(Codeunit::"Create Vat Posting Groups NO");
                    Codeunit.Run(Codeunit::"Create Posting Groups NO");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
        CreatePostingGroupsNO: Codeunit "Create Posting Groups NO";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create General Ledger Setup NO");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    CreateVatPostingGroupsNO.InsertVATPostingSetup();
                    CreatePostingGroupsNO.UpdateGenPostingSetup();
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate NO");
                    Codeunit.Run(Codeunit::"Create VAT Setup Post Grp. NO");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line NO");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Rec. Setup NO");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Item Template NO");
                    Codeunit.Run(Codeunit::"Create Location NO");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateItemNO: Codeunit "Create Item NO";
        CreateCurrencyNO: Codeunit "Create Currency NO";
        CreateCurrencyExchRateNO: Codeunit "Create Currency Ex. Rate NO";
        CreatePurchDimValueNO: Codeunit "Create Purch. Dim. Value NO";
        CreateSalesDimValueNO: Codeunit "Create Sales Dim Value NO";
        CreateGenJournalLineNO: Codeunit "Create Gen. Journal Line NO";
        CreateLocationNO: Codeunit "Create Location NO";
        CreateResourceNO: Codeunit "Create Resource NO";
        CreateCustomerNO: Codeunit "Create Customer NO";
        CreateReminderLevelNO: Codeunit "Create Reminder Level NO";
        CreateVendorNO: Codeunit "Create Vendor NO";
        CreateCustPostingGrpNO: Codeunit "Create Cust. Posting Grp NO";
        CreateVendorPostingGroupNO: Codeunit "Create Vendor Posting Group NO";
        CreateShiptoAddressNO: Codeunit "Create Ship-to Address NO";
        CreateBankAccountNO: Codeunit "Create Bank Account NO";
        CreateItemChargeNO: Codeunit "Create Item Charge NO";
        CreateCustomerTemplateNO: Codeunit "Create Customer Template NO";
        CreateVendorTemplateNO: Codeunit "Create Vendor Template NO";
        CreateAccScheduleLineNO: Codeunit "Create Acc. Schedule Line NO";
        CreateFADepreciationBookNO: Codeunit "Create FA Depreciation Book NO";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateLocationNO);
                    BindSubscription(CreateItemNO);
                    BindSubscription(CreateItemChargeNO);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyNO);
                    BindSubscription(CreateCurrencyExchRateNO);
                    BindSubscription(CreateResourceNO);
                    BindSubscription(CreateAccScheduleLineNO);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreatePurchDimValueNO);
                    BindSubscription(CreateVendorNO);
                    BindSubscription(CreateVendorPostingGroupNO);
                    BindSubscription(CreateVendorTemplateNO);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateSalesDimValueNO);
                    BindSubscription(CreateCustomerNO);
                    BindSubscription(CreateReminderLevelNO);
                    BindSubscription(CreateCustPostingGrpNO);
                    BindSubscription(CreateShiptoAddressNO);
                    BindSubscription(CreateCustomerTemplateNO);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccountNO);
                    BindSubscription(CreateGenJournalLineNO);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFADepreciationBookNO);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateItemNO: Codeunit "Create Item NO";
        CreateCurrencyNO: Codeunit "Create Currency NO";
        CreateCurrencyExchRateNO: Codeunit "Create Currency Ex. Rate NO";
        CreatePurchDimValueNO: Codeunit "Create Purch. Dim. Value NO";
        CreateSalesDimValueNO: Codeunit "Create Sales Dim Value NO";
        CreateGenJournalLineNO: Codeunit "Create Gen. Journal Line NO";
        CreateLocationNO: Codeunit "Create Location NO";
        CreateResourceNO: Codeunit "Create Resource NO";
        CreateCustomerNO: Codeunit "Create Customer NO";
        CreateReminderLevelNO: Codeunit "Create Reminder Level NO";
        CreateVendorNO: Codeunit "Create Vendor NO";
        CreateCustPostingGrpNO: Codeunit "Create Cust. Posting Grp NO";
        CreateVendorPostingGroupNO: Codeunit "Create Vendor Posting Group NO";
        CreateShiptoAddressNO: Codeunit "Create Ship-to Address NO";
        CreateBankAccountNO: Codeunit "Create Bank Account NO";
        CreateItemChargeNO: Codeunit "Create Item Charge NO";
        CreateCustomerTemplateNO: Codeunit "Create Customer Template NO";
        CreateVendorTemplateNO: Codeunit "Create Vendor Template NO";
        CreateAccScheduleLineNO: Codeunit "Create Acc. Schedule Line NO";
        CreateFADepreciationBookNO: Codeunit "Create FA Depreciation Book NO";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateLocationNO);
                    UnBindSubscription(CreateItemNO);
                    UnbindSubscription(CreateItemChargeNO);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreateCurrencyNO);
                    UnBindSubscription(CreateCurrencyExchRateNO);
                    UnbindSubscription(CreateResourceNO);
                    UnbindSubscription(CreateAccScheduleLineNO);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreatePurchDimValueNO);
                    UnbindSubscription(CreateVendorNO);
                    UnbindSubscription(CreateVendorPostingGroupNO);
                    UnbindSubscription(CreateVendorTemplateNO);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateSalesDimValueNO);
                    UnbindSubscription(CreateCustomerNO);
                    UnbindSubscription(CreateReminderLevelNO);
                    UnbindSubscription(CreateCustPostingGrpNO);
                    UnbindSubscription(CreateShiptoAddressNO);
                    UnbindSubscription(CreateCustomerTemplateNO);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccountNO);
                    UnbindSubscription(CreateGenJournalLineNO);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFADepreciationBookNO);
        end;
    end;
}