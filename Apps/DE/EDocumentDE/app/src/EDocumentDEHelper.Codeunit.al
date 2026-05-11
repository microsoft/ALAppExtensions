// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Reflection;

// Translation keyword reference (Leitweg-ID specification terminology):
//   E-Invoice Routing No. = Leitweg-ID
//   coarse routing         = Grobadressierung
//   fine routing           = Feinadressierung
//   check digit            = Prüfziffer
//   state code             = Bundesland-Code
//   federal code           = Bund-Code

codeunit 11038 "E-Document DE Helper"
{
    Access = Public;

    /// <summary>
    /// Checks whether the given routing number (Leitweg-ID) is structurally valid.
    /// </summary>
    /// <param name="RoutingNo">The routing number to validate.</param>
    /// <returns>True if the routing number passes all structural validation rules; otherwise, false.</returns>
    procedure IsValidRoutingNo(RoutingNo: Text[50]): Boolean
    begin
        exit(TryValidateRoutingNo(RoutingNo));
    end;

    /// <summary>
    /// Determines whether the source document has a routing number (Leitweg-ID) available.
    /// First checks the document's Buyer Reference field for a valid routing number,
    /// then falls back to the bill-to customer's E-Invoice Routing No.
    /// </summary>
    /// <param name="SourceDocumentHeader">A RecordRef pointing to a supported document header (Sales Header, Sales Invoice Header, Sales Cr.Memo Header, Service Header, Service Invoice Header, or Service Cr.Memo Header).</param>
    /// <returns>True if a routing number is found on the document or on the bill-to customer; otherwise, false.</returns>
    procedure HasRoutingNo(SourceDocumentHeader: RecordRef): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        BuyerReferenceFieldRef: FieldRef;
        CustomerNoFieldRef: FieldRef;
        BuyerReferenceValue: Text;
    begin
        if not IsSupportedDocumentType(SourceDocumentHeader) then
            exit(false);

        BuyerReferenceFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Buyer Reference"));
        BuyerReferenceValue := BuyerReferenceFieldRef.Value();
        if (BuyerReferenceValue <> '') and (StrLen(BuyerReferenceValue) <= 50) then
            if IsValidRoutingNo(CopyStr(BuyerReferenceValue, 1, 50)) then
                exit(true);

        CustomerNoFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Bill-to Customer No."));
        if Customer.Get(Format(CustomerNoFieldRef.Value)) then
            if Customer."E-Invoice Routing No." <> '' then
                exit(true);

        exit(false);
    end;

    /// <summary>
    /// Validates the structure of a routing number (Leitweg-ID) and raises an error if it is invalid.
    /// Validates the overall length, segment count, coarse routing (Grobadressierung), optional fine routing (Feinadressierung), and check digit (Prüfziffer) using Mod 97-10.
    /// </summary>
    /// <param name="RoutingNo">The routing number to validate. An empty value is accepted without error.</param>
    procedure ValidateRoutingNo(RoutingNo: Text[50])
    var
        TypeHelper: Codeunit "Type Helper";
        Parts: List of [Text];
        CoarseRouting: Text;
        FineRouting: Text;
        CheckDigitText: Text;
    begin
        if RoutingNo = '' then
            exit;

        if (StrLen(RoutingNo) < 5) or (StrLen(RoutingNo) > 46) then
            Error(OverallLengthErr, StrLen(RoutingNo));

        Parts := RoutingNo.Split('-');
        if not (Parts.Count() in [2, 3]) then
            Error(SegmentCountErr);

        CoarseRouting := Parts.Get(1);
        if Parts.Count() = 3 then
            FineRouting := Parts.Get(2);
        CheckDigitText := Parts.Get(Parts.Count());

        ValidateCoarseRouting(CoarseRouting);
        if FineRouting <> '' then
            ValidateFineRouting(FineRouting);
        ValidateCheckDigitFormat(CheckDigitText);
        ValidateCheckDigitMod97(CoarseRouting, FineRouting, CheckDigitText);
    end;

    local procedure ValidateCoarseRouting(CoarseRouting: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        StateCode: Integer;
        StateCodeText: Text;
        i: Integer;
    begin
        if CoarseRouting = '' then
            Error(CoarseDigitsErr, CoarseRouting);

        for i := 1 to StrLen(CoarseRouting) do
            if not TypeHelper.IsDigit(CoarseRouting[i]) then
                Error(CoarseDigitsErr, CoarseRouting);

        if not (StrLen(CoarseRouting) in [2, 3, 5, 8, 9, 12]) then
            Error(CoarseLengthErr, StrLen(CoarseRouting));

        StateCodeText := CopyStr(CoarseRouting, 1, 2);
        Evaluate(StateCode, StateCodeText);
        if not ((StateCode in [1 .. 16]) or (StateCode = 99)) then
            Error(StateCodeErr, StateCodeText);
    end;

    local procedure ValidateFineRouting(FineRouting: Text)
    begin
        if (StrLen(FineRouting) < 1) or (StrLen(FineRouting) > 30) then
            Error(FineRoutingLengthErr, FineRouting);

        if not IsAlphanumOnly(FineRouting) then
            Error(FineRoutingCharsErr, FineRouting);
    end;

    local procedure ValidateCheckDigitFormat(CheckDigitText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        i: Integer;
    begin
        if StrLen(CheckDigitText) <> 2 then
            Error(CheckDigitFormatErr, CheckDigitText);

        for i := 1 to StrLen(CheckDigitText) do
            if not TypeHelper.IsDigit(CheckDigitText[i]) then
                Error(CheckDigitFormatErr, CheckDigitText);
    end;

    local procedure ValidateCheckDigitMod97(CoarseRouting: Text; FineRouting: Text; CheckDigitText: Text)
    var
        FullNumeric: Text;
    begin
        FullNumeric := ConvertToNumericString(CoarseRouting + FineRouting + CheckDigitText);
        if ComputeMod97(FullNumeric) <> 1 then
            Error(CheckDigitVerifyErr);
    end;

    local procedure ConvertToNumericString(Input: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
        UpperInput: Text;
        Result: Text;
        Ch: Char;
        i: Integer;
    begin
        UpperInput := UpperCase(Input);
        for i := 1 to StrLen(UpperInput) do begin
            Ch := UpperInput[i];
            if TypeHelper.IsLatinLetter(Ch) then
                Result += Format(Ch - 55) // A=65 → 10, B=66 → 11, ..., Z=90 → 35
            else
                Result += Format(Ch - 48); // '0'=48 → 0, '1'=49 → 1, etc.
        end;
        exit(Result);
    end;

    local procedure ComputeMod97(NumericString: Text): Integer
    var
        Remainder: Integer;
        DigitValue: Integer;
        i: Integer;
    begin
        Remainder := 0;
        for i := 1 to StrLen(NumericString) do begin
            Evaluate(DigitValue, CopyStr(NumericString, i, 1));
            Remainder := (Remainder * 10 + DigitValue) mod 97;
        end;
        exit(Remainder);
    end;

    local procedure IsAlphanumOnly(Input: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        Ch: Char;
        i: Integer;
    begin
        if Input = '' then
            exit(false);
        for i := 1 to StrLen(Input) do begin
            Ch := Input[i];
            if not (TypeHelper.IsDigit(Ch) or TypeHelper.IsLatinLetter(Ch)) then
                exit(false);
        end;
        exit(true);
    end;

    local procedure IsSupportedDocumentType(SourceDocumentHeader: RecordRef): Boolean
    begin
        exit(SourceDocumentHeader.Number in
            [Database::"Sales Header",
            Database::"Sales Invoice Header",
            Database::"Sales Cr.Memo Header",
            Database::"Service Header",
            Database::"Service Invoice Header",
            Database::"Service Cr.Memo Header"]);
    end;

    [TryFunction]
    local procedure TryValidateRoutingNo(RoutingNo: Text[50])
    begin
        ValidateRoutingNo(RoutingNo);
    end;

    var
        OverallLengthErr: Label 'The E-Invoice Routing No. must be between 5 and 46 characters long. Current length: %1.', Comment = '%1 = actual length';
        SegmentCountErr: Label 'The E-Invoice Routing No. must consist of 2 or 3 segments separated by hyphens (-).';
        CoarseDigitsErr: Label 'The coarse routing segment must contain only digits (0-9). Found: "%1".', Comment = '%1 = coarse routing value';
        CoarseLengthErr: Label 'The coarse routing segment must be 2, 3, 5, 8, 9, or 12 digits long. Current length: %1.', Comment = '%1 = actual length';
        StateCodeErr: Label 'The coarse routing segment must start with a valid German state code (01-16) or federal code (99). Found: "%1".', Comment = '%1 = two-digit state code';
        FineRoutingLengthErr: Label 'The fine routing segment must be between 1 and 30 characters long. Found: "%1".', Comment = '%1 = fine routing value';
        FineRoutingCharsErr: Label 'The fine routing segment must contain only letters (A-Z) and digits (0-9). Found: "%1".', Comment = '%1 = fine routing value';
        CheckDigitFormatErr: Label 'The check digit must be exactly 2 digits. Found: "%1".', Comment = '%1 = check digit value';
        CheckDigitVerifyErr: Label 'The check digit verification failed (Mod 97-10). The E-Invoice Routing No. may contain a typo.';
}
