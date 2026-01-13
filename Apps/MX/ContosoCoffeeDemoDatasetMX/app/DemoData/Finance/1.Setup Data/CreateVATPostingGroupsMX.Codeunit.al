// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 14107 "Create VAT Posting Groups MX"
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
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 16, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 8, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 16, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateMXGLAccounts.PurchaseVat16PercEu(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 8, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateMXGLAccounts.PurchaseVat8PercEu(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT16(), StrSubstNo(MiscellaneousVATLbl, '16'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", VAT16());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT8(), StrSubstNo(MiscellaneousVATLbl, '8'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", VAT8());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.NoVAT(), StrSubstNo(MiscellaneousVATLbl, '0'));
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", CreateVATPostingGroups.NoVAT());
        end;

        FinanceModuleSetup.Modify(true);
    end;

#if not CLEAN27
    [Obsolete('Use NoVAT() in codeunit 5473 "Create VAT Posting Groups" instead.', '27.0')]
    procedure NOVAT(): Code[20]
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        exit(CreateVATPostingGroups.NOVAT());
    end;
#endif

    procedure VAT16(): Code[20]
    begin
        exit(VAT16Tok);
    end;

    procedure VAT8(): Code[20]
    begin
        exit(VAT8Tok);
    end;

    var
        VAT16Tok: Label 'VAT16', MaxLength = 20;
        VAT8Tok: Label 'VAT8', MaxLength = 20;
        MiscellaneousVATLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}
