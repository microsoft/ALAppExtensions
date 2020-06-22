codeunit 11516 "Swiss QR-Bill Incoming Doc"
{
    var
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        SwissQRBillPurchases: Codeunit "Swiss QR-Bill Purchases";
        ErrorLogContextRecordId: RecordId;
        IsAnyWarningLogged: Boolean;
        BlankedImportErr: Label 'There is no data to import.';
        ReplaceMainAttachmentQst: Label 'Are you sure you want to replace the attached file?';
        DocAlreadyCreatedErr: Label 'The document has already been created.';
        ConfirmNavigateDocAlreadyCreatedQst: Label 'The document has already been created. Do you want to open it?';
        ImportCompletedMsg: Label 'QR-Bill import has been successfully completed.';
        ImportCompletedWithWarningsMsg: Label 'QR-Bill import has been successfully completed with warnings.';
        ImportFailedMsg: Label 'QR-Bill import has been completed, but data parsing has been failed.';
        ImportFailedWithErrorsMsg: Label 'QR-Bill import has been completed, but data parsing has been failed. See error section for more details.';
        CreditorDetailsNotFoundTxt: Label 'Creditor''s detailed information is not found.';
        MatchWarningCreditorNameTxt: Label 'Creditor''s name %1 does not correspond to %2 from the vendor information.', Comment = '%1, %2 - actual\expected names';
        MatchWarningCreditorCityTxt: Label 'Creditor''s city %1 does not correspond to %2 from the vendor information.', Comment = '%1, %2 - actual\expected city value';
        MatchWarningCreditorPostCodeTxt: Label 'Creditor''s post code %1 does not correspond to %2 from the vendor information.', Comment = '%1, %2 - actual\expected post code value';
        MatchWarningCreditorCountryTxt: Label 'Creditor''s country %1 does not correspond to %2 from the vendor information.', Comment = '%1, %2 - actual\expected country value';
        DebitorDetailsNotFoundTxt: Label 'Debitor''s detailed information is not found.';
        MatchWarningDebitorNameTxt: Label 'Debitor''s name %1 does not correspond to %2 from the company information.', Comment = '%1, %2 - actual\expected names';
        MatchWarningDebitorCityTxt: Label 'Debitor''s city %1 does not correspond to %2 from the company information.', Comment = '%1, %2 - actual\expected city value';
        MatchWarningDebitorPostCodeTxt: Label 'Debitor''s post code %1 does not correspond to %2 from the company information.', Comment = '%1, %2 - actual\expected post code value';
        MatchWarningDebitorCountryTxt: Label 'Debitor''s country %1 does not correspond to %2 from the company information.', Comment = '%1, %2 - actual\expected country value';
        MatchCurrencyTxt: Label 'Currency %1 is assigned, but is not found in the system.', Comment = '%1 - currency code';
        QRReferenceDigitsTxt: Label 'QR refernce %1 must contain only digits.', Comment = '%1 - payment reference number\code';
        QRReferenceCheckDigitsTxt: Label 'QR reference %1 check digit is wrong.', Comment = '%1 - payment reference number\code';
        CreditorReferenceCheckDigitsTxt: Label 'Creditor reference %1 check digit is wrong.', Comment = '%1 - payment reference number\code';
        VendorNotFoundMsg: Label 'Vendor is not found with bank account IBAN = %1.', Comment = '%1 - IBAN value';
        ImportFailedTxt: Label 'QR-Bill import failed.';
        DecodeFailedTxt: Label 'Could not decode QR-Bill information.';

    internal procedure GetImportFailedTxt(): Text
    begin
        exit(ImportFailedTxt);
    end;

    internal procedure QRBillImportDecodeToPurchase(var IncomingDocument: Record "Incoming Document"; FromFile: Boolean) Result: Boolean
    var
        DecodeResult: Boolean;
        DecodeErrorLogged: Boolean;
    begin
        Result := QRBillImportDecode(IncomingDocument, FromFile, DecodeResult, DecodeErrorLogged);
        Result := Result and DecodeResult;
    end;

    internal procedure DrillDownVendorIBAN(IBAN: Code[50])
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if IBAN <> '' then
            if FindVendorBankAccount(VendorBankAccount, IBAN) then begin
                VendorBankAccount.SetRecFilter();
                Page.RunModal(Page::"Vendor Bank Account Card", VendorBankAccount);
            end else
                Message(StrSubstNo(VendorNotFoundMsg, IBAN));
    end;

    internal procedure CreateNewIncomingDocFromQRBill(FromFile: Boolean)
    var
        IncomingDocument: Record "Incoming Document";
    begin
        if DecodeQRCodeToIncomingDocument(IncomingDocument, FromFile) then
            if IncomingDocument.Find() then
                Page.Run(Page::"Incoming Document", IncomingDocument);
    end;

    internal procedure ImportQRBillToIncomingDoc(var IncomingDocument: Record "Incoming Document"; FromFile: Boolean)
    begin
        if IncomingDocRelatedRecNotExists(IncomingDocument, false) then
            if ConfirmNewAttachment(IncomingDocument) then
                DecodeQRCodeToIncomingDocument(IncomingDocument, FromFile);
    end;

    internal procedure CreateJournalAction(var IncomingDocument: Record "Incoming Document")
    begin
        IncomingDocument.TestField("Vendor No.");
        IncomingDocument.TestField("Vendor Bank Account No.");
        if IncomingDocRelatedRecNotExists(IncomingDocument, true) then
            IncomingDocument.CreateGenJnlLine();
    end;

    internal procedure CreatePurchaseInvoiceAction(var IncomingDocument: Record "Incoming Document")
    begin
        IncomingDocument.TestField("Vendor No.");
        if IncomingDocRelatedRecNotExists(IncomingDocument, true) then
            IncomingDocument.CreatePurchInvoice();
    end;

    local procedure CreateJournalFromIncDoc(var IncomingDocument: Record "Incoming Document"): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        RecordVariant: Variant;
    begin
        if not IncomingDocument.GetRecord(RecordVariant) then
            exit(false);

        if not SwissQRBillPurchases.CheckConfirmIfPmtReferenceAlreadyExist(
                 IncomingDocument."Vendor No.", IncomingDocument."Swiss QR-Bill Reference No.", false, true, false)
        then
            exit(false);

        with GenJournalLine do begin
            GenJournalLine := RecordVariant;
            UpdateGenJournalLineFromIncomingDoc(GenJournalLine, IncomingDocument);
            Modify(true);
        end;

        exit(true);
    end;

    internal procedure UpdateGenJournalLineFromIncomingDoc(var GenJournalLine: Record "Gen. Journal Line"; IncomingDocument: Record "Incoming Document")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Sign: Decimal;
    begin
        with GenJournalLine do begin
            GenJournalTemplate.Get("Journal Template Name");
            if GenJournalTemplate.Type = GenJournalTemplate.Type::Purchases then begin
                Validate("Document Type", "Document Type"::Invoice);
                Sign := -1;
            end else begin
                Validate("Document Type", "Document Type"::Payment);
                Sign := 1;
            end;

            Validate("Account Type", "Account Type"::Vendor);
            if IncomingDocument."Vendor No." <> '' then begin
                Validate("Account No.", IncomingDocument."Vendor No.");
                if IncomingDocument."Vendor Bank Account No." <> '' then
                    Validate("Recipient Bank Account",
                        CopyStr(IncomingDocument."Vendor Bank Account No.", 1, MaxStrLen("Recipient Bank Account")));
            end;

            Validate("Currency Code", GetCurrency(IncomingDocument."Currency Code"));
            Validate(Amount, Sign * IncomingDocument."Amount Incl. VAT");
            Validate("Transaction Information", CopyStr(IncomingDocument."Swiss QR-Bill Bill Info", 1, MaxStrLen("Transaction Information")));
            Validate("Message to Recipient", IncomingDocument."Swiss QR-Bill Unstr. Message");
            Validate(Description, CopyStr(SwissQRBillMgt.GetQRBillCaption(), 1, MaxStrLen(Description)));
            Validate("Payment Reference", DelChr(IncomingDocument."Swiss QR-Bill Reference No."));
            Validate("External Document No.", IncomingDocument."Vendor Invoice No.");
            "Swiss QR-Bill" := true;
        end;
    end;

    local procedure CreatePurchaseInvoiceFromIncDoc(var IncomingDocument: Record "Incoming Document"; var PurchaseHeader: Record "Purchase Header"): Boolean
    begin
        if not PurchaseHeader.Find() then
            exit(false);

        if not SwissQRBillPurchases.CheckConfirmIfPmtReferenceAlreadyExist(
                 IncomingDocument."Vendor No.", IncomingDocument."Swiss QR-Bill Reference No.", false, true, false)
        then
            exit(false);

        UpdatePurchDocFromIncDoc(PurchaseHeader, IncomingDocument);

        exit(true);
    end;

    internal procedure UpdatePurchDocFromIncDoc(var PurchaseHeader: Record "Purchase Header"; var IncomingDocument: Record "Incoming Document")
    begin
        with PurchaseHeader do begin
            if ("Buy-from Vendor No." = '') and (IncomingDocument."Vendor No." <> '') then begin
                Validate("Buy-from Vendor No.", IncomingDocument."Vendor No.");
                Validate("Currency Code", GetCurrency(IncomingDocument."Currency Code"));
            end;
            Validate("Posting Description", CopyStr(IncomingDocument."Swiss QR-Bill Unstr. Message", 1, MaxStrLen("Posting Description")));
            Validate("Payment Reference", DelChr(IncomingDocument."Swiss QR-Bill Reference No."));
            Validate("Vendor Invoice No.", IncomingDocument."Vendor Invoice No.");

            "Swiss QR-Bill IBAN" := IncomingDocument."Vendor IBAN";
            "Swiss QR-Bill Currency" := IncomingDocument."Currency Code";
            "Swiss QR-Bill Amount" := IncomingDocument."Amount Incl. VAT";
            "Swiss QR-Bill Unstr. Message" := IncomingDocument."Swiss QR-Bill Unstr. Message";
            "Swiss QR-Bill Bill Info" := IncomingDocument."Swiss QR-Bill Bill Info";
            "Swiss QR-Bill" := true;
            Modify(true);
        end;
    end;

    local procedure ConfirmNewAttachment(IncomingDocument: Record "Incoming Document"): Boolean
    var
        MainIncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        if not IncomingDocument.GetMainAttachment(MainIncomingDocumentAttachment) then
            exit(true);
        exit(Confirm(ReplaceMainAttachmentQst));
    end;

    local procedure QRBillImportDecode(var IncomingDocument: Record "Incoming Document"; FromFile: Boolean; var DecodeResult: Boolean; var DecodeErrorLogged: Boolean) Result: Boolean
    var
        TempSwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary;
        SwissQRBillDecode: Codeunit "Swiss QR-Bill Decode";
        QRCodeText: Text;
        FileName: Text;
    begin
        if not QRBillImport(QRCodeText, FileName, FromFile) then
            exit(false);

        if not IncomingDocument.IsTemporary() then begin
            if IncomingDocument."Entry No." = 0 then
                IncomingDocument.CreateIncomingDocument(FileName, '');
            UpdateIncomingDocumentMainAttachment(IncomingDocument, QRCodeText, FileName);
            ClearIncomingDocument(IncomingDocument);
            SwissQRBillDecode.SetContextRecordId(IncomingDocument.RecordId());
        end;

        Result := true;
        DecodeResult := SwissQRBillDecode.DecodeQRCodeText(TempSwissQRBillBuffer, QRCodeText);
        DecodeErrorLogged := SwissQRBillDecode.AnyErrorLogged();

        if DecodeResult then begin
            BusinessValidation(TempSwissQRBillBuffer, IncomingDocument);
            Result :=
                SwissQRBillPurchases.CheckConfirmIfPmtReferenceAlreadyExist(
                    IncomingDocument."Vendor No.", IncomingDocument."Swiss QR-Bill Reference No.", true, true, true);
        end else
            if IncomingDocument.IsTemporary() then
                Message(StrSubstNo('%1\\%2', ImportFailedTxt, DecodeFailedTxt));
    end;

    local procedure QRBillImport(var QRCodeText: Text; var FileName: Text; FromFile: Boolean) Result: Boolean
    var
        SwissQRBillScan: Page "Swiss QR-Bill Scan";
    begin
        if FromFile then
            Result := QRBillImportFromFile(QRCodeText, FileName)
        else begin
            SwissQRBillScan.LookupMode(true);
            Result := SwissQRBillScan.RunModal() = Action::LookupOK;
            if Result then
                QRCodeText := SwissQRBillScan.GetQRBillText();
            FileName := SwissQRBillMgt.GetQRBillCaption();
        end;

        if Result and (QRCodeText = '') then
            Error(BlankedImportErr);
    end;

    local procedure QRBillImportFromFile(var QRCodeText: Text; var FileName: Text): boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStream: InStream;
    begin
        FileName := FileMgt.BLOBImport(TempBlob, 'Import QR-Bill Text File');
        FileName := FileMgt.GetFileNameWithoutExtension(FileName);
        if TempBlob.HasValue() then begin
            TempBlob.CreateInStream(InStream);
            InStream.Read(QRCodeText);
        end;

        exit(FileName <> '');
    end;

    local procedure DecodeQRCodeToIncomingDocument(var IncomingDocument: Record "Incoming Document"; FromFile: Boolean): Boolean
    var
        DecodeResult: Boolean;
        AnyErrorLogged: Boolean;
    begin
        if not QRBillImportDecode(IncomingDocument, FromFile, DecodeResult, AnyErrorLogged) then
            exit(false);

        IncomingDocument."Swiss QR-Bill" := true;
        IncomingDocument.Modify(true);
        Commit();

        if DecodeResult then begin
            if IsAnyWarningLogged then
                Message(ImportCompletedWithWarningsMsg)
            else
                Message(ImportCompletedMsg);
        end else
            if AnyErrorLogged then
                Message(ImportFailedWithErrorsMsg)
            else
                Message(ImportFailedMsg);

        exit(true);
    end;

    local procedure UpdateIncomingDocumentMainAttachment(var IncomingDocument: Record "Incoming Document"; QRCodeText: Text; FileName: Text)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        TempBlob.CreateInStream(InStream);
        OutStream.Write(QRCodeText);
        if IncomingDocument.GetMainAttachment(IncomingDocumentAttachment) then
            IncomingDocumentAttachment.Delete();

        if FileName = '' then
            FileName := SwissQRBillMgt.GetQRBillCaption();

        with IncomingDocumentAttachment do begin
            "Incoming Document Entry No." := IncomingDocument."Entry No.";
            Name := CopyStr(FileMgt.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(Name));
            Validate("File Extension", 'txt');
            SetContentFromBlob(TempBlob);
            Insert(true);
        end;
    end;

    local procedure ClearIncomingDocument(var IncomingDocument: Record "Incoming Document")
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(IncomingDocument.RecordId());
        ErrorMessage.ClearLog();

        with IncomingDocument do begin
            Clear("Vendor IBAN");
            Clear("Vendor VAT Registration No.");
            Clear("Amount Incl. VAT");
            Clear("Currency Code");
            Clear("Vendor Invoice No.");
            Clear("Swiss QR-Bill Reference Type");
            Clear("Swiss QR-Bill Reference No.");
            Clear("Swiss QR-Bill Unstr. Message");
            Clear("Swiss QR-Bill Bill Info");

            Clear("Vendor No.");
            Clear("Vendor Name");
            Clear("Vendor Bank Account No.");
            Clear("Swiss QR-Bill Vendor Address 1");
            Clear("Swiss QR-Bill Vendor Address 2");
            Clear("Swiss QR-Bill Vendor Post Code");
            Clear("Swiss QR-Bill Vendor City");
            Clear("Swiss QR-Bill Vendor Country");

            Clear("Swiss QR-Bill Debitor Name");
            Clear("Swiss QR-Bill Debitor Address1");
            Clear("Swiss QR-Bill Debitor Address2");
            Clear("Swiss QR-Bill Debitor PostCode");
            Clear("Swiss QR-Bill Debitor City");
            Clear("Swiss QR-Bill Debitor Country");
        end;
    end;

    internal procedure BusinessValidation(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary; var IncomingDocument: Record "Incoming Document")
    begin
        IsAnyWarningLogged := false;
        if not IncomingDocument.IsTemporary() then
            ErrorLogContextRecordId := IncomingDocument.RecordId();

        BusinessValidationVendorNo(SwissQRBillBuffer, IncomingDocument);
        BusinessValidationCurrency(SwissQRBillBuffer);
        BusinessValidationReferenceNo(SwissQRBillBuffer);

        IncomingDocument."Vendor IBAN" := SwissQRBillBuffer.IBAN;
        IncomingDocument."Amount Incl. VAT" := SwissQRBillBuffer.Amount;
        IncomingDocument."Currency Code" := SwissQRBillBuffer.Currency;
        IncomingDocument."Swiss QR-Bill Reference Type" := SwissQRBillBuffer."Payment Reference Type";
        IncomingDocument."Swiss QR-Bill Reference No." := SwissQRBillBuffer."Payment Reference";
        IncomingDocument."Swiss QR-Bill Unstr. Message" := SwissQRBillBuffer."Unstructured Message";
        IncomingDocument."Swiss QR-Bill Bill Info" := SwissQRBillBuffer."Billing Information";

        BusinessValidationCreditor(SwissQRBillBuffer, IncomingDocument);
        BusinessValidationDebitor(SwissQRBillBuffer, IncomingDocument);
        BusinessValidationBillingInfo(SwissQRBillBuffer, IncomingDocument);
    end;

    local procedure BusinessValidationCreditor(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary; var IncomingDocument: Record "Incoming Document")
    var
        TempCustomer: Record Customer temporary;
        Vendor: Record Vendor;
    begin
        if SwissQRBillBuffer.GetCreditorInfo(TempCustomer) then begin
            IncomingDocument."Vendor Name" := TempCustomer.Name;
            IncomingDocument."Swiss QR-Bill Vendor Address 1" := TempCustomer.Address;
            IncomingDocument."Swiss QR-Bill Vendor Address 2" := TempCustomer."Address 2";
            IncomingDocument."Swiss QR-Bill Vendor Post Code" := TempCustomer."Post Code";
            IncomingDocument."Swiss QR-Bill Vendor City" := TempCustomer.City;
            IncomingDocument."Swiss QR-Bill Vendor Country" := TempCustomer."Country/Region Code";

            if IncomingDocument."Vendor No." <> '' then
                if Vendor.Get(IncomingDocument."Vendor No.") then begin
                    if (Vendor."Country/Region Code" <> '') and (TempCustomer."Country/Region Code" <> '') and
                        (Vendor."Country/Region Code" <> TempCustomer."Country/Region Code")
                    then
                        LogWarning(StrSubstNo(MatchWarningCreditorCountryTxt, TempCustomer."Country/Region Code", Vendor."Country/Region Code"));

                    if (Vendor."Post Code" <> '') and (TempCustomer."Post Code" <> '') and
                        (Vendor."Post Code" <> TempCustomer."Post Code")
                    then
                        LogWarning(StrSubstNo(MatchWarningCreditorPostCodeTxt, TempCustomer."Post Code", Vendor."Post Code"));

                    if (Vendor.City <> '') and (TempCustomer.City <> '') then
                        if NotSimilarStrings(TempCustomer.City, Vendor.City) then
                            LogWarning(StrSubstNo(MatchWarningCreditorCityTxt, TempCustomer.City, Vendor.City));

                    if (Vendor.Name <> '') and (TempCustomer.Name <> '') then
                        if NotSimilarStrings(TempCustomer.Name, Vendor.Name) then
                            LogWarning(StrSubstNo(MatchWarningCreditorNameTxt, TempCustomer.Name, Vendor.Name));
                end;
        end else
            LogWarning(CreditorDetailsNotFoundTxt);
    end;

    local procedure BusinessValidationDebitor(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary; var IncomingDocument: Record "Incoming Document")
    var
        TempCustomer: Record Customer temporary;
        CompanyInfo: Record "Company Information";
    begin
        if SwissQRBillBuffer.GetUltimateDebitorInfo(TempCustomer) then begin
            IncomingDocument."Swiss QR-Bill Debitor Name" := TempCustomer.Name;
            IncomingDocument."Swiss QR-Bill Debitor Address1" := TempCustomer.Address;
            IncomingDocument."Swiss QR-Bill Debitor Address2" := TempCustomer."Address 2";
            IncomingDocument."Swiss QR-Bill Debitor PostCode" := TempCustomer."Post Code";
            IncomingDocument."Swiss QR-Bill Debitor City" := TempCustomer.City;
            IncomingDocument."Swiss QR-Bill Debitor Country" := TempCustomer."Country/Region Code";

            CompanyInfo.Get();
            if (CompanyInfo."Country/Region Code" <> '') and (TempCustomer."Country/Region Code" <> '') and
                (CompanyInfo."Country/Region Code" <> TempCustomer."Country/Region Code")
            then
                LogWarning(StrSubstNo(MatchWarningDebitorCountryTxt, TempCustomer."Country/Region Code", CompanyInfo."Country/Region Code"));

            if (CompanyInfo."Post Code" <> '') and (TempCustomer."Post Code" <> '') and
                (CompanyInfo."Post Code" <> TempCustomer."Post Code")
            then
                LogWarning(StrSubstNo(MatchWarningDebitorPostCodeTxt, TempCustomer."Post Code", CompanyInfo."Post Code"));

            if (CompanyInfo.City <> '') and (TempCustomer.City <> '') then
                if NotSimilarStrings(TempCustomer.City, CompanyInfo.City) then
                    LogWarning(StrSubstNo(MatchWarningDebitorCityTxt, TempCustomer.City, CompanyInfo.City));

            if (CompanyInfo.Name <> '') and (TempCustomer.Name <> '') then
                if NotSimilarStrings(TempCustomer.Name, CompanyInfo.Name) then
                    LogWarning(StrSubstNo(MatchWarningDebitorNameTxt, TempCustomer.Name, CompanyInfo.Name));
        end else
            LogWarning(DebitorDetailsNotFoundTxt);
    end;

    local procedure BusinessValidationBillingInfo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary; var IncomingDocument: Record "Incoming Document")
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
        SwissQRBillBillingInfo: Codeunit "Swiss QR-Bill Billing Info";
    begin
        if SwissQRBillBillingInfo.ParseBillingInfo(TempSwissQRBillBillingDetail, SwissQRBillBuffer."Billing Information") then
            with TempSwissQRBillBillingDetail do begin
                SetRange("Tag Type", "Tag Type"::"VAT Registration No.");
                if FindFirst() then
                    IncomingDocument."Vendor VAT Registration No." :=
                        CopyStr("Tag Value", 1, MaxStrLen(IncomingDocument."Vendor VAT Registration No."));

                Reset();
                SetRange("Tag Type", "Tag Type"::"Document No.");
                if FindFirst() then
                    IncomingDocument."Vendor Invoice No." :=
                        CopyStr("Tag Value", 1, MaxStrLen(IncomingDocument."Vendor Invoice No."));
            end;
    end;

    local procedure NotSimilarStrings(Actual: Text; Expected: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.TextDistance(Actual, Expected) > (StrLen(Actual) / 3));
    end;

    local procedure BusinessValidationCurrency(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary)
    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
    begin
        GLSetup.Get();
        if GLSetup."LCY Code" <> SwissQRBillBuffer.Currency then
            if not Currency.Get(SwissQRBillBuffer.Currency) then
                LogWarning(StrSubstNo(MatchCurrencyTxt, SwissQRBillBuffer.Currency));
    end;

    local procedure BusinessValidationReferenceNo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary)
    var
        i: Integer;
    begin
        with SwissQRBillBuffer do
            case "Payment Reference Type" of
                "Payment Reference Type"::"QR Reference":
                    begin
                        for i := 1 to StrLen("Payment Reference") do
                            if ("Payment Reference"[i] < '0') and ("Payment Reference"[i] > '9') then begin
                                LogWarning(StrSubstNo(QRReferenceDigitsTxt, "Payment Reference"));
                                exit;
                            end;
                        if not SwissQRBillMgt.CheckDigitForQRReference("Payment Reference") then
                            LogWarning(StrSubstNo(QRReferenceCheckDigitsTxt, "Payment Reference"));
                    end;
                "Payment Reference Type"::"Creditor Reference (ISO 11649)":
                    if not SwissQRBillMgt.CheckDigitForCreditorReference("Payment Reference") then
                        LogWarning(StrSubstNo(CreditorReferenceCheckDigitsTxt, "Payment Reference"));
            end;
    end;

    local procedure BusinessValidationVendorNo(var SwissQRBillBuffer: Record "Swiss QR-Bill Buffer" temporary; var IncomingDocument: Record "Incoming Document")
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        SwissQRBillBuffer.TestField(IBAN);
        if FindVendorBankAccount(VendorBankAccount, SwissQRBillBuffer.IBAN) then begin
            IncomingDocument."Vendor No." := VendorBankAccount."Vendor No.";
            IncomingDocument."Vendor Bank Account No." := VendorBankAccount.Code;
            exit;
        end;

        LogWarning(StrSubstNo(VendorNotFoundMsg, SwissQRBillBuffer.IBAN));
    end;

    local procedure FindVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; IBAN: Code[50]): Boolean
    begin
        if FindVendorBankAccountWithGivenIBAN(VendorBankAccount, CopyStr(DelChr(IBAN), 1, MaxStrLen(IBAN))) then
            exit(true);

        exit(FindVendorBankAccountWithGivenIBAN(VendorBankAccount, SwissQRBillMgt.FormatIBAN(IBAN)));
    end;

    local procedure FindVendorBankAccountWithGivenIBAN(var VendorBankAccount: Record "Vendor Bank Account"; SearchIBAN: Code[50]): Boolean
    begin
        with VendorBankAccount do begin
            Reset();
            SetRange(IBAN, SearchIBAN);
            if FindFirst() then
                exit(true);
        end;

        exit(false);
    end;

    local procedure LogWarning(WarningDescription: Text)
    var
        ErrorMessage: Record "Error Message";
    begin
        IsAnyWarningLogged := true;
        if ErrorLogContextRecordId.TableNo() <> 0 then begin
            ErrorMessage.SetContext(ErrorLogContextRecordId);
            ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Information, WarningDescription);
        end;
    end;

    local procedure IncomingDocRelatedRecNotExists(IncomingDocument: Record "Incoming Document"; NavigateIfCreated: Boolean) Result: Boolean
    var
        RelatedRecord: Variant;
    begin
        Result := not IncomingDocument.GetRecord(RelatedRecord);
        if not Result then
            if NavigateIfCreated then begin
                if Confirm(ConfirmNavigateDocAlreadyCreatedQst) then
                    IncomingDocument.ShowRecord();
            end else
                Error(DocAlreadyCreatedErr)
    end;

    internal procedure GetCurrency(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode <> '' then
            if GLSetup.Get() then
                if GLSetup."LCY Code" = CurrencyCode then
                    CurrencyCode := '';
        exit(CurrencyCode);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnBeforeGetJournalTemplateAndBatch', '', false, false)]
    local procedure OnBeforeGetJournalTemplateAndBatch(sender: Record "Incoming Document"; var JournalBatch: Code[10]; var JournalTemplate: Code[10]; var IsHandled: Boolean)
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        if not sender."Swiss QR-Bill" or IsHandled then
            exit;

        with SwissQRBillSetup do
            if Get() then begin
                TestField("Journal Template");
                TestField("Journal Batch");
                JournalTemplate := "Journal Template";
                JournalBatch := "Journal Batch";
                IsHandled := true;
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterCreateGenJnlLineFromIncomingDocFail', '', false, false)]
    local procedure OnAfterCreateGenJnlLineFromIncomingDocFail(var IncomingDocument: Record "Incoming Document")
    begin
        if not IncomingDocument."Swiss QR-Bill" then
            exit;

        IncomingDocument.Status := IncomingDocument.Status::Failed;
        IncomingDocument.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterCreateGenJnlLineFromIncomingDocSuccess', '', false, false)]
    local procedure OnAfterCreateGenJnlLineFromIncomingDocSuccess(var IncomingDocument: Record "Incoming Document")
    begin
        if not IncomingDocument."Swiss QR-Bill" then
            exit;

        if CreateJournalFromIncDoc(IncomingDocument) then
            IncomingDocument.Status := IncomingDocument.Status::Created
        else
            IncomingDocument.Status := IncomingDocument.Status::Failed;
        IncomingDocument.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnAfterCreatePurchHeaderFromIncomingDoc', '', false, false)]
    local procedure OnAfterCreatePurchHeaderFromIncomingDoc(var sender: Record "Incoming Document"; var PurchHeader: Record "Purchase Header")
    begin
        if not sender."Swiss QR-Bill" then
            exit;

        if CreatePurchaseInvoiceFromIncDoc(sender, PurchHeader) then
            sender.Status := sender.Status::Created
        else
            sender.Status := sender.Status::Failed;
        sender.Modify();
    end;
}
