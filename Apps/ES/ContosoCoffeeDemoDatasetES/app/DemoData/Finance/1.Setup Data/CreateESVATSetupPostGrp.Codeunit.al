// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 10839 "Create ES Vat Setup Post Grp"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateVATPostingGroupES: Codeunit "Create ES VAT Posting Groups";
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        FinanceModuleSetup.Get();

        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVATPostingGroupES.NoTax(), true, 0, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true, 1, SetupExportNoTaxDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", true, 0, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true, 1, SetupExportReducedDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true, 7, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true, 1, SetupExportStandardDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVATPostingGroupES.VAT4(), true, 4, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true, 1, SetupExportDecreaseDescLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(FinanceModuleSetup."VAT Prod. Post Grp. Standard", true, 21, CreateESGLAccount.VatCollByTheComp(), CreateESGLAccount.GovVatDeductible(), true, 1, SetupExportIncreaseDescLbl);
    end;

    var
        SetupExportReducedDescLbl: Label 'Setup for EXPORT / NO VAT', MaxLength = 100;
        SetupExportNoTaxDescLbl: Label 'Setup for EXPORT / NO TAX', MaxLength = 100;
        SetupExportStandardDescLbl: Label 'Setup for EXPORT / VAT7', MaxLength = 100;
        SetupExportDecreaseDescLbl: Label 'Setup for EXPORT / VAT4', MaxLength = 100;
        SetupExportIncreaseDescLbl: Label 'Setup for EXPORT / VAT21', MaxLength = 100;
}
