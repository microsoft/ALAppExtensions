// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 11016 "Create XML-File VAT Adv.Notif."
{
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("Sales VAT Advance Notif."; "Sales VAT Advance Notif.")
        {
            DataItemTableView = sorting("No.")
                                order(Ascending);

            trigger OnPreDataItem()
            begin
                if GuiAllowed() then
                    Window.Open('#1########');
            end;

            trigger OnAfterGetRecord()
            var
                PeriodSelection: Enum "VAT Statement Report Period Selection";
                Continued: Decimal;
                TotalLine1: Decimal;
                TotalLine2: Decimal;
                TotalLine3: Decimal;
                PosTaxOffice: Integer;
                NumberTaxOffice: Integer;
                PosArea: Integer;
                NumberArea: Integer;
                PosDistinction: Integer;
                NumberDistinction: Integer;
                TaxUnrealizedAmount: array[100] of Decimal;
                TaxUnrealizedBase: array[100] of Decimal;
            begin
                Session.LogMessage('0000C9S', CreateXMLFileMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ElsterTok);

                if "XML-File Creation Date" <> 0D then
                    Error(XMLFileExistsErr, TableCaption());
                TestField("Contact for Tax Office");
                if GuiAllowed() then
                    Window.Update(1, CalcTaxAmountMsg);
                VATStmtName.SetRange("Sales VAT Adv. Notif.", true);
                VATStmtName.FindFirst();
                CheckDate("Starting Date");
                CheckVATNo(PosTaxOffice, NumberTaxOffice, PosArea, NumberArea, PosDistinction, NumberDistinction);
                if "Incl. VAT Entries (Period)" = "Incl. VAT Entries (Period)"::"Before and Within Period" then
                    PeriodSelection := PeriodSelection::"Before and Within Period"
                else
                    PeriodSelection := PeriodSelection::"Within Period";
                SetCalcParameters("Starting Date", CalcEndDate("Starting Date"),
                  "Incl. VAT Entries (Closing)", PeriodSelection,
                  "Amounts in Add. Rep. Currency");
                CalcTaxFigures(VATStmtName, TaxAmount, TaxBase, TaxUnrealizedAmount, TaxUnrealizedBase,
                  Continued, TotalLine1, TotalLine2, TotalLine3);
                if GuiAllowed() then
                    Window.Update(1, CreateSalesVATAdvNotifMsg);

                CheckTaxPairs();

                CreateXmlSubDoc();

                Session.LogMessage('0000C9T', CreateXMLFileSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ElsterTok);
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    Window.Close();
                Commit();
                case SubsequentAction of
                    SubsequentAction::"Create and export":
                        Export();
                    SubsequentAction::"Only create":
                        Message(XMLFileHasBeenCreatedMsg, TableCaption());
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(XmlFile; SubsequentAction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'XML-File';
                        OptionCaption = 'Create,Create and export';
                        ToolTip = 'Specifies if you want to create the XML document, create and export the XML document.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        VATStmtName: Record "VAT Statement Name";
        CompanyInfo: Record "Company Information";
        CalcTaxAmountMsg: Label 'Calculating Tax Amounts';
        CreateSalesVATAdvNotifMsg: Label 'Creating Sales VAT Adv. Notif.';
        XMLDocHasNotBeenCreatedErr: Label 'The XML Document has not been created.';
        ErrorMustConsistErr: Label 'The %1 must consist of 4 digits.';
        ErrorKeyFigureErr: Label 'Key figure %1 must not be negative.';
        XMLFileHasBeenCreatedMsg: Label 'The XML-File for the %1 has been created successfully.';
        XMLFileExistsErr: Label 'The XML-File for the %1 already exists.';
        TruncateRequestMsg: Label 'The length of the field %1 of table %2 exceeds the maximum length of %3 allowed. The text will be truncated from\\%4 to\%5.\\Do you want to continue?';
        ErrorCategoryErr: Label 'Please make sure that as well category %1 and %2 are defined in %3 %4.';
        ElsterTok: Label 'ElsterTelemetryCategoryTok', Locked = true;
        CreateXMLFileMsg: Label 'Creating XML file', Locked = true;
        CreateXMLFileSuccessMsg: Label 'XML file created successfully', Locked = true;
        Window: Dialog;
        SubsequentAction: Option "Only create","Create and export";
        TaxAmount: array[100] of Decimal;
        TaxBase: array[100] of Decimal;
        XmlNameSpace: Text[250];
        DatenLieferantTransferHeader: Text[256];
        DatenLieferantNutzdatenHeader: Text[256];
        Version: Text[250];
        DateText: Text[30];
        ElsterVATNo: Text[30];
        ContactForTaxOffice: Text[30];
        ManufacturerID: Code[10];
        UseAuthentication: Boolean;
        AdditionalInformation: Text[250];

    local procedure CreateXmlSubDoc()
    var
        XmlSubDoc: XmlDocument;
        XmlRootElem: XmlElement;
        t: Text;
    begin
        PrepareXmlDoc();

        if not XmlDocument.ReadFrom('<?xml version="1.0" encoding="UTF-8"?>' + '<Elster xmlns="' + XmlNameSpace + '"></Elster>', XmlSubDoc) then
            LogInternalError(XMLDocHasNotBeenCreatedErr, DataClassification::SystemMetadata, Verbosity::Error);
        XmlSubDoc.GetRoot(XmlRootElem);
        AddTransferHeader(XmlRootElem);
        AddUseDataHeader(XmlRootElem);
        AddUseData(XmlRootElem);
        XmlSubDoc.WriteTo(t);

        UpdateSalesVATAdvNotif(XmlSubDoc);
        Clear(XmlSubDoc);
    end;

    local procedure AddAddressText(Type: Integer; TextToAdd: Text[80])
    begin
        case Type of
            1:
                begin                     // TransferHeader
                    if StrLen(DatenLieferantTransferHeader) + StrLen(TextToAdd) >= 253 then
                        exit;
                    DatenLieferantTransferHeader :=
                      CopyStr(DatenLieferantTransferHeader + TextToAdd, 1, MaxStrLen(DatenLieferantTransferHeader));
                end;
            2:
                begin                     // NutzdatenHeader
                    if StrLen(DatenLieferantNutzdatenHeader) + StrLen(TextToAdd) >= 253 then
                        exit;
                    DatenLieferantNutzdatenHeader :=
                      CopyStr(DatenLieferantNutzdatenHeader + TextToAdd, 1, MaxStrLen(DatenLieferantNutzdatenHeader));
                end;
        end;
    end;

    local procedure UpdateSalesVATAdvNotif(XmlSubDoc: XmlDocument)
    var
        XmlSubDocOutStream: OutStream;
    begin
        with "Sales VAT Advance Notif." do begin
            "XML Submission Document".CreateOutStream(XmlSubDocOutStream);
            XmlSubDoc.WriteTo(XmlSubDocOutStream);
            CalcFields("XML Submission Document");
            if "XML Submission Document".HasValue() then begin
                "XML-File Creation Date" := Today();
                "Statement Template Name" := VATStmtName."Statement Template Name";
                "Statement Name" := VATStmtName.Name;
                Modify();
            end;
        end;
    end;

    local procedure PrepareXmlDoc()
    var
        Country: Record "Country/Region";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        CompanyInfo.Get();
        CompanyInfo.TestField("VAT Representative");
        if CompanyInfo."Country/Region Code" <> '' then
            Country.Get(CompanyInfo."Country/Region Code");

        UseAuthentication := "Sales VAT Advance Notif."."Use Authentication";
        ContactForTaxOffice := "Sales VAT Advance Notif."."Contact for Tax Office";
        AdditionalInformation := "Sales VAT Advance Notif."."Additional Information";

        CheckAddressData(5, CompanyInfo."VAT Representative", 45);
        CheckAddressData(6, ContactForTaxOffice, 30);
        if CompanyInfo.Address <> '' then
            CheckAddressData(1, CompanyInfo.Address, 30)
        else
            CheckAddressData(2, CompanyInfo."Address 2", 30);
        CheckAddressData(3, CompanyInfo."Post Code", 12);
        CheckAddressData(4, CompanyInfo.City, 30);
        CheckAddressData(7, AdditionalInformation, 250);

        if UseAuthentication then
            AddAddressText(1, 'ElsterOnline-Portal: ' + CompanyInfo."VAT Representative" + '; ')
        else
            AddAddressText(1, CompanyInfo."VAT Representative" + '; ');
        AddAddressText(1, CopyStr(CompanyInfo.Address + '; ', 1, 80));
        AddAddressText(1, '; ');
        AddAddressText(1, '; ');
        AddAddressText(1, CompanyInfo."Address 2" + '; ');
        AddAddressText(1, CompanyInfo."Post Code" + '; ');
        AddAddressText(1, CompanyInfo.City + '; ');
        AddAddressText(1, Country.Name + '; ');
        AddAddressText(1, CompanyInfo."Phone No." + '; ');
        AddAddressText(1, CompanyInfo."E-Mail");

        AddAddressText(2, ContactForTaxOffice + '; ');
        AddAddressText(2, CopyStr(CompanyInfo.Address + '; ', 1, 80));
        AddAddressText(2, '; ');
        AddAddressText(2, '; ');
        AddAddressText(2, CompanyInfo."Address 2" + '; ');
        AddAddressText(2, CompanyInfo."Post Code" + '; ');
        AddAddressText(2, CompanyInfo.City + '; ');
        AddAddressText(2, Country.Name + '; ');
        AddAddressText(2, "Sales VAT Advance Notif."."Contact Phone No." + '; ');
        AddAddressText(2, "Sales VAT Advance Notif."."Contact E-Mail");

        XmlNameSpace := 'http://www.elster.de/elsterxml/schema/v11';

        Version :=
          CopyStr(
            'Navision ' + ApplicationSystemConstants.ApplicationVersion() + ' Build # ' + ApplicationSystemConstants.ApplicationBuild(), 1, MaxStrLen(Version));

        if "Sales VAT Advance Notif.".Period = "Sales VAT Advance Notif.".Period::Month then
            DateText := CopyStr(Format("Sales VAT Advance Notif."."Starting Date", 0, '<month,2>'), 1, MaxStrLen(DateText))
        else
            DateText := CopyStr('4' + Format(((Date2DMY("Sales VAT Advance Notif."."Starting Date", 2) + 2) / 3)), 1, MaxStrLen(DateText));

        if StrLen(CompanyInfo."Tax Office Number") <> 4 then
            Error(ErrorMustConsistErr, CompanyInfo.FieldCaption("Tax Office Number"));
        ElsterVATNo := CopyStr(DelChr(CompanyInfo."Registration No."), 1, MaxStrLen(ElsterVATNo));
        ElsterVATNo := CopyStr(DelChr(ElsterVATNo, '=', '/'), 1, MaxStrLen(ElsterVATNo));
        ElsterVATNo := CompanyInfo."Tax Office Number" + '0' + CopyStr(ElsterVATNo, StrLen(ElsterVATNo) - 7);
        ManufacturerID := '20784';
    end;

    local procedure AddTransferHeader(var XmlRootElem: XmlElement)
    var
        XmlElemNew: XmlElement;
    begin
        if not AddElement(XmlRootElem, XmlElemNew, 'TransferHeader', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not XmlRootElem.Add(XmlAttribute.Create('version', '11')) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Verfahren', 'ElsterAnmeldung', XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'DatenArt', 'UStVA', XmlNameSpace) then
            exit;
        if UseAuthentication then begin
            if not AddElement(XmlRootElem, XmlElemNew, 'Vorgang', 'send-Auth', XmlNameSpace) then
                exit;
        end else
            if not AddElement(XmlRootElem, XmlElemNew, 'Vorgang', 'send-NoSig', XmlNameSpace) then
                exit;
        if "Sales VAT Advance Notif.".Testversion then begin
            if not AddElement(XmlRootElem, XmlElemNew, 'Testmerker', '700000004', XmlNameSpace) then
                exit;
        end else
            if not AddElement(XmlRootElem, XmlElemNew, 'Testmerker', '000000000', XmlNameSpace) then
                exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'HerstellerID', ManufacturerID, XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'DatenLieferant', DatenLieferantTransferHeader, XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Datei', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Verschluesselung', 'CMSEncryptedData', XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Kompression', 'GZIP', XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'TransportSchluessel', '', XmlNameSpace) then
            exit;

        XmlRootElem.GetParent(XmlRootElem);

        if StrLen(Version) > 42 then
            Version := CopyStr(Version, 1, 42);
        if not AddElement(XmlRootElem, XmlElemNew, 'VersionClient', Version, XmlNameSpace) then
            exit;

        if "Sales VAT Advance Notif."."Additional Information" <> '' then begin
            if not AddElement(XmlRootElem, XmlElemNew, 'Zusatz', '', XmlNameSpace) then
                exit;
            if AddElement(XmlRootElem, XmlElemNew, 'Info', AdditionalInformation, XmlNameSpace) then
                exit;
        END;
        XmlRootElem.GetParent(XmlRootElem);
    end;

    local procedure AddUseDataHeader(var XmlRootElem: XmlElement)
    var
        XmlElemNew: XmlElement;
    begin
        if not AddElement(XmlRootElem, XmlElemNew, 'DatenTeil', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Nutzdatenblock', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'NutzdatenHeader', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not XmlRootElem.Add(XmlAttribute.Create('version', '11')) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'NutzdatenTicket', "Sales VAT Advance Notif."."No.", XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Empfaenger', CompanyInfo."Tax Office Number", XmlNameSpace) then
            exit;
        if not XmlElemNew.Add(XmlAttribute.Create('id', 'F')) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Hersteller', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'ProduktName', 'Microsoft Business Solutions-Navision', XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'ProduktVersion', GetProductVersion(), XmlNameSpace) then
            exit;
        XmlRootElem.GetParent(XmlRootElem);
        if not AddElement(XmlRootElem, XmlElemNew, 'DatenLieferant', DatenLieferantNutzdatenHeader, XmlNameSpace) then
            exit;
        if "Sales VAT Advance Notif."."Additional Information" <> '' then begin
            if not AddElement(XmlRootElem, XmlElemNew, 'Zusatz', '', XmlNameSpace) then
                exit;
            if not AddElement(XmlRootElem, XmlElemNew, 'Info', AdditionalInformation, XmlNameSpace) then
                exit;
        END;
        XmlRootElem.GetParent(XmlRootElem);
    end;

    local procedure AddUseData(var XmlRootElem: XmlElement)
    var
        XmlElemNew: XmlElement;
        i: Integer;
        AmtToUse: Decimal;
        TaxAmtText: Text[30];
        NotificationVersion: Text[2];
    begin
        if not AddElement(XmlRootElem, XmlElemNew, 'Nutzdaten', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Anmeldungssteuern', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not XmlRootElem.Add(XmlAttribute.Create('art', 'UStVA')) then
            exit;
        if ("Sales VAT Advance Notif."."Starting Date" >= DMY2Date(1, 7, 2011)) and
           ("Sales VAT Advance Notif."."Starting Date" <= DMY2Date(31, 12, 2011))
        then
            NotificationVersion := '02'
        else
            NotificationVersion := '01';
        if not XmlRootElem.Add(XmlAttribute.Create('version', Format(Date2DMY("Sales VAT Advance Notif."."Starting Date", 3)) + NotificationVersion)) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'DatenLieferant', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Name', ContactForTaxOffice, XmlNameSpace) then
            exit;
        if CompanyInfo.Address <> '' then begin
            if not AddElement(XmlRootElem, XmlElemNew, 'Strasse', CompanyInfo.Address, XmlNameSpace) then
                exit;
        end else
            if not AddElement(XmlRootElem, XmlElemNew, 'Strasse', CompanyInfo."Address 2", XmlNameSpace) then
                exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'PLZ', CompanyInfo."Post Code", XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Ort', CompanyInfo.City, XmlNameSpace) then
            exit;
        XmlRootElem.GetParent(XmlRootElem);
        if not AddElement(XmlRootElem, XmlElemNew, 'Erstellungsdatum', Format(Today(), 0, '<year4><month,2><day,2>'), XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Steuerfall', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Umsatzsteuervoranmeldung', '', XmlNameSpace) then
            exit;
        XmlRootElem := XmlElemNew;
        if not AddElement(XmlRootElem, XmlElemNew, 'Jahr', Format(Date2DMY("Sales VAT Advance Notif."."Starting Date", 3)), XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Zeitraum', DateText, XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Steuernummer', ElsterVATNo, XmlNameSpace) then
            exit;
        if not AddElement(XmlRootElem, XmlElemNew, 'Kz09', ManufacturerID, XmlNameSpace) then
            exit;
        if "Sales VAT Advance Notif."."Corrected Notification" then
            if not AddElement(XmlRootElem, XmlElemNew, 'Kz10', '1', XmlNameSpace) then
                exit;
        if "Sales VAT Advance Notif."."Documents Submitted Separately" then
            if not AddElement(XmlRootElem, XmlElemNew, 'Kz22', '1', XmlNameSpace) then
                exit;
        if "Sales VAT Advance Notif."."Cancel Order for Direct Debit" then
            if not AddElement(XmlRootElem, XmlElemNew, 'Kz26', '1', XmlNameSpace) then
                exit;
        if "Sales VAT Advance Notif."."Offset Amount of Refund" then
            if not AddElement(XmlRootElem, XmlElemNew, 'Kz29', '1', XmlNameSpace) then
                exit;
        if TaxAmount[39] < 0 then
            Error(ErrorKeyFigureErr, Format(39));
        for i := 21 to 100 do begin
            TaxAmtText := '';
            case i of
                21, 35, 41, 42, 43, 44, 45, 46, 48, 49, 51, 52, 54, 55, 57, 60, 68, 73, 76, 77, 78, 81, 84, 86, 89, 91, 93, 94, 95, 97:
                    AmtToUse := TaxBase[i];
                else
                    AmtToUse := TaxAmount[i];
            end;
            if (AmtToUse <> 0) or
               (i = 83)
            then begin
                case i of
                    21, 35, 41, 42, 43, 44, 45, 46, 48, 49, 51, 52, 57, 60, 68, 73, 76, 77, 78, 81, 84, 86, 89, 91, 93, 94, 95, 97:
                        TaxAmtText := Format(AmtToUse, 0, '<Sign><Integer>');
                    36, 39, 47, 53, 54, 55, 58, 59, 61, 62, 63, 64, 65, 66, 67, 69, 74, 79, 80, 83, 85, 96, 98:
                        TaxAmtText := Format(AmtToUse, 0, '<precision,2:2><Sign><Integer><Decimals><comma,.>');
                end;
                if TaxAmtText <> '' then
                    if not AddElement(XmlRootElem, XmlElemNew, 'Kz' + Format(i), TaxAmtText, XmlNameSpace) then
                        exit;
            end;
        end;
    end;

    local procedure CheckAddressData(FieldID: Integer; TextToCheck: Text[250]; MaxLength: Integer)
    var
        TruncatedText: Text;
    begin
        case FieldID of
            1:
                begin
                    CompanyInfo.Address := CopyStr(ConvertSpecialChars(CompanyInfo.Address, MaxStrLen(CompanyInfo.Address)), 1, MaxStrLen(CompanyInfo.Address));
                    TextToCheck := CompanyInfo.Address;
                end;
            2:
                begin
                    CompanyInfo."Address 2" := CopyStr(ConvertSpecialChars(CompanyInfo."Address 2", MaxStrLen(CompanyInfo."Address 2")), 1, MaxStrLen(CompanyInfo."Address 2"));
                    TextToCheck := CompanyInfo."Address 2";
                end;
            4:
                begin
                    CompanyInfo.City := CopyStr(ConvertSpecialChars(CompanyInfo.City, MaxStrLen(CompanyInfo.City)), 1, MaxStrLen(CompanyInfo.City));
                    TextToCheck := CompanyInfo.City;
                end;
            6:
                begin
                    ContactForTaxOffice := CopyStr(ConvertSpecialChars(ContactForTaxOffice, MaxStrLen(ContactForTaxOffice)), 1, MaxStrLen(ContactForTaxOffice));
                    CLEAR(TextToCheck);
                end;
            7:
                begin
                    AdditionalInformation := ConvertSpecialChars(AdditionalInformation, MaxStrLen(AdditionalInformation));
                    TextToCheck := AdditionalInformation;
                end;
        end;
        Clear(TruncatedText);
        if StrLen(TextToCheck) > MaxLength then
            case FieldID of
                1:
                    begin
                        TruncatedText := TruncateText(CompanyInfo.Address, CompanyInfo.FieldCaption(Address), CompanyInfo.TableCaption(), MaxLength);
                        CompanyInfo.Address := CopyStr(TruncatedText, 1, MaxStrLen(CompanyInfo.Address));
                    end;
                2:
                    begin
                        TruncatedText := TruncateText(CompanyInfo."Address 2", CompanyInfo.FieldCaption("Address 2"), CompanyInfo.TableCaption(), MaxLength);
                        CompanyInfo."Address 2" := TruncatedText.Substring(1, MaxStrLen(CompanyInfo."Address 2"));
                    end;
                3:
                    begin
                        TruncatedText := TruncateText(CompanyInfo."Post Code", CompanyInfo.FieldCaption("Post Code"), CompanyInfo.TableCaption(), MaxLength);
                        CompanyInfo."Post Code" := CopyStr(TruncatedText, 1, MaxStrLen(CompanyInfo."Post Code"));
                    end;
                4:
                    begin
                        TruncatedText := TruncateText(CompanyInfo.City, CompanyInfo.FieldCaption(City), CompanyInfo.TableCaption(), MaxLength);
                        CompanyInfo.City := TruncatedText.Substring(1, MaxStrLen(CompanyInfo.City));
                    end;
            end;
    end;

    local procedure TruncateText(FieldValue: Text; FieldCaption: Text; TableCaption: Text; MaxLength: Integer) TruncatedText: Text
    begin
        TruncatedText := PadStr(FieldValue, MaxLength);
        if not Confirm(TruncateRequestMsg, true, FieldCaption, TableCaption, MaxLength, FieldValue, TruncatedText) then
            Error('');
    end;

    local procedure CheckTaxPairs()
    var
        TaxError: Boolean;
        TaxPair: array[9, 2] of Integer;
        loop: Integer;
    begin
        CLEAR(TaxError);
        CLEAR(TaxPair);

        TaxPair[1] [1] := 35;
        TaxPair[1] [2] := 36;
        TaxPair[2] [1] := 76;
        TaxPair[2] [2] := 80;
        TaxPair[3] [1] := 95;
        TaxPair[3] [2] := 98;
        TaxPair[4] [1] := 94;
        TaxPair[4] [2] := 96;
        TaxPair[5] [1] := 52;
        TaxPair[5] [2] := 53;
        TaxPair[6] [1] := 73;
        TaxPair[6] [2] := 74;
        TaxPair[7] [1] := 84;
        TaxPair[7] [2] := 85;
        TaxPair[8] [1] := 46;
        TaxPair[8] [2] := 47;
        TaxPair[9] [1] := 78;
        TaxPair[9] [2] := 79;

        loop := 1;
        while (not TaxError) and (loop <= ArrayLen(TaxPair, 1)) do begin
            if not TaxError then
                if TaxBase[TaxPair[loop] [1]] <> 0 then
                    TaxError := TaxAmount[TaxPair[loop] [2]] = 0;
            loop += 1;
        end;
        if TaxError then
            Error(ErrorCategoryErr, TaxPair[loop - 1] [1], TaxPair[loop - 1] [2], VATStmtName.TableCaption(), VATStmtName.Name);
    end;

    local procedure ConvertSpecialChars(Text: Text[250]; MaxLen: Integer): Text[250]
    var
        SpecialCharPos: Integer;
        loop: Integer;
        SpecialChars: Text[20];
        ConvertedChars: Text[20];
    begin
        SpecialChars := 'ÄäÖöÜüß'; // Fixing wrong encoding
        ConvertedChars := 'AeaeOeoeUeuess';
        for loop := 1 to 7 do
            while StrPos(Text, CopyStr(SpecialChars, loop, 1)) <> 0 do begin
                SpecialCharPos := StrPos(Text, CopyStr(SpecialChars, loop, 1));
                if StrLen(Text) = MaxLen then
                    Text := CopyStr(PadStr(Text, MaxLen - 1), 1, MaxStrLen(Text));
                Text := CopyStr(DelStr(Text, SpecialCharPos, 1), 1, MaxStrLen(Text));
                Text := CopyStr(InsStr(Text, CopyStr(ConvertedChars, loop * 2 - 1, 2), SpecialCharPos), 1, MaxStrLen(Text));
            end;

        exit(Text);
    end;

    local procedure GetProductVersion(): Text[50]
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
        ProductVersion: Text;
        Result: Text[50];
    begin
        ProductVersion := ApplicationSystemConstants.ApplicationVersion();
        OnGetProductVersion(ProductVersion);
        Result := CopyStr(ProductVersion, 1, MaxStrLen(Result));

        exit(Result);
    end;

    local procedure AddElement(var XmlNodeCurr: XmlElement; var XmlNodeNew: XmlElement; Name: Text; NodeText: Text; NameSpace: Text): Boolean
    begin
        XmlNodeNew := XmlElement.Create(Name, NameSpace, NodeText);
        exit(XmlNodeCurr.Add(XmlNodeNew));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetProductVersion(var ProductVersion: Text)
    begin
    end;
}

