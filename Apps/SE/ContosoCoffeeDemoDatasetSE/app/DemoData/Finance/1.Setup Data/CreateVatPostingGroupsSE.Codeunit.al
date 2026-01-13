// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 11207 "Create Vat Posting Groups SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(Only(), OnlyDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT6(), Vat6DescriptionLbl);

        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT25(), Vat25DescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", VAT25());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT12(), Vat12DescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", VAT12());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.NoVAT(), NoVatDescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", CreateVATPostingGroups.NoVAT());
        end;

        FinanceModuleSetup.Modify(true);
    end;

    procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateSEGLAccounts: Codeunit "Create SE GL Accounts";
    begin
        FinanceModuleSetup.Get();
        ContosoPostingSetup.SetOverwriteData(true);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Only(), '', CreateSEGLAccounts.OnlyVAT(), Only(), 0, Enum::"Tax Calculation Type"::"Full VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateSEGLAccounts.SalesVAT12(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 12, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT6(), '', '', VAT6(), 6, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateSEGLAccounts.SalesVAT12(), CreateSEGLAccounts.PurchaseVAT12EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateSEGLAccounts.PurchaseVAT12EU(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25EU(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT6(), '', '', VAT6(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateSEGLAccounts.SalesVAT12(), CreateGLAccount.PurchaseVAT25(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT6(), '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

#if not CLEAN27
    [Obsolete('This procedure is moved to codeunit 5473 "Create VAT Posting Groups".', '27.0')]
    procedure NoVat(): Code[20]
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        exit(CreateVATPostingGroups.NoVAT());
    end;
#endif

    procedure Only(): Code[20]
    begin
        exit(OnlyTok);
    end;

    procedure VAT25(): Code[20]
    begin
        exit(VAT25Tok);
    end;

    procedure VAT12(): Code[20]
    begin
        exit(VAT12Tok);
    end;

    procedure VAT6(): Code[20]
    begin
        exit(VAT6Tok);
    end;

    var
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        OnlyTok: Label 'ONLY', Locked = true;
        OnlyDescriptionLbl: Label 'Manually posted VAT', MaxLength = 100;
        VAT12Tok: Label 'VAT12', Locked = true;
        Vat12DescriptionLbl: Label 'Miscellaneous 12 VAT', MaxLength = 100;
        VAT25Tok: Label 'VAT25', Locked = true;
        Vat25DescriptionLbl: Label 'Miscellaneous 25 VAT', MaxLength = 100;
        VAT6Tok: Label 'VAT6', Locked = true;
        Vat6DescriptionLbl: Label 'Miscellaneous 6 VAT', MaxLength = 100;

}
