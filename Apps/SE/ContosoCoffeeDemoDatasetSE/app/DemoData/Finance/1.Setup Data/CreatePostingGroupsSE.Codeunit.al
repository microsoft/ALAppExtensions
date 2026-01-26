// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11213 "Create Posting Groups SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenPostingGroup();
    end;

    local procedure InsertGenPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateVATPostingGroupsSE: Codeunit "Create VAT Posting Groups SE";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingGroup.InsertGenProductPostingGroup(NoVatPostingGroup(), NoVatDescriptionLbl, FinanceModuleSetup."VAT Prod. Post Grp. NO VAT");
        ContosoPostingGroup.InsertGenProductPostingGroup(OnlyPostingGroup(), OnlyDescriptionLbl, CreateVATPostingGroupsSE.Only());
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateSEGLAccounts: Codeunit "Create SE GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVatPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NoVatPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailEU(), CreateGLAccount.PurchRetailEU(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NoVatPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoVatPostingGroup(): Code[20]
    begin
        exit(NoVatTok);
    end;

    procedure OnlyPostingGroup(): Code[20]
    begin
        exit(OnlyTok);
    end;

    var
        NoVatTok: Label 'NO VAT', Locked = true, MaxLength = 20;
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        OnlyTok: Label 'ONLY', Locked = true, MaxLength = 20;
        OnlyDescriptionLbl: Label 'Manually Posted VAT', MaxLength = 100;
}
