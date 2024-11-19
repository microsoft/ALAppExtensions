codeunit 27054 "CA Contoso Localization"
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
            Enum::"Contoso Demo Data Module"::CRM:
                CRMModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                HumanResourcesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Company Information");
                    Codeunit.Run(Codeunit::"Create CA Post Code");
                    Codeunit.Run(Codeunit::"Create CA CountryRegion Trans.");
                    Codeunit.Run(Codeunit::"Create CA Payment Term Trans.");
                    Codeunit.Run(Codeunit::"Create CA Data Exchange");
                    Codeunit.Run(Codeunit::"Create CA UnitOfMeasureTrans.");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
        CreateCAVatPostingGroup: Codeunit "Create CA Vat Posting Group";
        CreateCAPostingGroup: Codeunit "Create CA Posting Group";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create CA Posting Group");
                    CreateCAVatPostingGroup.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create CA Acc. Schedule Line");
                    Codeunit.Run(Codeunit::"Create CA Column Layout Name");
                    CreateCAGLAccounts.AddCategoriesToGLAccountsForMini();
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Column Layout");
                    Codeunit.Run(Codeunit::"Create CA Tax Group");
                    Codeunit.Run(Codeunit::"Create CA Tax Jurisdiction");
                    Codeunit.Run(Codeunit::"Create CA Tax Jurisd. Transl.");
                    Codeunit.Run(Codeunit::"Create CA Tax Setup");
                    Codeunit.Run(Codeunit::"Create CA Tax Area");
                    Codeunit.Run(Codeunit::"Create CA Tax Area Line");
                    Codeunit.Run(Codeunit::"Create CA Tax Detail");
                    CreateCATaxGroup.UpdateTaxGroupOnGL();
                    CreateCAPostingGroup.UpdateGenPostingSetup();
                    Codeunit.Run(Codeunit::"Create CA GIFI Code");
                end;
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create CA Sales Recv. Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Sales Dim. Value");
                    Codeunit.Run(Codeunit::"Create CA Ship-to Address");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create CA Sales Document");
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Pay. Method Trans.");
                    Codeunit.Run(Codeunit::"Create CA Bank Acc Posting Grp");
                    Codeunit.Run(Codeunit::"Create CA Bank Exp/Imp Setup");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create CA Gen. Journal Line");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create CA Bank Acc. Reco.")
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Marketing Setup");
                    Codeunit.Run(Codeunit::"Create CA Word Template");
                end;
        end;
    end;

    local procedure HumanResourcesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create CA Employee");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create CA Inv. Posting Group");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create CA Inv. Posting Setup");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CA Purch. Payable Setup");
                    Codeunit.Run(Codeunit::"Create CA Vendor Posting Group");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create CA Purchase Line");
        end;
    end;

    // Bind subscription for localization events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateCANoSeriesLine: Codeunit "Create CA No. Series Line";
        CreateCAGenJournalTemplate: Codeunit "Create CA Gen Journal Template";
        CreateCACurrency: Codeunit "Create CA Currency";
        CreateCACurrExchRate: Codeunit "Create CA Curr. Exch. Rate";
        CreateCAAccScheduleLine: Codeunit "Create CA Acc. Schedule Line";
        CreateCAColumnLayout: Codeunit "Create CA Column Layout";
        CreateCAResource: Codeunit "Create CA Resource";
        CreateCABankAccount: Codeunit "Create CA Bank Account";
        CreateCAItemJnlTemplate: Codeunit "Create CA Item Jnl. Template";
        CreateCAItem: Codeunit "Create CA Item";
        CreateCAInvPostingSetup: Codeunit "Create CA Inv. Posting Setup";
        CreateCAItemCharge: Codeunit "Create CA Item Charge";
        CreateCALocation: Codeunit "Create CA Location";
        CreateCAPurchDimValue: Codeunit "Create CA Purch. Dim. Value";
        CreateCAVendor: Codeunit "Create CA Vendor";
        CreateCAReminderLevel: Codeunit "Create CA Reminder Level";
        CreateCACustomer: Codeunit "Create CA Customer";
        CreateCACustBankAccount: Codeunit "Create CA Cust. Bank Account";
        CreateCAVendBankAccount: Codeunit "Create CA Vend. Bank Account";
        CreateCASalesDimValue: Codeunit "Create CA Sales Dim. Value";
        CreateCACustomerTempl: Codeunit "Create CA Customer Templ.";
        CreateCAVendorTempl: Codeunit "Create CA Vendor Templ.";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                BindSubscription(CreateCANoSeriesLine);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCAGenJournalTemplate);
                    BindSubscription(CreateCACurrency);
                    BindSubscription(CreateCACurrExchRate);
                    BindSubscription(CreateCAAccScheduleLine);
                    BindSubscription(CreateCAColumnLayout);
                    BindSubscription(CreateCAResource);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCAReminderLevel);
                    BindSubscription(CreateCACustomer);
                    BindSubscription(CreateCACustBankAccount);
                    BindSubscription(CreateCASalesDimValue);
                    BindSubscription(CreateCACustomerTempl);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                BindSubscription(CreateCABankAccount);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateCAItemJnlTemplate);
                    BindSubscription(CreateCAItem);
                    BindSubscription(CreateCAItemCharge);
                    BindSubscription(CreateCALocation);
                    BindSubscription(CreateCAInvPostingSetup);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateCAVendor);
                    BindSubscription(CreateCAVendBankAccount);
                    BindSubscription(CreateCAPurchDimValue);
                    BindSubscription(CreateCAVendorTempl);
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateCANoSeriesLine: Codeunit "Create CA No. Series Line";
        CreateCAGenJournalTemplate: Codeunit "Create CA Gen Journal Template";
        CreateCACurrency: Codeunit "Create CA Currency";
        CreateCACurrExchRate: Codeunit "Create CA Curr. Exch. Rate";
        CreateCAAccScheduleLine: Codeunit "Create CA Acc. Schedule Line";
        CreateCAColumnLayout: Codeunit "Create CA Column Layout";
        CreateCAResource: Codeunit "Create CA Resource";
        CreateCABankAccount: Codeunit "Create CA Bank Account";
        CreateCAItemJnlTemplate: Codeunit "Create CA Item Jnl. Template";
        CreateCAItem: Codeunit "Create CA Item";
        CreateCAItemCharge: Codeunit "Create CA Item Charge";
        CreateCAInvPostingSetup: Codeunit "Create CA Inv. Posting Setup";
        CreateCALocation: Codeunit "Create CA Location";
        CreateCAPurchDimValue: Codeunit "Create CA Purch. Dim. Value";
        CreateCAVendor: Codeunit "Create CA Vendor";
        CreateCAReminderLevel: Codeunit "Create CA Reminder Level";
        CreateCACustomer: Codeunit "Create CA Customer";
        CreateCACustBankAccount: Codeunit "Create CA Cust. Bank Account";
        CreateCAVendBankAccount: Codeunit "Create CA Vend. Bank Account";
        CreateCASalesDimValue: Codeunit "Create CA Sales Dim. Value";
        CreateCACustomerTempl: Codeunit "Create CA Customer Templ.";
        CreateCAVendorTempl: Codeunit "Create CA Vendor Templ.";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                UnBindSubscription(CreateCANoSeriesLine);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreateCAGenJournalTemplate);
                    UnbindSubscription(CreateCACurrency);
                    UnbindSubscription(CreateCACurrExchRate);
                    UnbindSubscription(CreateCAAccScheduleLine);
                    UnbindSubscription(CreateCAColumnLayout);
                    UnBindSubscription(CreateCAResource);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnBindSubscription(CreateCAReminderLevel);
                    UnBindSubscription(CreateCACustomer);
                    UnbindSubscription(CreateCACustBankAccount);
                    UnBindSubscription(CreateCASalesDimValue);
                    UnbindSubscription(CreateCACustomerTempl);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                UnBindSubscription(CreateCABankAccount);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnBindSubscription(CreateCAItemJnlTemplate);
                    UnBindSubscription(CreateCAItem);
                    UnBindSubscription(CreateCAItemCharge);
                    UnBindSubscription(CreateCALocation);
                    UnbindSubscription(CreateCAInvPostingSetup);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnBindSubscription(CreateCAVendor);
                    UnbindSubscription(CreateCAVendBankAccount);
                    UnBindSubscription(CreateCAPurchDimValue);
                    UnbindSubscription(CreateCAVendorTempl);
                end;
        end;
    end;
}