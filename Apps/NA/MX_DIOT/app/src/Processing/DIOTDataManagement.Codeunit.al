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
    trigger OnRun()
    begin
    end;

    var
        DIOTSetupGuideTxt: Label 'Set up DIOT';
        ConceptDesc1Txt: Label 'Value of acts or activities paid at the rate of 15% or 16% VAT';
        ConceptDesc2Txt: Label 'Value of acts or activities paid at the 15% VAT rate';
        ConceptDesc3Txt: Label 'Amount of VAT paid not creditable at the rate of 15% or 16% (corresponding to the proportion of authorized deductions)';
        ConceptDesc4Txt: Label 'Value of acts or activities paid at the rate of 10% or 11% VAT';
        ConceptDesc5Txt: Label 'Value of acts or activities paid at the 10% VAT rate';
        ConceptDesc6Txt: Label 'Value of the acts or activities paid subject to the stimulation of the northern border region';
        ConceptDesc7Txt: Label 'Amount of VAT paid not creditable at the rate of 10% or 11% (corresponding to the proportion of authorized deductions)';
        ConceptDesc8Txt: Label 'Amount of VAT not creditable subject to the stimulation of the northern border region (corresponding to the proportion of authorized deductions)';
        ConceptDesc9Txt: Label 'Value of acts or activities paid in the importation of goods and services at the rate of 15% or 16% VAT';
        ConceptDesc10Txt: Label 'Amount of VAT paid not creditable for importation at the rate of 15% or 16% (corresponding to the proportion of authorized deductions)';
        ConceptDesc11Txt: Label 'Value of the acts or activities paid in the import of goods and services at the rate of 10% or 11% VAT';
        ConceptDesc12Txt: Label 'Amount of VAT paid not creditable for importation at the rate of 10% or 11% (corresponding in the proportion of authorized deductions)';
        ConceptDesc13Txt: Label 'Value of acts or activities paid in the importation of goods and services for which VAT is not paid (Exempt)';
        ConceptDesc14Txt: Label 'Value of other acts or activities paid at the 0% VAT rate';
        ConceptDesc15Txt: Label 'Value of acts or activities paid for which VAT will not be paid (Exempt)';
        ConceptDesc16Txt: Label 'VAT Withheld by the taxpayer';
        ConceptDesc17Txt: Label 'VAT corresponding to returns, discounts and bonuses on purchases';
        BlankTypeOfOperationErr: Label 'Operations reported in DIOT must have a non-blank Type of Operation or Vendor must have a Type of Operation.';
        LeaseAndRentNonMXErr: Label 'Operations with non-mx Vendor cannot have Lease And Rent Type of operation.';
        MissingRFCNoErr: Label 'MX vendors must have RFC Number filled in.';
        CountryCodeNotValidErr: Label 'Vendor''s Country Code is not among valid DIOT Country Codes.';
        NegativeAmountErr: Label 'The amount for Concept No. %1 for Vendor with No. = %2 is negative, which is not valid.', Comment = '%1 = DIOT Concept No. Field Value; %2 = Vendor No. Field Value';
        NoDataMsg: Label 'There are no VAT Entries for configured concepts in the specified date range.';

    procedure GetTypeOfOperationCode(TypeOfOperation: Option): code[2]
    var
        DummyVendor: Record Vendor;
    begin
        case (TypeOfOperation) of
            DummyVendor."DIOT Type of Operation"::"Prof. Services":
                exit('03');
            DummyVendor."DIOT Type of Operation"::"Lease and Rent":
                exit('06');
            DummyVendor."DIOT Type of Operation"::Others:
                exit('85');
            else
                exit('');
        end;
    end;

    local procedure GetTypeOfVendorText(CountryRegionCode: Code[10]): Text[2]
    begin
        if CountryRegionCode = GetMXCountryCode() then
            exit('04');
        exit('05');
    end;

    local procedure GetTypeOfOperationForEntry(VATEntry: Record "VAT Entry"): Option
    var
        Vendor: Record Vendor;
    begin
        if VATEntry."DIOT Type of Operation" <> VATEntry."DIOT Type of Operation"::" " then
            exit(VATEntry."DIOT Type of Operation");
        Vendor.Get(VATEntry."Bill-to/Pay-to No.");
        exit(Vendor."DIOT Type of Operation");
    end;

    procedure InsertDefaultDIOTConcepts()
    begin
        InsertDIOTConcept(1, 8, 1, ConceptDesc1Txt, 0);
        InsertDIOTConcept(2, 9, 0, ConceptDesc2Txt, 0);
        InsertDIOTConcept(3, 10, 2, ConceptDesc3Txt, 20);
        InsertDIOTConcept(4, 11, 0, ConceptDesc4Txt, 0);
        InsertDIOTConcept(5, 12, 0, ConceptDesc5Txt, 0);
        InsertDIOTConcept(6, 13, 1, ConceptDesc6Txt, 0);
        InsertDIOTConcept(7, 14, 0, ConceptDesc7Txt, 0);
        InsertDIOTConcept(8, 15, 2, ConceptDesc8Txt, 20);
        InsertDIOTConcept(9, 16, 1, ConceptDesc9Txt, 0);
        InsertDIOTConcept(10, 17, 2, ConceptDesc10Txt, 20);
        InsertDIOTConcept(11, 18, 0, ConceptDesc11Txt, 0);
        InsertDIOTConcept(12, 19, 0, ConceptDesc12Txt, 0);
        InsertDIOTConcept(13, 20, 1, ConceptDesc13Txt, 0);
        InsertDIOTConcept(14, 21, 1, ConceptDesc14Txt, 0);
        InsertDIOTConcept(15, 22, 1, ConceptDesc15Txt, 0);
        InsertDIOTConcept(16, 23, 2, ConceptDesc16Txt, 0);
        InsertDIOTConcept(17, 24, 2, ConceptDesc17Txt, 0);
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
        exit(16);
    end;

    procedure GetConceptCount(): Integer
    begin
        exit(17);
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

    procedure ConvertToDIOTCountryCode(CountryCode: Code[10]): Text[2]
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
    begin
        DIOTCountryData.SetRange("BC Country/Region Code", CountryCode);
        IF DIOTCountryData.FindFirst() then
            exit(DIOTCountryData."Country/Region Code");
        if DIOTCountryData.Get(CountryCode) then
            exit(DIOTCountryData."Country/Region Code");
        exit('');
    end;

    local procedure InsertVendorBufferConditionally(var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; VendorNo: Code[20]; DIOTTypeOfOperation: Option)
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
                    Nationality := CopyStr(GetNationalyForCountryCode("Country/Region Code"), 1, MaxStrLen(Nationality));
                end;
                Insert();
            end;
    end;

    local procedure InsertBufferConditionally(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; VendorNo: Code[20]; TypeOfOperation: Option; ConceptNo: Integer; Amount: Decimal)
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
        TypeOfOperation: Option;
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

    local procedure GenerateDIOTLine(DIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer"; ColumnAmounts: array[17] of Decimal): Text
    var
        DIOTLine: Text;
        i: Integer;
        DIOTLineTxt: Label '%1|%2|%3|%4|%5|%6|%7|', Locked = true;
    begin
        with DIOTReportVendorBuffer do begin
            DIOTLine := StrSubstNo(DIOTLineTxt, "Type of Vendor Text", "Type of Operation Text", "RFC Number", "TAX Registration ID", "Vendor Name", "Country/Region Code", Nationality);
            for i := 1 to ArrayLen(ColumnAmounts) do begin
                if ColumnAmounts[i] > 0 then
                    DIOTLine += Format(ROUND(ColumnAmounts[i], 1), 0, 9);
                DIOTLine += '|';
            end;
        end;
        exit(DIOTLine);
    end;

    procedure GenerateDIOTFile(var TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary; var TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary; var TempBLOB: Codeunit "Temp Blob")
    var
        DummyDIOTConcept: Record "DIOT Concept";
        CurrentColumnNumbers: array[17] of Decimal;
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
