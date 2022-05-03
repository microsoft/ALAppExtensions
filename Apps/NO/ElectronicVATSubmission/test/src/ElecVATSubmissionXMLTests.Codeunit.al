codeunit 148131 "Elec. VAT Submission XML Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryElecVATSubmission: Codeunit "Library - Elec. VAT Submission";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission] [XML]
    end;

    [Test]
    procedure SubmissionMessageStructureMultipleCodes()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: array[3] of Record "VAT Statement Report Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATReportMediator: Codeunit "VAT Report Mediator";
        VATCode: Code[10];
    begin
        // [SCENARIO 418697] The structure of the XML submission message is correct when using mix of codes with different setup

        Initialize();
        SetVATRegNoInCompanyInfo(GetVATRegNoWithLetters());
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Month);
        VATReportHeader.Validate(KID, LibraryUtility.GenerateGUID());
        VATReportHeader.Modify(true);
        // Simple VAT code
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine[1], VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        // VAT code with specification and note
        VATCode := LibraryElecVATSubmission.CreateSimpleVATCode();
        LibraryElecVATSubmission.SetVATSpecificationAndNoteToVATCode(VATCode);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine[2], VATReportHeader, VATCode);
        // Reverse charge VAT code
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(VATStatementReportLine[3], VATReportHeader, GetReverseChargeVATCode());
        LibraryElecVATSubmission.SetVATCodeReportVATRate(GetReverseChargeVATCode(), LibraryRandom.RandDec(10, 2));
        VATReportMediator.Generate(VATReportHeader);
        LoadFromVATReportSubmissionArchive(TempXMLBuffer, VATReportHeader);
        VerifySubmissionMessageStructureSimpleAndReverseChargeCodesFirstMonth(TempXMLBuffer, VATReportHeader, VATStatementReportLine);
    end;

    [Test]
    procedure VATReturnSubmissionStructure()
    var
        VATReportHeader: Record "VAT Report Header";
        TempXMLBuffer: Record "XML Buffer" temporary;
        ElecVATCreateContent: Codeunit "Elec. VAT Create Content";
    begin
        // [SCENARIO 418697] The structure of the XML submission message is correct when using mix of codes with different setup

        Initialize();
        SetVATRegNoInCompanyInfo(GetVATRegNoWithLetters());
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Month);
        TempXMLBuffer.LoadFromText(ElecVATCreateContent.CreateVATReturnSubmissionContent(VATReportHeader));
        VerifyVATReturnSubmissionStructure(TempXMLBuffer);
    end;

    [Test]
    procedure XmlRequestWithBiMonthlyPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Bi-Monthly" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::"Bi-Monthly");
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeToMaaneder', 'januar-februar');
    end;

    [Test]
    procedure XmlRequestWithHalfMonthPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Half-Month" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::"Half-Month");
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeHalvMaaned', 'foerste halvdel januar');
    end;

    [Test]
    procedure XmlRequestWithHalfYearPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Half-Year" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::"Half-Year");
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeSeksMaaneder', 'januar-juni');
    end;

    [Test]
    procedure XmlRequestWithQuarterPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Quarter" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Quarter);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeTreMaaneder', 'januar-mars');
    end;

    [Test]
    procedure XmlRequestWithWeeklyPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Weekly" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Weekly);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeUke', 'uke 1');
    end;

    [Test]
    procedure XmlRequestWithYearPeriodType()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 418697] The XML request with "Year" period type is correct

        Initialize();
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Year);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader, 'skattleggingsperiodeAar', 'aarlig');
    end;

    [Test]
    procedure VATNoteOfVATReturnLineExportsToXml()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 433237] The value of the "Note" field from the VAT return line exports to the xml file

        Initialize();
        LibraryElecVATSubmission.SetReportVATNoteInVATReportSetup(true);
        LibraryElecVATSubmission.InsertElecVATReportHeader(VATReportHeader);
        SetPeriodTypeWithFirstPeriodToVATReport(VATReportHeader, VATReportHeader."Period Type"::Month);
        LibraryElecVATSubmission.InsertVATStatementReportLineWithBoxNo(
            VATStatementReportLine, VATReportHeader, LibraryElecVATSubmission.CreateSimpleVATCode());
        VATStatementReportLine.Validate(Note, LibraryUtility.GenerateGUID());
        VATStatementReportLine.Modify(true);
        VerifyVATNoteValueInSubmissionMessage(VATReportHeader, VATStatementReportLine.Note);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
        LibrarySetupStorage.SaveCompanyInformation();
        LibrarySetupStorage.Save(Database::"VAT Report Setup");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Elec. VAT Submission XML Tests");
    end;

    local procedure SetPeriodTypeWithFirstPeriodToVATReport(var VATReportHeader: Record "VAT Report Header"; PeriodType: Integer)
    begin
        VATReportHeader.Validate("Period Year", Date2DMY(WorkDate(), 3));
        VATReportHeader.Validate("Period Type", PeriodType);
        VATReportHeader.Validate("Period No.", 1);
        VATReportHeader.Modify(true);
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

    local procedure GetReverseChargeVATCode(): Code[10]
    begin
        exit('81');
    end;

    local procedure SetVATRegNoInCompanyInfo(NewVATRegNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := NewVATRegNo;
        CompanyInformation.Modify(true);
    end;

    local procedure GetVATRegNoWithLetters(): Text[20]
    begin
        exit('NO 123456789 MVA');
    end;

    local procedure GetVATRegNoOnlyDigits(): Text[20]
    begin
        exit('123456789');
    end;

    local procedure VerifySubmissionMessageStructureSimpleAndReverseChargeCodesFirstMonth(var TempXMLBuffer: Record "XML Buffer" temporary; VATReportHeader: Record "VAT Report Header"; VATStatementReportLine: array[3] of Record "VAT Statement Report Line")
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
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'skattleggingsperiodeMaaned', 'januar');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'aar', Format(Date2DMY(WorkDate(), 3)));
        // The third reverse charge code does not affect the total amount
        LibraryElecVATSubmission.AssertElementValue(
            TempXMLBuffer, 'fastsattMerverdiavgift',
            LibraryElecVATSubmission.GetAmountTextRounded(VATStatementReportLine[1].Amount + VATStatementReportLine[2].Amount));
        VerifyVATCodeSimpleXmlBlock(
            TempXMLBuffer, VATStatementReportLine[1]."Box No.", VATStatementReportLine[1].Description, VATStatementReportLine[1].Amount);
        VerifyVATCodeWithSpecAndNoteXmlBlock(
            TempXMLBuffer, VATStatementReportLine[2]."Box No.", VATStatementReportLine[2].Description, VATStatementReportLine[2].Amount);
        VerifyVATCodeComplexXmlBlock(
            TempXMLBuffer, VATStatementReportLine[3]."Box No.", VATStatementReportLine[3].Description, VATStatementReportLine[3].Base, VATStatementReportLine[3].Amount);
        VerifyVATCodeSimpleXmlBlock(
            TempXMLBuffer, VATStatementReportLine[3]."Box No.", VATStatementReportLine[3].Description, -VATStatementReportLine[3].Amount);
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'betalingsinformasjon');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'kundeIdentifikasjonsnummer', VATReportHeader.KID);
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'skattepliktig');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'organisasjonsnummer', GetVATRegNoOnlyDigits());
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'meldingskategori', 'alminnelig');
    end;

    local procedure VerifyVATReturnSubmissionStructure(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, 'mvaMeldingInnsending');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'norskIdentifikator');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'organisasjonsnummer', GetVATRegNoOnlyDigits());
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'skattleggingsperiode');
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'periode');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'skattleggingsperiodeMaaned', 'januar');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'aar', Format(Date2DMY(WorkDate(), 3)));
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'meldingskategori', 'alminnelig');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'innsendingstype', 'komplett');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'instansstatus', 'default');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'opprettetAv', UserSecurityId());
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'opprettingstidspunkt', TypeHelper.GetCurrUTCDateTimeISO8601());
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'vedlegg');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'vedleggstype', 'mva-melding');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'kildegruppe', 'sluttbrukersystem');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'opprettetAv', UserSecurityId());
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'opprettingstidspunkt', TypeHelper.GetCurrUTCDateTimeISO8601());
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'vedleggsfil', '');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'filnavn', 'melding_xml');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'filekstensjon', 'xml');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'filinnhold', '-');

    end;

    local procedure VerifyVATCodeSimpleXmlBlock(var TempXMLBuffer: Record "XML Buffer" temporary; BoxNo: Text; Description: Text; Amount: Decimal)
    begin
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'mvaSpesifikasjonslinje');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKode', BoxNo);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKodeRegnskapsystem', Description);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'merverdiavgift', LibraryElecVATSubmission.GetAmountTextRounded(Amount));
    end;

    local procedure VerifyVATCodeWithSpecAndNoteXmlBlock(var TempXMLBuffer: Record "XML Buffer" temporary; BoxNo: Text; Description: Text; Amount: Decimal)
    var
        VATCode: Record "VAT Code";
        VATSpecification: Record "VAT Specification";
        VATNote: Record "VAT Note";
    begin
        VATCode.Get(CopyStr(BoxNo, 1, MaxStrLen(VATCode.Code)));
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'mvaSpesifikasjonslinje');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKode', BoxNo);
        VATSpecification.Get(VATCode."VAT Specification Code");
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'spesifikasjon', VATSpecification."VAT Report Value");
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'mvaKodeRegnskapsystem', Description);
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'merverdiavgift', LibraryElecVATSubmission.GetAmountTextRounded(Amount));
        VATNote.Get(VATCode."VAT Note Code");
        LibraryElecVATSubmission.AssertElementName(TempXMLBuffer, 'merknad');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'utvalgtMerknad', VATNote."VAT Report Value");
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

    local procedure VerifyPeriodXMLNodesInSubmissionMessage(VATReportHeader: Record "VAT Report Header"; PeriodType: Text; PeriodText: Text)
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATReportMediator: Codeunit "VAT Report Mediator";
    begin
        VATReportMediator.Generate(VATReportHeader);
        LoadFromVATReportSubmissionArchive(TempXMLBuffer, VATReportHeader);
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, 'mvaMeldingDto/skattegrunnlagOgBeregnetSkatt/skattleggingsperiode/periode');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, PeriodType, PeriodText);
    end;

    local procedure VerifyVATNoteValueInSubmissionMessage(VATReportHeader: Record "VAT Report Header"; VATNoteValue: Text)
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        VATReportMediator: Codeunit "VAT Report Mediator";
    begin
        VATReportMediator.Generate(VATReportHeader);
        LoadFromVATReportSubmissionArchive(TempXMLBuffer, VATReportHeader);
        TempXMLBuffer.FindNodesByXPath(
            TempXMLBuffer, 'mvaMeldingDto/skattegrunnlagOgBeregnetSkatt/mvaSpesifikasjonslinje/merknad');
        LibraryElecVATSubmission.AssertElementValue(TempXMLBuffer, 'beskrivelse', VATNoteValue);
        TempXMLBuffer.FindNodesByXPath(
            TempXMLBuffer, 'mvaMeldingDto/skattegrunnlagOgBeregnetSkatt/mvaSpesifikasjonslinje/merknad/utvalgtMerknad');
        Assert.RecordCount(TempXMLBuffer, 0);
    end;
}
