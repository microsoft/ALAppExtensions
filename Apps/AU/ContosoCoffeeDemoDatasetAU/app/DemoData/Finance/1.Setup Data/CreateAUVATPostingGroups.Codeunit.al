// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Foundation.Enums;
using Microsoft.DemoTool.Helpers;

codeunit 17121 "Create AU VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", '', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.DomesticPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.MiscPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 10, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.MiscPostingGroup(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroups.ExportPostingGroup(), '', CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), '', 0, Enum::"Tax Calculation Type"::"Normal VAT");
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Standard" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Gst10(), Gst10Lbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Standard", Gst10());
        end;

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", Gst10());

        if FinanceModuleSetup."VAT Prod. Post Grp. NO VAT" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(NonGst(), NonGstLbl);
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. NO VAT", NonGst());
        end;

        FinanceModuleSetup.Modify(true);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CreatePostingGroups.ExportPostingGroup(), 'Other customers and vendors (not MISC)');
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CreatePostingGroups.MiscPostingGroup(), CustomersAndVendorsInMiscLbl);
    end;

    procedure Gst10(): Code[20]
    begin
        exit(Gst10Tok);
    end;

    procedure NonGst(): Code[20]
    begin
        exit(NonGstTok);
    end;

#if not CLEAN27
    [Obsolete('Use Gst10() instead.', '27.0')]
    procedure Vat10(): Code[20]
    begin
        exit(Gst10Tok);
    end;

    [Obsolete('Use NonGst() instead.', '27.0')]
    procedure NoVat(): Code[20]
    begin
        exit(NonGstTok);
    end;

    [Obsolete('Use Gst10() instead.', '27.0')]
    procedure Vat15(): Code[20]
    begin
        exit(Gst10Tok);
    end;
#endif

    var
        Gst10Tok: Label 'GST10', MaxLength = 20, Locked = true;
        NonGstTok: Label 'NON GST', MaxLength = 20, Locked = true;
        Gst10Lbl: Label 'GST10', MaxLength = 100;
        NonGstLbl: Label 'NON GST', MaxLength = 100;
        CustomersAndVendorsInMiscLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
}
