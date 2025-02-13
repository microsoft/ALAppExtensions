codeunit 11113 "DE Contoso Localization"
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

        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create DE Employee");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create DE Area");
                    Codeunit.Run(Codeunit::"Create DE No. Series");
                    Codeunit.Run(Codeunit::"Create DE Post Code");
                    Codeunit.Run(Codeunit::"Create DE Receiver/Dispatcher");
                    Codeunit.Run(Codeunit::"Create DE Company Information");
                end;
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create DE Purch. Payable Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create DE Inv. Posting Setup");
                    Codeunit.Run(Codeunit::"Create DE Item Template");
                end;
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create DE Sales Document");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create DE General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create DE GL Acc.");
                    Codeunit.Run(Codeunit::"Create DE Posting Groups");
                    Codeunit.Run(Codeunit::"Create DE VAT Posting Groups");
                    Codeunit.Run(Codeunit::"Create DE Currency");
                    Codeunit.Run(Codeunit::"Create DE General Ledger Setup");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create DE Currency Ex. Rate");
                    Codeunit.Run(Codeunit::"Create DE VAT Statement");
                    Codeunit.Run(Codeunit::"Create DE Data Export");
                    Codeunit.Run(Codeunit::"Create DE Data Exp. Rec. Type");
                    Codeunit.Run(Codeunit::"Create DE Data Export Record");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateDEAccScheduleLine: Codeunit "Create DE Acc. Schedule Line";
        CreateDEAnalysisView: Codeunit "Create DE Analysis View";
        CreateDECurrencyExRate: Codeunit "Create DE Currency Ex. Rate";
        CreateDEVatPostingGroup: Codeunit "Create DE VAT Posting Groups";
        CreateDEPurchDimValue: Codeunit "Create DE Purch. Dim. Value";
        CreateDESalesDimValue: Codeunit "Create DE Sales Dim Value";
        CreateDEBankAccPostingGrp: Codeunit "Create Bank Acc. Post. Grp DE";
        CreateDEBankAccount: Codeunit "Create DE Bank Account";
        CreateDEFADepreciation: Codeunit "Create DE FA Depreciation Book";
        CreateDEFAPostingGrp: Codeunit "Create DE FA Posting Grp.";
        CreateDEInvPostingSetup: Codeunit "Create DE Inv. Posting Setup";
        CreateDEItem: Codeunit "Create DE Item";
        CreateDEItemCharge: Codeunit "Create DE Item Charge";
        CreateDELocation: Codeunit "Create DE Location";
        CreateDEResource: Codeunit "Create DE Resource";
        CreatDeVendorPostingGrp: Codeunit "Create DE Vendor Posting Grp";
        CreateDEVendor: Codeunit "Create DE Vendor";
        CreateDECustPostingGrp: Codeunit "Create DE Cust. Posting Grp";
        CreateDEReminderLevel: Codeunit "Create DE Reminder Level";
        CreateDECustomer: Codeunit "Create DE Customer";
        CreateDEShipToAddress: Codeunit "Create DE Ship-to Address";
        CreatePaymentTermDE: Codeunit "Create Payment Terms DE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                BindSubscription(CreatePaymentTermDE);

            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateDEAccScheduleLine);
                    BindSubscription(CreateDEAnalysisView);
                    BindSubscription(CreateDECurrencyExRate);
                    BindSubscription(CreateDEVatPostingGroup);
                    BindSubscription(CreateDEResource);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateDEBankAccPostingGrp);
                    BindSubscription(CreateDEBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateDEFADepreciation);
                    BindSubscription(CreateDEFAPostingGrp);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateDEInvPostingSetup);
                    BindSubscription(CreateDEItem);
                    BindSubscription(CreateDEItemCharge);
                    BindSubscription(CreateDELocation);
                end;

            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreatDeVendorPostingGrp);
                    BindSubscription(CreateDEVendor);
                    BindSubscription(CreateDEPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateDECustPostingGrp);
                    BindSubscription(CreateDEReminderLevel);
                    BindSubscription(CreateDECustomer);
                    BindSubscription(CreateDEShipToAddress);
                    BindSubscription(CreateDESalesDimValue);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateDEAccScheduleLine: Codeunit "Create DE Acc. Schedule Line";
        CreateDEAnalysisView: Codeunit "Create DE Analysis View";
        CreateDEVatPostingGroup: Codeunit "Create DE VAT Posting Groups";
        CreateDECurrencyExRate: Codeunit "Create DE Currency Ex. Rate";
        CreateDEPurchDimValue: Codeunit "Create DE Purch. Dim. Value";
        CreateDESalesDimValue: Codeunit "Create DE Sales Dim Value";
        CreateDEBankAccPostingGrp: Codeunit "Create Bank Acc. Post. Grp DE";
        CreateDEBankAccount: Codeunit "Create DE Bank Account";
        CreateDEFADepreciation: Codeunit "Create DE FA Depreciation Book";
        CreateDEFAPostingGrp: Codeunit "Create DE FA Posting Grp.";
        CreateDEInvPostingSetup: Codeunit "Create DE Inv. Posting Setup";
        CreateDEItem: Codeunit "Create DE Item";
        CreateDEItemCharge: Codeunit "Create DE Item Charge";
        CreateDELocation: Codeunit "Create DE Location";
        CreateDEResource: Codeunit "Create DE Resource";
        CreatDeVendorPostingGrp: Codeunit "Create DE Vendor Posting Grp";
        CreateDEVendor: Codeunit "Create DE Vendor";
        CreateDECustPostingGrp: Codeunit "Create DE Cust. Posting Grp";
        CreateDEReminderLevel: Codeunit "Create DE Reminder Level";
        CreateDECustomer: Codeunit "Create DE Customer";
        CreateDEShipToAddress: Codeunit "Create DE Ship-to Address";
        CreatePaymentTermDE: Codeunit "Create Payment Terms DE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                UnbindSubscription(CreatePaymentTermDE);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateDEAccScheduleLine);
                    UnbindSubscription(CreateDEAnalysisView);
                    UnbindSubscription(CreateDECurrencyExRate);
                    UnbindSubscription(CreateDEVatPostingGroup);
                    UnbindSubscription(CreateDEResource);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateDEBankAccPostingGrp);
                    UnbindSubscription(CreateDEBankAccount);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateDEFADepreciation);
                    UnbindSubscription(CreateDEFAPostingGrp);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateDEInvPostingSetup);
                    UnbindSubscription(CreateDEItem);
                    UnbindSubscription(CreateDEItemCharge);
                    UnbindSubscription(CreateDELocation);
                end;

            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreatDeVendorPostingGrp);
                    UnbindSubscription(CreateDEVendor);
                    UnbindSubscription(CreateDEPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateDECustPostingGrp);
                    UnbindSubscription(CreateDEReminderLevel);
                    UnbindSubscription(CreateDECustomer);
                    UnbindSubscription(CreateDEShipToAddress);
                    UnbindSubscription(CreateDESalesDimValue);
                end;
        end;
    end;
}