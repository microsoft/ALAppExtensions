codeunit 148131 "Elec. VAT Submission XML Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryElecVATSubmission: Codeunit "Library - Elec. VAT Submission";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission] [XML]
    end;

    //[Test]
    procedure SubmissionMessageStructureMultipleCodes()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: array[2] of Record "VAT Statement Report Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATReportMediator: Codeunit "VAT Report Mediator";
    begin
        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        VATReportHeader."Start Date" := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));
        VATReportHeader."End Date" := DMY2Date(1, 2, Date2DMY(WorkDate(), 3));
        VATReportHeader.Modify(true);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(VATStatementReportLine[1], VATReportHeader, GetSimpleSalesVATCode());
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(VATStatementReportLine[2], VATReportHeader, GetReverseChargeVATCode());
        LibraryElecVATSubmission.SetVATCodeReportVATRate(GetReverseChargeVATCode(), LibraryRandom.RandDec(10, 2));
        VATReportMediator.Generate(VATReportHeader);
        LoadFromVATReportSubmissionArchive(TempXMLBuffer, VATReportHeader);
        VerifySubmissionMessageStructureSimpleAndReverseChargeCodes(TempXMLBuffer, VATStatementReportLine);
    end;

    local procedure LoadFromVATReportSubmissionArchive(var TempXMLBuffer: Record "XML Buffer" temporary; VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
        MessageInStream: InStream;
    begin
        VATReportArchive.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.");
        VATReportArchive.CalcFields("Submission Message BLOB");
        VATReportArchive."Submission Message BLOB".CreateInStream(MessageInStream, TextEncoding::UTF8);
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        TempXMLBuffer.LoadFromStream(MessageInStream);
    end;

    local procedure GetSimpleSalesVATCode(): Code[10]
    begin
        exit('3');
    end;

    local procedure GetReverseChargeVATCode(): Code[10]
    begin
        exit('81');
    end;

    local procedure VerifySubmissionMessageStructureSimpleAndReverseChargeCodes(var TempXMLBuffer: Record "XML Buffer" temporary; VATStatementReportLine: array[2] of Record "VAT Statement Report Line")
    begin
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, 'mvaMeldingDto');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'innsending');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'regnskapssystemsreferanse', VATStatementReportLine[1]."VAT Report No.");
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'regnskapssystem');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'systemnavn', 'Microsoft Dynamics 365 Business Central');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'systemversjon', '20.0');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'skattegrunnlagOgBeregnetSkatt');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'skattleggingsperiode');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'periode');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'skattleggingsperiodeToMaaneder', 'januar-februar');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'aar', Format(Date2DMY(WorkDate(), 3)));
        LibraryElecVATSubmission.AssertElementValue(
            TempXMLBuffer, 'fastsattMerverdiavgift', LibraryElecVATSubmission.GetAmountTextRounded(VATStatementReportLine[1].Amount));
        VerifyVATCodeSimpleXmlBlock(
            TempXMLBuffer, VATStatementReportLine[1]."Box No.", VATStatementReportLine[1].Description, VATStatementReportLine[1].Amount);
        VerifyVATCodeComplexXmlBlock(
            TempXMLBuffer, VATStatementReportLine[2]."Box No.", VATStatementReportLine[2].Description, VATStatementReportLine[2].Base, VATStatementReportLine[2].Amount);
        VerifyVATCodeSimpleXmlBlock(
            TempXMLBuffer, VATStatementReportLine[1]."Box No.", VATStatementReportLine[1].Description, -VATStatementReportLine[1].Amount);
    end;

    local procedure VerifyVATCodeSimpleXmlBlock(var TempXMLBuffer: Record "XML Buffer" temporary; BoxNo: Text; Description: Text; Amount: Decimal)
    begin
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'mvaSpesifikasjonslinje');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKode', BoxNo);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKodeRegnskapsystem', Description);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'merverdiavgift', LibraryElecVATSubmission.GetAmountTextRounded(Amount));
    end;

    local procedure VerifyVATCodeComplexXmlBlock(var TempXMLBuffer: Record "XML Buffer" temporary; BoxNo: Text; Description: Text; Base: Decimal; Amount: Decimal)
    var
        VATCode: Record "VAT Code";
    begin
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'mvaSpesifikasjonslinje');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKode', BoxNo);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKodeRegnskapsystem', Description);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'grunnlag', LibraryElecVATSubmission.GetAmountTextRounded(Base));
        VATCode.Get(CopyStr(BoxNo, 1, MaxStrLen(VATCode.Code)));
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'sats', Format(VATCode."VAT Rate For Reporting", 0, '<Integer><Decimals><Comma,,>'));
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'merverdiavgift', LibraryElecVATSubmission.GetAmountTextRounded(Amount));
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
    end;
}