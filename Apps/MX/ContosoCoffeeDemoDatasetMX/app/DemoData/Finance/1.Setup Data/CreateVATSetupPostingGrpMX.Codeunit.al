// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;
using Microsoft.Finance.VAT.Setup;
using Microsoft.DemoTool.Helpers;

codeunit 14111 "Create VATSetupPostingGrp. MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        CreateVatSetupPostingGrp();
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        VATSetupPostingGroups: Record "VAT Setup Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        FinanceModuleSetup.Get();

        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", true, 0, CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, FinanceModuleSetup."VAT Prod. Post Grp. NO VAT"));
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Standard", true, 16, CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, FinanceModuleSetup."VAT Prod. Post Grp. Standard"));
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true, 8, CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, FinanceModuleSetup."VAT Prod. Post Grp. Reduced"));
        ContosoVATStatement.SetOverwriteData(false);
    end;

    var
        VATDescriptionLbl: Label 'Setup for EXPORT / %1', Comment = '%1 is Vat posting group', MaxLength = 100;
}
