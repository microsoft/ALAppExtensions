// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Sales;
using Microsoft.DemoData.HumanResources;
using Microsoft.DemoTool;

codeunit 11214 "SE Contoso Localization"
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
        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResourceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateCompanyInformationSE: Codeunit "Create Company Information SE";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Post Code SE");
                    CreateCompanyInformationSE.UpdateCompanyRegistrationInformation();
                    Codeunit.Run(Codeunit::"Create Vat Posting Groups SE");
                    Codeunit.Run(Codeunit::"Create Posting Groups SE");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Company Information SE");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupSE: Codeunit "Create VAT Posting Groups SE";
        CreatePostingGroupsSE: Codeunit "Create Posting Groups SE";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    CreateVatPostingGroupSE.UpdateVATPostingSetup();
                    CreatePostingGroupsSE.UpdateGenPostingSetup();
                    Codeunit.Run(Codeunit::"Create General Ledger Setup SE");
                    Codeunit.Run(Codeunit::"Create VAT Statement SE");
                    Codeunit.Run(Codeunit::"Create VAT Setup PostingGrp SE");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Currency Ex. Rate SE");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Sales Recv. Setup SE");
                    Codeunit.Run(Codeunit::"Create Finance Charge Terms SE");
                end;
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create FA Ins Jnl. Template SE");
        end;
    end;

    local procedure HumanResourceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group SE");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Employee SE");
                    Codeunit.Run(Codeunit::"Create Employee Template SE");
                end;
        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateInvPostingSetupSE: Codeunit "Create Inv. Posting Setup SE";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Inv. Posting Setup SE");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    CreateInvPostingSetupSE.UpdateInventoryPosting();
                    Codeunit.Run(Codeunit::"Create Item Template SE");
                    Codeunit.Run(Codeunit::"Create Location SE");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationSE: Codeunit "Create Location SE";
        CreateItemSE: Codeunit "Create Item SE";
        CreateBankAccountSE: Codeunit "Create Bank Account SE";
        CreateCustPostingGroupSE: Codeunit "Create Cust. Posting Group SE";
        CreateReminderLevelSE: Codeunit "Create Reminder Level SE";
        CreateCustomerSE: Codeunit "Create Customer SE";
        CreateSalesDimValueSE: Codeunit "Create Sales Dim Value SE";
        CreateShiptoAddressSE: Codeunit "Create Ship-to Address SE";
        CreateVendorSE: Codeunit "Create Vendor SE";
        CreateVendorPostingGroupSE: Codeunit "Create Vendor Posting Group SE";
        CreatePurchDimValueSE: Codeunit "Create Purch. Dim. Value SE";
        CreateResourceSE: Codeunit "Create Resource SE";
        CreateCurrencySE: Codeunit "Create Currency SE";
        CreateCurrencyExchRateSE: Codeunit "Create Currency Ex. Rate SE";
        CreateFADepreciationBookSE: Codeunit "Create FA Depreciation Book SE";
        CreateAccScheduleSE: Codeunit "Create Acc. Schedule SE";
        CreateItemChargeSE: Codeunit "Create Item Charge SE";
        CreateGenJournalLineSE: Codeunit "Create Gen. Journal Line SE";
        CreateVATStatementSE: Codeunit "Create VAT Statement SE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccountSE);
                    BindSubscription(CreateGenJournalLineSE)
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateItemSE);
                    BindSubscription(CreateLocationSE);
                    BindSubscription(CreateItemChargeSE);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustomerSE);
                    BindSubscription(CreateShiptoAddressSE);
                    BindSubscription(CreateSalesDimValueSE);
                    BindSubscription(CreateReminderLevelSE);
                    BindSubscription(CreateCustPostingGroupSE);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorSE);
                    BindSubscription(CreatePurchDimValueSE);
                    BindSubscription(CreateVendorPostingGroupSE);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateCurrencySE);
                    BindSubscription(CreateCurrencyExchRateSE);
                    BindSubscription(CreateResourceSE);
                    BindSubscription(CreateAccScheduleSE);
                    BindSubscription(CreateVATStatementSE);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFADepreciationBookSE);
        end;
    end;

    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateLocationSE: Codeunit "Create Location SE";
        CreateItemSE: Codeunit "Create Item SE";
        CreateBankAccountSE: Codeunit "Create Bank Account SE";
        CreateCustPostingGroupSE: Codeunit "Create Cust. Posting Group SE";
        CreateReminderLevelSE: Codeunit "Create Reminder Level SE";
        CreateCustomerSE: Codeunit "Create Customer SE";
        CreateSalesDimValueSE: Codeunit "Create Sales Dim Value SE";
        CreateShiptoAddressSE: Codeunit "Create Ship-to Address SE";
        CreateVendorSE: Codeunit "Create Vendor SE";
        CreateVendorPostingGroupSE: Codeunit "Create Vendor Posting Group SE";
        CreatePurchDimValueSE: Codeunit "Create Purch. Dim. Value SE";
        CreateResourceSE: Codeunit "Create Resource SE";
        CreateCurrencySE: Codeunit "Create Currency SE";
        CreateCurrencyExchRateSE: Codeunit "Create Currency Ex. Rate SE";
        CreateFADepreciationBookSE: Codeunit "Create FA Depreciation Book SE";
        CreateAccScheduleSE: Codeunit "Create Acc. Schedule SE";
        CreateItemChargeSE: Codeunit "Create Item Charge SE";
        CreateGenJournalLineSE: Codeunit "Create Gen. Journal Line SE";
        CreateVATStatementSE: Codeunit "Create VAT Statement SE";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnBindSubscription(CreateBankAccountSE);
                    UnbindSubscription(CreateGenJournalLineSE)
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnBindSubscription(CreateItemSE);
                    UnBindSubscription(CreateLocationSE);
                    UnbindSubscription(CreateItemChargeSE);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnBindSubscription(CreateCustomerSE);
                    UnBindSubscription(CreateShiptoAddressSE);
                    UnBindSubscription(CreateSalesDimValueSE);
                    UnBindSubscription(CreateReminderLevelSE);
                    UnBindSubscription(CreateCustPostingGroupSE);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnBindSubscription(CreateVendorSE);
                    UnBindSubscription(CreatePurchDimValueSE);
                    UnBindSubscription(CreateVendorPostingGroupSE);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreateCurrencySE);
                    UnBindSubscription(CreateCurrencyExchRateSE);
                    UnBindSubscription(CreateResourceSE);
                    UnBindSubscription(CreateAccScheduleSE);
                    UnbindSubscription(CreateVATStatementSE);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnBindSubscription(CreateFADepreciationBookSE);
        end;
    end;
}
