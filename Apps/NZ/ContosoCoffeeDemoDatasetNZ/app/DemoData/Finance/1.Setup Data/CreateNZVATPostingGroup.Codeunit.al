// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Setup;
using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 17124 "Create NZ VAT Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenBusinessPostingGroup(var Rec: Record "VAT Business Posting Group")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVATPostingGroups.Export():
                Rec.Validate(Description, ExportPostingGroupDescriptionLbl);
        end;
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT15(), MiscellaneousVAT15VATDescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", VAT15());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(VAT9(), MiscellaneousVAT9VATDescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", VAT9());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.NoVAT(), NoVATDescriptionLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", CreateVATPostingGroups.NoVAT());
        end;

        FinanceModuleSetup.Modify(true);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(MISC(), MiscPostingGroupDescriptionLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateNZGLAccounts: Codeunit "Create NZ GL Accounts";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 15, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(MISC(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(MISC(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 15, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(MISC(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);

        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure MISC(): Code[20]
    begin
        exit(MiscTok);
    end;

#if not CLEAN27
    [Obsolete('This procedure is moved to codeunit 5473 "Create VAT Posting Groups".', '27.0')]
    procedure NoVAT(): Code[20]
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        exit(CreateVATPostingGroups.NOVAT());
    end;
#endif

    procedure VAT15(): Code[20]
    begin
        exit(VAT15Tok);
    end;

    procedure VAT9(): Code[20]
    begin
        exit(VAT9Tok);
    end;

    var
        MiscTok: Label 'MISC', MaxLength = 20;
        VAT15Tok: Label 'VAT15', MaxLength = 20;
        VAT9Tok: Label 'VAT9', MaxLength = 20;
        MiscPostingGroupDescriptionLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not MISC)', MaxLength = 100;
        NoVATDescriptionLbl: Label 'No VAT', MaxLength = 100;
        MiscellaneousVAT15VATDescriptionLbl: Label 'Miscellaneous VAT15 VAT', MaxLength = 100;
        MiscellaneousVAT9VATDescriptionLbl: Label 'Miscellaneous VAT9 VAT', MaxLength = 100;
}
