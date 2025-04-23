// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Enums;
using Microsoft.DemoTool.Helpers;

codeunit 11120 "Create DE VAT Statement"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        ContosoVATStatement.InsertVATStatementName(CreateVATStatement.VATTemplateName(), USTVATStatementName(), StatementNameDescLbl);
        CreateVATStatementLine();
    end;

    local procedure CreateVATStatementLine()
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateDEVATPostingGroups: Codeunit "Create DE VAT Posting Groups";
    begin
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 10000, '', Enum::"VAT Statement Line Type"::"Description", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, MehrwertsteuerabrechnungLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 20000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 30000, '41', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, SteuerfreieErlöse41B1Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 40000, '41', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, SteuerfreieErlöse41B2Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 50000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 60000, '43', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StfrUmsätzeMVorstAbzug43B1Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 70000, '43', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StfrUmsätzeMVorstAbzug43B2Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 80000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 90000, '81A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StpflUmsätze81BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 100000, '81S', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, Umsatzsteuer81SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 110000, '50A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min19(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, MinderungBmg5019Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 120000, '50AS', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, MinderungBetr5019Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 130000, '81', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '81A|50A', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, StpflUmsätze81BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 140000, '81ST', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '81S|50AS', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, Umsatzsteuer81SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 150000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 160000, '86A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StpflUmsätze86BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 170000, '86S', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, Umsatzsteuer86SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 180000, '87', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.NoVAT(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StpflUmsätze87Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 190000, '50B', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min7(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, MinderungBmg507Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 200000, '50BS', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, MinderungBetr507Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 210000, '86', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '86A|50B', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, StpflUmsätze886BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 220000, '86ST', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '86S|50BS', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, Umsatzsteuer86SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 230000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 240000, '50', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min19(), '', Enum::"VAT Statement Line Amount Type"::Base, 1, true, 1, MinderungBmg5019Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 250000, '50', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min7(), '', Enum::"VAT Statement Line Amount Type"::Base, 1, true, 1, MinderungBmg507Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 260000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 270000, '36', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), '', '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, UmsätzeZuAnderenSteuersätzen36Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 280000, '35', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), '', '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 1, SteuerAusUmsätzeZuAnderenSteuersätzen35Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 290000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 300000, '91', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.NoVAT(), '', Enum::"VAT Statement Line Amount Type"::Base, 1, true, 1, InnergemErwerbe91Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 310000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 320000, '89', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Base, 1, true, 1, StpflInnergemErwerbe89BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 330000, '89', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, Erwerbsteuer89SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 340000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 350000, '93', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Base, 1, true, 1, StpflInnergemErwerbe93BLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 360000, '93', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, Erwerbsteuer93SLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 370000, '90', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.NoVAT(), '', Enum::"VAT Statement Line Amount Type"::Base, 0, true, 1, StpflInnergemErwerbe90Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 380000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 390000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 400000, '66A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, VorsteuerN66S1Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 410000, '66B', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, VorsteuerN66S2Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 420000, '37A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, MinderungBetr19Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 430000, '37B', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, MinderungBetr7Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 440000, '66', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '66A|66B|37A|37B', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VorsteuerN66Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 450000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 460000, '37', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, MinderungBetr19Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 470000, '37', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.Min7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 1, true, 1, MinderungBetr7Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 480000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 490000, '61A', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT19(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, Erwerbvorsteuer61S1Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 500000, '61B', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateDEVATPostingGroups.VAT7(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, Erwerbvorsteuer61S2Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 510000, '61', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '61A|61B', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, Erwerbvorsteuer61Lbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 520000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 530000, '62', Enum::"VAT Statement Line Type"::"VAT Entry Totaling", Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateDEVATPostingGroups.EUPostingGroupST(), '', Enum::"VAT Statement Line Amount Type"::Amount, 0, true, 0, EntrichteteEinfuhrumsatzsteuerLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 540000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 550000, '83', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '81|86|35|89|93|66|61|62', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VerbleibenderBetragLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 560000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, '', '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 570000, '', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ProbeLbl, '');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 580000, '10', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, UmsatzsteuerP51Lbl, '1775');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 590000, '11', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, UmsatzsteuerP86Lbl, '1771');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 600000, '12', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ErwerbsteuerP97Lbl, '1773');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 610000, '13', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, ErwerbsteuerP93Lbl, '1772');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 620000, '14', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, VorsteuerP66Lbl, '1571|1575');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 630000, '15', Enum::"VAT Statement Line Type"::"Account Totaling", Enum::"General Posting Type"::" ", '', '', '', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 0, ErwerbvorsteuerP61Lbl, '1773|1784');
        ContosoVatStatement.InsertVatStatementLine(CreateVATStatement.VATTemplateName(), USTVATStatementName(), 640000, '16', Enum::"VAT Statement Line Type"::"Row Totaling", Enum::"General Posting Type"::" ", '', '', '10..15', Enum::"VAT Statement Line Amount Type"::" ", 0, true, 1, VerbleibenderBetragLbl, '');
    end;

    procedure USTVATStatementName(): Code[10]
    begin
        exit(USTVATStatementNameTok);
    end;

    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVATStatement: Codeunit "Create VAT Statement";
        USTVATStatementNameTok: Label 'USTVA', Locked = true;
        StatementNameDescLbl: Label 'VAT Statement Germany', MaxLength = 100;
        MehrwertsteuerabrechnungLbl: Label 'MEHRWERTSTEUERABRECHNUNG', MaxLength = 100;
        SteuerfreieErlöse41B1Lbl: Label '41B1 / Steuerfreie Erlöse §4 1b UStG EG m. ID-Nr.', MaxLength = 100;
        SteuerfreieErlöse41B2Lbl: Label '41B2 / Steuerfreie Erlöse §4 1b UStG EG m. ID-Nr.', MaxLength = 100;
        StfrUmsätzeMVorstAbzug43B1Lbl: Label '43B1 / Stfr. Umsätze m. VorSt-Abzug §4 2-7 UStG', MaxLength = 100;
        StfrUmsätzeMVorstAbzug43B2Lbl: Label '43B2 / Stfr. Umsätze m. VorSt-Abzug §4 2-7 UStG', MaxLength = 100;
        StpflUmsätze81BLbl: Label '81B / Stpfl. Umsätze 19 %', MaxLength = 100;
        Umsatzsteuer81SLbl: Label '81S / Umsatzsteuer 19 %', MaxLength = 100;
        MinderungBetr5019Lbl: Label '50 / Minderung Betr 19%', MaxLength = 100;
        StpflUmsätze86BLbl: Label '86B / Stpfl. Umsätze 7 %', MaxLength = 100;
        StpflUmsätze87Lbl: Label '87 / Stpfl. Umsätze 0%', MaxLength = 100;
        MinderungBetr507Lbl: Label '50 / Minderung Betr 7%', MaxLength = 100;
        StpflUmsätze886BLbl: Label '886B / Stpfl. Umsätze 7 %', MaxLength = 100;
        Umsatzsteuer86SLbl: Label '86S / Umsatzsteuer 7 %', MaxLength = 100;
        MinderungBmg5019Lbl: Label '50 / Minderung Bmg 19%', MaxLength = 100;
        MinderungBmg507Lbl: Label '50 / Minderung Bmg 7%', MaxLength = 100;
        UmsätzeZuAnderenSteuersätzen36Lbl: Label '36 / Umsätze zu anderen Steuersätzen', MaxLength = 100;
        SteuerAusUmsätzeZuAnderenSteuersätzen35Lbl: Label '35 / Steuer aus Umsätze zu anderen Steuersätzen', MaxLength = 100;
        InnergemErwerbe91Lbl: Label '91 / Innergem. Erwerbe § 4b UStG', MaxLength = 100;
        StpflInnergemErwerbe89BLbl: Label '89B / Stpfl. innergem. Erwerbe 19 % n. §1a UStG', MaxLength = 100;
        Erwerbsteuer89SLbl: Label '89S / Erwerbsteuer 19 % n. §1a UStG', MaxLength = 100;
        StpflInnergemErwerbe93BLbl: Label '93B / Stpfl. innergem. Erwerbe 7 % n. §1a UStG', MaxLength = 100;
        Erwerbsteuer93SLbl: Label '93S / Erwerbsteuer 7 % n. §1a UStG', MaxLength = 100;
        StpflInnergemErwerbe90Lbl: Label '90 / Stpfl. innergem. Erwerbe 0%', MaxLength = 100;
        VorsteuerN66S1Lbl: Label '66S1 / Vorsteuer n. §15(1)1 u. n. §25b(5) UStG', MaxLength = 100;
        VorsteuerN66S2Lbl: Label '66S2 / Vorsteuer n. §15(1)1 u. n. §25b(5) UStG', MaxLength = 100;
        VorsteuerN66Lbl: Label '66 / Vorsteuer n. §15(1)1 u. n. §25b(5) UStG', MaxLength = 100;
        MinderungBetr19Lbl: Label '37 / Minderung Betr 19%', MaxLength = 100;
        MinderungBetr7Lbl: Label '37 / Minderung Betr 7%', MaxLength = 100;
        Erwerbvorsteuer61S1Lbl: Label '61S1 / Erwerbvorsteuer §15(1)3 UStG', MaxLength = 100;
        Erwerbvorsteuer61S2Lbl: Label '61S2 / Erwerbvorsteuer §15(1)3 UStG', MaxLength = 100;
        Erwerbvorsteuer61Lbl: Label '61 / Erwerbvorsteuer §15(1)3 UStG', MaxLength = 100;
        EntrichteteEinfuhrumsatzsteuerLbl: Label 'Entrichtete Einfuhrumsatzsteuer §15(1)S.1 Nr.2UStG', MaxLength = 100;
        ProbeLbl: Label 'PROBE', MaxLength = 100;
        UmsatzsteuerP51Lbl: Label 'P51 / Umsatzsteuer 19 %', MaxLength = 100;
        UmsatzsteuerP86Lbl: Label 'P86 / Umsatzsteuer 7 %', MaxLength = 100;
        ErwerbsteuerP97Lbl: Label 'P97 / Erwerbsteuer 19 %', MaxLength = 100;
        ErwerbsteuerP93Lbl: Label 'P93 / Erwerbsteuer 7 %', MaxLength = 100;
        VorsteuerP66Lbl: Label 'P66 / Vorsteuer', MaxLength = 100;
        ErwerbvorsteuerP61Lbl: Label 'P61 / Erwerbvorsteuer', MaxLength = 100;
        VerbleibenderBetragLbl: Label 'Verbleibender Betrag', MaxLength = 100;
}
