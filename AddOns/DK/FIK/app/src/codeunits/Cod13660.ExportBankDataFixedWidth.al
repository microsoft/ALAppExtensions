// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13660 "Export BankData Fixed Width"
{
    Permissions = TableData 1220 = rimd,
              TableData 1221 = rimd,
              TableData 1226 = rimd;
    TableNo = 1226;

    var
        DataExchDef: Record "Data Exch. Def";
        Delimiter: Text;
        Separator: Text;
        NotSameDueDateForAllLinesErr: Label 'The Transfer Date value should be the same for all payment export data within the specified filters: %1.';

    trigger OnRun();
    var
        DataLines: Text;
        FooterLine: Text;
        HeaderLine: Text;
    begin
        FindDefinition();
        DefineLineCharacteristics();

        HeaderLine := PrepareHeaderLine(Rec);
        DataLines := PrepareDataLines("Data Exch Entry No.");
        FooterLine := PrepareFooterLine(Rec);

        WriteToBlob("Data Exch Entry No.", HeaderLine, DataLines, FooterLine);
    end;

    local procedure FindDefinition();
    begin
        DataExchDef.SETRANGE(Type, DataExchDef.Type::"Payment Export");
        DataExchDef.SETRANGE("Reading/Writing Codeunit", CODEUNIT::"Export BankData Fixed Width");
        DataExchDef.FINDFIRST();
    end;

    local procedure DefineLineCharacteristics();
    begin
        Separator := DataExchDef.ColumnSeparatorChar();
        Delimiter := '"';
    end;

    local procedure GetTransferDate(var PaymentExportData: Record "Payment Export Data"): Text;
    var
        PaymentExportData2: Record "Payment Export Data";
    begin
        PaymentExportData2.COPYFILTERS(PaymentExportData);
        PaymentExportData2.SETRANGE("Data Exch Entry No.", PaymentExportData."Data Exch Entry No.");
        PaymentExportData2.SETFILTER("Transfer Date", '<>%1', PaymentExportData."Transfer Date");

        IF NOT PaymentExportData2.ISEMPTY() THEN
            ERROR(NotSameDueDateForAllLinesErr, PaymentExportData.GETFILTERS());

        EXIT(FORMAT(PaymentExportData."Transfer Date", 0, '<Year4><Month,2><Day,2>'));
    end;

    local procedure GetLineCount(PaymentExportData: Record "Payment Export Data"): Text;
    begin
        EXIT(FORMAT(PaymentExportData."Line No.", 0, '<Integer,6><Filler Character,0>'));
    end;

    local procedure GetTotalAmount(PaymentExportData: Record "Payment Export Data"): Text;
    begin
        EXIT(FORMAT(100 * PaymentExportData.Amount, 0, '<Integer,13><Filler Character,0><Sign,1><Filler Character,+>'));
    end;

    local procedure PrepareHeaderLine(var PaymentExportData: Record "Payment Export Data") HeaderLine: Text;
    begin
        HeaderLine := Delimiter + 'IB000000000000' + Delimiter + Separator;
        HeaderLine += Delimiter + GetTransferDate(PaymentExportData) + Delimiter + Separator;
        HeaderLine += Delimiter + PADSTR('', 90, ' ') + Delimiter + Separator;
        HeaderLine += Delimiter + PADSTR('', 255, ' ') + Delimiter + Separator;
        HeaderLine += Delimiter + PADSTR('', 255, ' ') + Delimiter + Separator;
        HeaderLine += Delimiter + PADSTR('', 255, ' ') + Delimiter;
    end;

    local procedure PrepareDataLines(DataExchEntryNo: Integer): Text;
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        GenerateDataLines(DataExchEntryNo, TempBlob);
        EXIT(RetrieveDataLines(TempBlob));
    end;

    local procedure GenerateDataLines(DataExchEntryNo: Integer; var TempBlob: Codeunit "Temp Blob");
    var
        DataExchField: Record "Data Exch. Field";
        ExportGenericFixedWidth: XMLport "Export Generic Fixed Width";
        OutputStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutputStream);
        DataExchField.SETRANGE("Data Exch. No.", DataExchEntryNo);

        ExportGenericFixedWidth.SETTABLEVIEW(DataExchField);
        ExportGenericFixedWidth.FIELDDELIMITER(Delimiter);
        ExportGenericFixedWidth.FIELDSEPARATOR(Separator);
        ExportGenericFixedWidth.SETDESTINATION(OutputStream);
        ExportGenericFixedWidth.EXPORT();
    end;

    local procedure RetrieveDataLines(var TempBlob: Codeunit "Temp Blob") DataLines: Text;
    var
        InputStream: InStream;
        CarriageReturn: Char;
        DataLine: Text;
        LineFeed: Char;
    begin
        TempBlob.CreateInStream(InputStream);
        CarriageReturn := 13;
        LineFeed := 10;

        REPEAT
            InputStream.READTEXT(DataLine);
            DataLines += DataLine;
            IF NOT InputStream.EOS() THEN
                DataLines += FORMAT(CarriageReturn) + FORMAT(LineFeed);
        UNTIL InputStream.EOS();
    end;

    local procedure PrepareFooterLine(var PaymentExportData: Record "Payment Export Data") FooterLine: Text;
    begin
        FooterLine := Delimiter + 'IB999999999999' + Delimiter + Separator;
        FooterLine += Delimiter + GetTransferDate(PaymentExportData) + Delimiter + Separator;
        FooterLine += Delimiter + GetLineCount(PaymentExportData) + Delimiter + Separator;
        FooterLine += Delimiter + GetTotalAmount(PaymentExportData) + Delimiter + Separator;
        FooterLine += Delimiter + PADSTR('', 64, ' ') + Delimiter + Separator;
        FooterLine += Delimiter + PADSTR('', 255, ' ') + Delimiter + Separator;
        FooterLine += Delimiter + PADSTR('', 255, ' ') + Delimiter + Separator;
        FooterLine += Delimiter + PADSTR('', 255, ' ') + Delimiter;
    end;

    local procedure WriteToBlob(DataExchEntryNo: Integer; Header: Text; Body: Text; Footer: Text);
    var
        DataExch: Record "Data Exch.";
        OutStream: OutStream;
    begin
        DataExch.GET(DataExchEntryNo);
        DataExch."File Content".CREATEOUTSTREAM(OutStream);

        OutStream.WRITETEXT(Header);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT(Body);
        OutStream.WRITETEXT();
        OutStream.WRITETEXT(Footer);

        DataExch.MODIFY();
    end;
}