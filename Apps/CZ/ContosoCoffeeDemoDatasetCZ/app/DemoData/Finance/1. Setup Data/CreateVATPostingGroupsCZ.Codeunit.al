// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Foundation.Enums;

codeunit 31189 "Create Vat Posting Groups CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATClause();
        InsertVATProductPostingGroup();
    end;

    procedure InsertVATPostingSetupWithoutGLAccounts()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetupCZ: Codeunit "Contoso Posting Setup CZ";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingSetupCZ.InsertVATPostingSetup('', NOVAT(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::" ");
        ContosoPostingSetupCZ.InsertVATPostingSetup('', VAT12I(), VAT12I(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup('', VAT12S(), VAT12S(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup('', VAT21I(), VAT21I(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup('', VAT21S(), VAT21S(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NOVAT(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::" ");
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12RC(), VAT12RC(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", RC12(), false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12I(), VAT12I(), 12, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12S(), VAT12S(), 12, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21RC(), VAT21RC(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", RC21(), false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21I(), VAT21I(), 21, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21S(), VAT21S(), 21, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NOVAT(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::" ");
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT12I(), VAT12I(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", EU(), false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT12S(), VAT12S(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", EU(), true, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT21I(), VAT21I(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", EU(), false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT21S(), VAT21S(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", EU(), true, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NOVAT(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::" ");
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT12I(), VAT12I(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT12S(), VAT12S(), 12, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Reduced);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT21I(), VAT21I(), 0, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
        ContosoPostingSetupCZ.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT21S(), VAT21S(), 21, Enum::"Tax Calculation Type"::"Normal VAT", '', false, "VAT Rate CZL"::Base);
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetupCZ: Codeunit "Contoso Posting Setup CZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingSetupCZ.UpdateVATPostingSetup('', NOVAT(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup('', VAT12I(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup('', VAT12S(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup('', VAT21I(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup('', VAT21S(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), NOVAT(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12RC(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), CreateGLAccountCZ.ReverseChargeVAT12());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12I(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12S(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21RC(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), CreateGLAccountCZ.ReverseChargeVAT21());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21I(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT21S(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), NOVAT(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), VAT12I(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), CreateGLAccountCZ.ReverseChargeVAT12());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), VAT12S(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), CreateGLAccountCZ.ReverseChargeVAT12());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), VAT21I(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), CreateGLAccountCZ.ReverseChargeVAT21());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), VAT21S(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), CreateGLAccountCZ.ReverseChargeVAT21());
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Export(), NOVAT(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Export(), VAT12I(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Export(), VAT12S(), CreateGLAccountCZ.OutputVAT12(), CreateGLAccountCZ.InputVAT12(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Export(), VAT21I(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
        ContosoPostingSetupCZ.UpdateVATPostingSetup(CreateVATPostingGroups.Export(), VAT21S(), CreateGLAccountCZ.OutputVAT21(), CreateGLAccountCZ.InputVAT21(), '');
    end;

    procedure DeleteVATProductPostingGroups()
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        VATProductPostingGroup.SetFilter(Code, '%1|%2|%3|%4|%5|%6|%7|%8', CreateVATPostingGroups.FullNormal(), CreateVATPostingGroups.FullRed(), CreateVATPostingGroups.Standard(), CreateVATPostingGroups.Reduced(), CreateVATPostingGroups.ServNormal(), CreateVATPostingGroups.ServRed(), CreateVATPostingGroups.Zero(), '');
        VATProductPostingGroup.DeleteAll(true);
    end;

    procedure DeleteVATClauses()
    var
        VATClause: Record "VAT Clause";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        VATClause.SetFilter(Code, '%1|%2', CreateVATPostingGroups.Reduced(), CreateVATPostingGroups.Zero());
        VATClause.DeleteAll(true);
    end;

    internal procedure CreateDummyVATProductPostingGroup()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Reduced(), ''); // Reduced is used in Resources in Finance module
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Standard(), ''); // Standard is used in VAT Posting Setup in Common module
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATProductPostingGroup(NOVAT(), MiscellaneousWithoutVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT12I(), VAT12itemLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT12RC(), VAT12reversechargeLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT12S(), VAT12serviceLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT21I(), VAT21itemLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT21RC(), VAT21reversechargeLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT21S(), VAT21serviceLbl);
    end;

    local procedure InsertVATClause()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        ContosoPostingSetupCZ: Codeunit "Contoso Posting Setup CZ";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingSetup.InsertVATClause(EU(), EUVATClauseDescriptionLbl);
        ContosoPostingSetupCZ.InsertVATClause(RC12(), ReverseChargeVATClauseDescriptionLbl, StrSubstNo(ReverseChargeVATClauseDescription2Lbl, 21));
        ContosoPostingSetupCZ.InsertVATClause(RC21(), ReverseChargeVATClauseDescriptionLbl, StrSubstNo(ReverseChargeVATClauseDescription2Lbl, 21));
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertVATPostingSetup(var Rec: Record "VAT Posting Setup")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        if Rec."VAT Prod. Posting Group" in
            [CreateVATPostingGroups.FullNormal(), CreateVATPostingGroups.FullRed(),
             CreateVATPostingGroups.Standard(), CreateVATPostingGroups.Reduced(),
             CreateVATPostingGroups.ServNormal(), CreateVATPostingGroups.ServRed(),
             CreateVATPostingGroups.Zero(), '']
        then
            Rec.Delete(true);
    end;

    procedure EU(): Code[20]
    begin
        exit(EULbl);
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NOVATLbl);
    end;

    procedure RC12(): Code[20]
    begin
        exit(RC12Lbl);
    end;

    procedure RC21(): Code[20]
    begin
        exit(RC21Lbl);
    end;

    procedure VAT12RC(): Code[20]
    begin
        exit(VAT12RCLbl);
    end;

    procedure VAT12S(): Code[20]
    begin
        exit(VAT12SLbl);
    end;

    procedure VAT12I(): Code[20]
    begin
        exit(VAT12ILbl);
    end;

    procedure VAT21RC(): Code[20]
    begin
        exit(VAT21RCLbl);
    end;

    procedure VAT21S(): Code[20]
    begin
        exit(VAT21SLbl);
    end;

    procedure VAT21I(): Code[20]
    begin
        exit(VAT21ILbl);
    end;

    var
        EULbl: Label 'EU', MaxLength = 20;
        EUVATClauseDescriptionLbl: Label 'This is an exempt performance according to Act No. 235/2004 Coll., the Value Added Tax Act as amended. The tax will be paid by the customer.', MaxLength = 250;
        ReverseChargeVATClauseDescriptionLbl: Label 'According to §92a of Act No. 235/2004 Coll. on VAT, it is a transfer of tax liability, where the amount of tax is REQUIRED to be ADDED AND ADMITTED', MaxLength = 250;
        ReverseChargeVATClauseDescription2Lbl: Label 'the taxpayer for whom the transaction was carried out. The VAT rate is %1% and the customer pays the tax.', MaxLength = 250, Comment = '%1 = vat rate';
        MiscellaneousWithoutVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NOVATLbl: Label 'NO VAT', MaxLength = 20;
        RC12Lbl: Label 'RC12', MaxLength = 20;
        RC21Lbl: Label 'RC21', MaxLength = 20;
        VAT12RCLbl: Label 'VAT12RC', MaxLength = 20;
        VAT12reversechargeLbl: Label 'VAT 12% reverse charge', MaxLength = 100;
        VAT12SLbl: Label 'VAT12S', MaxLength = 20;
        VAT12serviceLbl: Label 'VAT 12% service', MaxLength = 100;
        VAT12ILbl: Label 'VAT12I', MaxLength = 20;
        VAT12itemLbl: Label 'VAT 12% item', MaxLength = 100;
        VAT21RCLbl: Label 'VAT21RC', MaxLength = 20;
        VAT21reversechargeLbl: Label 'VAT 21% reverse charge', MaxLength = 100;
        VAT21SLbl: Label 'VAT21S', MaxLength = 20;
        VAT21serviceLbl: Label 'VAT 21% service', MaxLength = 100;
        VAT21ILbl: Label 'VAT21I', MaxLength = 20;
        VAT21itemLbl: Label 'VAT 21% item', MaxLength = 100;
}
