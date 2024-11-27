codeunit 12251 "IT Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Information IT");
                    Codeunit.Run(Codeunit::"Create No. Series IT");
                    Codeunit.Run(Codeunit::"Create Post Code IT");
                    Codeunit.Run(Codeunit::"Create Payment Term IT");
                    Codeunit.Run(Codeunit::"Create VAT Identifier IT");
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups IT");
                    Codeunit.Run(Codeunit::"Create ABI CAB Code IT");
                    Codeunit.Run(Codeunit::"Create Source Code IT");
                    Codeunit.Run(Codeunit::"Create Source Code Setup IT");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupIT: Codeunit "Create VAT Posting Groups IT";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVatPostingGroupIT.InsertVATPostingSetup();
                    CreateVatPostingGroupIT.UpdateVATPostingSetupIT();
                    Codeunit.Run(Codeunit::"Create General Ledger Setup IT");
                    Codeunit.Run(Codeunit::"Create Currency IT");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate IT");
                    Codeunit.Run(Codeunit::"Create VAT Statement IT");
                    Codeunit.Run(Codeunit::"Create Bill Code IT");
                    Codeunit.Run(Codeunit::"Create Payment Method IT");
                end;
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Recv. Setup IT");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Sales Document IT");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup IT");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Document IT");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Marketing Setup IT");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Territory IT");
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Gen. Journal Line IT");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationIT: Codeunit "Create Location IT";
        CreateItemIT: Codeunit "Create Item IT";
        CreateBankAccountIT: Codeunit "Create Bank Account IT";
        CreateCustomerIT: Codeunit "Create Customer IT";
        CreateVendorIT: Codeunit "Create Vendor IT";
        CreateResourceIT: Codeunit "Create Resource IT";
        CreateCurrencyExchRateIT: Codeunit "Create Currency Ex. Rate IT";
        CreateVatPostingGroupsIT: Codeunit "Create Vat Posting Groups IT";
        CreateVATSetupPostingGrpIT: Codeunit "Create VATSetupPostingGrp. IT";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
        CreatePurchaseDocumentIT: Codeunit "Create Purchase Document IT";
        CreateSalesDocumentIT: Codeunit "Create Sales Document IT";
        CreateGenJournalBatchIT: Codeunit "Create Gen Journal Batch IT";
        CreateShiptoAddressIT: Codeunit "Create Ship-to Address IT";
        CreateReminderLevelIT: Codeunit "Create Reminder Level IT";
        CreateAccScheduleLineIT: Codeunit "Create Acc. Schedule Line IT";
        CreateVATStatementIT: Codeunit "Create VAT Statement IT";
        CreateGenJournalLineIT: Codeunit "Create Gen. Journal Line IT";
        CreateSalesDimValueIT: Codeunit "Create Sales Dim Value IT";
        CreatePurchDimValueIT: Codeunit "Create Purch. Dim. Value IT";
        CreateUnitOfMeasureTransIT: Codeunit "Create UnitOfMeasureTrans. IT";
        CreateCurrencyIT: Codeunit "Create Currency IT";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    BindSubscription(CreateNoSeriesIT);
                    BindSubscription(CreateUnitOfMeasureTransIT);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccountIT);
                    BindSubscription(CreateGenJournalLineIT);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemIT);
                    BindSubscription(CreateLocationIT);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerIT);
                    BindSubscription(CreateSalesDocumentIT);
                    BindSubscription(CreateShiptoAddressIT);
                    BindSubscription(CreateReminderLevelIT);
                    BindSubscription(CreateSalesDimValueIT);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorIT);
                    BindSubscription(CreatePurchaseDocumentIT);
                    BindSubscription(CreatePurchDimValueIT);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyExchRateIT);
                    BindSubscription(CreateResourceIT);
                    BindSubscription(CreateVatPostingGroupsIT);
                    BindSubscription(CreateVATSetupPostingGrpIT);
                    BindSubscription(CreateGenJournalBatchIT);
                    BindSubscription(CreateAccScheduleLineIT);
                    BindSubscription(CreateVATStatementIT);
                    BindSubscription(CreateCurrencyIT);
                end;
            Enum::"Contoso Demo Data Module"::"Warehouse Module":
                begin
                    BindSubscription(CreateSalesDocumentIT);
                    BindSubscription(CreatePurchaseDocumentIT);
                end;
            Enum::"Contoso Demo Data Module"::"Service Module":
                begin
                    BindSubscription(CreateSalesDocumentIT);
                    BindSubscription(CreatePurchaseDocumentIT);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateNoSeriesIT);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationIT: Codeunit "Create Location IT";
        CreateItemIT: Codeunit "Create Item IT";
        CreateBankAccountIT: Codeunit "Create Bank Account IT";
        CreateCustomerIT: Codeunit "Create Customer IT";
        CreateVendorIT: Codeunit "Create Vendor IT";
        CreateResourceIT: Codeunit "Create Resource IT";
        CreateCurrencyExchRateIT: Codeunit "Create Currency Ex. Rate IT";
        CreateVatPostingGroupsIT: Codeunit "Create Vat Posting Groups IT";
        CreateVATSetupPostingGrpIT: Codeunit "Create VATSetupPostingGrp. IT";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
        CreatePurchaseDocumentIT: Codeunit "Create Purchase Document IT";
        CreateSalesDocumentIT: Codeunit "Create Sales Document IT";
        CreateGenJournalBatchIT: Codeunit "Create Gen Journal Batch IT";
        CreateShiptoAddressIT: Codeunit "Create Ship-to Address IT";
        CreateReminderLevelIT: Codeunit "Create Reminder Level IT";
        CreateAccScheduleLineIT: Codeunit "Create Acc. Schedule Line IT";
        CreateVATStatementIT: Codeunit "Create VAT Statement IT";
        CreateGenJournalLineIT: Codeunit "Create Gen. Journal Line IT";
        CreateSalesDimValueIT: Codeunit "Create Sales Dim Value IT";
        CreatePurchDimValueIT: Codeunit "Create Purch. Dim. Value IT";
        CreateUnitOfMeasureTransIT: Codeunit "Create UnitOfMeasureTrans. IT";
        CreateCurrencyIT: Codeunit "Create Currency IT";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    UnbindSubscription(CreateNoSeriesIT);
                    UnbindSubscription(CreateUnitOfMeasureTransIT);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccountIT);
                    UnbindSubscription(CreateGenJournalLineIT);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateNoSeriesIT);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemIT);
                    UnbindSubscription(CreateLocationIT);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustomerIT);
                    UnbindSubscription(CreateSalesDocumentIT);
                    UnbindSubscription(CreateShiptoAddressIT);
                    UnbindSubscription(CreateReminderLevelIT);
                    UnbindSubscription(CreateSalesDimValueIT);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorIT);
                    UnbindSubscription(CreatePurchaseDocumentIT);
                    UnbindSubscription(CreatePurchDimValueIT);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateCurrencyExchRateIT);
                    UnbindSubscription(CreateResourceIT);
                    UnbindSubscription(CreateVatPostingGroupsIT);
                    UnbindSubscription(CreateVATSetupPostingGrpIT);
                    UnbindSubscription(CreateGenJournalBatchIT);
                    UnbindSubscription(CreateAccScheduleLineIT);
                    UnbindSubscription(CreateVATStatementIT);
                    UnbindSubscription(CreateCurrencyIT);
                end;
            Enum::"Contoso Demo Data Module"::"Warehouse Module":
                begin
                    UnbindSubscription(CreatePurchaseDocumentIT);
                    UnbindSubscription(CreateSalesDocumentIT);
                end;
            Enum::"Contoso Demo Data Module"::"Service Module":
                begin
                    UnbindSubscription(CreatePurchaseDocumentIT);
                    UnbindSubscription(CreateSalesDocumentIT);
                end;
        end;
    end;
}