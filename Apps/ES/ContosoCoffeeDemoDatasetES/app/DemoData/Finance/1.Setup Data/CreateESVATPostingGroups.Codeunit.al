// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 10794 "Create ES VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    procedure InsertVATPostingSetupWithGLAccounts()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        FinanceModuleSetup.Get();
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 7, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 4, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateESGLAccounts.VatEuReversion(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 7, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 4, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateESGLAccounts.VatEuReversion(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NoTax(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), NoTax(), 0, Enum::"Tax Calculation Type"::"No Taxable VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Vat4(), CreateESGLAccounts.VatCollByTheComp(), CreateESGLAccounts.GovVatDeductible(), Vat4(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Vat21(), Miscellaneous21VatLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", Vat21());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Vat7(), Miscellaneous7VatLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", Vat7());
        end;
        FinanceModuleSetup.Modify();

        ContosoPostingGroup.InsertVATProductPostingGroup(NoTax(), NotchargeableVatLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat4(), Vat21VatLbl);
    end;

    procedure NoTax(): Code[20]
    begin
        exit(NoTaxTok);
    end;

#if not CLEAN27
    [Obsolete('Use NoVat in codeunit 5473 "Create VAT Posting Groups" instead', '27.0')]
    procedure NoVat(): Code[20]
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        exit(CreateVATPostingGroups.NOVAT());
    end;
#endif

    procedure Vat7(): Code[20]
    begin
        exit(Vat7Tok);
    end;

    procedure Vat21(): Code[20]
    begin
        exit(Vat21Tok);
    end;

    procedure Vat4(): Code[20]
    begin
        exit(Vat4Tok);
    end;

    var
        NoTaxTok: Label 'NO TAX', MaxLength = 20, Locked = true;
        Vat7Tok: Label 'VAT7', MaxLength = 20, Locked = true;
        Vat21Tok: Label 'VAT21', MaxLength = 20, Locked = true;
        Vat4Tok: Label 'VAT4', MaxLength = 20, Locked = true;
        NotchargeableVatLbl: Label 'Not chargeable VAT', MaxLength = 100;
        Vat21VatLbl: Label 'Reduced VAT', MaxLength = 100;
        Miscellaneous21VatLbl: Label 'Miscellaneous 21 VAT', MaxLength = 100;
        Miscellaneous7VatLbl: Label 'Miscellaneous 7 VAT', MaxLength = 100;
}
