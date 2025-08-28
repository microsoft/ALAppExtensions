// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.DemoTool.Helpers;

codeunit 13429 "Create Vat Posting Groups FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATProductPostingGroup(var Rec: Record "VAT Product Posting Group")
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        FinanceModuleSetup.Get();

        case Rec.Code of
            CreateVATPostingGroups.FullNormal():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '24'));
            CreateVATPostingGroups.FullRed():
                Rec.Validate(Description, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '17'));
            FinanceModuleSetup."VAT Prod. Post Grp. Reduced":
                Rec.Validate(Description, StrSubstNo(ReducedVatDescriptionLbl, '14'));
            CreateVATPostingGroups.ServNormal():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '24'));
            CreateVATPostingGroups.ServRed():
                Rec.Validate(Description, StrSubstNo(MiscellaneousVATDescriptionLbl, '17'));
            FinanceModuleSetup."VAT Prod. Post Grp. Standard":
                Rec.Validate(Description, StrSubstNo(NormalVatDescriptionLbl, '25.5'));
        end;
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT8(), Vat8DescriptionLbl);
    end;

    procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 14, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25.5, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 14, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables6(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25.5, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables4(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateFIGLAccounts.Deferredtaxreceivables6(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT8(), CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1(), FinanceModuleSetup."VAT Prod. Post Grp. No VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. No VAT", false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure VAT8(): Code[20]
    begin
        exit(VAT8Tok);
    end;

    var
        VAT8Tok: Label 'VAT10';
        Vat8DescriptionLbl: Label 'Miscellaneous 10 VAT', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}
