// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11187 "Create Vat Setup Post Grp AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        FinanceModuleSetup.Get();

        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", true, 0, CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), true, 1, SetupExportReducedDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true, 10, CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), true, 1, SetupExportStandardDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Standard", true, 20, CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), true, 1, SetupExportIncreaseDescLbl);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    var
        SetupExportReducedDescLbl: Label 'Setup for EXPORT / NO VAT', MaxLength = 100;
        SetupExportStandardDescLbl: Label 'Setup for EXPORT / VAT10', MaxLength = 100;
        SetupExportIncreaseDescLbl: Label 'Setup for EXPORT / VAT20', MaxLength = 100;
}
