// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Foundation.Enums;
using Microsoft.Finance.VAT.Setup;
using Microsoft.DemoTool.Helpers;

codeunit 11186 "Create VAT Posting Group AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    procedure CreateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreatePostingGroup: codeunit "Create Posting Groups";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 20, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateATGLAccount.SalesTax20(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATAcquisitionReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateATGLAccount.SalesTaxProfitAndIncomeTax10(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATAcquisitionStandard(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 20, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateATGLAccount.SalesTaxProfitAndIncomeTax20(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        UpdateAdjustforPaymentDiscount('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT");
        UpdateAdjustforPaymentDiscount('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced");
        UpdateAdjustforPaymentDiscount('', FinanceModuleSetup."VAT Prod. Post Grp. Standard");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced");
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard");
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure UpdateAdjustforPaymentDiscount(VatBusPostingGrp: Code[20]; VatProdPostingGrp: Code[20])
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        if not VatPostingSetup.Get(VatBusPostingGrp, VatProdPostingGrp) then
            exit;

        VatPostingSetup.Validate("Adjust for Payment Discount", false);
        VatPostingSetup.Modify(true);
    end;

    procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT20(), StrSubstNo(MiscellaneousVATLbl, '20'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", VAT20());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT10(), StrSubstNo(MiscellaneousVATLbl, '10'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", VAT10());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.NOVAT(), StrSubstNo(MiscellaneousVATLbl, '0'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", CreateVATPostingGroups.NOVAT());
        end;

        FinanceModuleSetup.Modify(true);
    end;

#if not CLEAN27
    [Obsolete('This procedure is not used in the current version.', '27.0')]
    procedure UpdateGeneralProdPostingGroup()
    begin

    end;
#endif

#if not CLEAN27
    [Obsolete('This procedure is moved to codeunit 5473 "Create VAT Posting Groups".', '27.0')]
    procedure NOVAT(): Code[20]
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        exit(CreateVATPostingGroups.NOVAT());
    end;
#endif

    procedure VAT10(): Code[20]
    begin
        exit(VAT10Tok);
    end;

    procedure VAT20(): Code[20]
    begin
        exit(VAT20Tok);
    end;

    var
        VAT10Tok: Label 'VAT10', MaxLength = 20;
        VAT20Tok: Label 'VAT20', MaxLength = 20;
        MiscellaneousVATLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}
