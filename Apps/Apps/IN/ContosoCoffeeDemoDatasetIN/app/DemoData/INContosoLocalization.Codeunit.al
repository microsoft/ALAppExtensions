// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Sales;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.CRM;
using Microsoft.DemoData.Foundation;

codeunit 19047 "IN Contoso Localization"
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
        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create IN Purch. Pay. Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create IN Vendor");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create IN Purch. Document");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create IN Interac. Tmpl. Lang.");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create IN Sales Rcvble Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create IN Customer");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create IN Sales Document");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create IN Source Code");
                    Codeunit.Run(Codeunit::"Create IN TAN Nos.");
                    Codeunit.Run(Codeunit::"Create IN TCAN Nos.");
                    Codeunit.Run(Codeunit::"Create IN Deductor Category");
                    Codeunit.Run(Codeunit::"Create IN Ministry");
                    Codeunit.Run(Codeunit::"Create IN Post Code");
                    Codeunit.Run(Codeunit::"Create IN State");
                    Codeunit.Run(Codeunit::"Create IN No. Series");
                    Codeunit.Run(Codeunit::"Create IN UOM Translation");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create IN Company Information");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create IN Tax Acc. Period");
                    Codeunit.Run(Codeunit::"Create IN Tax Type");
                    Codeunit.Run(Codeunit::"Create IN Act Applicable");
                    Codeunit.Run(Codeunit::"Create IN Concessional Code");
                    Codeunit.Run(Codeunit::"Create IN Assessee Code");
                    Codeunit.Run(Codeunit::"Create IN General Ledger Setup");
                    Codeunit.Run(Codeunit::"Create IN Gen. Journ. Template");
                    Codeunit.Run(Codeunit::"Create IN Gen. Journal Batch");
                    Codeunit.Run(Codeunit::"Create IN GST Group");
                    Codeunit.Run(Codeunit::"Create IN HSN/SAC");
                    Codeunit.Run(Codeunit::"Create IN GST Posting Setup");
                    Codeunit.Run(Codeunit::"Create IN TCS Nature of Coll.");
                    Codeunit.Run(Codeunit::"Create IN TCS Posting Setup");
                    Codeunit.Run(Codeunit::"Create IN TDS Section");
                    Codeunit.Run(Codeunit::"Create IN TDS Nature of Rem.");
                    Codeunit.Run(Codeunit::"Create IN TDS Posting Setup");
                    Codeunit.Run(Codeunit::"Create IN GST Rates");
                    Codeunit.Run(Codeunit::"Create IN TDS Rates");
                    Codeunit.Run(Codeunit::"Create IN TCS Rates");
                    Codeunit.RUn(Codeunit::"Create IN GL Acc. Category");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create IN Currency Ex. Rate");
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create IN Fixed Asset Block");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create IN FA Depreciation Book");
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create IN Payment Method");
                    Codeunit.Run(Codeunit::"Create IN Bank Charge");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create IN Bank Account");
                    Codeunit.Run(Codeunit::"Create IN Vouch. Post. Setup");
                    Codeunit.Run(Codeunit::"Create IN Vouc. Post. Cr. Acc.");
                end;
            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create IN Gen. Journal Line");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create IN Location");
                    Codeunit.Run(Codeunit::"Create IN Inven. Posting Setup");
                    Codeunit.Run(Codeunit::"Create IN Inventory Setup");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create IN Transfer Orders");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateINItem: Codeunit "Create IN Item";
        CreateINItemCharge: Codeunit "Create IN Item Charge";
        CreateINInvenPostingSetup: Codeunit "Create IN Inven. Posting Setup";
        CreateINBankAccount: Codeunit "Create IN Bank Account";
        CreateINReminderLevel: Codeunit "Create IN Reminder Level";
        CreateINCustomer: Codeunit "Create IN Customer";
        CreateINSalesDimValue: Codeunit "Create IN Sales Dim Value";
        CreateINShiptoAddress: Codeunit "Create IN Ship-to Address";
        CreateINVendor: Codeunit "Create IN Vendor";
        CreateINPurchDimValue: Codeunit "Create IN Purch. Dim. Value";
        CreateINCurrency: Codeunit "Create IN Currency";
        CreateINCurrencyExRate: Codeunit "Create IN Currency Ex. Rate";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINResource: Codeunit "Create IN Resource";
        CreateINAccScheduleLine: Codeunit "Create IN Acc. Schedule Line";
        CreateINGenJournalLine: Codeunit "Create IN Gen. Journal Line";
        CreateINFAClass: Codeunit "Create IN FA Class";
        CreateINWordTemplate: Codeunit "Create IN Word Template";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateINBankAccount);
                    BindSubscription(CreateINGenJournalLine)
                end;
            Enum::"Contoso Demo Data Module"::CRM:
                BindSubscription(CreateINWordTemplate);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateINFAClass);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateINItemCharge);
                    BindSubscription(CreateINInvenPostingSetup);
                    BindSubscription(CreateINItem);
                    BindSubscription(CreateINLocation)
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateINCustomer);
                    BindSubscription(CreateINShiptoAddress);
                    BindSubscription(CreateINSalesDimValue);
                    BindSubscription(CreateINReminderLevel);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateINVendor);
                    BindSubscription(CreateINPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateINCurrency);
                    BindSubscription(CreateINAccScheduleLine);
                    BindSubscription(CreateINCurrencyExRate);
                    BindSubscription(CreateINResource);
                end;
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateINItem: Codeunit "Create IN Item";
        CreateINItemCharge: Codeunit "Create IN Item Charge";
        CreateINInvenPostingSetup: Codeunit "Create IN Inven. Posting Setup";
        CreateINBankAccount: Codeunit "Create IN Bank Account";
        CreateINReminderLevel: Codeunit "Create IN Reminder Level";
        CreateINCustomer: Codeunit "Create IN Customer";
        CreateINShiptoAddress: Codeunit "Create IN Ship-to Address";
        CreateINSalesDimValue: Codeunit "Create IN Sales Dim Value";
        CreateINVendor: Codeunit "Create IN Vendor";
        CreateINPurchDimValue: Codeunit "Create IN Purch. Dim. Value";
        CreateINCurrency: Codeunit "Create IN Currency";
        CreateINCurrencyExRate: Codeunit "Create IN Currency Ex. Rate";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINResource: Codeunit "Create IN Resource";
        CreateINAccScheduleLine: Codeunit "Create IN Acc. Schedule Line";
        CreateINGenJournalLine: Codeunit "Create IN Gen. Journal Line";
        CreateINFAClass: Codeunit "Create IN FA Class";
        CreateINWordTemplate: Codeunit "Create IN Word Template";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateINBankAccount);
                    UnbindSubscription(CreateINGenJournalLine)
                end;
            Enum::"Contoso Demo Data Module"::CRM:
                UnbindSubscription(CreateINWordTemplate);
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateINFAClass);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateINItemCharge);
                    UnbindSubscription(CreateINInvenPostingSetup);
                    UnbindSubscription(CreateINItem);
                    UnbindSubscription(CreateINLocation)
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateINCustomer);
                    UnbindSubscription(CreateINShiptoAddress);
                    UnbindSubscription(CreateINSalesDimValue);
                    UnbindSubscription(CreateINReminderLevel);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateINVendor);
                    UnbindSubscription(CreateINPurchDimValue);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateINCurrency);
                    UnbindSubscription(CreateINAccScheduleLine);
                    UnbindSubscription(CreateINCurrencyExRate);
                    UnbindSubscription(CreateINResource);
                end;
        end;
    end;
}
