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
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.HumanResources;

codeunit 14628 "IS Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            InventoryModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Post Code IS");
                    Codeunit.Run(Codeunit::"Create Vat Posting Groups IS");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Company Information IS");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupIS: Codeunit "Create VAT Posting Groups IS";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVatPostingGroupIS.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create General Ledger Setup IS");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Currency Ex. Rate IS");
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Location IS");
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group IS");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Employee IS");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateItemIS: Codeunit "Create Item IS";
        CreateBankAccountIS: Codeunit "Create Bank Account IS";
        CreateReminderLevelIS: Codeunit "Create Reminder Level IS";
        CreateCustomerIS: Codeunit "Create Customer IS";
        CreateSalesDimValueIS: Codeunit "Create Sales Dim Value IS";
        CreateShiptoAddressIS: Codeunit "Create Ship-to Address IS";
        CreateVendorIS: Codeunit "Create Vendor IS";
        CreatePurchDimValueIS: Codeunit "Create Purch. Dim. Value IS";
        CreateResourceIS: Codeunit "Create Resource IS";
        CreateCurrencyIS: Codeunit "Create Currency IS";
        CreateCurrencyExchRateIS: Codeunit "Create Currency Ex. Rate IS";
        CreateFADepreciationBookIS: Codeunit "Create FA Depreciation Book IS";
        CreateLocationIS: Codeunit "Create Location IS";
        CreateVATSetupPostingGrpIS: Codeunit "Create VAT Setup PostingGrpIS";
        CreateVATStatementIS: Codeunit "Create VAT Statement IS";
        CreateAccScheduleLineIS: Codeunit "Create Acc. Schedule Line IS";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                BindSubscription(CreateBankAccountIS);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemIS);
                    BindSubscription(CreateLocationIS)
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerIS);
                    BindSubscription(CreateShiptoAddressIS);
                    BindSubscription(CreateSalesDimValueIS);
                    BindSubscription(CreateReminderLevelIS);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorIS);
                    BindSubscription(CreatePurchDimValueIS);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencyIS);
                    BindSubscription(CreateCurrencyExchRateIS);
                    BindSubscription(CreateResourceIS);
                    BindSubscription(CreateVATSetupPostingGrpIS);
                    BindSubscription(CreateVATStatementIS);
                    BindSubscription(CreateAccScheduleLineIS);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFADepreciationBookIS);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateItemIS: Codeunit "Create Item IS";
        CreateBankAccountIS: Codeunit "Create Bank Account IS";
        CreateReminderLevelIS: Codeunit "Create Reminder Level IS";
        CreateCustomerIS: Codeunit "Create Customer IS";
        CreateSalesDimValueIS: Codeunit "Create Sales Dim Value IS";
        CreateShiptoAddressIS: Codeunit "Create Ship-to Address IS";
        CreateVendorIS: Codeunit "Create Vendor IS";
        CreatePurchDimValueIS: Codeunit "Create Purch. Dim. Value IS";
        CreateResourceIS: Codeunit "Create Resource IS";
        CreateCurrencyIS: Codeunit "Create Currency IS";
        CreateCurrencyExchRateIS: Codeunit "Create Currency Ex. Rate IS";
        CreateFADepreciationBookIS: Codeunit "Create FA Depreciation Book IS";
        CreateLocationIS: Codeunit "Create Location IS";
        CreateVATSetupPostingGrpIS: Codeunit "Create VAT Setup PostingGrpIS";
        CreateVATStatementIS: Codeunit "Create VAT Statement IS";
        CreateAccScheduleLineIS: Codeunit "Create Acc. Schedule Line IS";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                UnBindSubscription(CreateBankAccountIS);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnBindSubscription(CreateItemIS);
                    UnbindSubscription(CreateLocationIS);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnBindSubscription(CreateCustomerIS);
                    UnBindSubscription(CreateShiptoAddressIS);
                    UnBindSubscription(CreateSalesDimValueIS);
                    UnBindSubscription(CreateReminderLevelIS);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnBindSubscription(CreateVendorIS);
                    UnBindSubscription(CreatePurchDimValueIS);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreateCurrencyIS);
                    UnBindSubscription(CreateCurrencyExchRateIS);
                    UnBindSubscription(CreateResourceIS);
                    UnbindSubscription(CreateVATSetupPostingGrpIS);
                    UnbindSubscription(CreateVATStatementIS);
                    UnbindSubscription(CreateAccScheduleLineIS);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnBindSubscription(CreateFADepreciationBookIS);
        end;
    end;
}
