// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Foundation.Enums;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
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
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreatePostingGroup: codeunit "Create Posting Groups";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', NOVAT(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT10(), CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), VAT10(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT20(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), VAT20(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), NOVAT(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), VAT10(), CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), VAT10(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), VAT20(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), VAT20(), 20, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), NOVAT(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateATGLAccount.SalesTax20(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), VAT10(), CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATAcquisitionReduced(), VAT10(), 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateATGLAccount.SalesTaxProfitAndIncomeTax10(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), VAT20(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATAcquisitionStandard(), VAT20(), 20, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateATGLAccount.SalesTaxProfitAndIncomeTax20(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), NOVAT(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), VAT10(), CreateATGLAccount.SalesTax10(), CreateATGLAccount.PurchaseVATReduced(), VAT10(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), VAT20(), CreateATGLAccount.SalesTax20(), CreateATGLAccount.PurchaseVATStandard(), VAT20(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        UpdateAdjustforPaymentDiscount('', NOVAT());
        UpdateAdjustforPaymentDiscount('', VAT10());
        UpdateAdjustforPaymentDiscount('', VAT20());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), NOVAT());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), VAT10());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.DomesticPostingGroup(), VAT20());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), NOVAT());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), VAT10());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.EUPostingGroup(), VAT20());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), NOVAT());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), VAT10());
        UpdateAdjustforPaymentDiscount(CreatePostingGroup.ExportPostingGroup(), VAT20());
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
        ContosoPostingGroup: codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT20(), StrSubstNo(MiscellaneousVATLbl, '20'));
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), MiscellaneousNoVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT10(), StrSubstNo(MiscellaneousVATLbl, '10'));
    end;

    procedure UpdateGeneralProdPostingGroup()
    var
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        UpdateGenProdPostingGrp(CreatePostingGroup.FreightPostingGroup(), VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.RawMatPostingGroup(), VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.RetailPostingGroup(), VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.MiscPostingGroup(), VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.ServicesPostingGroup(), VAT10());
    end;

    local procedure UpdateGenProdPostingGrp(ProdPostingGroup: COde[20]; DefaultVATProdPostingGroup: Code[20])
    var
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        if GenProdPostingGroup.Get(ProdPostingGroup) then begin
            GenProdPostingGroup.Validate("Def. VAT Prod. Posting Group", DefaultVATProdPostingGroup);
            GenProdPostingGroup.Modify(true);
        end;
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure VAT10(): Code[20]
    begin
        exit(VAT10Tok);
    end;

    procedure VAT20(): Code[20]
    begin
        exit(VAT20Tok);
    end;

    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        VAT10Tok: Label 'VAT10', MaxLength = 20, Locked = true;
        VAT20Tok: Label 'VAT20', MaxLength = 20, Locked = true;
        MiscellaneousVATLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        MiscellaneousNoVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}
