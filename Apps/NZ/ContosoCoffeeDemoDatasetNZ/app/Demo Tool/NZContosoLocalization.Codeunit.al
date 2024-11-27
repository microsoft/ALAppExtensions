codeunit 17142 "NZ Contoso Localization"
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
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::CRM:
                CRMModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create NZ Gen. Journal Line");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create NZ Bank Acc. Reco.");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create NZ Industry Group");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create NZ Item Template");
                    Codeunit.Run(Codeunit::"Create NZ Location");
                end;
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create NZ Company Information");
                    Codeunit.Run(Codeunit::"Create NZ No. Series");
                    Codeunit.Run(Codeunit::"Create NZ County");
                    Codeunit.Run(Codeunit::"Create NZ Post Code");
                    Codeunit.Run(Codeunit::"Create NZ Shipping Agent");
                    Codeunit.Run(Codeunit::"Create NZ Source Code");
                    Codeunit.Run(Codeunit::"Create NZ Source Code Setup");
                    Codeunit.Run(Codeunit::"Create NZ VAT Posting Group");
                    Codeunit.Run(Codeunit::"Create NZ Posting Groups");
                end;
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create NZ Purch Payable Setup");
                    Codeunit.Run(Codeunit::"Create NZ Vendor Posting Group");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create NZ Purchase Document");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create NZ Sales Recv Setup");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create NZ Sales Document");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
        CreateNZGLAccounts: Codeunit "Create NZ GL Accounts";
        CreateNZPostingGroups: Codeunit "Create NZ Posting Groups";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create NZ General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create NZ GL Accounts");
                    CreateNZGLAccounts.AddCategoriesToGLAccounts();
                    CreateNZVATPostingGroup.UpdateVATPostingSetup();
                    CreateNZPostingGroups.InsertGenPostingSetup();
                    Codeunit.Run(Codeunit::"Create NZ Acc Schedule Name");
                    Codeunit.Run(Codeunit::"Create NZ VAT Setup PostingGrp");
                    Codeunit.Run(Codeunit::"Create NZ Gen. Journ. Template");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create NZ Currency Ex. Rate");
                    Codeunit.Run(Codeunit::"Create NZ Financial Report");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateNZBankAccount: Codeunit "Create NZ Bank Account";
        CreateNZVendor: Codeunit "Create NZ Vendor";
        CreateNZCustomer: Codeunit "Create NZ Customer";
        CreateNZReminderLevel: Codeunit "Create NZ Reminder Level";
        CreateNZCurrency: Codeunit "Create NZ Currency";
        CreateNZCurrencyExRate: Codeunit "Create NZ Currency Ex. Rate";
        CreateNZEmployee: Codeunit "Create NZ Employee";
        CreateNZCountryRegion: Codeunit "Create NZ Country Region";
        CreateNZPaymentTerms: Codeunit "Create NZ Payment Terms";
        CreateNZShippingAgent: Codeunit "Create NZ Shipping Agent";
        CreateNZItem: Codeunit "Create NZ Item";
        CreateNZItemCharge: Codeunit "Create NZ Item Charge";
        CreateNZLocation: Codeunit "Create NZ Location";
        CreateNZShipToAddress: Codeunit "Create NZ Ship-To Address";
        CreateNZResource: Codeunit "Create NZ Resource";
        CreateNZPostingGroups: Codeunit "Create NZ Posting Groups";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
        CreateNZAccScheduleLine: Codeunit "Create NZ Acc. Schedule Line";
        CreaateNZGenJournalBatch: Codeunit "Create NZ Gen. Journal Batch";
        CreateNZVATStatement: Codeunit "Create NZ VAT Statement";
        CreateNZSalesDimValue: Codeunit "Create NZ Sales Dim Value";
        CreateNZPurchDimValue: Codeunit "Create NZ Purch. Dim. Value";
        CreateNZVATSetupPostingGrp: Codeunit "Create NZ VAT Setup PostingGrp";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    BindSubscription(CreateNZCountryRegion);
                    BindSubscription(CreateNZPaymentTerms);
                    BindSubscription(CreateNZShippingAgent);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateNZResource);
                    BindSubscription(CreateNZPostingGroups);
                    BindSubscription(CreateNZVATPostingGroup);
                    BindSubscription(CreateNZAccScheduleLine);
                    BindSubscription(CreateNZVATStatement);
                    BindSubscription(CreateNZVATSetupPostingGrp);
                    BindSubscription(CreateNZCurrency);
                    BindSubscription(CreateNZCurrencyExRate);
                    BindSubscription(CreaateNZGenJournalBatch);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateNZLocation);
                    BindSubscription(CreateNZItem);
                    BindSubscription(CreateNZItemCharge);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                BindSubscription(CreateNZBankAccount);
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateNZVendor);
                    BindSubscription(CreateNZPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateNZCustomer);
                    BindSubscription(CreateNZSalesDimValue);
                    BindSubscription(CreateNZReminderLevel);
                    BindSubscription(CreateNZShipToAddress);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateNZEmployee);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateNZBankAccount: Codeunit "Create NZ Bank Account";
        CreateNZVendor: Codeunit "Create NZ Vendor";
        CreateNZCustomer: Codeunit "Create NZ Customer";
        CreateNZCurrencyExRate: Codeunit "Create NZ Currency Ex. Rate";
        CreateNZReminderLevel: Codeunit "Create NZ Reminder Level";
        CreateNZCurrency: Codeunit "Create NZ Currency";
        CreateNZEmployee: Codeunit "Create NZ Employee";
        CreateNZCountryRegion: Codeunit "Create NZ Country Region";
        CreateNZPaymentTerms: Codeunit "Create NZ Payment Terms";
        CreateNZShippingAgent: Codeunit "Create NZ Shipping Agent";
        CreateNZItemCharge: Codeunit "Create NZ Item Charge";
        CreateNZItem: Codeunit "Create NZ Item";
        CreateNZLocation: Codeunit "Create NZ Location";
        CreateNZShipToAddress: Codeunit "Create NZ Ship-To Address";
        CreateNZVATSetupPostingGrp: Codeunit "Create NZ VAT Setup PostingGrp";
        CreateNZResource: Codeunit "Create NZ Resource";
        CreateNZPostingGroups: Codeunit "Create NZ Posting Groups";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
        CreateNZAccScheduleLine: Codeunit "Create NZ Acc. Schedule Line";
        CreateNZVATStatement: Codeunit "Create NZ VAT Statement";
        CreaateNZGenJournalBatch: Codeunit "Create NZ Gen. Journal Batch";
        CreateNZSalesDimValue: Codeunit "Create NZ Sales Dim Value";
        CreateNZPurchDimValue: Codeunit "Create NZ Purch. Dim. Value";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    UnbindSubscription(CreateNZCountryRegion);
                    UnbindSubscription(CreateNZPaymentTerms);
                    UnbindSubscription(CreateNZShippingAgent);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                UnbindSubscription(CreateNZBankAccount);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateNZItem);
                    UnbindSubscription(CreateNZItemCharge);
                    UnbindSubscription(CreateNZLocation);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateNZVendor);
                    UnbindSubscription(CreateNZPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateNZCustomer);
                    UnbindSubscription(CreateNZSalesDimValue);
                    UnbindSubscription(CreateNZReminderLevel);
                    UnbindSubscription(CreateNZShipToAddress);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateNZEmployee);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateNZResource);
                    UnbindSubscription(CreateNZPostingGroups);
                    UnbindSubscription(CreateNZVATPostingGroup);
                    UnbindSubscription(CreateNZAccScheduleLine);
                    UnbindSubscription(CreateNZVATSetupPostingGrp);
                    UnbindSubscription(CreateNZVATStatement);
                    UnbindSubscription(CreateNZCurrency);
                    UnbindSubscription(CreateNZCurrencyExRate);
                    UnbindSubscription(CreaateNZGenJournalBatch);
                end;
        end;
    end;
}