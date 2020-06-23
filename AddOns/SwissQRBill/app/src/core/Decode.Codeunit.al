codeunit 11512 "Swiss QR-Bill Decode"
{
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        ErrorLogContextRecordId: RecordId;
        CurrentLineNo: Integer;
        IsAnyErrorLog: Boolean;
        UnstrMsgNotFoundLbl: Label 'Unstructured message is not found.';
        TrailerEPDNotFoundLbl: Label 'Trailer value EPD is not found.';
        EmptyFileLbl: Label 'The file is empty.';
        HeaderSPCValueNotFoundLbl: Label 'Header QR type value SPC is not found.';
        HeaderVersionValueNotFoundLbl: Label 'Header version value 0200 is not found.';
        HeaderCodingTypeNotFoundLbl: Label 'Header coding type value 1 is not found.';
        CreditorIBANNotFoundLbl: Label 'Creditor''s account value (IBAN or QR-IBAN) is not found.';
        CreditorIBANLengthLbl: Label 'Creditor''s account value (IBAN or QR-IBAN) should be 21 chars length.';
        CreditorIBANCountryLbl: Label 'Only CH and LI IBAN values are permitted.';
        ParseAmountFailedLbl: Label 'Failed to parse amount value.';
        CurrencyNotFoundLbl: Label 'Currency is not found.';
        WrongCurrencyLbl: Label 'Only CHF and EUR currencies are permitted.';
        PmtReferenceTypeNotFoundLbl: Label 'Payment reference type is not found.';
        UnknownPmtReferenceTypeLbl: Label 'Payment reference type (QRR, SCOR or NON) is not found.';
        QRReferenceLengthLbl: Label 'QR-Reference must be 27 chars length.';
        CreditorReferenceLengthLbl: Label 'Creditor-Reference must be up to 25 chars length and start with RF and two check digits.';
        BlankedReferenceExpectedLbl: Label 'Blanked reference number is expected for reference type NON.';
        AddressTypeNotFoundLbl: Label 'Address type "S" or "K" is not found.';
        NameNotFoundLbl: Label 'The Name value is not found.';
        ExpectedBlankedValueLbl: Label 'The line value is expected to be blanked.';
        ExpectedEOFLbl: Label 'Unexpected end of file.';
        FileLineLbl: Label 'File line %1: %2', Comment = '%1 - line number, %2 - line text message';

    internal procedure SetContextRecordId(NewRecordId: RecordId)
    begin
        ErrorLogContextRecordId := NewRecordId;
    end;

    internal procedure AnyErrorLogged(): Boolean
    begin
        exit(IsAnyErrorLog);
    end;

    internal procedure DecodeQRCodeText(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"; QRCodeText: Text): Boolean
    begin
        Clear(SwissQRBillBuffer);

        if not InitializeLineBuffer(QRCodeText) then
            exit(false);

        if not ReadHeader() then
            exit(false);
        if not ReadIBAN(SwissQRBillBuffer) then
            exit(false);
        if not ReadCreditorPartyInfo(SwissQRBillBuffer) then
            exit(false);
        if not ReadUltimateCreditorPartyInfo(SwissQRBillBuffer) then
            exit(false);
        if not ReadPaymentInfo(SwissQRBillBuffer) then
            exit(false);
        if not ReadUltimateDebitorPartyInfo(SwissQRBillBuffer) then
            exit(false);
        if not ReadPaymentReferenceInfo(SwissQRBillBuffer) then
            exit(false);
        if not ReadNextLineIntoFieldNo(SwissQRBillBuffer, SwissQRBillBuffer.FieldNo("Unstructured Message"), UnstrMsgNotFoundLbl) then
            exit(false);
        if not ReadNextLineAndAssertValue('EPD', TrailerEPDNotFoundLbl) then
            exit(false);
        // Optional
        if not ReadNextLineIntoFieldNo(SwissQRBillBuffer, SwissQRBillBuffer.FieldNo("Billing Information"), '') then
            exit(not AnyErrorLogged());
        if not ReadNextLineIntoFieldNo(SwissQRBillBuffer, SwissQRBillBuffer.FieldNo("Alt. Procedure Value 1"), '') then
            exit(not AnyErrorLogged());
        ReadNextLineIntoFieldNo(SwissQRBillBuffer, SwissQRBillBuffer.FieldNo("Alt. Procedure Value 2"), '');
        ParseAltProcedures(SwissQRBillBuffer);
        exit(not AnyErrorLogged());
    end;

    local procedure ParseAltProcedures(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer")
    begin
        with SwissQRBillBuffer do begin
            ParseAltProcedure("Alt. Procedure Name 1", "Alt. Procedure Value 1", 'AV1');
            ParseAltProcedure("Alt. Procedure Name 2", "Alt. Procedure Value 2", 'AV2');
        end;
    end;

    local procedure ParseAltProcedure(var NameText: Text[10]; var ValueText: Text[100]; defaultName: Text[10])
    var
        Pos: Integer;
    begin
        if ValueText <> '' then begin
            Pos := StrPos(ValueText, ':');
            if (Pos > 1) and (Pos <= (MaxStrLen(NameText) + 1)) then begin
                NameText := CopyStr(CopyStr(ValueText, 1, Pos - 1), 1, MaxStrLen(NameText));
                ValueText := CopyStr(DelStr(ValueText, 1, Pos + 1), 1, MaxStrLen(ValueText));
            end else
                NameText := defaultName;
        end;
    end;

    local procedure InitializeLineBuffer(QRCodeText: Text): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        LineText: Text;
        MaxLineNo: Integer;
        EmptyBuffer: Boolean;
    begin
        MaxLineNo := 100;
        CurrentLineNo := 0;
        if StrLen(QRCodeText) = 0 then
            exit(LogErrorAndExit(EmptyFileLbl, true, false));

        TempBlob.CreateOutStream(OutStream);
        TempBlob.CreateInStream(InStream);
        OutStream.Write(QRCodeText);

        TempNameValueBuffer.Init();
        while not InStream.EOS() and (TempNameValueBuffer.ID < MaxLineNo) do begin
            TempNameValueBuffer.ID += 1;
            InStream.ReadText(LineText);
            TempNameValueBuffer.Value := CopyStr(LineText, 1, MaxStrLen(TempNameValueBuffer.Value));
            TempNameValueBuffer.Insert();
        end;

        EmptyBuffer := TempNameValueBuffer.IsEmpty();
        exit(LogErrorAndExit(EmptyFileLbl, EmptyBuffer, not EmptyBuffer));
    end;

    local procedure ReadHeader(): Boolean
    begin
        if not ReadNextLineAndAssertValue('SPC', HeaderSPCValueNotFoundLbl) then
            exit(false);

        if not ReadNextLineAndAssertValue('0200', HeaderVersionValueNotFoundLbl) then
            exit(false);

        exit(ReadNextLineAndAssertValue('1', HeaderCodingTypeNotFoundLbl));
    end;

    local procedure ReadIBAN(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        LineText: Text;
    begin
        if not ReadNextLineAndTestValue(LineText, CreditorIBANNotFoundLbl) then
            exit(false);

        if CheckIBAN(LineText) then
            SwissQRBillBuffer.IBAN := CopyStr(LineText, 1, MaxStrLen(SwissQRBillBuffer.IBAN));
        exit(true);
    end;

    local procedure CheckIBAN(var IBAN: Text): Boolean
    begin
        IBAN := DelChr(IBAN);
        if StrLen(IBAN) <> 21 then
            exit(LogErrorAndExit(CreditorIBANLengthLbl, true, false));

        if not (CopyStr(IBAN, 1, 2) in ['CH', 'LI']) then
            exit(LogErrorAndExit(CreditorIBANCountryLbl, true, false));

        exit(true);
    end;

    local procedure ReadCreditorPartyInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        TempCustomer: Record Customer temporary;
        AddressType: Text;
    begin
        if not ReadPartyInfo(TempCustomer, AddressType, true) then
            exit(false);

        SwissQRBillBuffer.SetCreditorInfo(TempCustomer);
        SwissQRBillBuffer."Creditor Address Type" := MapAddressType(AddressType);
        exit(true);
    end;

    local procedure ReadUltimateCreditorPartyInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        TempCustomer: Record Customer temporary;
        AddressType: Text;
    begin
        if not ReadPartyInfo(TempCustomer, AddressType, false) then
            exit(false);

        if AddressType <> '' then begin
            SwissQRBillBuffer.SetUltimateCreditorInfo(TempCustomer);
            SwissQRBillBuffer."UCreditor Address Type" := MapAddressType(AddressType);
        end;
        exit(true);
    end;

    local procedure ReadPaymentInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        AmountText: Text;
        CurrencyText: Text;
    begin
        if not ReadNextLine(AmountText, true) then
            exit(false);
        if AmountText <> '' then
            if not Evaluate(SwissQRBillBuffer.Amount, DelChr(AmountText), 9) then
                LogErrorAndExit(ParseAmountFailedLbl, true, false);
        if not ReadNextLineAndTestValue(CurrencyText, CurrencyNotFoundLbl) then
            exit(false);
        SwissQRBillBuffer.Currency := CopyStr(CurrencyText, 1, 3);
        exit(LogErrorAndExit(WrongCurrencyLbl, not SwissQRBillMgt.AllowedISOCurrency(CurrencyText), true));
    end;

    local procedure ReadUltimateDebitorPartyInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        TempCustomer: Record Customer temporary;
        AddressType: Text;
    begin
        if not ReadPartyInfo(TempCustomer, AddressType, false) then
            exit(false);

        if AddressType <> '' then begin
            SwissQRBillBuffer.SetUltimateDebitorInfo(TempCustomer);
            SwissQRBillBuffer."UDebtor Address Type" := MapAddressType(AddressType);
        end;
        exit(true);
    end;

    local procedure ReadPaymentReferenceInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        ReferenceTypeText: Text;
    begin
        if not ReadNextLineAndTestValue(ReferenceTypeText, PmtReferenceTypeNotFoundLbl) then
            exit(false);

        with SwissQRBillBuffer do
            case ReferenceTypeText of
                'QRR':
                    begin
                        "IBAN Type" := "IBAN Type"::"QR-IBAN";
                        "Payment Reference Type" := "Payment Reference Type"::"QR Reference";
                    end;
                'SCOR':
                    begin
                        "IBAN Type" := "IBAN Type"::IBAN;
                        "Payment Reference Type" := "Payment Reference Type"::"Creditor Reference (ISO 11649)";
                    end;
                'NON':
                    "Payment Reference Type" := "Payment Reference Type"::"Without Reference";
                else
                    LogErrorAndExit(UnknownPmtReferenceTypeLbl, true, false);
            end;

        exit(ReadCheckAndValidateReferenceNo(SwissQRBillBuffer));
    end;

    local procedure ReadCheckAndValidateReferenceNo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"): Boolean
    var
        PaymentReferenceNoText: Text;
    begin
        if not ReadNextLine(PaymentReferenceNoText, true) then
            exit(false);

        PaymentReferenceNoText := DelChr(PaymentReferenceNoText);
        with SwissQRBillBuffer do begin
            case "Payment Reference Type" of
                "Payment Reference Type"::"QR Reference":
                    if StrLen(PaymentReferenceNoText) <> 27 then
                        exit(LogErrorAndExit(QRReferenceLengthLbl, true, true));
                "Payment Reference Type"::"Creditor Reference (ISO 11649)":
                    if (StrLen(PaymentReferenceNoText) > 25) or
                       (StrLen(PaymentReferenceNoText) < 5) or
                       (CopyStr(PaymentReferenceNoText, 1, 2) <> 'RF')
                    then
                        exit(LogErrorAndExit(CreditorReferenceLengthLbl, true, true));
                "Payment Reference Type"::"Without Reference":
                    if StrLen(PaymentReferenceNoText) > 0 then
                        exit(LogErrorAndExit(BlankedReferenceExpectedLbl, true, true));
            end;
            "Payment Reference" := CopyStr(PaymentReferenceNoText, 1, MaxStrLen("Payment Reference"));
        end;

        exit(true);
    end;

    local procedure ReadPartyInfo(var Customer: Record Customer; var AddressType: Text; Mandatory: Boolean): Boolean
    var
        NewName: Text;
        AddressLine1: Text;
        AddressLine2: Text;
        PostalCode: Text;
        NewCity: Text;
        Country: Text;
        i: Integer;
    begin
        Clear(Customer);

        if not ReadNextLine(AddressType, true) then
            exit(false);

        if not Mandatory and (AddressType = '') then
            exit(ReadBlankedPartyInfo());

        if not (AddressType in ['S', 'K']) then
            LogErrorAndExit(AddressTypeNotFoundLbl, true, false);

        if not ReadNextLineAndTestValue(NewName, NameNotFoundLbl) then
            exit(false);
        if not ReadNextLine(AddressLine1, true) then
            exit(false);
        if not ReadNextLine(AddressLine2, true) then
            exit(false);
        if AddressType = 'S' then begin
            if not ReadNextLine(PostalCode, true) then
                exit(false);
            if not ReadNextLine(NewCity, true) then
                exit(false);
        end else
            for i := 1 to 2 do
                if not ReadNextLineAndAssertValue('', ExpectedBlankedValueLbl) then
                    exit(false);
        if not ReadNextLine(Country, true) then
            exit(false);

        with Customer do begin
            Name := CopyStr(NewName, 1, MaxStrLen(Name));
            Address := CopyStr(AddressLine1, 1, MaxStrLen(Address));
            "Address 2" := CopyStr(AddressLine2, 1, MaxStrLen("Address 2"));
            if AddressType = 'S' then begin
                "Post Code" := CopyStr(PostalCode, 1, MaxStrLen("Post Code"));
                City := CopyStr(NewCity, 1, MaxStrLen(City));
            end;
            "Country/Region Code" := CopyStr(Country, 1, MaxStrLen("Country/Region Code"));
        end;

        exit(true);
    end;

    local procedure MapAddressType(AddressType: Text) Result: Enum "Swiss QR-Bill Address Type"
    begin
        if AddressType = 'S' then
            exit(Result::Structured);
        exit(Result::Combined);
    end;

    local procedure ReadBlankedPartyInfo(): Boolean
    var
        i: Integer;
    begin
        for i := 1 to 6 do
            if not ReadNextLineAndAssertValue('', ExpectedBlankedValueLbl) then
                exit(false);
        exit(true);
    end;

    local procedure ReadNextLineIntoFieldNo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer"; FieldNo: Integer; ErrorDescription: Text): Boolean
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        LineText: Text;
    begin
        if not ReadNextLine(LineText, ErrorDescription <> '') then
            exit(LogErrorAndExit(ErrorDescription, true, false));

        RecordRef.GetTable(SwissQRBillBuffer);
        FieldRef := RecordRef.Field(FieldNo);
        FieldRef.Value := CopyStr(LineText, 1, FieldRef.Length());
        RecordRef.SetTable(SwissQRBillBuffer);
        exit(true);
    end;

    local procedure ReadNextLine(var LineText: Text; LogEOF: Boolean) FileRead: Boolean
    begin
        if CurrentLineNo = 0 then
            FileRead := TempNameValueBuffer.FindSet()
        else
            FileRead := TempNameValueBuffer.Next() <> 0;

        CurrentLineNo += 1;
        LineText := TempNameValueBuffer.Value;
        exit(LogErrorAndExit(ExpectedEOFLbl, not FileRead and LogEOF, FileRead));
    end;

    local procedure ReadNextLineAndTestValue(var LineText: Text; ErrorDescription: Text) Result: Boolean
    begin
        Result := ReadNextLine(LineText, true);
        exit(LogErrorAndExit(ErrorDescription, Result and (LineText = ''), Result));
    end;

    local procedure ReadNextLineAndAssertValue(ExpectedValue: Text; ErrorDescription: Text) Result: Boolean
    var
        LineText: Text;
    begin
        Result := ReadNextLine(LineText, true);
        exit(LogErrorAndExit(ErrorDescription, Result and (LineText <> ExpectedValue), Result));
    end;

    local procedure LogErrorAndExit(ErrorDescription: Text; ErrorCondition: Boolean; Result: Boolean): Boolean
    var
        ErrorMessage: Record "Error Message";
    begin
        exit(LogAndExit(ErrorMessage."Message Type"::Error, ErrorDescription, ErrorCondition, Result));
    end;

    local procedure LogAndExit(MessageType: Option; MessageDescription: Text; MessageCondition: Boolean; Result: Boolean): Boolean
    var
        ErrorMessage: Record "Error Message";
    begin
        if MessageCondition and (MessageDescription <> '') then
            if ErrorLogContextRecordId.TableNo() <> 0 then begin
                ErrorMessage.SetContext(ErrorLogContextRecordId);
                if CurrentLineNo > 0 then
                    MessageDescription := StrSubstNo(FileLineLbl, CurrentLineNo, MessageDescription);
                ErrorMessage.LogSimpleMessage(MessageType, MessageDescription);
                IsAnyErrorLog := true;
            end;
        exit(Result);
    end;
}
