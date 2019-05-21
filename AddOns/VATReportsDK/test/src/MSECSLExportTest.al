// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148040 "MS - ECSL Export Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    trigger OnRun();
    begin
        // [FEATURE] [VAT Report] [EC Sales List]
    end;

    [Test]
    PROCEDURE ECSLGenerateAllNodesQuarterly();
    var
        VATReportHeader: Record "VAT Report Header";
        ECSalesListSuggestLines: Codeunit "EC Sales List Suggest Lines";
        MSECSLReportExportFile: Codeunit "MS - ECSL Report Export File";
        ReportTxt: Text;
        StartDate: Date;
        EndDate: Date;
    BEGIN
        // [Scenario] generating full file for a quarter
        StartDate := DMY2DATE(1, 1, 2017);
        EndDate := DMY2DATE(31, 1, 2017);
        InitPrerequisites();
        // [Given] VAT report header
        InitReportHeader(VATReportHeader, StartDate, EndDate);
        VATReportHeader."Period Type" := VATReportHeader."Period Type"::Quarter;
        VATReportHeader."Period No." := 1;
        VATReportHeader.MODIFY();

        // [Given] 100 B2B Goods, 100 B2B Services and 100 EU 3-Party Trade  Vat Entry
        GenerateData(100, StartDate);
        ECSalesListSuggestLines.Run(VATReportHeader);

        // [When] Generate the file
        MSECSLReportExportFile.AvoidDownload();
        MSECSLReportExportFile.Run(VATReportHeader);

        // [THEN] File has all the expected values and elements
        ReportTxt := MSECSLReportExportFile.GetOutputContent();
        AssertFile(ReportTxt, VATReportHeader."No.");
    END;

    local procedure AssertFile(ReportTxt: Text; VatReportNo: Code[20]);
    var
        InStrm: InStream;
        OutStrm: OutStream;
        LineCounter: Integer;
        FileObj: File;
        Linetxt: Text;
    begin
        FileObj.CreateTempFile();
        FileObj.CREATEOUTSTREAM(OutStrm);
        OutStrm.WRITETEXT(ReportTxt);
        FileObj.CreateInStream(InStrm);

        while InStrm.ReadText(Linetxt) <> 0 do
            case SelectStr(1, Linetxt) of
                '0':
                    AssertHeader(Linetxt);
                '2':
                    begin
                        LineCounter += 1;
                        AssertLine(Linetxt, VatReportNo);
                    end;
                '10':
                    AssertFooter(Linetxt, LineCounter, VatReportNo);
            end;
    end;

    local procedure AssertHeader(lineTxt: Text);
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        Assert.AreEqual(CompanyInformation."VAT Registration No.", SelectStr(2, Linetxt), '')

    end;

    local procedure AssertLine(lineTxt: Text; ReportNo: code[20]);
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VatRegNo: Code[20];
        CountryCode: Code[10];
        SrvValInt: Integer;
        GoodsValInt: Integer;
        TriGoodsValInt: Integer;
    begin
        VatRegNo := CopyStr(SelectStr(6, Linetxt), 1, MaxStrLen(VatRegNo));

        ECSLVATReportLine.SetRange("Report No.", ReportNo);
        ECSLVATReportLine.SetRange("Customer VAT Reg. No.", VatRegNo);

        Evaluate(CountryCode, SelectStr(5, lineTxt));
        Evaluate(GoodsValInt, SelectStr(7, Linetxt));
        Evaluate(SrvValInt, SelectStr(8, Linetxt));
        Evaluate(TriGoodsValInt, SelectStr(9, Linetxt));

        ECSLVATReportLine.Init();
        if ECSLVATReportLine.FindFirst() then;
        Assert.AreEqual(ECSLVATReportLine."Country Code", CountryCode, '');

        ECSLVATReportLine.SetRange("Transaction Indicator", ECSLVATReportLine."Transaction Indicator"::"B2B Goods");
        ECSLVATReportLine.Init();
        if ECSLVATReportLine.FindFirst() then;
        Assert.AreEqual(ECSLVATReportLine."Total Value Of Supplies", GoodsValInt, '');

        ECSLVATReportLine.SetRange("Transaction Indicator", ECSLVATReportLine."Transaction Indicator"::"B2B Services");
        ECSLVATReportLine.Init();
        if ECSLVATReportLine.FindFirst() then;
        Assert.AreEqual(ECSLVATReportLine."Total Value Of Supplies", SrvValInt, '');

        ECSLVATReportLine.SetRange("Transaction Indicator", ECSLVATReportLine."Transaction Indicator"::"Triangulated Goods");
        ECSLVATReportLine.Init();
        if ECSLVATReportLine.FindFirst() then;
        Assert.AreEqual(ECSLVATReportLine."Total Value Of Supplies", TriGoodsValInt, '');

    end;

    procedure GenerateData(RecordToGen: Integer; PostingDate: Date);
    var
        VATEntry: Record "VAT Entry";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VatRegNo: Integer;
        LastVatRegNo: Integer;
    begin
        VATEntry.DELETEALL();
        LastVatRegNo := 100000 + RecordToGen;
        for VatRegNo := 100000 to LastVatRegNo do begin
            InitVatEntry(VATEntry, Format(VatRegNo), PostingDate, ECSLVATReportLine."Transaction Indicator"::"B2B Goods");
            InitVatEntry(VATEntry, Format(VatRegNo), PostingDate, ECSLVATReportLine."Transaction Indicator"::"B2B Services");
            InitVatEntry(VATEntry, Format(VatRegNo), PostingDate, ECSLVATReportLine."Transaction Indicator"::"Triangulated Goods");
        end;
    end;

    local procedure AssertFooter(lineTxt: Text; LineCount: integer; ReportNo: code[20]);
    var
        LineCountInt: Integer;
        TotalValueInt: Integer;
    begin
        Evaluate(LineCountInt, SelectStr(2, Linetxt));
        Assert.AreEqual(LineCount, LineCountInt, 'Line count does not match the actual lines.');
        Evaluate(TotalValueInt, SelectStr(3, Linetxt));
        Assert.AreEqual(GetReportTotalValue(ReportNo), TotalValueInt, 'Total value of the report doesn not match.');
    end;

    LOCAL PROCEDURE InitPrerequisites();
    var
        CompanyInformation: Record "Company Information";
    BEGIN
        CompanyInformation.GET();
        CompanyInformation."VAT Registration No." := '7777777';
        CompanyInformation."Post Code" := '12345';
        CompanyInformation.MODIFY();
    END;

    LOCAL PROCEDURE InitReportHeader(VAR VATReportHeader: Record "VAT Report Header"; StartDate: Date; EndDate: Date);
    BEGIN
        VATReportHeader.INIT();
        VATReportHeader."Start Date" := StartDate;
        VATReportHeader."End Date" := EndDate;
        VATReportHeader."No." := COPYSTR(CREATEGUID(), 2, 10);

        VATReportHeader."Period Type" := VATReportHeader."Period Type"::Month;
        VATReportHeader."Period No." := DATE2DMY(StartDate, 2);
        VATReportHeader."Period Year" := DATE2DMY(StartDate, 3);

        VATReportHeader."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code"::"EC Sales List";
        VATReportHeader.INSERT();
    END;

    LOCAL PROCEDURE InitVatEntry(VAR VATEntry: Record "VAT Entry"; VatRegNo: Text[20]; PostingDate: Date; TradeType: Option);
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        LastId: Integer;

    BEGIN
        IF VATEntry.FINDLAST() THEN
            LastId := VATEntry."Entry No.";

        VATEntry.INIT();
        VATEntry."Entry No." := LastId + 1;
        VATEntry.Base := -1.7;
        VATEntry."Posting Date" := PostingDate;
        VATEntry.Type := VATEntry.Type::Sale;
        VATEntry."EU 3-Party Trade" := false;
        VATEntry."EU Service" := false;

        case TradeType of
            ECSLVATReportLine."Transaction Indicator"::"B2B Services":
                VATEntry."EU Service" := true;
            ECSLVATReportLine."Transaction Indicator"::"Triangulated Goods":
                VATEntry."EU 3-Party Trade" := true;
        end;

        VATEntry."VAT Registration No." := VatRegNo;
        VATEntry."Country/Region Code" := 'DE';
        VATEntry.INSERT();
    END;

    LOCAL PROCEDURE GetReportTotalValue(ReportNo: Code[20]): Integer;
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
    BEGIN
        ECSLVATReportLine.SETRANGE("Report No.", ReportNo);
        ECSLVATReportLine.SETCURRENTKEY("Report No.");
        ECSLVATReportLine.CALCSUMS("Total Value Of Supplies");
        EXIT(ECSLVATReportLine."Total Value Of Supplies");
    END;

}
