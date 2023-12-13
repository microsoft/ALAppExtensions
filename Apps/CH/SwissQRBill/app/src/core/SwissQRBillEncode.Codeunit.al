// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Sales.Customer;

codeunit 11513 "Swiss QR-Bill Encode"
{
    var
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";

    internal procedure GenerateQRCodeText(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Text
    var
        Result: Text;
    begin
        // header
        AddLine(Result, 'SPC'); // QRType
        AddLine(Result, '0200'); // Version
        AddLine(Result, '1'); // Coding Type

        with SwissQRBillBuffer do begin
            AddLine(Result, DelChr(IBAN));
            AddCreditorPartyInfo(Result, SwissQRBillBuffer);
            AddUltimateCreditorPartyInfo(Result, SwissQRBillBuffer);
            AddLine(Result, FormatAmount(Amount));
            AddLine(Result, Currency);
            AddUltimateDebitorPartyInfo(Result, SwissQRBillBuffer);
            AddReferenceInfo(Result, SwissQRBillBuffer);
            AddLine(Result, "Unstructured Message");
            AddLine(Result, 'EPD'); // Trailer
            AddLineConditionally(Result, "Billing Information", ("Alt. Procedure Value 1" <> '') or ("Alt. Procedure Value 2" <> ''));
            AddLineConditionally(
              Result, FormatAltProcedureText("Alt. Procedure Name 1", "Alt. Procedure Value 1"), "Alt. Procedure Value 2" <> '');
            AddLineIfNotBlanked(Result, FormatAltProcedureText("Alt. Procedure Name 2", "Alt. Procedure Value 2"));
        end;

        exit(Result);
    end;

    local procedure FormatAmount(Amount: Decimal): Text
    begin
        if Amount = 0 then
            exit('');
        exit(Format(Round(Amount, 0.01), 0, '<Sign><Integer><Decimals,3><Comma,.><Filler Character,0>'));
    end;

    local procedure FormatAddressType(AddressType: Enum "Swiss QR-Bill Address Type"): Text
    begin
        case AddressType of
            AddressType::Structured:
                exit('S');
            AddressType::Combined:
                exit('K');
        end;
    end;

    local procedure FormatReferenceType(ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"): Text
    var
        DummySwissQRBillBuffer: Record "Swiss QR-Bill Buffer";
    begin
        case ReferenceType of
            DummySwissQRBillBuffer."Payment Reference Type"::"QR Reference":
                exit('QRR');
            DummySwissQRBillBuffer."Payment Reference Type"::"Creditor Reference (ISO 11649)":
                exit('SCOR');
            DummySwissQRBillBuffer."Payment Reference Type"::"Without Reference":
                exit('NON');
        end;
    end;

    local procedure FormatAltProcedureText(ProcName: Text; ProcValue: Text): Text
    begin
        if (ProcName <> '') and (ProcValue <> '') then
            exit(ProcName + ': ' + ProcValue);
    end;

    local procedure AddCreditorPartyInfo(var TargetText: Text; var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        TempCustomer: Record Customer temporary;
    begin
        SwissQRBillBuffer.GetCreditorInfo(TempCustomer);
        AddPartyInfo(TargetText, TempCustomer, SwissQRBillBuffer."Creditor Address Type");
    end;

    local procedure AddUltimateCreditorPartyInfo(var TargetText: Text; var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        TempCustomer: Record Customer temporary;
    begin
        if SwissQRBillBuffer.GetUltimateCreditorInfo(TempCustomer) then
            AddPartyInfo(TargetText, TempCustomer, SwissQRBillBuffer."UCreditor Address Type")
        else
            AddBlankedPartyInfo(TargetText);
    end;

    local procedure AddUltimateDebitorPartyInfo(var TargetText: Text; var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    var
        TempCustomer: Record Customer temporary;
    begin
        if SwissQRBillBuffer.GetUltimateDebitorInfo(TempCustomer) then
            AddPartyInfo(TargetText, TempCustomer, SwissQRBillBuffer."UDebtor Address Type")
        else
            AddBlankedPartyInfo(TargetText);
    end;

    local procedure AddPartyInfo(var TargetText: Text; Customer: Record Customer; AddressType: Enum "Swiss QR-Bill Address Type")
    var
        LineText: Text;
    begin
        AddLine(TargetText, FormatAddressType(AddressType));
        with Customer do begin
            AddLine(TargetText, CopyStr(Name, 1, 70));
            case AddressType of
                AddressType::Structured:
                    begin
                        AddLine(TargetText, CopyStr(Address, 1, 70));
                        AddLine(TargetText, CopyStr("Address 2", 1, 16));
                        AddLine(TargetText, CopyStr("Post Code", 1, 16));
                        AddLine(TargetText, City);
                    end;
                AddressType::Combined:
                    begin
                        AddLine(LineText, Address);
                        AddTextToLine(LineText, "Address 2");
                        AddLine(TargetText, CopyStr(LineText, 1, 70));
                        LineText := '';
                        AddLine(LineText, "Post Code");
                        AddTextToLine(LineText, City);
                        AddLine(TargetText, CopyStr(LineText, 1, 70));
                        AddLine(TargetText, '');
                        AddLine(TargetText, '');
                    end;
            end;
            AddLine(TargetText, "Country/Region Code");
        end;
    end;

    local procedure AddReferenceInfo(var TargetText: Text; SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    begin
        AddLine(TargetText, FormatReferenceType(SwissQRBillBuffer."Payment Reference Type"));
        AddLine(TargetText, DelChr(SwissQRBillBuffer."Payment Reference"));
    end;

    local procedure AddBlankedPartyInfo(var TargetText: Text)
    var
        i: Integer;
    begin
        for i := 1 to 7 do
            AddLine(TargetText, '');
    end;

    local procedure AddTextToLine(var TargetText: Text; AddText: Text)
    begin
        if AddText <> '' then
            TargetText += ' ' + AddText;
    end;

    local procedure AddLineConditionally(var TargetText: Text; LineText: Text; Condition: Boolean)
    begin
        if Condition then
            AddLine(TargetText, LineText)
        else
            AddLineIfNotBlanked(TargetText, LineText);
    end;

    local procedure AddLine(var TargetText: Text; LineText: Text)
    begin
        SwissQRBillMgt.AddLine(TargetText, LineText);
    end;

    local procedure AddLineIfNotBlanked(var TargetText: Text; LineText: Text)
    begin
        SwissQRBillMgt.AddLineIfNotBlanked(TargetText, LineText);
    end;
}
