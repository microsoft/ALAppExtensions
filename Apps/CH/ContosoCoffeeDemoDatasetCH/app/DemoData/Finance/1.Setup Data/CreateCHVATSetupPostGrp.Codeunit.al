// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11623 "Create CH VAT Setup Post. Grp."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateCHVatPostingGroups: Codeunit "Create CH VAT Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        FinanceModuleSetup.Get();

        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.HalfNormal(), true, 3.66089, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Hotel(), true, 3.6, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Import(), true, 100, ' ', CreateCHGLAccounts.PurchVatOnImports100Percent(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", true, 0, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Standard", true, 8, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.OperatingExpense(), true, 8, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true, 2.4, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
    end;
}
