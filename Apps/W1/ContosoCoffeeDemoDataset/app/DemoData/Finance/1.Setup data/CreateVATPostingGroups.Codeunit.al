// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 5473 "Create VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();

        InsertVATClause();
        InsertVATPostingSetupWithoutGLAccounts();
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT10EU(), Reduced(), true);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25EU(), '', false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);
        end;
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATPostingSetupWithoutGLAccounts()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        FinanceModuleSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', Reduced(), true);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);

            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", '', '', FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', NoVAT(), false);
        end;
    end;

    local procedure InsertVATClause()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingSetup.InsertVATClause(Reduced(), ReducedVATClauseDescriptionLbl);
        ContosoPostingSetup.InsertVATClause(NoVAT(), ZeroVATClauseDescriptionLbl);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATProductPostingGroup(FullNormal(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '25'));
        ContosoPostingGroup.InsertVATProductPostingGroup(FullRed(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '10'));
        ContosoPostingGroup.InsertVATProductPostingGroup(ServNormal(), StrSubstNo(MiscellaneousVATDescriptionLbl, '25'));
        ContosoPostingGroup.InsertVATProductPostingGroup(ServRed(), StrSubstNo(MiscellaneousVATDescriptionLbl, '10'));

        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Standard(), StrSubstNo(NormalVatDescriptionLbl, '25'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", Standard());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Reduced(), StrSubstNo(ReducedVatDescriptionLbl, '10'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", Reduced());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), NoVatDescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", NoVAT());
        end;
        FinanceModuleSetup.Modify();
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATBusinessPostingGroup(Domestic(), DomesticPostingGroupDescriptionLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(EU(), EUPostingGroupDescriptionLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(Export(), ExportPostingGroupDescriptionLbl);
    end;

    procedure Domestic(): Code[20]
    begin
        exit(DomesticTok);
    end;

    procedure EU(): Code[20]
    begin
        exit(EUTok);
    end;

    procedure Export(): Code[20]
    begin
        exit(ExportTok);
    end;

#if not CLEAN27
    [Obsolete('Zero() is now replaced with NoVAT() instead', '27.0')]
    procedure Zero(): Code[20]
    begin
        exit(NoVATTok);
    end;
#endif

    procedure NoVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure Standard(): Code[20]
    begin
        exit(StandardTok);
    end;

    procedure Reduced(): Code[20]
    begin
        exit(ReducedTok);
    end;

    procedure ServRed(): Code[20]
    begin
        exit(ServRedTok);
    end;

    procedure ServNormal(): Code[20]
    begin
        exit(ServNormTok);
    end;

    procedure FullRed(): Code[20]
    begin
        exit(FullRedTok);
    end;

    procedure FullNormal(): Code[20]
    begin
        exit(FullNormalTok);
    end;

    var
        DomesticTok: Label 'DOMESTIC', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ExportTok: Label 'EXPORT', MaxLength = 20;
        NoVATTok: Label 'NO VAT', MaxLength = 20;
        StandardTok: Label 'STANDARD', MaxLength = 20;
        ReducedTok: Label 'REDUCED', MaxLength = 20;
        ServRedTok: Label 'SERV RED', MaxLength = 20;
        ServNormTok: Label 'SERV NORM', MaxLength = 20;
        FullRedTok: Label 'FULL RED', MaxLength = 20;
        FullNormalTok: Label 'FULL NORM', MaxLength = 20;
        ReducedVATClauseDescriptionLbl: Label 'Reduced VAT Rate is used due to VAT Act regulation 1 article II', MaxLength = 250;
        ZeroVATClauseDescriptionLbl: Label 'Zero VAT Rate is used due to VAT Act regulation 2 article III', MaxLength = 250;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NoVatDescriptionLbl: Label 'No VAT', MaxLength = 100;
        DomesticPostingGroupDescriptionLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        EUPostingGroupDescriptionLbl: Label 'Customers and vendors in EU', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
}
