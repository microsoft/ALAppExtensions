codeunit 4810 IntrastatReportManagement
{
    Permissions = TableData "Intrastat Report Header" = imd,
                  TableData "Intrastat Report Line" = imd,
                  TableData "NAV App Installed App" = r;

    var
        AdvChecklistErr: Label 'There are one or more errors. For details, see the report error FactBox.';
        UpdateSelectionQst: Label '&Weight,&Supplemental UOM Qty,&Both';
        ExportSelectionQst: Label '&Receipts,&Shipments,&Both';
        NoDataExchMappingErr: Label '%1 for %2 %3 does not exist.', Comment = '%1 - Data Exchange Mapping caption, %2 - Data Exchange Definition caption, %3 - Data Exchange Definition code';
        PeriodAlreadyReportedQst: Label 'You''ve already submitted the report for this period.\Do you want to continue?';
        ExternalContentErr: Label '%1 is empty.', Comment = '%1 - File Content';
        DownloadFromStreamErr: Label 'The file has not been saved.';
        FileNameLbl: Label 'Intrastat-%1.txt', Comment = '%1 - Statistics Period';
        ReceptFileNameLbl: Label 'Receipt-%1.txt', Comment = '%1 - Statistics Period';
        ShipmentFileNameLbl: Label 'Shipment-%1.txt', Comment = '%1 - Statistics Period';
        ZipFileNameLbl: Label 'Intrastat-%1.zip', Comment = '%1 - Statistics Period';
        FeatureNotEnabledMessageTxt: Label 'The %1 page is part of the new Intrastat Report feature, which is not yet enabled in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';
        NewFeatureEnabledMessageTxt: Label 'The Intrastat Report extension is enabled, which means you can''t use the %1 page. You''ve been redirected to the %2 page for the extension.', Comment = '%1 - old page caption, %2 - new page caption';
        DisableNotificationTxt: Label 'Disable this notification';
        LearnMoreTxt: Label 'Learn more';
        IntrastatAwarenessNotificationNameTxt: Label 'Notify the user about the Intrastat Report extension.';
        IntrastatAwarenessNotificationDescriptionTxt: Label 'Alert users about the capabilities of the Intrastat Report extension.';
        IntrastatAwarenessNotificationTxt: Label 'This version of Intrastat will be deprecated. We recommend that you enable the Intrastat Report extension.';
        SupplementaryUnitUpdateNotificationNameTxt: Label 'Notify the user about the %1 update.', Comment = '%1 - Supplementary Unit of Measure caption';
        SupplementaryUnitUpdateNotificationDescriptionTxt: Label 'Alert users about the update of %1 during %2 change.', Comment = '%1 - Supplementary Unit of Measure caption, %2 - Tariff Number caption';
        SupplementaryUnitUpdateNotificationTxt: Label '%1 was updated, due to change of %2.', Comment = '%1 - Supplementary Unit of Measure caption, %2 - Tariff Number caption';
        ImportDefaultIntrastatDataExchDefConfirmQst: Label 'This will create the default Intrastat %1 . \\All existing default Intrastat %1 will be overwritten.\\Do you want to continue?', Comment = '%1 - Data Exchange Definition caption';
        AssistedSetupTxt: Label 'Set up Intrastat reporting';
        AssistedSetupDescriptionTxt: Label 'The Intrastat reporting makes it easy to export the Intrastat report in the format that the authorities in your country require.';
        UserDisabledNotificationTxt: Label 'The user disabled notification %1.', Locked = true;
        IntrastatFeatureKeyIdTok: Label 'ReplaceIntrastat', Locked = true;
        IntrastatFeatureAwarenessNotificationIdTok: Label 'dcd4e71a-8c6a-44fc-9642-54f931e5e7d9', Locked = true;
        SupplementaryUnitUpdateNotificationIdTok: Label '52f2c034-1857-4922-99cb-448c09e01474', Locked = true;
        IntrastatCoreAppIdTok: Label '70912191-3c4c-49fc-a1de-bc6ea1ac9da6', Locked = true;
        IntrastatTelemetryCategoryTok: Label 'AL Intrastat', Locked = true;
        LearnMoreLinkTok: Label 'https://go.microsoft.com/fwlink/?linkid=2283605', Locked = true;
        RangeCrossingErr: Label 'There is a conflict in checklist rules for ''%1'' in ''%2'' (field must be both blank and not blank). Please review filters in %3.', Comment = '%1=caption of a field, %2=key of record, %3=caption of report checklist page';
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="4813" ColumnSeparator="1" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="9"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="2" Name="Country/Region Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="3" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="4" Name="Quantity" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="5" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="6" Name="Statistical Value" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="7" Name="Internal Ref. No." Show="false" DataType="0" Length="30" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="8" Name="Partner Tax ID" Show="false" DataType="0" Length="20" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="5" FieldID="21" Optional="true" TransformationRule="ROUNDUPTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDUPTOINT</Code><Description>Round up to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>&gt;</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="6" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="24" Optional="true" TransformationRule="EUCOUNTRYCODELOOKUP"><TransformationRules><Code>EUCOUNTRYCODELOOKUP</Code><Description>EU Country Lookup</Description><TransformationType>13</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available        

    procedure GetIntrastatBaseCountryCode(ItemLedgEntry: Record "Item Ledger Entry") CountryCode: Code[10]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SalesShptHeader: Record "Sales Shipment Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShptHeader: Record "Return Shipment Header";
        IsHandled: Boolean;
    begin
        IntrastatReportSetup.Get();

        IsHandled := false;
        OnBeforeGetIntrastatBaseCountryCode(ItemLedgEntry, IntrastatReportSetup, CountryCode, IsHandled);
        if IsHandled then
            exit(CountryCode);

        CountryCode := ItemLedgEntry."Country/Region Code";

        case ItemLedgEntry."Document Type" of
            ItemLedgEntry."Document Type"::"Sales Shipment":
                if SalesShptHeader.Get(ItemLedgEntry."Document No.") then
                    case IntrastatReportSetup."Shipments Based On" of
                        IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                            CountryCode := SalesShptHeader."Ship-to Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                            CountryCode := SalesShptHeader."Sell-to Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                            CountryCode := SalesShptHeader."Bill-to Country/Region Code";
                    end;
            ItemLedgEntry."Document Type"::"Sales Return Receipt":
                if ReturnRcptHeader.Get(ItemLedgEntry."Document No.") then
                    case IntrastatReportSetup."Shipments Based On" of
                        IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                            if ReturnRcptHeader."Rcvd.-from Count./Region Code" <> '' then
                                CountryCode := ReturnRcptHeader."Rcvd.-from Count./Region Code"
                            else
                                CountryCode := ReturnRcptHeader."Ship-to Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                            CountryCode := ReturnRcptHeader."Sell-to Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                            CountryCode := ReturnRcptHeader."Bill-to Country/Region Code";
                    end;
            ItemLedgEntry."Document Type"::"Purchase Receipt":
                if PurchRcptHeader.Get(ItemLedgEntry."Document No.") then
                    case IntrastatReportSetup."Shipments Based On" of
                        IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                            CountryCode := PurchRcptHeader."Buy-from Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                            CountryCode := PurchRcptHeader."Buy-from Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                            CountryCode := PurchRcptHeader."Pay-to Country/Region Code";
                    end;
            ItemLedgEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShptHeader.Get(ItemLedgEntry."Document No.") then
                    case IntrastatReportSetup."Shipments Based On" of
                        IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                            CountryCode := ReturnShptHeader."Buy-from Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                            CountryCode := ReturnShptHeader."Buy-from Country/Region Code";
                        IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                            CountryCode := ReturnShptHeader."Pay-to Country/Region Code";
                    end;
            else
                OnGetIntrastatBaseCountryCodeFromItemLedgerElseCase(ItemLedgEntry, IntrastatReportSetup, CountryCode);
        end;
    end;

    procedure GetIntrastatBaseCountryCode(JobLedgerEntry: Record "Job Ledger Entry") CountryCode: Code[10]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Job: Record Job;
        IsHandled: Boolean;
    begin
        IntrastatReportSetup.Get();

        IsHandled := false;
        OnBeforeGetIntrastatBaseCountryCodeFromJLE(JobLedgerEntry, IntrastatReportSetup, CountryCode, IsHandled);
        if IsHandled then
            exit(CountryCode);

        CountryCode := JobLedgerEntry."Country/Region Code";

        if Job.Get(JobLedgerEntry."Job No.") then
            case IntrastatReportSetup."Shipments Based On" of
                IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                    CountryCode := Job."Ship-to Country/Region Code";
                IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                    CountryCode := Job."Sell-to Country/Region Code";
                IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                    CountryCode := Job."Bill-to Country/Region Code";
            end;
    end;

    procedure GetIntrastatBaseCountryCode(FALedgerEntry: Record "FA Ledger Entry") CountryCode: Code[10]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IsHandled: Boolean;
    begin
        IntrastatReportSetup.Get();

        IsHandled := false;
        OnBeforeGetIntrastatBaseCountryCodeFromFALE(FALedgerEntry, IntrastatReportSetup, CountryCode, IsHandled);
        if IsHandled then
            exit(CountryCode);

        CountryCode := '';

        if FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Acquisition Cost" then
            case FALedgerEntry."Document Type" of
                FALedgerEntry."Document Type"::Invoice:
                    if PurchInvHeader.Get(FALedgerEntry."Document No.") then
                        case IntrastatReportSetup."Shipments Based On" of
                            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                                CountryCode := PurchInvHeader."Buy-from Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                                CountryCode := PurchInvHeader."Buy-from Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                                CountryCode := PurchInvHeader."Pay-to Country/Region Code";
                        end;
                FALedgerEntry."Document Type"::"Credit Memo":
                    if PurchCrMemoHdr.Get(FALedgerEntry."Document No.") then
                        case IntrastatReportSetup."Shipments Based On" of
                            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                                CountryCode := PurchCrMemoHdr."Buy-from Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                                CountryCode := PurchCrMemoHdr."Buy-from Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                                CountryCode := PurchCrMemoHdr."Pay-to Country/Region Code";
                        end;
            end;

        if FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Proceeds on Disposal" then
            case FALedgerEntry."Document Type" of
                FALedgerEntry."Document Type"::Invoice:
                    if SalesInvHeader.Get(FALedgerEntry."Document No.") then
                        case IntrastatReportSetup."Shipments Based On" of
                            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                                CountryCode := SalesInvHeader."Ship-to Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                                CountryCode := SalesInvHeader."Sell-to Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                                CountryCode := SalesInvHeader."Bill-to Country/Region Code";
                        end;
                FALedgerEntry."Document Type"::"Credit Memo":
                    if SalesCrMemoHeader.Get(FALedgerEntry."Document No.") then
                        case IntrastatReportSetup."Shipments Based On" of
                            IntrastatReportSetup."Shipments Based On"::"Ship-to Country":
                                CountryCode := SalesCrMemoHeader."Sell-to Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Sell-to Country":
                                CountryCode := SalesCrMemoHeader."Sell-to Country/Region Code";
                            IntrastatReportSetup."Shipments Based On"::"Bill-to Country":
                                CountryCode := SalesCrMemoHeader."Bill-to Country/Region Code";
                        end;
            end;
        OnAfterGetIntrastatBaseCountryCodeFromFAEntry(FALedgerEntry, IntrastatReportSetup, CountryCode);
    end;

    procedure GetOriginalCurrency(FALedgerEntry: Record "FA Ledger Entry") CurrencyCode: Code[10]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        case FALedgerEntry."Document Type" of
            FALedgerEntry."Document Type"::Invoice:
                if PurchInvHeader.Get(FALedgerEntry."Document No.") then
                    CurrencyCode := PurchInvHeader."Currency Code";
            FALedgerEntry."Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get(FALedgerEntry."Document No.") then
                    CurrencyCode := PurchCrMemoHdr."Currency Code";
            else
                CurrencyCode := '';
        end;
    end;

    procedure GetOriginalCurrency(ItemLedgerEntry: Record "Item Ledger Entry") CurrencyCode: Code[10]
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        case ItemLedgerEntry."Document Type" of
            ItemLedgerEntry."Document Type"::"Sales Invoice":
                if SalesInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := SalesInvoiceHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Sales Credit Memo":
                if SalesCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := SalesCrMemoHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Sales Shipment":
                if SalesShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := SalesShipmentHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Sales Return Receipt":
                if ReturnReceiptHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := ReturnReceiptHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Purchase Credit Memo":
                if PurchCrMemoHdr.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := PurchCrMemoHdr."Currency Code";
            ItemLedgerEntry."Document Type"::"Purchase Return Shipment":
                if ReturnShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := ReturnShipmentHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Purchase Invoice":
                if PurchInvHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := PurchInvHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Purchase Receipt":
                if PurchRcptHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := PurchRcptHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Service Shipment":
                if ServiceShipmentHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := ServiceShipmentHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Service Invoice":
                if ServiceInvoiceHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := ServiceInvoiceHeader."Currency Code";
            ItemLedgerEntry."Document Type"::"Service Credit Memo":
                if ServiceCrMemoHeader.Get(ItemLedgerEntry."Document No.") then
                    CurrencyCode := ServiceCrMemoHeader."Currency Code";
            else
                OnGetOriginalCurrencyFromItemLedgerElseCase(ItemLedgerEntry, CurrencyCode);
        end;
    end;

    procedure CalcStatisticalValue(var IntrastatReportLine: Record "Intrastat Report Line"; LastIntrastatReportLine: Record "Intrastat Report Line"; var StatisticalValue: Decimal; var TotalStatisticalValue: Decimal; var ShowStatisticalValue: Boolean; var ShowTotalStatisticalValue: Boolean)
    var
        IntrastatReportLine2: Record "Intrastat Report Line";
        IntrastatReportLine3: Record "Intrastat Report Line";
    begin
        IntrastatReportLine2.CopyFilters(IntrastatReportLine);

        if IntrastatReportLine2.CalcSums("Statistical Value") then begin
            if IntrastatReportLine."Line No." <> 0 then // 0 = New record
                TotalStatisticalValue := IntrastatReportLine2."Statistical Value"
            else
                TotalStatisticalValue := IntrastatReportLine2."Statistical Value" + LastIntrastatReportLine."Statistical Value";

            ShowTotalStatisticalValue := true;
        end else
            ShowTotalStatisticalValue := false;

        if IntrastatReportLine."Line No." <> 0 then begin // 0 = New record
            IntrastatReportLine2.SetFilter("Line No.", '<=%1', IntrastatReportLine."Line No.");
            if IntrastatReportLine2.CalcSums("Statistical Value") then begin
                StatisticalValue := IntrastatReportLine2."Statistical Value";
                ShowStatisticalValue := true;
            end else
                ShowStatisticalValue := false;
        end else begin
            IntrastatReportLine2.SetFilter("Line No.", '<=%1', LastIntrastatReportLine."Line No.");
            if IntrastatReportLine2.CalcSums("Statistical Value") then begin
                IntrastatReportLine3.CopyFilters(IntrastatReportLine);
                IntrastatReportLine3 := LastIntrastatReportLine;
                if IntrastatReportLine3.Next() <> 0 then
                    StatisticalValue := IntrastatReportLine2."Statistical Value"
                else
                    StatisticalValue := IntrastatReportLine2."Statistical Value" + LastIntrastatReportLine."Statistical Value";

                ShowStatisticalValue := true;
            end else
                ShowStatisticalValue := false;
        end;
    end;

    procedure ValidateReportWithAdvancedChecklist(IntrastatReportHeader: Record "Intrastat Report Header"; ThrowError: Boolean): Boolean
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        ChecklistClearBatchErrors(IntrastatReportHeader);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        OnBeforeValidateReportWithAdvancedChecklist(IntrastatReportLine, IntrastatReportHeader);
        if IntrastatReportLine.FindSet() then
            repeat
                ValidateReportLineWithAdvancedChecklist(IntrastatReportLine, ThrowError);
            until IntrastatReportLine.Next() = 0;
    end;

    procedure ValidateReportLineWithAdvancedChecklist(IntrastatReportLine: Record "Intrastat Report Line"; ThrowError: Boolean): Boolean
    begin
        exit(ValidateObjectWithAdvancedChecklist(IntrastatReportLine, ThrowError));
    end;

    local procedure ValidateObjectWithAdvancedChecklist(IntrastatReportLine: Record "Intrastat Report Line"; ThrowError: Boolean): Boolean
    var
        ErrorMessage: Record "Error Message";
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportChecklistPage: Page "Intrastat Report Checklist";
        AnyError, LinePassesNonBlank, LinePassesBlank : Boolean;
    begin
        ChecklistSetBatchContext(ErrorMessage, IntrastatReportLine);
        if IntrastatReportChecklist.FindSet() then
            repeat
                LinePassesNonBlank := IntrastatReportChecklist.LinePassesFilterExpression(IntrastatReportLine);
                LinePassesBlank := IntrastatReportChecklist.LinePassesFilterExpressionForMustBeBlank(IntrastatReportLine);

                if LinePassesBlank and LinePassesNonBlank then begin
                    IntrastatReportChecklist.CalcFields("Field Name");
                    AnyError :=
                      AnyError or
                      (ErrorMessage.LogMessage(
                         IntrastatReportLine, IntrastatReportChecklist."Field No.", ErrorMessage."Message Type"::Error, StrSubstNo(RangeCrossingErr, IntrastatReportChecklist."Field Name", Format(IntrastatReportLine.RecordId), IntrastatReportChecklistPage.Caption)) <> 0)
                end else begin
                    if LinePassesNonBlank then
                        AnyError :=
                          AnyError or
                          (ErrorMessage.LogIfEmpty(
                             IntrastatReportLine, IntrastatReportChecklist."Field No.", ErrorMessage."Message Type"::Error) <> 0);

                    if LinePassesBlank then
                        AnyError :=
                          AnyError or
                          (ErrorMessage.LogIfNotEmpty(
                             IntrastatReportLine, IntrastatReportChecklist."Field No.", ErrorMessage."Message Type"::Error) <> 0);
                end;
            until IntrastatReportChecklist.Next() = 0;

        if AnyError and ThrowError then
            ThrowChecklistError();

        exit(not AnyError);
    end;

    procedure ChecklistClearBatchErrors(IntrastatReportHeader: Record "Intrastat Report Header")
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(IntrastatReportHeader);
        ErrorMessage.ClearLog();
    end;

    local procedure ChecklistSetBatchContext(var ErrorMessage: Record "Error Message"; IntrastatReportLine: Record "Intrastat Report Line")
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader."No." := IntrastatReportLine."Intrastat No.";
        ErrorMessage.SetContext(IntrastatReportHeader);
    end;

    local procedure ThrowChecklistError()
    begin
        Commit();
        Error(AdvChecklistErr);
    end;

    procedure GetCompanyVATRegNo(): Text[50]
    var
        CompanyInformation: Record "Company Information";
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        CompanyInformation.Get();
        if not IntrastatReportSetup.Get() then
            exit(CompanyInformation."VAT Registration No.");
        OnGetCompanyVATRegNoOnAfterGetIntrastatReportSetup(CompanyInformation, IntrastatReportSetup);
        exit(
          GetVATRegNo(
            CompanyInformation."Country/Region Code", CompanyInformation."VAT Registration No.",
            IntrastatReportSetup."Company VAT No. on File"));
    end;

    procedure GetVATRegNo(CountryCode: Code[10]; VATRegNo: Text[20]; VATRegNoType: Enum "Intrastat Report VAT File Fmt"): Text[50]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        CountryRegion: Record "Country/Region";
    begin
        case VATRegNoType of
            IntrastatReportSetup."Company VAT No. on File"::"VAT Reg. No.":
                exit(VATRegNo);
            IntrastatReportSetup."Company VAT No. on File"::"EU Country Code + VAT Reg. No":
                begin
                    CountryRegion.Get(CountryCode);
                    if CountryRegion."EU Country/Region Code" <> '' then
                        CountryCode := CountryRegion."EU Country/Region Code";
                    exit(CountryCode + VATRegNo);
                end;
            IntrastatReportSetup."Company VAT No. on File"::"VAT Reg. No. Without EU Country Code":
                begin
                    CountryRegion.Get(CountryCode);
                    if CountryRegion."EU Country/Region Code" <> '' then
                        CountryCode := CountryRegion."EU Country/Region Code";
                    if CopyStr(VATRegNo, 1, StrLen(DelChr(CountryCode, '<>'))) =
                       DelChr(CountryCode, '<>')
                    then
                        exit(CopyStr(VATRegNo, StrLen(DelChr(CountryCode, '<>')) + 1, 50));
                    exit(VATRegNo);
                end;
        end;
    end;

    procedure RecalculateWaightAndSupplUOMQty(IntrastatReportHeader: Record "Intrastat Report Header")
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemUOM: Record "Item Unit of Measure";
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        Selection: Integer;
        SupplUOMCode: Code[10];
        SupplConversionFactor: Decimal;
        NetWeight: Decimal;
    begin
        Selection := StrMenu(UpdateSelectionQst, 3);
        if Selection = 0 then
            exit;

        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        if IntrastatReportLine.FindSet() then
            repeat
                if (IntrastatReportLine."Source Type" = IntrastatReportLine."Source Type"::"FA Entry") then begin
                    if IntrastatReportLine."Item No." = '' then
                        Clear(FixedAsset)
                    else
                        FixedAsset.Get(IntrastatReportLine."Item No.");

                    SupplUOMCode := FixedAsset."Supplementary Unit of Measure";
                    SupplConversionFactor := 1;
                    NetWeight := FixedAsset."Net Weight";
                end else begin
                    if IntrastatReportLine."Item No." = '' then
                        Clear(Item)
                    else
                        Item.Get(IntrastatReportLine."Item No.");

                    SupplUOMCode := Item."Supplementary Unit of Measure";
                    if ItemUOM.Get(Item."No.", Item."Supplementary Unit of Measure") and
                        (ItemUOM."Qty. per Unit of Measure" <> 0)
                    then
                        SupplConversionFactor := 1 / ItemUOM."Qty. per Unit of Measure"
                    else
                        SupplConversionFactor := 0;
                    NetWeight := Item."Net Weight";
                end;

                if Selection <> 1 then begin
                    IntrastatReportLine."Suppl. Unit of Measure" := SupplUOMCode;
                    IntrastatReportLine."Suppl. Conversion Factor" := SupplConversionFactor;
                    IntrastatReportLine.Validate("Suppl. Conversion Factor");
                end;

                if Selection <> 2 then
                    IntrastatReportLine.Validate("Net Weight", NetWeight);

                IntrastatReportLine.Modify(true);
            until IntrastatReportLine.Next() = 0;
    end;

    procedure ReleaseIntrastatReport(var IntrastatReportHeader: Record "Intrastat Report Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReleaseIntrastatHeader(IntrastatReportHeader, IsHandled);
        if IsHandled then
            exit;

        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        OnAfterReleaseIntrastatHeader(IntrastatReportHeader);
    end;

    procedure ReopenIntrastatReport(var IntrastatReportHeader: Record "Intrastat Report Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopenIntrastatHeader(IntrastatReportHeader, IsHandled);
        if IsHandled then
            exit;

        if IntrastatReportHeader.Reported then
            if not Confirm(PeriodAlreadyReportedQst) then
                exit;

        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Open;
        IntrastatReportHeader.Modify();

        OnAfterReopenIntrastatHeader(IntrastatReportHeader);
    end;

    procedure ExportWithDataExch(IntrastatReportHeader: Record "Intrastat Report Header"; ExportType: Integer)
    var
        DataExch1: Record "Data Exch.";
        DataExch2: Record "Data Exch.";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        Selection: Integer;
        IsHandled: Boolean;
        FileName: Text;
        ReceptFileName: Text;
        ShipmentFileName: Text;
        ZipFileName: Text;
    begin
        IsHandled := false;
        OnBeforeExportIntrastatHeader(IntrastatReportHeader, IsHandled);
        if IsHandled then
            exit;

        if IntrastatReportHeader.Reported then
            if not Confirm(PeriodAlreadyReportedQst) then
                exit;

        OnBeforeDefineFileNames(IntrastatReportHeader, FileName, ReceptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if not IsHandled then begin
            FileName := StrSubstNo(FileNameLbl, IntrastatReportHeader."Statistics Period");
            ReceptFileName := StrSubstNo(ReceptFileNameLbl, IntrastatReportHeader."Statistics Period");
            ShipmentFileName := StrSubstNo(ShipmentFileNameLbl, IntrastatReportHeader."Statistics Period");
            ZipFileName := StrSubstNo(ZipFileNameLbl, IntrastatReportHeader."Statistics Period");
        end;

        IntrastatReportSetup.Get();
        OnExportWithDataExchOnAfterGetIntrastatReportSetup(IntrastatReportSetup, IntrastatReportHeader);
        if IntrastatReportSetup."Split Files" then begin
            IntrastatReportSetup.TestField("Data Exch. Def. Code - Receipt");
            IntrastatReportSetup.TestField("Data Exch. Def. Code - Shpt.");
            FileName := ReceptFileName;
            Selection := StrMenu(ExportSelectionQst, 3);
            if Selection = 0 then
                exit;

            if Selection <> 2 then begin
                ExportOneDataExchangeDef(IntrastatReportHeader, IntrastatReportSetup."Data Exch. Def. Code - Receipt", 1, DataExch1);
                DataExch1.CalcFields("File Content");
                IntrastatReportHeader.Validate("Arrivals Reported", true);
            end;
            if Selection <> 1 then begin
                ExportOneDataExchangeDef(IntrastatReportHeader, IntrastatReportSetup."Data Exch. Def. Code - Shpt.", 2, DataExch2);
                DataExch2.CalcFields("File Content");
                IntrastatReportHeader.Validate("Dispatches Reported", true);
            end;

            if not (DataExch1."File Content".HasValue() or DataExch2."File Content".HasValue()) then
                Error(ExternalContentErr, DataExch1.FieldCaption("File Content"));

        end else begin
            IntrastatReportSetup.TestField("Data Exch. Def. Code");
            ExportOneDataExchangeDef(IntrastatReportHeader, IntrastatReportSetup."Data Exch. Def. Code", 0, DataExch1);
            DataExch1.CalcFields("File Content");
            if not DataExch1."File Content".HasValue() then
                Error(ExternalContentErr, DataExch1.FieldCaption("File Content"));

            IntrastatReportHeader.Validate("Dispatches Reported", true);
            IntrastatReportHeader.Validate("Arrivals Reported", true);
        end;

        if (Selection = 3) or IntrastatReportSetup."Zip Files" then
            ExportToZip(DataExch1, DataExch2, IntrastatReportHeader."Statistics Period", FileName, ReceptFileName, ShipmentFileName, ZipFileName)
        else
            if DataExch1."File Content".HasValue then begin
                TempBlob.FromRecord(DataExch1, DataExch1.FieldNo("File Content"));
                ExportToFile(DataExch1, TempBlob, FileName);
            end else
                if DataExch2."File Content".HasValue then begin
                    TempBlob.FromRecord(DataExch2, DataExch2.FieldNo("File Content"));
                    ExportToFile(DataExch2, TempBlob, ShipmentFileName);
                end;

        IsHandled := false;
        OnAfterExportIntrastatHeader(IntrastatReportHeader, IsHandled);
        if IsHandled then
            exit;

        IntrastatReportHeader."Export Date" := Today;
        IntrastatReportHeader."Export Time" := Time;
        IntrastatReportHeader.Modify();
    end;

    procedure ExportOneDataExchangeDef(IntrastatReportHeader: Record "Intrastat Report Header"; DataExchDefCode: Code[20]; ExportType: Integer; var DataExch: Record "Data Exch.")
    var
        DataExchFieldGrouping: Record "Data Exch. Field Grouping";
        IntrastatReportLine: Record "Intrastat Report Line";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchDef: Record "Data Exch. Def";
        RecordRefSrc: RecordRef;
        OutStreamFilters: OutStream;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExportOneDataExchangeDef(IntrastatReportHeader, DataExchDefCode, ExportType, DataExch, IsHandled);
        if not IsHandled then begin
            DataExchMapping.SetRange("Data Exch. Def Code", DataExchDefCode);
            DataExchMapping.SetRange("Table ID", Database::"Intrastat Report Line");
            if not DataExchMapping.FindFirst() then
                Error(NoDataExchMappingErr, DataExchMapping.TableCaption, DataExchDef.TableCaption, DataExchDefCode);

            if DataExchMapping."Key Index" <> 0 then begin
                RecordRefSrc.GetTable(IntrastatReportLine);
                RecordRefSrc.CurrentKeyIndex(DataExchMapping."Key Index");
                RecordRefSrc.SetTable(IntrastatReportLine);
            end;

            IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
            if ExportType = 1 then // Receipt
                IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Receipt);
            if ExportType = 2 then // Shipment
                IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Shipment);
            OnBeforeExportIntrastatReportLines(IntrastatReportLine, IntrastatReportHeader);

            if not IntrastatReportLine.IsEmpty then begin
                DataExchFieldGrouping.SetRange("Data Exch. Def Code", DataExchMapping."Data Exch. Def Code");
                DataExchFieldGrouping.SetRange("Data Exch. Line Def Code", DataExchMapping."Data Exch. Line Def Code");
                DataExchFieldGrouping.SetRange("Table ID", DataExchMapping."Table ID");
                SetInternalRefNo(IntrastatReportLine, DataExchFieldGrouping, IntrastatReportHeader);

                DataExch.Init();
                DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
                DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
                DataExch."Table Filters".CreateOutStream(OutStreamFilters);
                OutStreamFilters.WriteText(IntrastatReportLine.GetView(false));
                if DataExch.Insert(true) then
                    DataExch.ExportFromDataExch(DataExchMapping);
                DataExch.Modify(true);
            end;
        end;
    end;

    local procedure ExportToZip(var DataExch1: Record "Data Exch."; var DataExch2: Record "Data Exch."; StatisticsPeriod: Code[10]; FileName: Text; ReceiptFileName: Text; ShipmentFileName: Text; ZipFileName: Text)
    var
        DataCompression: Codeunit "Data Compression";
        ZipTempBlob: Codeunit "Temp Blob";
        ServerShipmentsInStream: InStream;
        ServerReceiptsInStream: InStream;
        ZipInStream: InStream;
        ZipOutStream: OutStream;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExportToZip(DataExch1, DataExch2, StatisticsPeriod, FileName, ReceiptFileName, ShipmentFileName, ZipFileName, IsHandled);
        if IsHandled then
            exit;

        DataCompression.CreateZipArchive();
        DataExch1.CalcFields("File Content");
        DataExch2.CalcFields("File Content");

        if not (DataExch1."File Content".HasValue) and (not DataExch2."File Content".HasValue) then
            Error(ExternalContentErr, DataExch1.FieldCaption("File Content"));

        if DataExch2."File Content".HasValue then
            FileName := ReceiptFileName;

        if DataExch1."File Content".HasValue then begin
            DataExch1."File Content".CreateInStream(ServerReceiptsInStream);
            DataCompression.AddEntry(ServerReceiptsInStream, FileName);
        end;

        if DataExch2."File Content".HasValue then begin
            DataExch2."File Content".CreateInStream(ServerShipmentsInStream);
            DataCompression.AddEntry(ServerShipmentsInStream, ShipmentFileName);
        end;

        ZipTempBlob.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();
        ZipTempBlob.CreateInStream(ZipInStream);
        DownloadFromStream(ZipInStream, '', '', '', ZipFileName);
    end;

    procedure ExportToFile(DataExch: Record "Data Exch."; var TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        FileMgt: Codeunit "File Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExportToFile(DataExch, FileName, IsHandled);
        if IsHandled then
            exit;

        if FileMgt.BLOBExport(TempBlob, FileName, true) = '' then
            Error(DownloadFromStreamErr);
    end;

    local procedure SetInternalRefNo(var IntrastatReportLine: Record "Intrastat Report Line"; var DataExchFieldGrouping: Record "Data Exch. Field Grouping"; IntrastatReportHeader: Record "Intrastat Report Header")
    var
        CompoundField: Text;
        PrevCompoundField: Text;
        IntraReferenceNo: Text[10];
        PrevType: Enum "Intrastat Report Line Type";
        ProgressiveNo: Integer;
    begin
        if not IntrastatReportLine.FindSet() then
            exit;
        ProgressiveNo := 0;
        IntraReferenceNo := PadStr(IntrastatReportHeader."Statistics Period", MaxStrLen(IntraReferenceNo), '0');
        repeat
            CompoundField := GetCompound(DataExchFieldGrouping, IntrastatReportLine);
            if CompoundField = '' then
                CompoundField := Format(IntrastatReportLine."Line No.");
            // IntraReferenceNo is a group identifier string, consisting of fields specified in data exchange field grouping
            if (PrevType <> IntrastatReportLine.Type) or (StrLen(PrevCompoundField) = 0) then begin
                PrevType := IntrastatReportLine.Type;
                IntraReferenceNo := CopyStr(IntraReferenceNo, 1, 4) + Format(IntrastatReportLine.Type, 1, 2) + '01001';
                ProgressiveNo += 1;
            end else
                if PrevCompoundField <> CompoundField then begin
                    if CopyStr(IntraReferenceNo, 8, 3) = '999' then
                        IntraReferenceNo := CopyStr(IncStr(CopyStr(IntraReferenceNo, 1, 7)), 1, 7) + '001'
                    else
                        IntraReferenceNo := IncStr(IntraReferenceNo);
                    ProgressiveNo += 1;
                end;

            IntrastatReportLine."Progressive No." := Format(ProgressiveNo);
            IntrastatReportLine."Internal Ref. No." := IntraReferenceNo;
            OnBeforeUpdateInternalRefNo(IntrastatReportLine, CompoundField, PrevCompoundField);
            IntrastatReportLine.Modify();
            PrevCompoundField := CompoundField;
        until IntrastatReportLine.Next() = 0;
    end;

    local procedure GetCompound(var DataExchFieldGrouping: Record "Data Exch. Field Grouping"; IntrastatReportLine: Record "Intrastat Report Line") Compound: Text
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.GetTable(IntrastatReportLine);
        if DataExchFieldGrouping.FindSet() then
            repeat
                FieldRef := RecordRef.Field(DataExchFieldGrouping."Field ID");
                Compound += Format(FieldRef.Value, FieldRef.Length);
            until DataExchFieldGrouping.Next() = 0;
    end;

    procedure InitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup")
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        IsHandled: Boolean;
    begin
        if IntrastatReportSetup.Get() then
            IntrastatReportSetup.Delete(true);

        if not NoSeries.Get('INTRA') then begin
            NoSeries.Init();
            NoSeries.Code := 'INTRA';
            NoSeries.Description := 'Intrastat';
            NoSeries.Validate("Default Nos.", true);
            NoSeries.Validate("Manual Nos.", true);
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'INTRA';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Validate("Starting No.", 'INTRA00001');
            NoSeriesLine.Insert(true);
            NoSeriesLine.Validate(Implementation, Enum::"No. Series Implementation"::Sequence);
            NoSeriesLine.Modify(true);
        end;

        IntrastatReportSetup.Init();
        IntrastatReportSetup.Validate("Intrastat Nos.", NoSeries.Code);
        IntrastatReportSetup.Insert();

        IsHandled := false;
        OnBeforeInitSetup(IntrastatReportSetup, IsHandled);

        if not IsHandled then begin
            IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
            IntrastatReportSetup."Get Partner VAT For" := IntrastatReportSetup."Get Partner VAT For"::Shipment;
            IntrastatReportSetup."Def. Private Person VAT No." := 'QV999999999999';
            IntrastatReportSetup."Def. 3-Party Trade VAT No." := 'QV999999999999';
            IntrastatReportSetup."Def. VAT for Unknown State" := 'QV999999999999';
            IntrastatReportSetup.Modify();

            CreateDefaultDataExchangeDef();
        end;

        IntrastatReportChecklist.DeleteAll(true);

        IsHandled := false;
        OnBeforeInitCheckList(IsHandled);

        if not IsHandled then begin
            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 5);
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 7);
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 8);
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 14);
            IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: True');
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 21);
            IntrastatReportChecklist.Validate("Filter Expression", 'Supplementary Units: False');
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 24);
            IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
            IntrastatReportChecklist.Insert(true);

            IntrastatReportChecklist.Init();
            IntrastatReportChecklist.Validate("Field No.", 29);
            IntrastatReportChecklist.Validate("Filter Expression", 'Type: Shipment');
            IntrastatReportChecklist.Insert(true);
        end;
    end;

    internal procedure CreateDefaultDataExchangeDef()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        DataExchDef: Record "Data Exch. Def";
        TempBlob: Codeunit "Temp Blob";
        IsHandled: Boolean;
        XMLOutStream: OutStream;
        XMLInStream: InStream;
    begin
        IsHandled := false;
        OnBeforeCreateDefaultDataExchangeDef(IsHandled);
        if IsHandled then
            exit;

        if DataExchDef.Get('INTRA-2022') then
            DataExchDef.Delete(true);

        TempBlob.CreateOutStream(XMLOutStream);
        XMLOutStream.WriteText(DataExchangeXMLTxt);
        TempBlob.CreateInStream(XMLInStream);
        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);

        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022';
        IntrastatReportSetup.Modify();
    end;

    internal procedure ReCreateDefaultDataExchangeDef()
    var
        DataExchDefCard: Page "Data Exch Def Card";
    begin
        if Confirm(StrSubstNo(ImportDefaultIntrastatDataExchDefConfirmQst, DataExchDefCard.Caption)) then
            CreateDefaultDataExchangeDef();
    end;

    procedure UpdateItemUOM(var ItemUOM: Record "Item Unit of Measure"; TariffNumber: Record "Tariff Number")
    var
        Item: Record Item;
        BaseItemUOM: Record "Item Unit of Measure";
        RoundingPrecision: Decimal;
    begin
        Item.Get(ItemUOM."Item No.");
        if BaseItemUOM.Get(Item."No.", Item."Base Unit of Measure") then
            RoundingPrecision := BaseItemUOM."Qty. Rounding Precision";
        if RoundingPrecision = 0 then
            RoundingPrecision := 0.00001;
        if TariffNumber."Suppl. Conversion Factor" <> 0 then
            ItemUOM.Validate("Qty. per Unit of Measure", Round(1 / TariffNumber."Suppl. Conversion Factor", RoundingPrecision))
        else
            ItemUOM.Validate("Qty. per Unit of Measure", 1);
        ItemUOM.Modify(true);
    end;

    procedure IsFeatureEnabled() IsEnabled: Boolean
    var
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        IsEnabled := FeatureMgtFacade.IsEnabled(GetIntrastatFeatureKeyId());
        OnAfterCheckFeatureEnabled(IsEnabled);
    end;

    procedure NotifyUserAboutIntrastatFeature()
    var
        MyNotifications: Record "My Notifications";
        IntrastatFeatureAwarenessNotification: Notification;
    begin
        if IsInstalledByAppId(GetAppId()) then
            if MyNotifications.IsEnabled(GetIntrastatFeatureAwarenessNotificationId()) then begin
                IntrastatFeatureAwarenessNotification.Id(GetIntrastatFeatureAwarenessNotificationId());
                IntrastatFeatureAwarenessNotification.SetData('NotificationId', GetIntrastatFeatureAwarenessNotificationId());
                IntrastatFeatureAwarenessNotification.Message(IntrastatAwarenessNotificationTxt);

                IntrastatFeatureAwarenessNotification.AddAction(LearnMoreTxt, Codeunit::IntrastatReportManagement, 'LearnMore');
                IntrastatFeatureAwarenessNotification.AddAction(DisableNotificationTxt, Codeunit::IntrastatReportManagement, 'DisableNotification');
                IntrastatFeatureAwarenessNotification.Send();
            end;
    end;

    procedure LearnMore(HostNotification: Notification)
    begin
        Hyperlink(LearnMoreLinkTok);
    end;

    procedure DisableNotification(HostNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := HostNotification.GetData('NotificationId');
        if MyNotifications.Get(UserId(), NotificationId) then
            MyNotifications.Disable(NotificationId)
        else
            MyNotifications.InsertDefault(NotificationId, IntrastatAwarenessNotificationNameTxt, IntrastatAwarenessNotificationDescriptionTxt, false);
        Session.LogMessage('0000I9Q', StrSubstNo(UserDisabledNotificationTxt, HostNotification.GetData('NotificationId')), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', IntrastatTelemetryCategoryTok);
    end;

    internal procedure NotifyUserAboutSupplementaryUnitUpdate()
    var
        Item: Record Item;
        MyNotifications: Record "My Notifications";
        SupplementaryUnitUpdateNotification: Notification;
    begin
        if MyNotifications.IsEnabled(GetSupplementaryUnitUpdateNotificationId()) then begin
            SupplementaryUnitUpdateNotification.Id(GetSupplementaryUnitUpdateNotificationId());
            SupplementaryUnitUpdateNotification.SetData('NotificationId', GetSupplementaryUnitUpdateNotificationId());
            SupplementaryUnitUpdateNotification.Message(StrSubstNo(SupplementaryUnitUpdateNotificationTxt, Item.FieldCaption("Supplementary Unit of Measure"), Item.FieldCaption("Tariff No.")));

            SupplementaryUnitUpdateNotification.AddAction(DisableNotificationTxt, Codeunit::IntrastatReportManagement, 'DisableSupplementaryUnitUpdateNotification');
            SupplementaryUnitUpdateNotification.Send();
        end;
    end;

    internal procedure DisableSupplementaryUnitUpdateNotification(HostNotification: Notification)
    var
        Item: Record Item;
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := HostNotification.GetData('NotificationId');
        if MyNotifications.Get(UserId(), NotificationId) then
            MyNotifications.Disable(NotificationId)
        else
            MyNotifications.InsertDefault(NotificationId, StrSubstNo(SupplementaryUnitUpdateNotificationNameTxt, Item.FieldCaption("Supplementary Unit of Measure")),
                StrSubstNo(SupplementaryUnitUpdateNotificationDescriptionTxt, Item.FieldCaption("Supplementary Unit of Measure"), Item.FieldCaption("Tariff No.")), false);
    end;

    procedure ShowNotEnabledMessage(PageCaption: Text)
    begin
        Message(FeatureNotEnabledMessageTxt, PageCaption);
    end;

    procedure ShowFeatureEnabledMessage(OldPageCaption: Text; NewPageCaption: Text)
    begin
        Message(NewFeatureEnabledMessageTxt, OldPageCaption, NewPageCaption);
    end;

    procedure IsCustomerPrivatePerson(Customer: Record Customer): Boolean;
    begin
        if Customer."Intrastat Partner Type" <> "Partner Type"::" " then
            exit(Customer."Intrastat Partner Type" = "Partner Type"::Person)
        else
            exit(Customer."Partner Type" = "Partner Type"::Person);
    end;

    procedure IsVendorPrivatePerson(Vendor: Record Vendor): Boolean
    begin
        if Vendor."Intrastat Partner Type" <> "Partner Type"::" " then
            exit(Vendor."Intrastat Partner Type" = "Partner Type"::Person)
        else
            exit(Vendor."Partner Type" = "Partner Type"::Person);
    end;

    local procedure GetIntrastatFeatureKeyId(): Text[50]
    begin
        exit(IntrastatFeatureKeyIdTok);
    end;

    local procedure GetIntrastatFeatureAwarenessNotificationId(): Guid;
    begin
        exit(IntrastatFeatureAwarenessNotificationIdTok);
    end;

    local procedure GetSupplementaryUnitUpdateNotificationId(): Guid;
    begin
        exit(SupplementaryUnitUpdateNotificationIdTok);
    end;

    local procedure GetAppId(): Guid;
    begin
        exit(IntrastatCoreAppIdTok);
    end;

    local procedure IsInstalledByAppId(AppID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get(AppID));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"Intrastat Report Setup Wizard", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, LearnMoreLinkTok);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeReleaseIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterReleaseIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeReopenIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterReopenIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterExportIntrastatHeader(var IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportToFile(DataExch: Record "Data Exch."; var FileName: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportToZip(DataExch1: Record "Data Exch."; DataExch2: Record "Data Exch."; StatisticsPeriod: Text; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitCheckList(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDefineFileNames(var IntrastatReportHeader: Record "Intrastat Report Header"; var FileName: Text; var ReceptFileName: Text; var ShipmentFileName: Text; var ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateInternalRefNo(var IntrastatReportLine: Record "Intrastat Report Line"; var CompoundField: Text; var PrevCompoundField: Text);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeExportOneDataExchangeDef(var IntrastatReportHeader: Record "Intrastat Report Header"; DataExchDefCode: Code[20]; ExportType: Integer; var DataExch: Record "Data Exch."; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateReportWithAdvancedChecklist(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportHeader: Record "Intrastat Report Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeExportIntrastatReportLines(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportHeader: Record "Intrastat Report Header");
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreateDefaultDataExchangeDef(var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetIntrastatBaseCountryCodeFromFAEntry(var FALedgerEntry: Record "FA Ledger Entry"; var IntrastatReportSetup: Record "Intrastat Report Setup"; var CountryCode: Code[10]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetIntrastatBaseCountryCode(var ItemLedgerEntry: Record "Item Ledger Entry"; var IntrastatReportSetup: Record "Intrastat Report Setup"; var CountryCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetIntrastatBaseCountryCodeFromJLE(var JobLedgerEntry: Record "Job Ledger Entry"; var IntrastatReportSetup: Record "Intrastat Report Setup"; var CountryCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetIntrastatBaseCountryCodeFromFALE(var FALedgerEntry: Record "FA Ledger Entry"; var IntrastatReportSetup: Record "Intrastat Report Setup"; var CountryCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCompanyVATRegNoOnAfterGetIntrastatReportSetup(var CompanyInformation: Record "Company Information"; var IntrastatReportSetup: Record "Intrastat Report Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportWithDataExchOnAfterGetIntrastatReportSetup(var IntrastatReportSetup: Record "Intrastat Report Setup"; var IntrastatReportHeader: Record "Intrastat Report Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntrastatBaseCountryCodeFromItemLedgerElseCase(ItemLedgerEntry: Record "Item Ledger Entry"; IntrastatReportSetup: Record "Intrastat Report Setup"; var CountryCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetOriginalCurrencyFromItemLedgerElseCase(ItemLedgerEntry: Record "Item Ledger Entry"; var CurrencyCode: Code[10])
    begin
    end;
}