codeunit 10824 "ES Contoso Localization"
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
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                FixedAssetModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Inventory:
                InventoryModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::CRM:
                CRMModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Bank:
                BankModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create ES Payment Method");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create ES Bank Acc. Reco.");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create ES Cust Bank Account");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create ES Sales Document");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create ES Vendor Posting Group");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create ES Vendor Bank Account");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create ES Purchase Document");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create ES Territory");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create ES Inv Posting Setup");
                    Codeunit.Run(Codeunit::"Create ES Item Template");
                    Codeunit.Run(Codeunit::"Create ES Location");
                end;
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create ES FA Posting Group");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create ES Company Information");
                    Codeunit.Run(Codeunit::"Create ES No. Series");
                    Codeunit.Run(Codeunit::"Create ES Area");
                    Codeunit.Run(Codeunit::"Create ES Payment Terms");
                    Codeunit.Run(Codeunit::"Create ES Post Code");
                    Codeunit.Run(Codeunit::"Create ES Installment");
                    Codeunit.Run(Codeunit::"Create ES Source Code");
                    Codeunit.Run(Codeunit::"Create ES Source Code Setup");
                    Codeunit.Run(Codeunit::"Create ES VAT Posting Groups");
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateESVATPostingGroups: Codeunit "Create ES VAT Posting Groups";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create ES Posting Groups");
                    CreateESVATPostingGroups.InsertVATPostingSetupWithGLAccounts();
                    Codeunit.Run(Codeunit::"Create ES Acc Schedule Name");
                    Codeunit.Run(Codeunit::"Create ES Column Layout Name");
                    Codeunit.Run(Codeunit::"Create ES General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create ES Currency");
                    Codeunit.Run(Codeunit::"Create ES Vat Setup Post Grp");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create ES Column Layout");
                    Codeunit.Run(Codeunit::"Create ES Financial Report");
                    Codeunit.Run(Codeunit::"Create ES VAT Statement Name");
                    Codeunit.Run(Codeunit::"Create ES VAT Statement Line");
                    Codeunit.Run(Codeunit::"Create ES Currency Exch");
                    Codeunit.Run(Codeunit::"Create ES Vat Reg. No. Format");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateESBankAccPostingGrp: Codeunit "Create ES Bank Acc. PostingGrp";
        CreateESBankAccount: Codeunit "Create ES Bank Account";
        CreateESVendor: Codeunit "Create ES Vendor";
        CreateESCustomer: Codeunit "Create ES Customer";
        CreateESCountryRegion: Codeunit "Create ES Country Region";
        CreateESPaymentTerms: Codeunit "Create ES Payment Terms";
        CreateESItem: Codeunit "Create ES Item";
        CreateESItemCharge: Codeunit "Create ES Item Charge";
        CreateESLocation: Codeunit "Create ES Location";
        CreateESCustomerTemplate: Codeunit "Create ES Cust Template";
        CreateESShipToAddress: Codeunit "Create ES Ship-To Address";
        CreateESFAPostingGroup: Codeunit "Create ES FA Posting Group";
        CreateESResource: Codeunit "Create ES Resource";
        CreateESCustPostingGroup: Codeunit "Create ES Cust Posting Group";
        CreateESAnalysisView: Codeunit "Create ES Analysis View";
        CreateESPostingGroups: Codeunit "Create ES Posting Groups";
        CreateESEmployee: Codeunit "Create ES Employee";
        CreateESEmployeeTemplate: Codeunit "Create ES Employee Template";
        CreateESBankAccReco: Codeunit "Create ES Bank Acc. Reco.";
        CreateESAccScheduleLine: Codeunit "Create ES Acc. Schedule Line";
        CreateESFinancialReport: Codeunit "Create ES Financial Report";
        CreateESReminderLevel: Codeunit "Create ES Reminder Level";
        CreateESCurrencyExch: Codeunit "Create ES Currency Exch";
        CreateESPurchDimValue: Codeunit "Create ES Purch. Dim. Value";
        CreateESSalesDimValue: Codeunit "Create ES Sales Dim Value";
        CreateESVatRegNoFormat: Codeunit "Create ES Vat Reg. No. Format";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    BindSubscription(CreateESCountryRegion);
                    BindSubscription(CreateESPaymentTerms);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateESResource);
                    BindSubscription(CreateESAnalysisView);
                    BindSubscription(CreateESAccScheduleLine);
                    BindSubscription(CreateESPostingGroups);
                    BindSubscription(CreateESFinancialReport);
                    BindSubscription(CreateESCurrencyExch);
                    BindSubscription(CreateESVatRegNoFormat);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateESLocation);
                    BindSubscription(CreateESItem);
                    BindSubscription(CreateESItemCharge);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateESBankAccPostingGrp);
                    BindSubscription(CreateESBankAccount);
                    BindSubscription(CreateESBankAccReco);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateESVendor);
                    BindSubscription(CreateESPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateESCustPostingGroup);
                    BindSubscription(CreateESCustomer);
                    BindSubscription(CreateESSalesDimValue);
                    BindSubscription(CreateESCustomerTemplate);
                    BindSubscription(CreateESShipToAddress);
                    BindSubscription(CreateESReminderLevel);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateESFAPostingGroup);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                begin
                    BindSubscription(CreateESEmployee);
                    BindSubscription(CreateESEmployeeTemplate);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateESBankAccPostingGrp: Codeunit "Create ES Bank Acc. PostingGrp";
        CreateESBankAccount: Codeunit "Create ES Bank Account";
        CreateESVendor: Codeunit "Create ES Vendor";
        CreateESCustomer: Codeunit "Create ES Customer";
        CreateESCountryRegion: Codeunit "Create ES Country Region";
        CreateESPaymentTerms: Codeunit "Create ES Payment Terms";
        CreateESItemCharge: Codeunit "Create ES Item Charge";
        CreateESItem: Codeunit "Create ES Item";
        CreateESLocation: Codeunit "Create ES Location";
        CreateESCustomerTemplate: Codeunit "Create ES Cust Template";
        CreateESShipToAddress: Codeunit "Create ES Ship-To Address";
        CreateESFAPostingGroup: Codeunit "Create ES FA Posting Group";
        CreateESResource: Codeunit "Create ES Resource";
        CreateESCustPostingGroup: Codeunit "Create ES Cust Posting Group";
        CreateESAnalysisView: Codeunit "Create ES Analysis View";
        CreateESPostingGroups: Codeunit "Create ES Posting Groups";
        CreateESEmployee: Codeunit "Create ES Employee";
        CreateESEmployeeTemplate: Codeunit "Create ES Employee Template";
        CreateESBankAccReco: Codeunit "Create ES Bank Acc. Reco.";
        CreateESAccScheduleLine: Codeunit "Create ES Acc. Schedule Line";
        CreateESFinancialReport: Codeunit "Create ES Financial Report";
        CreateESReminderLevel: Codeunit "Create ES Reminder Level";
        CreateESCurrencyExch: Codeunit "Create ES Currency Exch";
        CreateESPurchDimValue: Codeunit "Create ES Purch. Dim. Value";
        CreateESSalesDimValue: Codeunit "Create ES Sales Dim Value";
        CreateESVatRegNoFormat: Codeunit "Create ES Vat Reg. No. Format";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                begin
                    UnbindSubscription(CreateESCountryRegion);
                    UnbindSubscription(CreateESPaymentTerms);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateESBankAccPostingGrp);
                    UnbindSubscription(CreateESBankAccount);
                    UnbindSubscription(CreateESBankAccReco);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateESItem);
                    UnbindSubscription(CreateESItemCharge);
                    UnbindSubscription(CreateESLocation);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateESVendor);
                    UnbindSubscription(CreateESPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateESCustPostingGroup);
                    UnbindSubscription(CreateESCustomer);
                    UnbindSubscription(CreateESSalesDimValue);
                    UnbindSubscription(CreateESCustomerTemplate);
                    UnbindSubscription(CreateESShipToAddress);
                    UnbindSubscription(CreateESReminderLevel);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateESFAPostingGroup);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateESResource);
                    UnbindSubscription(CreateESAnalysisView);
                    UnbindSubscription(CreateESPostingGroups);
                    UnbindSubscription(CreateESAccScheduleLine);
                    UnbindSubscription(CreateESFinancialReport);
                    UnbindSubscription(CreateESCurrencyExch);
                    UnbindSubscription(CreateESVatRegNoFormat);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                begin
                    UnbindSubscription(CreateESEmployee);
                    UnbindSubscription(CreateESEmployeeTemplate);
                end;
        end;
    end;
}