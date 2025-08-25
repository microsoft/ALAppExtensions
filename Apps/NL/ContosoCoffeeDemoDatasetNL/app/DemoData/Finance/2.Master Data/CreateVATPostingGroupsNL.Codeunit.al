// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Localization;
using Microsoft.Foundation.Enums;

codeunit 11534 "Create VAT Posting Groups NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateVATPostingSetup()
    end;

    local procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 9, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateNLGLAccounts.MiscVATPayables(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateNLGLAccounts.MiscVATPayables(), '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);
        end;
        ContosoPostingSetup.SetOverwriteData(false);
    end;
}
