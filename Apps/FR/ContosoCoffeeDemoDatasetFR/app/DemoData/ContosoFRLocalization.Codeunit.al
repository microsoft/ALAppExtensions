// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Sales;
using Microsoft.DemoTool;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.HumanResources;

codeunit 10864 "Contoso FR Localization"
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
                    Codeunit.Run(Codeunit::"Create Source Code FR");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Company Information FR");
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
                    Codeunit.Run(Codeunit::"Create VAT Statement FR");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Exc. Rate FR");
                    Codeunit.Run(Codeunit::"Create Column Layout FR");
                end;
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateInvPostingSetupFR: Codeunit "Create Inv. Posting Setup FR";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Inv. Posting Setup FR");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    CreateInvPostingSetupFR.UpdateInventoryPosting();
                    Codeunit.Run(Codeunit::"Create Item FR");
                end;
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
        CreateFAPostingGrpFR: Codeunit "Create FA Posting Grp. FR";
        CreateItemFR: Codeunit "Create Item FR";
        CreateLocationFR: Codeunit "Create Location FR";
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
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFAPostingGrpFR);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemFR);
                    BindSubscription(CreateLocationFR);
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
        CreateFAPostingGrpFR: Codeunit "Create FA Posting Grp. FR";
        CreateItemFR: Codeunit "Create Item FR";
        CreateLocationFR: Codeunit "Create Location FR";
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
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFAPostingGrpFR);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateItemFR);
                    UnbindSubscription(CreateLocationFR);
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
