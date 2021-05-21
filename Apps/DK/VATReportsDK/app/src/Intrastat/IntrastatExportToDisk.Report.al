// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 13690 "Intrastat Export To Disk"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Intrastat Jnl. Batch"; "Intrastat Jnl. Batch")
        {
            DataItemTableView = SORTING("Journal Template Name", Name);
            RequestFilterFields = "Journal Template Name", Name;
            dataitem("Intrastat Jnl. Line"; "Intrastat Jnl. Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD(Name);
                DataItemTableView = SORTING(Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method");
                RequestFilterFields = Type;

                trigger OnAfterGetRecord();
                begin
                    if ("Tariff No." = '') and
                       ("Country/Region Code" = '') and
                       ("Transaction Type" = '') and
                       ("Transport Method" = '') and
                       ("Total Weight" = 0)
                    then
                        CurrReport.SKIP();

                    TESTFIELD("Tariff No.");
                    TESTFIELD("Country/Region Code");
                    TESTFIELD("Transaction Type");
                    TESTFIELD("Total Weight");
                    if "Supplementary Units" then
                        TESTFIELD(Quantity);

                    TransMeth := "Transport Method";
                    if TransMeth = '' then
                        TransMeth := '0';

                    CompoundField :=
                      FORMAT("Country/Region Code", 10) + FORMAT(DELCHR("Tariff No."), 10) +
                      FORMAT("Transaction Type", 10) + FORMAT("Transport Method", 10);

                    if (TempType <> Type) or (STRLEN(TempCompoundField) = 0) then begin
                        TempType := Type;
                        TempCompoundField := CompoundField;
                        IntraReferenceNo := COPYSTR(IntraReferenceNo, 1, 4) + FORMAT(Type, 1, 2) + '01001';
                    end else
                        if TempCompoundField <> CompoundField then begin
                            TempCompoundField := CompoundField;
                            if COPYSTR(IntraReferenceNo, 8, 3) = '999' then
                                IntraReferenceNo := CopyStr(INCSTR(COPYSTR(IntraReferenceNo, 1, 7)) + '001', 1, MaxStrLen(IntraReferenceNo))
                            else
                                IntraReferenceNo := INCSTR(IntraReferenceNo);
                        end;

                    "Internal Ref. No." := IntraReferenceNo;
                    MODIFY();
                end;
            }
            dataitem(IntrastatJnlLine2; "Intrastat Jnl. Line")
            {
                DataItemTableView = SORTING("Internal Ref. No.");

                trigger OnAfterGetRecord();
                begin
                    if ("Tariff No." = '') and
                       ("Country/Region Code" = '') and
                       ("Transaction Type" = '') and
                       ("Transport Method" = '') and
                       ("Total Weight" = 0)
                    then
                        CurrReport.SKIP();
                    "Tariff No." := DELCHR("Tariff No.");

                    TotalWeightAmt += "Total Weight";
                    QuantityAmt += Quantity;
                    StatisticalValueAmt += "Statistical Value";

                    IntrastatJnlLine5.COPY(IntrastatJnlLine2);
                    if IntrastatJnlLine5.NEXT() = 1 then begin
                        if (DELCHR(IntrastatJnlLine5."Tariff No.") = "Tariff No.") and
                           (IntrastatJnlLine5."Country/Region Code" = "Country/Region Code") and
                           (IntrastatJnlLine5."Transaction Type" = "Transaction Type") and
                           (IntrastatJnlLine5."Transport Method" = "Transport Method")
                        then
                            GroupTotal := false
                        else
                            GroupTotal := true;
                    end else
                        GroupTotal := true;

                    if GroupTotal then begin
                        WriteGrTotalsToFile(TotalWeightAmt, QuantityAmt, StatisticalValueAmt);
                        StatisticalValueTotalAmt += StatisticalValueAmt;
                        TotalWeightAmt := 0;
                        QuantityAmt := 0;
                        StatisticalValueAmt := 0;
                    end;
                end;

                trigger OnPostDataItem();
                begin
                    if not Receipt then
                        WriteToFile(
                          FORMAT(
                            '02000' + FORMAT(IntraReferenceNo, 4) + '100000' +
                            FORMAT(VATRegNo, 8) + '1' + FORMAT(IntraReferenceNo, 4),
                            80));
                    if not Shipment then
                        WriteToFile(
                          FORMAT(
                            '02000' + FORMAT(IntraReferenceNo, 4) + '200000' +
                            FORMAT(VATRegNo, 8) + '2' + FORMAT(IntraReferenceNo, 4),
                            80));
                    IntraFile.WRITE(FORMAT('10' + DecimalNumeralZeroFormat(StatisticalValueTotalAmt, 16), 80));
                    IntraFile.CLOSE();
                    IntraFile.OPEN(FileName);
                    IntraFile.SEEK(IntraFile.LEN() - 2);
                    IntraFile.TRUNC();
                    IntraFile.CLOSE();

                    "Intrastat Jnl. Batch".Reported := true;
                    "Intrastat Jnl. Batch".MODIFY();

                    if ServerFileName = '' then
                        FileMgt.DownloadHandler(FileName, '', '', FileMgt.GetToFilterText('', DefaultFilenameTxt), DefaultFilenameTxt)
                    else
                        FileMgt.CopyServerFile(FileName, ServerFileName, true);
                end;

                trigger OnPreDataItem();
                begin
                    CompanyInfo.GET();
                    VATRegNo := CONVERTSTR(CompanyInfo."VAT Registration No.", RegNoFormatTxt, '    ');
                    WriteToFile(FORMAT('00' + FORMAT(VATRegNo, 8) + RegNoFormatNameTxt, 80));
                    WriteToFile(FORMAT('0100004', 80));

                    SETRANGE("Internal Ref. No.", COPYSTR(IntraReferenceNo, 1, 4), COPYSTR(IntraReferenceNo, 1, 4) + '9');
                    //     CurrReport.CREATETOTALS(Quantity,"Statistical Value","Total Weight");

                    IntrastatJnlLine3.SETCURRENTKEY("Internal Ref. No.");
                end;
            }

            trigger OnAfterGetRecord();
            begin
                TESTFIELD(Reported, false);
                IntraReferenceNo := CopyStr("Statistics Period" + '000000', 1, MaxStrLen(IntraReferenceNo));
            end;

            trigger OnPreDataItem();
            begin
                IntrastatJnlLine4.COPYFILTER("Journal Template Name", "Journal Template Name");
                IntrastatJnlLine4.COPYFILTER("Journal Batch Name", Name);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }

        trigger OnOpenPage();
        var
            IntrastatSetup: Record "Intrastat Setup";
        begin
            if not IntrastatSetup.GET() then
                exit;

            if IntrastatSetup."Report Receipts" and IntrastatSetup."Report Shipments" then
                exit;

            if IntrastatSetup."Report Receipts" then
                "Intrastat Jnl. Line".SETRANGE(Type, "Intrastat Jnl. Line".Type::Receipt)
            else
                if IntrastatSetup."Report Shipments" then
                    "Intrastat Jnl. Line".SETRANGE(Type, "Intrastat Jnl. Line".Type::Shipment)
        end;
    }

    labels
    {
    }

    trigger OnPreReport();
    begin
        FileName := FileMgt.ServerTempFileName('');

        IntrastatJnlLine4.COPYFILTERS("Intrastat Jnl. Line");
        if FileName = '' then
            ERROR(MissingFileNameErr);
        IntraFile.TEXTMODE := true;
        IntraFile.WRITEMODE := true;
        IntraFile.CREATE(FileName);
    end;

    var
        IntrastatJnlLine3: Record "Intrastat Jnl. Line";
        IntrastatJnlLine4: Record "Intrastat Jnl. Line";
        IntrastatJnlLine5: Record "Intrastat Jnl. Line";
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
        FileMgt: Codeunit "File Management";
        IntraFile: File;
        QuantityAmt: Decimal;
        StatisticalValueAmt: Decimal;
        StatisticalValueTotalAmt: Decimal;
        TotalWeightAmt: Decimal;
        FileName: Text;
        IntraReferenceNo: Text[10];
        CompoundField: Text[40];
        TempCompoundField: Text[40];
        ServerFileName: Text;
        TempType: Integer;
        NoOfEntries: Text[3];
        Receipt: Boolean;
        Shipment: Boolean;
        VATRegNo: Code[20];
        ImportExport: Code[1];
        OK: Boolean;
        GroupTotal: Boolean;
        TransMeth: Code[10];
        DefaultFilenameTxt: Label 'Default.txt', Locked = true;
        MissingFileNameErr: Label 'Enter the file name.';
        RegNoFormatTxt: Label 'WwWw';
        RegNoFormatNameTxt: Label 'INTRASTAT';
        ZeroFormatErr: Label 'It is not possible to display %1 in a field with a length of %2.';

    local procedure DecimalNumeralZeroFormat(DecimalNumeral: Decimal; Length: Integer): Text[250];
    begin
        exit(TextZeroFormat(CopyStr(DELCHR(FORMAT(ROUND(ABS(DecimalNumeral), 1, '<'), 0, 1)), 1, 250), Length));
    end;

    local procedure TextZeroFormat(Text: Text[250]; Length: Integer): Text[250];
    begin
        if STRLEN(Text) > Length then
            ERROR(
              ZeroFormatErr,
              Text, Length);
        exit(PADSTR('', Length - STRLEN(Text), '0') + Text);
    end;

    [Scope('Cloud')]
    procedure InitializeRequest(newServerFileName: Text);
    begin
        ServerFileName := newServerFileName;
    end;

    [Scope('OnPrem')]
    procedure WriteGrTotalsToFile(TotalWeightAmt: Decimal; QuantityAmt: Decimal; StatisticalValueAmt: Decimal);
    begin
        with IntrastatJnlLine2 do begin
            OK := COPYSTR("Internal Ref. No.", 8, 3) = '001';
            if OK then begin
                IntrastatJnlLine3.SETRANGE(
                  "Internal Ref. No.",
                  COPYSTR("Internal Ref. No.", 1, 7) + '000',
                  COPYSTR("Internal Ref. No.", 1, 7) + '999');
                IntrastatJnlLine3.FindLast();
                NoOfEntries := COPYSTR(IntrastatJnlLine3."Internal Ref. No.", 8, 3);
            end;
            ImportExport := CopyStr(INCSTR(FORMAT(Type, 1, 2)), 1, MaxStrLen(ImportExport));

            if Type = Type::Receipt then
                Receipt := true
            else
                Shipment := true;
            Country.GET("Country/Region Code");
            Country.TESTFIELD("Intrastat Code");

            if OK then
                WriteToFile(
                FORMAT(
                  '02' +
                  TextZeroFormat(DELCHR(NoOfEntries), 3) +
                  FORMAT(COPYSTR(IntrastatJnlLine3."Internal Ref. No.", 1, 7) + '000', 10) +
                  FORMAT(VATRegNo, 8) + FORMAT(ImportExport, 1) + FORMAT(IntraReferenceNo, 4),
                  80));

            WriteToFile(
              FORMAT(
                '03' +
                TextZeroFormat(COPYSTR("Internal Ref. No.", 8, 3), 3) +
                FORMAT("Internal Ref. No.", 10) + FORMAT(Country."Intrastat Code", 3) + FORMAT("Transaction Type", 2) +
                '0' + FORMAT(TransMeth, 1) + PADSTR("Tariff No.", 9, '0') +
                DecimalNumeralZeroFormat(ROUND(TotalWeightAmt, 1, '>'), 15) +
                DecimalNumeralZeroFormat(QuantityAmt, 10) +
                DecimalNumeralZeroFormat(StatisticalValueAmt, 15),
                80));
        end;
    end;

    local procedure WriteToFile(Text: Text[80]);
    begin
        IntraFile.WRITE(Text);
        IntraFile.SEEK(IntraFile.POS() - 2);
    end;
}