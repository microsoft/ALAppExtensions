// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Vendor;
using System.Environment.Configuration;
using System.IO;
using System.Utilities;

codeunit 27021 "DIOT Data Management"
{
    var
        DIOTSetupGuideTxt: Label 'Set up DIOT';
        ConceptDesc01Txt: Label 'Total value of acts or activities paid in the northern border region';
        ConceptDesc02Txt: Label 'Returns, discounts and bonuses paid in the northern border region';
        ConceptDesc03Txt: Label 'Total value of acts or activities paid in the southern border region';
        ConceptDesc04Txt: Label 'Returns, discounts and bonuses paid in the southern border region';
        ConceptDesc05Txt: Label 'Total value of acts or activities paid at 16% VAT rate';
        ConceptDesc06Txt: Label 'Returns, discounts and bonuses paid at 16% VAT rate';
        ConceptDesc07Txt: Label 'Total value of acts or activities paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc08Txt: Label 'Returns, discounts and bonuses paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc09Txt: Label 'Total value of acts or activities paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc10Txt: Label 'Returns, discounts and bonuses paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc11Txt: Label 'Exclusively from taxed activities paid in the northern border region';
        ConceptDesc12Txt: Label 'Activities with applied proportion paid in the northern border region';
        ConceptDesc13Txt: Label 'Exclusively from taxed activities paid in the southern border region';
        ConceptDesc14Txt: Label 'Activities with applied proportion paid in the southern border region';
        ConceptDesc15Txt: Label 'Exclusively from taxed activities paid at 16% VAT rate';
        ConceptDesc16Txt: Label 'Activities with applied proportion paid at 16% VAT rate';
        ConceptDesc17Txt: Label 'Exclusively from taxed activities paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc18Txt: Label 'Activities with applied proportion paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc19Txt: Label 'Exclusively from taxed activities paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc20Txt: Label 'Activities with applied proportion paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc21Txt: Label 'Activities with applied proportion paid in the northern border region';
        ConceptDesc22Txt: Label 'Activities that do not meet requirements paid in the northern border region';
        ConceptDesc23Txt: Label 'Exempt activities paid in the northern border region';
        ConceptDesc24Txt: Label 'Non-object activities paid in the northern border region';
        ConceptDesc25Txt: Label 'Activities with applied proportion paid in the southern border region';
        ConceptDesc26Txt: Label 'Activities that do not meet requirements paid in the southern border region';
        ConceptDesc27Txt: Label 'Exempt activities paid in the southern border region';
        ConceptDesc28Txt: Label 'Non-object activities paid in the southern border region';
        ConceptDesc29Txt: Label 'Activities with applied proportion paid at 16% VAT rate';
        ConceptDesc30Txt: Label 'Activities that do not meet requirements paid at 16% VAT rate';
        ConceptDesc31Txt: Label 'Exempt activities paid at 16% VAT rate';
        ConceptDesc32Txt: Label 'Non-object activities paid at 16% VAT rate';
        ConceptDesc33Txt: Label 'Activities with applied proportion paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc34Txt: Label 'Activities that do not meet requirements paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc35Txt: Label 'Exempt activities paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc36Txt: Label 'Non-object activities paid on customs import of tangible goods at 16% VAT rate';
        ConceptDesc37Txt: Label 'Activities with applied proportion paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc38Txt: Label 'Activities that do not meet requirements paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc39Txt: Label 'Exempt activities paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc40Txt: Label 'Non-object activities paid on import of intangible goods and services at 16% VAT rate';
        ConceptDesc41Txt: Label 'VAT withheld by the taxpayer';
        ConceptDesc42Txt: Label 'Acts or activities paid on import of goods and services for which VAT is not paid (Exempt)';
        ConceptDesc43Txt: Label 'Acts or activities paid for which VAT will not be paid (Exempt)';
        ConceptDesc44Txt: Label 'Other acts or activities paid at 0% VAT rate';
        ConceptDesc45Txt: Label 'Acts or activities not subject to VAT performed in national territory';
        ConceptDesc46Txt: Label 'Acts or activities not subject to VAT due to not having an establishment in national territory';
        BlankTypeOfOperationErr: Label 'Operations reported in DIOT must have a non-blank Type of Operation or Vendor must have a Type of Operation.';
        LeaseAndRentNonMXErr: Label 'Operations with non-mx Vendor cannot have Lease And Rent Type of operation.';
        MissingRFCNoErr: Label 'MX vendors must have RFC Number filled in.';
        CountryCodeNotValidErr: Label 'Vendor''s Country Code is not among valid DIOT Country Codes.';
        NegativeAmountErr: Label 'The amount for Concept No. %1 for Vendor with No. = %2 is negative, which is not valid.', Comment = '%1 = DIOT Concept No. Field Value; %2 = Vendor No. Field Value';
        NoDataMsg: Label 'There are no VAT Entries for configured concepts in the specified date range.';

#if not CLEAN27
    [Obsolete('Use GetTypeOfOperationCode(TypeOfOperation: Enum) instead.', '27.0')]
    procedure GetTypeOfOperationCode(TypeOfOperation: Option): code[2]
    var
        DummyVendor: Record Vendor;
    begin
        case (TypeOfOperation) of
            DummyVendor."DIOT Type of Operation"::"Prof. Services".AsInteger():
                exit('03');
            DummyVendor."DIOT Type of Operation"::"Lease and Rent".AsInteger():
                exit('06');
            DummyVendor."DIOT Type of Operation"::Others.AsInteger():
                exit('85');
            else
                exit('');
        end;
    end;
#endif
    procedure GetTypeOfOperationCode(TypeOfOperation: Enum "DIOT Type of Operation"): Text[2]
    begin
        case TypeOfOperation of
            Enum::"DIOT Type of Operation"::"Prof. Services":
                exit('03');
            Enum::"DIOT Type of Operation"::"Lease and Rent":
                exit('06');
            Enum::"DIOT Type of Operation"::Others:
                exit('85');
            Enum::"DIOT Type of Operation"::"Transfer of Goods":
                exit('02');
            Enum::"DIOT Type of Operation"::"Import of Goods or Services":
                exit('07');
            Enum::"DIOT Type of Operation"::"Import by Virtal Transfer":
                exit('08');
            Enum::"DIOT Type of Operation"::"Global operations":
                exit('87');
        end;
    end;

    local procedure GetTypeOfVendorText(CountryRegionCode: Code[10]): Text[2]
    begin
        if CountryRegionCode = GetMXCountryCode() then
            exit('04');
        exit('05');
    end;

    local procedure GetTypeOfOperationForEntry(VATEntry: Record "VAT Entry"): Enum "DIOT Type of Operation"
    var
        Vendor: Record Vendor;
    begin
        if VATEntry."DIOT Type of Operation" <> Enum::"DIOT Type of Operation"::" " then
            exit(VATEntry."DIOT Type of Operation");
        Vendor.Get(VATEntry."Bill-to/Pay-to No.");
        exit(Vendor."DIOT Type of Operation");
    end;

    procedure InsertDefaultDIOTConcepts()
    begin
        InsertDIOTConcept(1, 8, 0, ConceptDesc01Txt, 0);
        InsertDIOTConcept(2, 9, 0, ConceptDesc02Txt, 0);
        InsertDIOTConcept(3, 10, 0, ConceptDesc03Txt, 0);
        InsertDIOTConcept(4, 11, 0, ConceptDesc04Txt, 0);
        InsertDIOTConcept(5, 12, 1, ConceptDesc05Txt, 0);
        InsertDIOTConcept(6, 13, 1, ConceptDesc06Txt, 0);
        InsertDIOTConcept(7, 14, 1, ConceptDesc07Txt, 0);
        InsertDIOTConcept(8, 15, 1, ConceptDesc08Txt, 0);
        InsertDIOTConcept(9, 16, 1, ConceptDesc09Txt, 0);
        InsertDIOTConcept(10, 17, 1, ConceptDesc10Txt, 0);
        InsertDIOTConcept(11, 18, 0, ConceptDesc11Txt, 0);
        InsertDIOTConcept(12, 19, 0, ConceptDesc12Txt, 0);
        InsertDIOTConcept(13, 20, 0, ConceptDesc13Txt, 0);
        InsertDIOTConcept(14, 21, 0, ConceptDesc14Txt, 0);
        InsertDIOTConcept(15, 22, 1, ConceptDesc15Txt, 0);
        InsertDIOTConcept(16, 23, 1, ConceptDesc16Txt, 0);
        InsertDIOTConcept(17, 24, 1, ConceptDesc17Txt, 0);
        InsertDIOTConcept(18, 25, 1, ConceptDesc18Txt, 0);
        InsertDIOTConcept(19, 26, 1, ConceptDesc19Txt, 0);
        InsertDIOTConcept(20, 27, 1, ConceptDesc20Txt, 0);
        InsertDIOTConcept(21, 28, 0, ConceptDesc21Txt, 0);
        InsertDIOTConcept(22, 29, 0, ConceptDesc22Txt, 0);
        InsertDIOTConcept(23, 30, 0, ConceptDesc23Txt, 0);
        InsertDIOTConcept(24, 31, 0, ConceptDesc24Txt, 0);
        InsertDIOTConcept(25, 32, 0, ConceptDesc25Txt, 0);
        InsertDIOTConcept(26, 33, 0, ConceptDesc26Txt, 0);
        InsertDIOTConcept(27, 34, 0, ConceptDesc27Txt, 0);
        InsertDIOTConcept(28, 35, 0, ConceptDesc28Txt, 0);
        InsertDIOTConcept(29, 36, 1, ConceptDesc29Txt, 0);
        InsertDIOTConcept(30, 37, 1, ConceptDesc30Txt, 0);
        InsertDIOTConcept(31, 38, 1, ConceptDesc31Txt, 0);
        InsertDIOTConcept(32, 39, 1, ConceptDesc32Txt, 0);
        InsertDIOTConcept(33, 40, 1, ConceptDesc33Txt, 0);
        InsertDIOTConcept(34, 41, 1, ConceptDesc34Txt, 0);
        InsertDIOTConcept(35, 42, 1, ConceptDesc35Txt, 0);
        InsertDIOTConcept(36, 43, 1, ConceptDesc36Txt, 0);
        InsertDIOTConcept(37, 44, 1, ConceptDesc37Txt, 0);
        InsertDIOTConcept(38, 45, 1, ConceptDesc38Txt, 0);
        InsertDIOTConcept(39, 46, 1, ConceptDesc39Txt, 0);
        InsertDIOTConcept(40, 47, 1, ConceptDesc40Txt, 0);
        InsertDIOTConcept(41, 48, 2, ConceptDesc41Txt, 0);
        InsertDIOTConcept(42, 49, 1, ConceptDesc42Txt, 0);
        InsertDIOTConcept(43, 50, 1, ConceptDesc43Txt, 0);
        InsertDIOTConcept(44, 51, 1, ConceptDesc44Txt, 0);
        InsertDIOTConcept(45, 52, 1, ConceptDesc45Txt, 0);
        InsertDIOTConcept(46, 53, 1, ConceptDesc46Txt, 0);
    end;

    local procedure InsertDIOTConcept(ConceptNo: Integer; Column: Integer; ColumnType: Option; NewDescription: Text[250]; NonDeductiblePct: Decimal)
    var
        DIOTConcept: Record "DIOT Concept";
    begin
        with DIOTConcept do begin
            Init();
            Validate("Concept No.", ConceptNo);
            Validate("Column No.", Column);
            Validate("Column Type", ColumnType);
            Validate(Description, NewDescription);
            Validate("Non-Deductible Pct", NonDeductiblePct);
            if Insert(true) then;
        end;
    end;

    procedure GetDIOTSetupGuideTxt(): Text[250]
    begin
        exit(CopyStr(DIOTSetupGuideTxt, 1, 250));
    end;

    procedure GetWHTConceptNo(): Integer
    begin
        exit(41);
    end;

    procedure GetConceptCount(): Integer
    begin
        exit(46);
    end;

    procedure GetVendorNameLength(): Integer
    begin
        exit(43);
    end;

    procedure GetNationalityLength(): Integer
    begin
        exit(40);
    end;

    procedure GetMXCountryCode(): Code[10]
    begin
        exit('MX');
    end;

    local procedure GetDIOTOtherCountryCode(): Code[10]
    begin
        exit('ZZZ');
    end;

    procedure IsCountryCodeMXorBlank(CountryRegionCode: Code[10]): Boolean
    begin
        exit(CountryRegionCode in ['', GetMXCountryCode()]);
    end;

    local procedure ConvertToDIOTVendorName(InputVendorName: Text): Text
    begin
        exit(CopyStr(RemoveUnwantedCharacters(InputVendorName, ' @´%!¡$.&,'), 1, GetVendorNameLength()));
    end;

    procedure RemoveUnwantedCharacters(InputString: Text; SpecialCharactersAllowed: Text) OutputString: Text
    var
        AlphanumericChars: Text;
    begin
        AlphanumericChars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        OutputString := DelChr(InputString, '=', DelChr(InputString, '=', AlphanumericChars + SpecialCharactersAllowed));
    end;

    local procedure CalcAmountForVATEntryAndDIOTConcept(VATEntry: Record "VAT Entry"; DIOTConcept: Record "DIOT Concept"; VATPostingSetup: Record "VAT Posting Setup"): Decimal
    var
        WHTModifier: Decimal;
    begin
        WHTModifier := 1;
        if VATPostingSetup."VAT %" > 0 then
            WHTModifier -= VATPostingSetup."DIOT WHT %" / VATPostingSetup."VAT %";
        if DIOTConcept."Concept No." = GetWHTConceptNo() then
            exit(VATEntry.Amount * (1 - WHTModifier));
        case DIOTConcept."Column Type" of
            DIOTConcept."Column Type"::"VAT Base":
                exit(VATEntry.Base);
            DIOTConcept."Column Type"::"VAT Amount":
                if DIOTConcept."Non-Deductible" then
                    exit(VATEntry.Amount * WHTModifier * DIOTConcept."Non-Deductible Pct" / 100)
                else
                    exit(VATEntry.Amount * WHTModifier);
            DIOTConcept."Column Type"::None:
                exit(0);
        end;
    end;

    procedure ConvertToDIOTCountryCode(CountryCode: Code[10]): Text[10]
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
    begin
        DIOTCountryData.SetRange("BC Country/Region Code", CountryCode);
        if DIOTCountryData.FindFirst() then
            exit(DIOTCountryData."ISO A-3 Country/Region Code");
        if DIOTCountryData.Get(CountryCode) then
            exit(DIOTCountryData."ISO A-3 Country/Region Code");
        exit(GetDIOTOtherCountryCode());
    end;

    local procedure InsertVendorBufferConditionally(var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; VendorNo: Code[20]; DIOTTypeOfOperation: Enum "DIOT Type of Operation")
    var
        Vendor: Record Vendor;
    begin
        with TempDIOTReportVendorBuffer do
            if not get(VendorNo, DIOTTypeOfOperation) then begin
                Init();
                Vendor.Get(VendorNo);
                "Vendor No." := VendorNo;
                "Type of Operation" := DIOTTypeOfOperation;

                "Type of Vendor Text" := GetTypeOfVendorText(Vendor."Country/Region Code");

                "Type of Operation Text" := GetTypeOfOperationCode(DIOTTypeOfOperation);

                "RFC Number" := CopyStr(Vendor."RFC No.", 1, MaxStrLen("RFC Number"));

                if Vendor."Country/Region Code" <> GetMXCountryCode() then begin
                    "TAX Registration ID" := CopyStr(Vendor."VAT Registration No.", 1, MaxStrLen("TAX Registration ID"));
                    "Vendor Name" := CopyStr(ConvertToDIOTVendorName(Vendor.Name), 1, MaxStrLen("Vendor Name"));
                    "Country/Region Code" := ConvertToDIOTCountryCode(Vendor."Country/Region Code");
                    if "Country/Region Code" = GetDIOTOtherCountryCode() then
                        "Tax Jurisdiction Location" := Vendor."Tax Jurisdiction Location";
                end;

                "Tax Effects Applied" := Vendor."Tax Effects Applied";
                Insert();
            end;
    end;

    local procedure InsertBufferConditionally(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; VendorNo: Code[20]; TypeOfOperation: Enum "DIOT Type of Operation"; ConceptNo: Integer; Amount: Decimal)
    begin
        with TempDIOTReportBuffer do
            if get(VendorNo, TypeOfOperation, ConceptNo) then begin
                Validate(Value, Value + Amount);
                Modify(true);
            end
            else begin
                "Vendor No." := VendorNo;
                "Type of Operation" := TypeOfOperation;
                "DIOT Concept No." := ConceptNo;
                Value := Amount;
                Insert();
            end;
    end;

    procedure CollectDIOTDataSet(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; var TempErrorMessage: Record "Error Message" temporary; StartingDate: Date; EndingDate: Date)
    var
        DIOTConceptLink: Record "DIOT Concept Link";
        VATEntry: Record "VAT Entry";
        CurrentDIOTConcept: Record "DIOT Concept";
        CurrentVATPostingSetup: Record "VAT Posting Setup";
        VendorNo: Code[20];
        TypeOfOperation: Enum "DIOT Type of Operation";
        CalcAmount: Decimal;
    begin
        VATEntry.SetRange(Type, VATEntry.Type::Purchase);
        VATEntry.SetFilter("Bill-to/Pay-to No.", '<>%1', '');
        VATEntry.SetRange("Posting Date", StartingDate, EndingDate);
        if DIOTConceptLink.FindSet() then
            repeat
                CurrentDIOTConcept.Get(DIOTConceptLink."DIOT Concept No.");
                CurrentVATPostingSetup.Get(DIOTConceptLink."VAT Bus. Posting Group", DIOTConceptLink."VAT Prod. Posting Group");
                VATEntry.SetRange("VAT Bus. Posting Group", DIOTConceptLink."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", DIOTConceptLink."VAT Prod. Posting Group");
                if CurrentVATPostingSetup."Unrealized VAT Type" = CurrentVATPostingSetup."Unrealized VAT Type"::" " then
                    VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice)
                else
                    VATEntry.SetFilter("Unrealized VAT Entry No.", '<>%1', 0);
                if VATEntry.FindSet() then
                    repeat
                        VendorNo := VATEntry."Bill-to/Pay-to No.";
                        TypeOfOperation := GetTypeOfOperationForEntry(VATEntry);
                        CalcAmount := CalcAmountForVATEntryAndDIOTConcept(VATEntry, CurrentDIOTConcept, CurrentVATPostingSetup);
                        InsertBufferConditionally(TempDIOTReportBuffer, VendorNo, TypeOfOperation, DIOTConceptLink."DIOT Concept No.", CalcAmount);
                        InsertVendorBufferConditionally(TempDIOTReportVendorBuffer, VendorNo, TypeOfOperation);
                    until VATEntry.Next() = 0;
            until DIOTConceptLink.Next() = 0;
        CheckDIOTData(TempDIOTReportVendorBuffer, TempDIOTReportBuffer, TempErrorMessage);
    end;

    procedure GetAssistedSetupComplete(): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        exit(GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"DIOT Setup Wizard"));
    end;

    procedure SetAssistedSetupComplete()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"DIOT Setup Wizard");
    end;

    procedure GetNationalyForCountryCode(CountryRegionCode: Code[2]): Text
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
    begin
        if DIOTCountryData.Get(CountryRegionCode) then
            exit(CopyStr(DIOTCountryData.Nationality, 1, GetNationalityLength()));
        exit('');
    end;

    local procedure GenerateDIOTLine(ReportVendorBuffer: Record "DIOT Report Vendor Buffer"; ColumnAmounts: array[46] of Decimal): Text
    var
        DIOTLine: Text;
        i: Integer;
        DIOTLineTxt: Label '%1|%2|%3|%4|%5|%6|%7|', Locked = true;
    begin
        // vendor data
        DIOTLine :=
            StrSubstNo(
                DIOTLineTxt,
                ReportVendorBuffer."Type of Vendor Text",
                ReportVendorBuffer."Type of Operation Text",
                ReportVendorBuffer."RFC Number",
                ReportVendorBuffer."TAX Registration ID",
                ReportVendorBuffer."Vendor Name",
                ReportVendorBuffer."Country/Region Code",
                ReportVendorBuffer."Tax Jurisdiction Location");

        // amounts
        for i := 1 to ArrayLen(ColumnAmounts) do begin
            if ColumnAmounts[i] > 0 then
                DIOTLine += Format(Round(ColumnAmounts[i], 1), 0, 9);
            DIOTLine += '|';
        end;

        // tax effects
        if ReportVendorBuffer."Tax Effects Applied" then
            DIOTLine += '01'
        else
            DIOTLine += '02';

        exit(DIOTLine);
    end;

    procedure GenerateDIOTFile(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; var TempBLOB: Codeunit "Temp Blob")
    var
        DummyDIOTConcept: Record "DIOT Concept";
        CurrentColumnNumbers: array[46] of Decimal;
        oStream: OutStream;
    begin
        Clear(TempBLOB);
        TempBLOB.CreateOutStream(oStream);
        if TempDIOTReportVendorBuffer.FindSet() then
            repeat
                Clear(CurrentColumnNumbers);
                TempDIOTReportBuffer.SetRange("Vendor No.", TempDIOTReportVendorBuffer."Vendor No.");
                TempDIOTReportBuffer.SetRange("Type of Operation", TempDIOTReportVendorBuffer."Type of Operation");
                if TempDIOTReportBuffer.FindSet() then
                    repeat
                        CurrentColumnNumbers[DummyDIOTConcept.GetColumnNo(TempDIOTReportBuffer."DIOT Concept No.") - 7] := TempDIOTReportBuffer.Value;
                    until TempDIOTReportBuffer.Next() = 0;
                oStream.WriteText(GenerateDIOTLine(TempDIOTReportVendorBuffer, CurrentColumnNumbers));
                oStream.WriteText();
            until TempDIOTReportVendorBuffer.Next() = 0;
    end;

    local procedure CheckDIOTData(var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; var TempErrorMessage: Record "Error Message" temporary)
    begin
        if TempDIOTReportVendorBuffer.FindSet() then
            repeat
                CheckDIOTReportVendorBuffer(TempDIOTReportVendorBuffer, TempErrorMessage);
            until TempDIOTReportVendorBuffer.Next() = 0;
        CheckDIOTReportBuffer(TempDIOTReportBuffer, TempErrorMessage);
    end;


    local procedure CheckDIOTReportVendorBuffer(DIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer"; var TempErrorMessage: Record "Error Message" temporary)
    var
        DummyVendor: Record Vendor;
    begin
        with DIOTReportVendorBuffer do begin
            if ("Type of Operation Text" = '') then
                LogErrorForVendor(TempErrorMessage, DummyVendor.FieldNo("DIOT Type of Operation"), BlankTypeOfOperationErr, "Vendor No.");

            if ("Type of Operation Text" = '06') and ("Type of Vendor Text" = '05') then
                LogErrorForVendor(TempErrorMessage, DummyVendor.FieldNo("DIOT Type of Operation"), LeaseAndRentNonMXErr, "Vendor No.");

            if ("RFC Number" = '') and ("Type of Vendor Text" = '04') then
                LogErrorForVendor(TempErrorMessage, DummyVendor.FieldNo("RFC No."), MissingRFCNoErr, "Vendor No.");

            if ("Country/Region Code" = '') and ("Type of Vendor Text" = '05') then
                LogErrorForVendor(TempErrorMessage, DummyVendor.FieldNo("Country/Region Code"), CountryCodeNotValidErr, "Vendor No.");
        end;
    end;

    local procedure LogErrorForVendor(var TempErrorMessage: Record "Error Message" temporary; FieldNo: Integer; Message: Text; VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        TempErrorMessage.LogMessage(Vendor, FieldNo, TempErrorMessage."Message Type"::Error, Message);
    end;

    local procedure CheckDIOTReportBuffer(var TempDIOTReportBuffer: Record "DIOT Report Buffer"; var TempErrorMessage: Record "Error Message" temporary)
    begin
        with TempDIOTReportBuffer do
            if FindSet() then
                repeat
                    if Value < 0 then
                        TempErrorMessage.LogDetailedMessage(TempDIOTReportBuffer, 0, TempErrorMessage."Message Type"::Error, StrSubstNo(NegativeAmountErr, "DIOT Concept No.", "Vendor No."), '', '');
                until Next() = 0;
    end;

    procedure WriteDIOTFile(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary)
    var
        TempBLOB: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
    begin
        if TempDIOTReportVendorBuffer.IsEmpty() then
            Message(NoDataMsg)
        else begin
            GenerateDIOTFile(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempBLOB);
            FileManagement.BLOBExportWithEncoding(TempBLOB, 'diot.txt', true, TextEncoding::UTF8);
        end;

    end;

}
