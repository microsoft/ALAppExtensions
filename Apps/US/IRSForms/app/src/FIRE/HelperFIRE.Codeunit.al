// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;

codeunit 10048 "Helper FIRE"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FormBox: Record "IRS 1099 Form Box";
        FormatAddress: Codeunit "Format Address";
        PeriodNoGlobal: Text[4];
        FormBoxes: array[4, 30] of Code[10];
        Amounts: array[4, 30] of Decimal;
        Totals: array[4, 30] of Decimal;
        CodeNotSetupErr: Label 'The 1099 code %1 has not been setup in the initialization.', Comment = '%1 = 1099 Code';
        Unknown1099CodeErr: Label 'Invoice %1 on vendor %2 has unknown 1099 code  %3.', Comment = '%1 = Invoice Entry No., %2 = Vendor No., %3 = 1099 Code';

    procedure FillFormBoxNoArray(PeriodNo: Text[4])
    begin
        PeriodNoGlobal := PeriodNo;

        // Fill in the Codes used for 1099's
        Clear(FormBoxes);

        FormBoxes[1, 1] := 'MISC-01';
        FormBoxes[1, 2] := 'MISC-02';
        FormBoxes[1, 3] := 'MISC-03';
        FormBoxes[1, 4] := 'MISC-04';
        FormBoxes[1, 5] := 'MISC-05';
        FormBoxes[1, 6] := 'MISC-06';
        FormBoxes[1, 7] := 'MISC-07';
        FormBoxes[1, 8] := 'MISC-08';
        FormBoxes[1, 9] := 'MISC-09';
        FormBoxes[1, 10] := 'MISC-10';
        FormBoxes[1, 11] := 'MISC-11';
        FormBoxes[1, 12] := 'MISC-12';
        FormBoxes[1, 13] := 'MISC-13';
        FormBoxes[1, 14] := 'MISC-14';
        FormBoxes[1, 15] := 'MISC-15';

        FormBoxes[2, 1] := 'DIV-01-A';
        FormBoxes[2, 2] := 'DIV-01-B';
        FormBoxes[2, 3] := 'DIV-02-A';
        FormBoxes[2, 5] := 'DIV-05';
        FormBoxes[2, 6] := 'DIV-02-B';
        FormBoxes[2, 7] := 'DIV-02-C';
        FormBoxes[2, 8] := 'DIV-02-D';
        FormBoxes[2, 9] := 'DIV-03';
        FormBoxes[2, 10] := 'DIV-04';
        FormBoxes[2, 11] := 'DIV-06';
        FormBoxes[2, 12] := 'DIV-07';
        FormBoxes[2, 13] := 'DIV-09';
        FormBoxes[2, 14] := 'DIV-10';
        FormBoxes[2, 15] := 'DIV-12';
        FormBoxes[2, 16] := 'DIV-02-E';
        FormBoxes[2, 17] := 'DIV-02-F';
        FormBoxes[2, 18] := 'DIV-13';

        FormBoxes[3, 1] := 'INT-01';
        FormBoxes[3, 2] := 'INT-02';
        FormBoxes[3, 3] := 'INT-03';
        FormBoxes[3, 4] := 'INT-04';
        FormBoxes[3, 5] := 'INT-05';
        FormBoxes[3, 6] := 'INT-06';
        FormBoxes[3, 8] := 'INT-08';
        FormBoxes[3, 9] := 'INT-09';
        FormBoxes[3, 10] := 'INT-10';
        FormBoxes[3, 11] := 'INT-11';
        FormBoxes[3, 12] := 'INT-12';
        FormBoxes[3, 13] := 'INT-13';

        FormBoxes[4, 1] := 'NEC-01';
        FormBoxes[4, 2] := 'NEC-02';
        FormBoxes[4, 4] := 'NEC-04';

        OnRunOnAfterInitCodeValues(FormBoxes);
    end;

    local procedure GetFormNo(FormTypeIndex: Integer): Code[20]
    begin
        case FormTypeIndex of
            1:
                exit('MISC');
            2:
                exit('DIV');
            3:
                exit('INT');
            4:
                exit('NEC');
        end;
    end;

    procedure GetAmt(FormBoxNo: Code[20]; FormTypeIndex: Integer; EndLine: Integer): Decimal
    var
        FormBoxNoIndex: Integer;
    begin
        FormBoxNoIndex := 1;
        while (FormBoxes[FormTypeIndex, FormBoxNoIndex] <> FormBoxNo) and (FormBoxNoIndex <= EndLine) do
            FormBoxNoIndex := FormBoxNoIndex + 1;

        if (FormBoxes[FormTypeIndex, FormBoxNoIndex] = FormBoxNo) and (FormBoxNoIndex <= EndLine) then
            exit(Amounts[FormTypeIndex, FormBoxNoIndex]);

        Error(CodeNotSetupErr, FormBoxNo);
    end;

    procedure UpdateLines(InvoiceEntry: Record "Vendor Ledger Entry"; FormTypeIndex: Integer; EndLine: Integer; FormBoxNo: Code[20]; Amount: Decimal): Integer
    var
        FormBoxNoIndex: Integer;
    begin
        FormBoxNoIndex := 1;
        while (FormBoxes[FormTypeIndex, FormBoxNoIndex] <> FormBoxNo) and (FormBoxNoIndex <= EndLine) do
            FormBoxNoIndex := FormBoxNoIndex + 1;

        if (FormBoxes[FormTypeIndex, FormBoxNoIndex] = FormBoxNo) and (FormBoxNoIndex <= EndLine) then begin
            Amounts[FormTypeIndex, FormBoxNoIndex] += Amount;
            Totals[FormTypeIndex, FormBoxNoIndex] += Amount;
        end else
            Error(Unknown1099CodeErr, InvoiceEntry."Entry No.", InvoiceEntry."Vendor No.", FormBoxNo);
        exit(FormBoxNoIndex); // returns code index found
    end;

    procedure AnyAmount(FormTypeIndex: Integer; EndLine: Integer): Boolean
    var
        FormBoxNoIndex: Integer;
    begin
        for FormBoxNoIndex := 1 to EndLine do
            if FormBox.Get(PeriodNoGlobal, GetFormNo(FormTypeIndex), FormBoxes[FormTypeIndex, FormBoxNoIndex]) then begin
                if FormBox."Minimum Reportable Amount" < 0.0 then
                    if Amounts[FormTypeIndex, FormBoxNoIndex] <> 0.0 then begin
                        Amounts[FormTypeIndex, FormBoxNoIndex] := -Amounts[FormTypeIndex, FormBoxNoIndex];
                        exit(true);
                    end;
                if FormBox."Minimum Reportable Amount" >= 0.0 then
                    if Amounts[FormTypeIndex, FormBoxNoIndex] <> 0 then begin
                        if Amounts[FormTypeIndex, FormBoxNoIndex] >= FormBox."Minimum Reportable Amount" then
                            exit(true);
                        Totals[FormTypeIndex, FormBoxNoIndex] := Totals[FormTypeIndex, FormBoxNoIndex] - Amounts[FormTypeIndex, FormBoxNoIndex];
                        Amounts[FormTypeIndex, FormBoxNoIndex] := 0;
                    end;
            end;
        exit(false);
    end;

    procedure FormatMoneyAmount(Amount: Decimal; Length: Integer): Text[250]
    var
        AmtStr: Text[32];
    begin
        AmtStr := CopyStr(StripNonNumerics(Format(Round(Abs(Amount) * 100, 1))), 1, MaxStrLen(AmtStr));

        // left zero-padding
        if Length - StrLen(AmtStr) > 0 then
            AmtStr := CopyStr('0000000000000000000' + AmtStr, 1, MaxStrLen(AmtStr));
        AmtStr := DelStr(AmtStr, 1, StrLen(AmtStr) - Length);
        exit(AmtStr);
    end;

    procedure FormatAmount(Amount: Integer; Length: Integer): Text[250]
    var
        AmtStr: Text[30];
    begin
        AmtStr := Format(Amount);

        // left zero-padding
        if Length - StrLen(AmtStr) > 0 then
            AmtStr := CopyStr('000000000000000000' + AmtStr, 1, MaxStrLen(AmtStr));
        AmtStr := DelStr(AmtStr, 1, StrLen(AmtStr) - Length);
        exit(AmtStr);
    end;

    procedure StripNonNumerics(Text: Text[80]): Text[250]
    begin
        exit(DelChr(Text, '=', '-,. '));
    end;

    procedure EditCompanyInfo(var CompInfo: Record "Company Information")
    begin
        CompInfo."Federal ID No." := CopyStr(StripNonNumerics(CompInfo."Federal ID No."), 1, MaxStrLen(CompInfo."Federal ID No."));
    end;

    procedure SwitchZipCodeParts(var ZIP: Code[20])
    begin
        if StrLen(ZIP) > 5 then
            ZIP := PadStr(CopyStr(ZIP, 6), 5) + CopyStr(ZIP, 1, 5)
        else
            ZIP := CopyStr('     ' + ZIP, 1, MaxStrLen(ZIP));
    end;

    procedure FormatCompanyAddress(var CompanyInfo: Record "Company Information"; var CompanyAddress: array[8] of Text[30])
    begin
        CompanyInfo.Get();
        FormatAddress.Company(CompanyAddress, CompanyInfo);
    end;

    procedure BuildAddressLine(CompanyInfo: Record "Company Information"): Text[40]
    var
        Address3: Text[40];
    begin
        // Format City/State/Zip address line
        if StrLen(CompanyInfo.City + ', ' + CompanyInfo.County + '  ' + CompanyInfo."Post Code") > MaxStrLen(Address3) then
            Address3 := CompanyInfo.City
        else
            if (CompanyInfo.City <> '') and (CompanyInfo.County <> '') then
                Address3 := CopyStr(CompanyInfo.City + ', ' + CompanyInfo.County + '  ' + CompanyInfo."Post Code", 1, MaxStrLen(Address3))
            else
                Address3 := CopyStr(DelChr(CompanyInfo.City + ' ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code", '<>'), 1, MaxStrLen(Address3));
        exit(Address3);
    end;

    procedure ClearAmts()
    begin
        Clear(Amounts);
    end;

    procedure AmtCodes(var CodeNos: Text[12]; FormTypeIndex: Integer; EndLine: Integer)
    var
        ActualCodePos: array[30] of Integer;
        FormBoxNoIndex: Integer;
    begin
        Clear(CodeNos);

        case FormTypeIndex of
            1:   // MISC
                for FormBoxNoIndex := 1 to EndLine do
                    if Amounts[FormTypeIndex, FormBoxNoIndex] <> 0.0 then
                        case FormBoxNoIndex of
                            9:
                                IncrCodeNos(CodeNos, ActualCodePos, 'A', 10); // Crop Insurance Proceeds
                            10:
                                IncrCodeNos(CodeNos, ActualCodePos, 'C', 12); // gross legal proceeds
                            11:
                                IncrCodeNos(CodeNos, ActualCodePos, 'F', 15); // fish purchased for resale
                            12:
                                IncrCodeNos(CodeNos, ActualCodePos, 'D', 13); // 409A deferral
                            14:
                                IncrCodeNos(CodeNos, ActualCodePos, 'B', 11); // excess golden parachutes
                            15:
                                IncrCodeNos(CodeNos, ActualCodePos, 'E', 14); // 409A Income
                            else
                                IncrCodeNos(CodeNos, ActualCodePos, Format(FormBoxNoIndex), FormBoxNoIndex);
                        end;
            2: // DIV
                begin
                    if EndLine > 1 then
                        // special check for DIV complex amounts
                        if GetTotalOrdinaryDividendsAmt() <> 0 then
                            CodeNos := CopyStr(InsStr(CodeNos, Format(1), 1), 1, MaxStrLen(CodeNos));
                    AmtCodesDIV(CodeNos, FormTypeIndex, 2, EndLine);
                end;
            3: // INT
                AmtCodesINT(CodeNos, FormTypeIndex, 1, EndLine);
            4: // NEC
                CodeNos := '1';
        end;
    end;

    local procedure AmtCodesDIV(var CodeNos: Text[12]; FormTypeIndex: Integer; StartLine: Integer; EndLine: Integer)
    var
        FormBoxNoIndex: Integer;
        NewCode: Text;
    begin
        for FormBoxNoIndex := StartLine to EndLine do
            if Amounts[FormTypeIndex, FormBoxNoIndex] <> 0.0 then begin
                case FormBoxNoIndex of
                    10:
                        NewCode := InsStr(CodeNos, 'A', FormBoxNoIndex); // FIT withheld
                    12:
                        NewCode := InsStr(CodeNos, 'C', FormBoxNoIndex); // Foreign tax paid
                    13:
                        NewCode := InsStr(CodeNos, 'D', FormBoxNoIndex); // Cash liquidation distributions
                    14:
                        NewCode := InsStr(CodeNos, 'E', FormBoxNoIndex); // Noncash liquidation distributions
                    15:
                        NewCode := InsStr(CodeNos, 'F', FormBoxNoIndex); // Exempt-interest dividends
                    16:
                        NewCode := InsStr(CodeNos, 'G', FormBoxNoIndex); // Specified private activity bond interest dividends
                    17:
                        NewCode := InsStr(CodeNos, 'H', FormBoxNoIndex); // Section 897 ordinary dividends
                    18:
                        NewCode := InsStr(CodeNos, 'J', FormBoxNoIndex);  // Section 897 capital gain
                    else
                        NewCode := InsStr(CodeNos, Format(FormBoxNoIndex), FormBoxNoIndex);
                end;
                CodeNos := CopyStr(NewCode, 1, MaxStrLen(CodeNos));
            end;
    end;

    local procedure AmtCodesINT(var CodeNos: Text[12]; FormTypeIndex: Integer; StartLine: Integer; EndLine: Integer)
    var
        FormBoxNoIndex: Integer;
        NewCode: Text;
    begin
        for FormBoxNoIndex := StartLine to EndLine do
            if Amounts[FormTypeIndex, FormBoxNoIndex] <> 0.0 then begin
                case FormBoxNoIndex of
                    10:
                        NewCode := InsStr(CodeNos, 'A', FormBoxNoIndex); // Market discount
                    11:
                        NewCode := InsStr(CodeNos, 'B', FormBoxNoIndex); // Bond premium
                    12:
                        NewCode := InsStr(CodeNos, 'E', FormBoxNoIndex); // Bond premium on Treasury obligation
                    13:
                        NewCode := InsStr(CodeNos, 'D', FormBoxNoIndex); // Bond premium on tax exempt bond
                    else
                        NewCode := InsStr(CodeNos, Format(FormBoxNoIndex), FormBoxNoIndex);
                end;
                CodeNos := CopyStr(NewCode, 1, MaxStrLen(CodeNos));
            end;
    end;

    procedure GetTotal(FormBoxNo: Code[10]; FormTypeIndex: Integer; EndLine: Integer): Decimal
    var
        FormBoxNoIndex: Integer;
    begin
        FormBoxNoIndex := 1;
        while (FormBoxes[FormTypeIndex, FormBoxNoIndex] <> FormBoxNo) and (FormBoxNoIndex <= EndLine) do
            FormBoxNoIndex := FormBoxNoIndex + 1;

        if (FormBoxes[FormTypeIndex, FormBoxNoIndex] = FormBoxNo) and (FormBoxNoIndex <= EndLine) then
            exit(Totals[FormTypeIndex, FormBoxNoIndex]);

        Error(CodeNotSetupErr, FormBoxNo);
    end;

    procedure ClearTotals()
    begin
        Clear(Totals);
    end;

    procedure DirectSalesCheck(FormBoxNoIndex: Integer): Boolean
    begin
        if FormBox.Get(PeriodNoGlobal, 'MISC', FormBoxes[1, FormBoxNoIndex]) then
            if Amounts[1, FormBoxNoIndex] >= FormBox."Minimum Reportable Amount" then
                exit(true)
            else
                exit(false);
    end;

    local procedure GetTotalOrdinaryDividendsAmt(): Decimal
    begin
        exit(Amounts[2, 1] + Amounts[2, 2] + Amounts[2, 11] + Amounts[2, 5]);
    end;

    local procedure IncrCodeNos(var CodeNos: Text[12]; var ActualCodePosArray: array[30] of Integer; AmountCode: Text[1]; ExpectedCodePos: Integer)
    var
        i: Integer;
        ActualCodePos: Integer;
    begin
        if ExpectedCodePos > 2 then begin
            i := ExpectedCodePos;
            ActualCodePos := 0;
            while (i > 2) and (ActualCodePos = 0) do begin
                ActualCodePos := ActualCodePosArray[i - 1];
                i -= 1;
            end;
            if ActualCodePos <> 0 then
                for i := (ExpectedCodePos + 1) to ArrayLen(ActualCodePosArray) do
                    if ActualCodePosArray[i] <> 0 then
                        ActualCodePosArray[i] += 1;
        end;
        if ActualCodePos = 0 then
            ActualCodePos := StrLen(CodeNos) + 1;
        CodeNos := CopyStr(InsStr(CodeNos, AmountCode, ActualCodePos), 1, MaxStrLen(CodeNos));
        ActualCodePosArray[ExpectedCodePos] := ActualCodePos + 1;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterInitCodeValues(var Codes: array[4, 30] of Code[10]);
    begin
    end;
}