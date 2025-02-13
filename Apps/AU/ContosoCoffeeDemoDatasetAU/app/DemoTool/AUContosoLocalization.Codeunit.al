codeunit 17131 "AU Contoso Localization"
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
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                FixedAssetModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::CRM:
                CRMModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                HumanResourcesModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create AU Industry Group");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create AU Territory");
        end;
    end;

    local procedure HumanResourcesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group AU");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create AU Employee");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create AU Inv Posting Group");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU Inv Posting Setup");
                    Codeunit.Run(Codeunit::"Create AU Item Template");
                end;

        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create AU FA Posting Group");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU County");
                    Codeunit.Run(Codeunit::"Create AU Post Code");
                    Codeunit.Run(Codeunit::"Create AU Company Information");
                    Codeunit.Run(Codeunit::"Create AU No. Series");
                    Codeunit.Run(Codeunit::"Create AU Shipping Agent");
                    Codeunit.Run(Codeunit::"Create AU Source Code");
                    Codeunit.Run(Codeunit::"Create AU Source Code Setup");
                    Codeunit.Run(Codeunit::"Create AU Data Exchange");
                end;
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU Purch Payable Setup");
                    Codeunit.Run(Codeunit::"Create AU Vend Posting Group");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create AU Purchase Document");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU Sales Recv Setup");
                    Codeunit.Run(Codeunit::"Create AU Cust Posting Group");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create AU Sales Document");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateAUPostingGroups: Codeunit "Create AU Posting Groups";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateAUVATPostingGroups: Codeunit "Create AU VAT Posting Groups";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create AU VAT Posting Groups");
                    Codeunit.Run(Codeunit::"Create AU Posting Groups");
                    CreateAUGLAccounts.AddCategoriesToMiniGLAccounts();

                    CreateAUPostingGroups.UpdateGenPostingSetup();
                    CreateAUVATPostingGroups.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create AU Gen. Journ. Template");
                    Codeunit.Run(Codeunit::"Create AU Gen. Journal Batch");
                    Codeunit.Run(Codeunit::"Create AU Acc Schedule Name");
                    Codeunit.Run(Codeunit::"Create AU Column Layout Name");
                    Codeunit.Run(Codeunit::"Create AU WHT Revenue Type");
                    Codeunit.Run(Codeunit::"Create AU WHT Posting Setup");
                    Codeunit.Run(Codeunit::"Create BAS XML ID AU");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create AU Column Layout");
                    Codeunit.Run(Codeunit::"Create AU Financial Report");
                    Codeunit.Run(Codeunit::"Create AU VAT Statement");
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate AU");
                    Codeunit.Run(Codeunit::"Create VAT Setup Post.Grp. AU");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create AU Bank Acc Posting Grp");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create AU Gen. Journal Line");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateAUInvPostingSetup: Codeunit "Create AU Inv Posting Setup";
        CreateAUBankAccPostingGrp: Codeunit "Create AU Bank Acc Posting Grp";
        CreateAUPaymentMethod: Codeunit "Create AU Payment Method";
        CreateAUBankAccount: Codeunit "Create AU Bank Account";
        CreateAUVendor: Codeunit "Create AU Vendor";
        CreateAUCustomer: Codeunit "Create AU Customer";
        CreateAUEmployee: Codeunit "Create AU Employee";
        CreateAUCountryRegion: Codeunit "Create AU Country Region";
        CreateAUPaymentTerms: Codeunit "Create AU Payment Terms";
        CreateAUShippingAgent: Codeunit "Create AU Shipping Agent";
        CreateAUItem: Codeunit "Create AU Item";
        CreateAUItemCharge: Codeunit "Create AU Item Charge";
        CreateAULocation: Codeunit "Create AU Location";
        CreateAUCustomerTemplate: Codeunit "Create AU Customer Template";
        CreateAUShipToAddress: Codeunit "Create AU Ship-To Address";
        CreateAUFAPostingGroup: Codeunit "Create AU FA Posting Group";
        CreateAUResource: Codeunit "Create AU Resource";
        CreateAUAccScheduleLine: Codeunit "Create AU Acc. Schedule Line";
        CreateAUGenJournalBatch: Codeunit "Create AU Gen. Journal Batch";
        CreateAUJobPostingGroup: Codeunit "Create AU Job Posting Group";
        CreateAUCustPostingGroup: Codeunit "Create AU Cust Posting Group";
        CreateAUCurrency: Codeunit "Create AU Currency";
        CreateReminderLevelAU: Codeunit "Create Reminder Level AU";
        CreateSalesDimValueAU: Codeunit "Create Sales Dim Value AU";
        CreatePurchDimValueAU: Codeunit "Create Purch. Dim. Value AU";
        CreateCurrencyExRateAU: Codeunit "Create Currency Ex. Rate AU";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    BindSubscription(CreateAUCountryRegion);
                    BindSubscription(CreateAUPaymentTerms);
                    BindSubscription(CreateAUShippingAgent);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateAUResource);
                    BindSubscription(CreateAUAccScheduleLine);
                    BindSubscription(CreateAUGenJournalBatch);
                    BindSubscription(CreateAUCurrency);
                    BindSubscription(CreateCurrencyExRateAU);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateAULocation);
                    BindSubscription(CreateAUInvPostingSetup);
                    BindSubscription(CreateAUItem);
                    BindSubscription(CreateAUItemCharge);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateAUBankAccPostingGrp);
                    BindSubscription(CreateAUPaymentMethod);
                    BindSubscription(CreateAUBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreatePurchDimValueAU);
                    BindSubscription(CreateAUVendor);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateAUCustPostingGroup);
                    BindSubscription(CreateAUCustomer);
                    BindSubscription(CreateAUCustomerTemplate);
                    BindSubscription(CreateAUShipToAddress);
                    BindSubscription(CreateReminderLevelAU);
                    BindSubscription(CreateSalesDimValueAU);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateAUEmployee);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateAUFAPostingGroup);
            Enum::"Contoso Demo Data Module"::"Job Module":
                BindSubscription(CreateAUJobPostingGroup);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateAUInvPostingSetup: Codeunit "Create AU Inv Posting Setup";
        CreateAUBankAccPostingGrp: Codeunit "Create AU Bank Acc Posting Grp";
        CreateAUPaymentMethod: Codeunit "Create AU Payment Method";
        CreateAUBankAccount: Codeunit "Create AU Bank Account";
        CreateAUVendor: Codeunit "Create AU Vendor";
        CreateAUCustomer: Codeunit "Create AU Customer";
        CreateAUEmployee: Codeunit "Create AU Employee";
        CreateAUCountryRegion: Codeunit "Create AU Country Region";
        CreateAUPaymentTerms: Codeunit "Create AU Payment Terms";
        CreateAUShippingAgent: Codeunit "Create AU Shipping Agent";
        CreateAUItemCharge: Codeunit "Create AU Item Charge";
        CreateAUItem: Codeunit "Create AU Item";
        CreateAULocation: Codeunit "Create AU Location";
        CreateAUCustomerTemplate: Codeunit "Create AU Customer Template";
        CreateAUShipToAddress: Codeunit "Create AU Ship-To Address";
        CreateAUFAPostingGroup: Codeunit "Create AU FA Posting Group";
        CreateAUResource: Codeunit "Create AU Resource";
        CreateAUGenJournalBatch: Codeunit "Create AU Gen. Journal Batch";
        CreateAUAccScheduleLine: Codeunit "Create AU Acc. Schedule Line";
        CreateAUJobPostingGroup: Codeunit "Create AU Job Posting Group";
        CreateAUCustPostingGroup: Codeunit "Create AU Cust Posting Group";
        CreateAUCurrency: Codeunit "Create AU Currency";
        CreateReminderLevelAU: Codeunit "Create Reminder Level AU";
        CreateSalesDimValueAU: Codeunit "Create Sales Dim Value AU";
        CreatePurchDimValueAU: Codeunit "Create Purch. Dim. Value AU";
        CreateCurrencyExRateAU: Codeunit "Create Currency Ex. Rate AU";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    UnbindSubscription(CreateAUCountryRegion);
                    UnbindSubscription(CreateAUPaymentTerms);
                    UnbindSubscription(CreateAUShippingAgent);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateAUBankAccPostingGrp);
                    UnbindSubscription(CreateAUPaymentMethod);
                    UnbindSubscription(CreateAUBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateAUInvPostingSetup);
                    UnbindSubscription(CreateAUItem);
                    UnbindSubscription(CreateAUItemCharge);
                    UnbindSubscription(CreateAULocation);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreatePurchDimValueAU);
                    UnbindSubscription(CreateAUVendor);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateAUCustPostingGroup);
                    UnbindSubscription(CreateAUCustomer);
                    UnbindSubscription(CreateAUCustomerTemplate);
                    UnbindSubscription(CreateAUShipToAddress);
                    UnbindSubscription(CreateReminderLevelAU);
                    UnbindSubscription(CreateSalesDimValueAU)
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateAUEmployee);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateAUFAPostingGroup);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateAUResource);
                    UnbindSubscription(CreateAUAccScheduleLine);
                    UnbindSubscription(CreateAUGenJournalBatch);
                    UnbindSubscription(CreateAUCurrency);
                    UnbindSubscription(CreateCurrencyExRateAU);
                end;
            Enum::"Contoso Demo Data Module"::"Job Module":
                UnbindSubscription(CreateAUJobPostingGroup);
        end;
    end;
}
