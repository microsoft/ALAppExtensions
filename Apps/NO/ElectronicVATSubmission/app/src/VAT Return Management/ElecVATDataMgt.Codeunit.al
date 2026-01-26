// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;

codeunit 10683 "Elec. VAT Data Mgt."
{
    var
        InputVATDeductibleDomesticTxt: Label 'Input VAT deduct. (domestic)', Comment = 'Fradragsberettiget innenlands inngående merverdiavgift';
        InputVATDeductiblePayedOnImportTxt: Label 'Input VAT deduct. (payed on import)', Comment = 'Fradragsberettiget innførselsmerverdiavgift';
        OutputVATTxt: Label 'Output VAT', Comment = 'Utgående merverdiavgift';
        DomesticSalesReverseChargeTxt: Label 'Domestic sales of reverce charge /VAT obligation', Comment = 'Innenlandsk omsetning med omvendt avgiftplikt';
        NotLiableToVATTreatmentTxt: Label 'Not liable to VAT treatment, turnover outside the scope of the VAT legislation', Comment = 'Omsetning utenfor merverdiavgiftsloven';
        ExportOfGoodsAndServicesTxt: Label 'Export of goods and services', Comment = 'Utførsel av varer og tjenester';
        ImportationOfGoodsVATDeductibleTxt: Label 'Importation of goods, VAT deduct.', Comment = 'Grunnlag innførsel av varer med fradragsrett for innførselsmerverdiavgift';

        ImportationOfGoodsWithoutDeductionOfVATTxt: Label 'Importation of goods, without deduction of VAT', Comment = 'Grunnlag innførsel av varer uten fradragsrett for innførselsmerverdiavgift';
        ImportationOfGoodsNotApplicableForVATTxt: Label 'Importation of goods, not applicable for VAT', Comment = 'Grunnlag innførsel av varer som det ikke skal beregnes merverdiavgift av';
        ServicesPurchasedFromAbroadVATDeductibleTxt: Label 'Services purchased from abroad, VAT deduct.', Comment = 'Tjenester kjøpt fra utlandet med fradragsrett for merverdiavgift';
        ServicesPurchasedFromAbroadWithoutVATDeductionTxt: Label 'Services purchased from abroad, without deduction of VAT', Comment = 'Tjenester kjøpt fra utlandet uten fradragsrett for merverdiavgift';
        PurchaseOfEmissionsTradingOrGoldVATDeductibleTxt: Label 'Purchase of emissions trading or gold, VAT deduct.', Comment = 'Kjøp av klimakvoter eller gull med fradragsrett for merverdiavgift';
        PurchaseOfEmissionsTradingOrGoldWithoutVATDeductionTxt: Label 'Purchase of emissions trading or gold, without deduction of VAT', Comment = 'Kjøp av klimakvoter eller gull uten fradragsrett for merverdiavgift';
        VATStatementNameNotSpecifiedErr: Label 'VAT statement template or VAT statement name has not been specified.';
        VATStatementWithNameAlreadyExistsErr: Label 'VAT statement %1 already exists. Specify another name.', Comment = '%1 = name of the VAT statement';

        NewVATStatementNameDescriptionLbl: Label 'VAT statement for electronic VAT submission';
        VATRatesForReportingHaveBeenSetMsg: Label 'The actual VAT rates for reporting have been assigned to VAT codes.';

    procedure InsertMissingVATSpecificationsAndNotes()
    var
        VATSpecification: Record "VAT Specification";
        TempVATSpecification: Record "VAT Specification" temporary;
        VATNote: Record "VAT Note";
        TempVATNote: Record "VAT Note" temporary;
        NorwegianVATTools: Codeunit "Norwegian VAT Tools";
    begin
        NorwegianVATTools.GetVATSpecifications2022(TempVATSpecification);
        TempVATSpecification.FindSet();
        repeat
            VATSpecification := TempVATSpecification;
            if VATSpecification.Insert() then;
        until TempVATSpecification.Next() = 0;
        NorwegianVATTools.GetVATNotes2022(TempVATNote);
        TempVATNote.FindSet();
        repeat
            VATNote := TempVATNote;
            if VATNote.Insert() then;
        until TempVATNote.Next() = 0;
    end;

    procedure GetMissingVATReportingCodes(var TempMissingVATReportingCode: Record "VAT Reporting Code" temporary) MissedCodesExist: Boolean
    var
        TempRequiredVATCode: Record "VAT Reporting Code" temporary;
        TempNewVATCode: Record "VAT Reporting Code" temporary;
        VATReportingCode: Record "VAT Reporting Code";
        NorwegianVATTools: Codeunit "Norwegian VAT Tools";
    begin
        TempMissingVATReportingCode.Reset();
        TempMissingVATReportingCode.DeleteAll();
        GetRequiredVATReportingCodes(TempRequiredVATCode);
        NorwegianVATTools.GetVATReportingCodes2022(TempNewVATCode);
        if TempNewVATCode.FindSet() then
            repeat
                if TempRequiredVATCode.Get(TempNewVATCode."SAF-T VAT Code") then begin
                    TempNewVATCode."Report VAT Rate" := TempRequiredVATCode."Report VAT Rate";
                    TempNewVATCode."VAT Rate For Reporting" := TempRequiredVATCode."VAT Rate For Reporting";
                    TempRequiredVATCode := TempNewVATCode;
                    if TempRequiredVATCode.Insert() then;
                end;
            until TempNewVATCode.Next() = 0;
        TempRequiredVATCode.FindSet();
        repeat
            if not VATReportingCode.Get(TempRequiredVATCode.Code) then begin
                TempMissingVATReportingCode := TempRequiredVATCode;
                TempMissingVATReportingCode.Insert();
                MissedCodesExist := true;
            end;
        until TempRequiredVATCode.Next() = 0;
        exit(MissedCodesExist)
    end;

    procedure AddVATReportingCodes(var TempVATReportingCode: Record "VAT Reporting Code" temporary)
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        if not TempVATReportingCode.FindSet() then
            exit;

        repeat
            if not VATReportingCode.Get(TempVATReportingCode.Code) then begin
                VATReportingCode := TempVATReportingCode;
                VATReportingCode.Insert(true);
            end;
        until TempVATReportingCode.Next() = 0;
    end;

    procedure SetVATRatesForReportingOnVATReportingCodes()
    var
        TempRequiredVATCode: Record "VAT Reporting Code" temporary;
        VATReportingCode: Record "VAT Reporting Code";
    begin
        GetRequiredVATReportingCodes(TempRequiredVATCode);
        TempRequiredVATCode.FindSet();
        repeat
            if VATReportingCode.Get(TempRequiredVATCode.Code) then begin
                VATReportingCode."VAT Rate For Reporting" := TempRequiredVATCode."VAT Rate For Reporting";
                VATReportingCode."Report VAT Rate" := TempRequiredVATCode."Report VAT Rate";
                VATReportingCode.Modify();
            end;
        until TempRequiredVATCode.Next() = 0;
        if GuiAllowed() then
            Message(VATRatesForReportingHaveBeenSetMsg);
    end;

    procedure CreateVATStatement(VATStatementTemplateName: Code[10]; NewVATStatementName: Code[10])
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        if (VATStatementTemplateName = '') or (NewVATStatementName = '') then
            error(VATStatementNameNotSpecifiedErr);
        if VATStatementName.Get(NewVATStatementName) then
            Error(VATStatementWithNameAlreadyExistsErr);
        VATStatementName."Statement Template Name" := VATStatementTemplateName;
        VATStatementName.Name := NewVATStatementName;
        VATStatementName.Description := NewVATStatementNameDescriptionLbl;
        VATStatementName.Insert(true);
        CreateVATStatementLines(VATStatementName);
    end;

    procedure IsReverseChargeVATCode(VATCode: Code[20]): Boolean
    begin
        exit(VATCode in ['81', '83', '86', '88', '91'])
    end;

    procedure IsVATCodeWithDeductiblePart(VATCode: Code[20]): Boolean
    begin
        exit(VATCode in ['1', '11', '13'])
    end;

    procedure GetDigitVATRegNo(): Text[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        exit(DelChr(CompanyInformation."VAT Registration No.", '=', DelChr(CompanyInformation."VAT Registration No.", '=', '1234567890')));
    end;

    local procedure CreateVATStatementLines(VATStatementName: Record "VAT Statement Name")
    var
        TempRequiredVATCode: Record "VAT Reporting Code" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        TempVATPostingSetup: Record "VAT Posting Setup" temporary;
        VATStatementLine: Record "VAT Statement Line";
        AmountRowNo: Integer;
        RowTotalingFilter: Text[50];
        RowNo: Text[20];
        BoxNo: Text[30];
        LineNo: Integer;
        SetupCount: Integer;
        CalculateWith: Option;
    begin
        GetRequiredVATReportingCodes(TempRequiredVATCode);
        TempRequiredVATCode.FindSet();
        repeat
            TempVATPostingSetup.Reset();
            TempVATPostingSetup.DeleteAll();
            VATPostingSetup.Reset();
            VATPostingSetup.SetRange("Sale VAT Reporting Code", TempRequiredVATCode.Code);
            CopyVATPostingSetupToTempVATPostingSetup(TempVATPostingSetup, VATPostingSetup);
            VATPostingSetup.Reset();
            VATPostingSetup.SetRange("Purch. VAT Reporting Code", TempRequiredVATCode.Code);
            CopyVATPostingSetupToTempVATPostingSetup(TempVATPostingSetup, VATPostingSetup);
            if TempVATPostingSetup.FindSet() then begin
                AmountRowNo := 0;
                RowTotalingFilter := '';
                SetupCount := TempVATPostingSetup.Count();
                if IsReverseChargeVATCode(TempRequiredVATCode.Code) then
                    CalculateWith := VATStatementLine."Calculate with"::Sign
                else
                    CalculateWith := VATStatementLine."Calculate with"::"Opposite Sign";
                repeat
                    RowNo := TempRequiredVATCode.Code;
                    if (SetupCount > 1) or
                       ((TempVATPostingSetup."Sale VAT Reporting Code" = TempRequiredVATCode.Code) and (TempVATPostingSetup."Purch. VAT Reporting Code" = TempRequiredVATCode.Code))
                    then
                        BoxNo := ''
                    else
                        BoxNo := TempRequiredVATCode.Code;
                    if TempVATPostingSetup."Sale VAT Reporting Code" = TempRequiredVATCode.Code then begin
                        LineNo += 10000;
                        AmountRowNo += 1;
                        if BoxNo = '' then
                            RowNo += '-' + Format(AmountRowNo);
                        CreateVATEntryTotalingLine(
                            VATStatementLine, VATStatementName, RowNo, BoxNo, TempRequiredVATCode.Description, TempVATPostingSetup,
                            VATStatementLine."Gen. Posting Type"::Sale, LineNo, CalculateWith);
                        AddToFilter(RowTotalingFilter, VATStatementLine."Row No.");
                    end;
                    if TempVATPostingSetup."Purch. VAT Reporting Code" = TempRequiredVATCode.Code then begin
                        LineNo += 10000;
                        AmountRowNo += 1;
                        if BoxNo = '' then
                            RowNo += '-' + Format(AmountRowNo);
                        CreateVATEntryTotalingLine(
                            VATStatementLine, VATStatementName, RowNo, BoxNo, TempRequiredVATCode.Description, TempVATPostingSetup,
                            VATStatementLine."Gen. Posting Type"::Purchase, LineNo, CalculateWith);
                        AddToFilter(RowTotalingFilter, VATStatementLine."Row No.");
                    end;
                until TempVATPostingSetup.Next() = 0;
                if BoxNo = '' then begin
                    LineNo += 10000;
                    CreateRowTotalingLine(VATStatementName, TempRequiredVATCode.Code, TempRequiredVATCode.Description, LineNo, RowTotalingFilter);
                end;
            end;
        until TempRequiredVATCode.Next() = 0;
    end;

    local procedure AddToFilter(var Filter: Text[50]; Value: Text)
    begin
        if Filter <> '' then
            Filter += '|';
        Filter += Value;
    end;

    local procedure CopyVATPostingSetupToTempVATPostingSetup(var TempVATPostingSetup: Record "VAT Posting Setup" temporary; var VATPostingSetup: Record "VAT Posting Setup")
    begin
        if not VATPostingSetup.FindSet() then
            exit;
        repeat
            TempVATPostingSetup := VATPostingSetup;
            if not TempVATPostingSetup.Insert() then;
        until VATPostingSetup.Next() = 0;
    end;

    local procedure CreateVATEntryTotalingLine(var VATStatementLine: Record "VAT Statement Line"; VATStatementName: Record "VAT Statement Name"; RowNo: Code[20]; BoxNo: Text[30]; Description: Text[250]; VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Enum "General Posting Type"; LineNo: Integer; CalculateWith: Option)
    begin
        VATStatementLine.Init();
        VATStatementLine.Validate("Statement Template Name", VATStatementName."Statement Template Name");
        VATStatementLine.Validate("Statement Name", VATStatementName.Name);
        VATStatementLine.Validate("Line No.", LineNo);
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Row No.", RowNo);
        VATStatementLine.Validate("Box No.", BoxNo);
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATStatementLine.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("Amount Type", VATStatementLine."Amount Type"::Amount);
        VATStatementLine.Validate("Calculate with", CalculateWith);
        VATStatementLine.Insert(true);
    end;

    local procedure CreateRowTotalingLine(VATStatementName: Record "VAT Statement Name"; VATCode: Code[20]; Description: Text[250]; LineNo: Integer; RowTotalingFilter: Text[50])
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.Init();
        VATStatementLine.Validate("Statement Template Name", VATStatementName."Statement Template Name");
        VATStatementLine.Validate("Statement Name", VATStatementName.Name);
        VATStatementLine.Validate("Line No.", LineNo);
        VATStatementLine.Validate(Type, VATStatementLine.Type::"Row Totaling");
        VATStatementLine.Validate("Row No.", VATCode);
        VATStatementLine.Validate("Box No.", VATStatementLine."Row No.");
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate("Row Totaling", RowTotalingFilter);
        VATStatementLine.Insert(true);
    end;

    local procedure GetRequiredVATReportingCodes(var TempRequiredVATCode: Record "VAT Reporting Code" temporary)
    begin
        InsertTempVATReportingCode(TempRequiredVATCode, '1', InputVATDeductibleDomesticTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '3', OutputVATTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '5', DomesticSalesReverseChargeTxt, 0, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '6', NotLiableToVATTreatmentTxt, 0, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '11', InputVATDeductibleDomesticTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '12', InputVATDeductibleDomesticTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '13', InputVATDeductibleDomesticTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '14', InputVATDeductiblePayedOnImportTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '15', InputVATDeductiblePayedOnImportTxt, 0, false);
        InsertTempVATReportingCode(TempRequiredVATCode, '31', OutputVATTxt, 15, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '32', OutputVATTxt, 11.11, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '33', OutputVATTxt, 12, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '51', DomesticSalesReverseChargeTxt, 0, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '52', ExportOfGoodsAndServicesTxt, 0, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '81', ImportationOfGoodsVATDeductibleTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '82', ImportationOfGoodsWithoutDeductionOfVATTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '83', ImportationOfGoodsVATDeductibleTxt, 15, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '84', ImportationOfGoodsWithoutDeductionOfVATTxt, 15, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '85', ImportationOfGoodsNotApplicableForVATTxt, 0, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '86', ServicesPurchasedFromAbroadVATDeductibleTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '87', ServicesPurchasedFromAbroadWithoutVATDeductionTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '88', ServicesPurchasedFromAbroadVATDeductibleTxt, 12, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '89', ServicesPurchasedFromAbroadWithoutVATDeductionTxt, 12, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '91', PurchaseOfEmissionsTradingOrGoldVATDeductibleTxt, 25, true);
        InsertTempVATReportingCode(TempRequiredVATCode, '92', PurchaseOfEmissionsTradingOrGoldWithoutVATDeductionTxt, 25, true);
    end;

    local procedure InsertTempVATReportingCode(var TempVATReportingCode: Record "VAT Reporting Code"; Code: Code[20]; Description: Text; VATRateForReporting: Decimal; ReportVATRate: Boolean)
    begin
        TempVATReportingCode.Code := Code;
        TempVATReportingCode.Description := CopyStr(Description, 1, MaxStrLen(TempVATReportingCode.Description));
        TempVATReportingCode."VAT Rate For Reporting" := VATRateForReporting;
        TempVATReportingCode."Report VAT Rate" := ReportVATRate;
        TempVATReportingCode.Insert();
        GetRelatedVATReportingCodes(TempVATReportingCode, TempVATReportingCode.Code);
    end;

    local procedure GetRelatedVATReportingCodes(var TempRelatedVATReportingCode: Record "VAT Reporting Code" temporary; VATCodeValue: Code[20]): Boolean
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATReportingCode.SetRange("SAF-T VAT Code", VATCodeValue);
        if not VATReportingCode.FindSet() then
            exit(false);

        repeat
            TempRelatedVATReportingCode := VATReportingCode;
            TempRelatedVATReportingCode.Insert();
        until VATReportingCode.Next() = 0;
        exit(true);
    end;
}
