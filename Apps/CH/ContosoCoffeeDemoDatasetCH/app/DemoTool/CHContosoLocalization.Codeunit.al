codeunit 11620 "CH Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationVATPostingSetup(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResource(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create CH Word Templates");
        end;
    end;

    local procedure HumanResource(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create CH Employee");
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CH Payment Method");
                    Codeunit.Run(Codeunit::"Create CH ESR Setup");
                    Codeunit.Run(Codeunit::"Create CH LSV Setup");
                    Codeunit.Run(Codeunit::"Create CH Bank Ex/Import");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create CH Gen. Journal Line");
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create CH Bank Acc. Rec.");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CH No. Series");
                    Codeunit.Run(Codeunit::"Create CH Post Code");
                    Codeunit.Run(Codeunit::"Create CH Company Information");
                    Codeunit.Run(Codeunit::"Create CH Data Exchange");
                end;
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create CH Item Template");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create CH Purch. Payable Setup");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create CH Sales Recev. Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create CH Cust. Bank Account");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create CH General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create CH GL Accounts");
                    CreateCHGLAccounts.AddCategoriesToGLAccounts();
                    Codeunit.Run(Codeunit::"Create CH Posting Groups");
                    Codeunit.Run(Codeunit::"Create CH VAT Posting Groups");
                    Codeunit.Run(Codeunit::"Create CH Acc. Schedule Name");
                    Codeunit.Run(Codeunit::"Create CH Column Layout Name");
                    Codeunit.Run(Codeunit::"Create CH VAT Cipher");
                    Codeunit.Run(Codeunit::"Create CH VAT Setup Post. Grp.");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create CH Currency Ex. Rate");
                    Codeunit.Run(Codeunit::"Create CH Column Layout");
                    Codeunit.Run(Codeunit::"Create CH Financial Report");
                    Codeunit.Run(Codeunit::"Create CH VAT Reg. No. Format");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCHAccScheduleLine: Codeunit "Create CH Acc Schedule Line";
        CreateCHColumnLayout: Codeunit "Create CH Column Layout";
        CreateCHVATPostingGroups: Codeunit "Create CH VAT Posting Groups";
        CreateCHVATStatement: Codeunit "Create CH VAT Statement";
        CreateCHCurrency: Codeunit "Create CH Currency";
        CreateCHCurrencyExRate: Codeunit "Create CH Currency Ex. Rate";
        CreateCHPurchDimValue: Codeunit "Create CH Purch. Dim. Value";
        CreateCHSalesDimValue: Codeunit "Create CH Sales Dim. Value";
        CreateCHBankAccPostingGrp: Codeunit "Create CH Bank Acc Posting Grp";
        CreateCHBankAccount: Codeunit "Create CH Bank Account";
        CreateCHFACHpreciation: Codeunit "Create CH FA Depreciation Book";
        CreateCHFAPostingGrp: Codeunit "Create CH FA Posting Grp.";
        CreateCHInvPostingSetup: Codeunit "Create CH Inv. Posting Setup";
        CreateCHItem: Codeunit "Create CH Item";
        CreateCHItemCharge: Codeunit "Create CH Item Charge";
        CreateCHLocation: Codeunit "Create CH Location";
        CreateCHResource: Codeunit "Create CH Resource";
        CreatCHVendorPostingGrp: Codeunit "Create CH Vendor Posting Grp";
        CreateCHVendor: Codeunit "Create CH Vendor";
        CreateCHCustPostingGrp: Codeunit "Create CH Cust. Posting Grp";
        CreateCHReminderLevel: Codeunit "Create CH Reminder Level";
        CreateCHCustomer: Codeunit "Create CH Customer";
        CreateCHCustBankAccount: Codeunit "Create CH Cust. Bank Account";
        CreateCHShipToAddress: Codeunit "Create CH Ship-to Address";
        CreateCHEmployeeTemplate: Codeunit "Create CH Employee Template";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateCHEmployeeTemplate);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCHAccScheduleLine);
                    BindSubscription(CreateCHColumnLayout);
                    BindSubscription(CreateCHCurrency);
                    BindSubscription(CreateCHCurrencyExRate);
                    BindSubscription(CreateCHVATPostingGroups);
                    BindSubscription(CreateCHResource);
                    BindSubscription(CreateCHVATStatement);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    Codeunit.Run(Codeunit::"Create CH Bank Directory");
                    BindSubscription(CreateCHBankAccPostingGrp);
                    BindSubscription(CreateCHBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateCHFACHpreciation);
                    BindSubscription(CreateCHFAPostingGrp);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateCHInvPostingSetup);
                    BindSubscription(CreateCHItem);
                    BindSubscription(CreateCHItemCharge);
                    BindSubscription(CreateCHLocation);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreatCHVendorPostingGrp);
                    BindSubscription(CreateCHVendor);
                    BindSubscription(CreateCHPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCHCustPostingGrp);
                    BindSubscription(CreateCHReminderLevel);
                    BindSubscription(CreateCHCustomer);
                    BindSubscription(CreateCHShipToAddress);
                    BindSubscription(CreateCHSalesDimValue);
                    BindSubscription(CreateCHCustBankAccount);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCHAccScheduleLine: Codeunit "Create CH Acc Schedule Line";
        CreateCHColumnLayout: Codeunit "Create CH Column Layout";
        CreateCHVATPostingGroups: Codeunit "Create CH VAT Posting Groups";
        CreateCHVATStatement: Codeunit "Create CH VAT Statement";
        CreateCHCurrency: Codeunit "Create CH Currency";
        CreateCHCurrencyExRate: Codeunit "Create CH Currency Ex. Rate";
        CreateCHPurchDimValue: Codeunit "Create CH Purch. Dim. Value";
        CreateCHSalesDimValue: Codeunit "Create CH Sales Dim. Value";
        CreateCHBankAccPostingGrp: Codeunit "Create CH Bank Acc Posting Grp";
        CreateCHBankAccount: Codeunit "Create CH Bank Account";
        CreateCHFACHpreciation: Codeunit "Create CH FA Depreciation Book";
        CreateCHFAPostingGrp: Codeunit "Create CH FA Posting Grp.";
        CreateCHInvPostingSetup: Codeunit "Create CH Inv. Posting Setup";
        CreateCHItem: Codeunit "Create CH Item";
        CreateCHItemCharge: Codeunit "Create CH Item Charge";
        CreateCHLocation: Codeunit "Create CH Location";
        CreateCHResource: Codeunit "Create CH Resource";
        CreatCHVendorPostingGrp: Codeunit "Create CH Vendor Posting Grp";
        CreateCHVendor: Codeunit "Create CH Vendor";
        CreateCHCustPostingGrp: Codeunit "Create CH Cust. Posting Grp";
        CreateCHCustBankAccount: Codeunit "Create CH Cust. Bank Account";
        CreateCHReminderLevel: Codeunit "Create CH Reminder Level";
        CreateCHCustomer: Codeunit "Create CH Customer";
        CreateCHShipToAddress: Codeunit "Create CH Ship-to Address";
        CreateCHEmployeeTemplate: Codeunit "Create CH Employee Template";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateCHEmployeeTemplate);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateCHAccScheduleLine);
                    UnbindSubscription(CreateCHColumnLayout);
                    UnbindSubscription(CreateCHCurrency);
                    UnbindSubscription(CreateCHCurrencyExRate);
                    UnbindSubscription(CreateCHVATPostingGroups);
                    UnbindSubscription(CreateCHResource);
                    UnbindSubscription(CreateCHVATStatement);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateCHBankAccPostingGrp);
                    UnbindSubscription(CreateCHBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateCHFACHpreciation);
                    UnbindSubscription(CreateCHFAPostingGrp);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateCHInvPostingSetup);
                    UnbindSubscription(CreateCHItem);
                    UnbindSubscription(CreateCHItemCharge);
                    UnbindSubscription(CreateCHLocation);
                end;

            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreatCHVendorPostingGrp);
                    UnbindSubscription(CreateCHVendor);
                    UnbindSubscription(CreateCHPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCHCustPostingGrp);
                    UnbindSubscription(CreateCHReminderLevel);
                    UnbindSubscription(CreateCHCustomer);
                    UnbindSubscription(CreateCHShipToAddress);
                    UnbindSubscription(CreateCHSalesDimValue);
                    UnbindSubscription(CreateCHCustBankAccount);
                end;
        end;
    end;
}