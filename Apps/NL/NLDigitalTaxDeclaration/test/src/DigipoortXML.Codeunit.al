codeunit 148000 "Digipoort XML"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryVATReport: Codeunit "Library - VAT Report";
        LibraryXMLReadServer: Codeunit "Library - XML Read OnServer";
        IsInitialized: Boolean;
        ReportGeneratedMsg: Label 'The report has been successfully generated.';
        XbrliXbrlTok: Label 'xbrli:xbrl';
        AttrBdITok: Label 'xmlns:bd-i';
        AttrBdObTok: Label 'xmlns:bd-ob';

    [Test]
    [HandlerFunctions('VATStatementRequestPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure VATXBRLDocVerify()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        SavedVATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        // [FEATURE] [XML] [UI]
        // [SCENARIO] Verify XBLR document content for VAT Return with setup for Digipoort format
        // [SCENARIO 364897] Generated XML must contains correct startDate and endDate

        Initialize();

        // [GIVEN] Local Currency is "Euro" in General Ledger Setup that meets the validation rules
        SetLocalCurrencyEuro();
        // [GIVEN] VAT Return with "Additional Information" and lines calculated by VAT statement that meets the validation rules
        InitializeElecTaxDeclSetup();
        VATReportsConfiguration.SetRange("Content Codeunit ID", COdeunit::"Create Elec. Tax Declaration");
        LibraryVATReport.FindVATReturnConfiguration(VATReportsConfiguration);
        SavedVATReportsConfiguration := VATReportsConfiguration;
        VATReportsConfiguration.Validate("Submission Codeunit ID", 0);
        VATReportsConfiguration.Modify();
        // [GIVEN] VAT Report Header with StartDate = 01-01-2020 and EndDate = 31-01-2020
        CreateVATReturn(VATReportHeader, VATReportsConfiguration."VAT Report Version");
        LibraryVariableStorage.Enqueue(ReportGeneratedMsg);

        // [WHEN] Generate XBLR for VAT Return
        GenerateContent(VATReportHeader);

        // [THEN] XBLR content generats correctly for Tax Declaration
        // [THEN] "period/startDate" = 01-01-2020
        // [THEN] "period/endDate" = 31-01-2020
        VerifyVATXBLRDocContent(VATReportHeader);

        LibraryVariableStorage.AssertEmpty();

        // Tear down
        VATReportsConfiguration := SavedVATReportsConfiguration;
    end;

    local procedure SetLocalCurrencyEuro()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Local Currency", GeneralLedgerSetup."Local Currency"::Euro);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure GenerateContent(VATReportHeader: Record "VAT Report Header") TempFile: Text
    var
        VATReturnPage: TestPage "VAT Report";
    begin
        VATReturnPage.OpenEdit();
        VATReturnPage.FILTER.SetFilter("No.", VATReportHeader."No.");
        VATReturnPage.Release.Invoke();
        VATReturnPage.Generate.Invoke();
        VATReturnPage.Close();
    end;

    local procedure VerifyVATXBLRDocContent(VATReportHeader: Record "VAT Report Header")
    var
        VATReportArchive: Record "VAT Report Archive";
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
        CompanyInfo: Record "Company Information";
        ElecTaxDeclarationMgt: Codeunit "Elec. Tax Declaration Mgt.";
        SubmissionMessageInStream: InStream;
        Nodes: array[24] of Text;
        Index: Integer;
    begin
        VATReportArchive.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.");
        VATReportArchive.CalcFields("Submission Message BLOB");
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue(), 'No submission message exists for VAT return.');

        ElecTaxDeclarationSetup.Get();
        CompanyInfo.Get();

        VATReportArchive."Submission Message BLOB".CreateInStream(SubmissionMessageInStream, TextEncoding::UTF8);
        LibraryXMLReadServer.LoadXMLDocFromInStream(SubmissionMessageInStream);
        LibraryXMLReadServer.VerifyAttributeAbsence(XbrliXbrlTok, AttrBdObTok);
        LibraryXMLReadServer.VerifyAttributeValue(XbrliXbrlTok, AttrBdITok, ElecTaxDeclarationMgt.GetBDDataEndpoint());
        LibraryXMLReadServer.VerifyAttributeValueInSubtree(
          XbrliXbrlTok, 'link:schemaRef', 'xlink:href', ElecTaxDeclarationMgt.GetVATDeclarationSchemaEndpoint());
        LibraryXMLReadServer.VerifyNodeValueInSubtree('xbrli:context', 'xbrli:identifier', DelStr(CompanyInfo."VAT Registration No.", 1, 2));
        LibraryXMLReadServer.VerifyNodeValueInSubtree(
          'xbrli:period', 'xbrli:startDate', Format(VATReportHeader."Start Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        LibraryXMLReadServer.VerifyNodeValueInSubtree(
          'xbrli:period', 'xbrli:endDate', Format(VATReportHeader."End Date", 0, '<Year4>-<Month,2>-<Day,2>'));

        case ElecTaxDeclarationSetup."VAT Contact Type" of
            ElecTaxDeclarationSetup."VAT Contact Type"::"Tax Payer":
                begin
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactType', 'BPL');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactInitials', 'JHR');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactPrefix', 'Joe');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactSurname', 'Harris Roberts');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactTelephoneNumber', '6549-3216-7415');
                end;
            ElecTaxDeclarationSetup."VAT Contact Type"::Agent:
                begin
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactType', 'INT');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactInitials', 'JDS');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactPrefix', 'John');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactSurname', 'Doe Smith');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:ContactTelephoneNumber', '1972-3216-7415');
                    LibraryXMLReadServer.VerifyNodeValueInSubtree(XbrliXbrlTok, 'bd-i:TaxConsultantNumber', '123456789');
                end;
        end;

        Nodes[1] := 'bd-i:InstallationDistanceSalesWithinTheEC';
        Nodes[2] := 'bd-i:SmallEntrepreneurProvisionReduction';
        Nodes[3] := 'bd-i:SuppliesServicesNotTaxed';
        Nodes[4] := 'bd-i:SuppliesToCountriesOutsideTheEC';
        Nodes[5] := 'bd-i:SuppliesToCountriesWithinTheEC';
        Nodes[6] := 'bd-i:TaxedTurnoverPrivateUse';
        Nodes[7] := 'bd-i:TaxedTurnoverSuppliesServicesGeneralTariff';
        Nodes[8] := 'bd-i:TaxedTurnoverSuppliesServicesOtherRates';
        Nodes[9] := 'bd-i:TaxedTurnoverSuppliesServicesReducedTariff';
        Nodes[10] := 'bd-i:TurnoverFromTaxedSuppliesFromCountriesOutsideTheEC';
        Nodes[11] := 'bd-i:TurnoverFromTaxedSuppliesFromCountriesWithinTheEC';
        Nodes[12] := 'bd-i:TurnoverSuppliesServicesByWhichVATTaxationIsTransferred';
        Nodes[13] := 'bd-i:ValueAddedTaxOnInput';
        Nodes[14] := 'bd-i:ValueAddedTaxOnSuppliesFromCountriesOutsideTheEC';
        Nodes[15] := 'bd-i:ValueAddedTaxOnSuppliesFromCountriesWithinTheEC';
        Nodes[16] := 'bd-i:ValueAddedTaxOwed';
        Nodes[17] := 'bd-i:ValueAddedTaxOwedToBePaidBack';
        Nodes[18] := 'bd-i:ValueAddedTaxPrivateUse';
        Nodes[19] := 'bd-i:ValueAddedTaxSuppliesServicesByWhichVATTaxationIsTransferred';
        Nodes[20] := 'bd-i:ValueAddedTaxSuppliesServicesGeneralTariff';
        Nodes[21] := 'bd-i:ValueAddedTaxSuppliesServicesOtherRates';
        Nodes[22] := 'bd-i:ValueAddedTaxSuppliesServicesReducedTariff';

        for Index := 1 to 22 do begin
            LibraryXMLReadServer.GetNodeValueInSubtree(XbrliXbrlTok, Nodes[Index]); // Don't care about value, just verify existence
            LibraryXMLReadServer.VerifyAttributeValueInSubtree(XbrliXbrlTok, Nodes[Index], 'decimals', 'INF');
            LibraryXMLReadServer.VerifyAttributeValueInSubtree(XbrliXbrlTok, Nodes[Index], 'contextRef', 'Msg');
            LibraryXMLReadServer.VerifyAttributeValueInSubtree(XbrliXbrlTok, Nodes[Index], 'unitRef', 'EUR');
        end;

        LibraryXMLReadServer.VerifyXMLDeclaration('1.0', 'UTF-8', 'yes');
    end;

    local procedure Initialize()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        LibrarySetupStorage.Restore();
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Digipoort XML");
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        if IsInitialized then
            exit;

        LibrarySetupStorage.Save(Database::"General Ledger Setup");
        IsInitialized := true;
    end;

    local procedure InitializeElecTaxDeclSetup()
    var
        ElecTaxDeclSetup: Record "Elec. Tax Declaration Setup";
        CompanyInfo: Record "Company Information";
    begin
        ElecTaxDeclSetup.Get();
        ElecTaxDeclSetup."VAT Contact Type" := ElecTaxDeclSetup."VAT Contact Type"::"Tax Payer";
        ElecTaxDeclSetup."ICP Contact Type" := ElecTaxDeclSetup."ICP Contact Type"::"Tax Payer";
        ElecTaxDeclSetup."Tax Payer Contact Name" := 'Joe Harris Roberts';
        ElecTaxDeclSetup."Tax Payer Contact Phone No." := '6549-3216-7415';
        ElecTaxDeclSetup."Digipoort Client Cert. Name" := 'abcde';
        ElecTaxDeclSetup."Digipoort Service Cert. Name" := 'abcde';
        ElecTaxDeclSetup."Digipoort Delivery URL" := 'http://url.com';
        ElecTaxDeclSetup."Digipoort Status URL" := 'http://url.com';
        ElecTaxDeclSetup.Modify(true);

        CompanyInfo.Get();
        CompanyInfo.Address := 'Microsoft Avenue 1234';
        CompanyInfo.City := 'Seattle';
        CompanyInfo."Post Code" := '5678';
        CompanyInfo.Modify(true);
    end;

    local procedure CreateVATReturn(var VATReportHeader: Record "VAT Report Header"; VATReportVersion: Code[10])
    var
        VATReturnPage: TestPage "VAT Report";
    begin
        CreateVATReportHeader(VATReportHeader);
        VATReportHeader.Validate("VAT Report Version", VATReportVersion);
        VATReportHeader.Validate("Additional Information", 'OB-' + LibraryUtility.GenerateGUID());
        VATReportHeader.Modify(true);
        VATReturnPage.OpenEdit();
        VATReturnPage.FILTER.SetFilter("No.", VATReportHeader."No.");
        Commit();
        LibraryVariableStorage.Enqueue(VATReportHeader."Start Date");
        LibraryVariableStorage.Enqueue(VATReportHeader."End Date");
        VATReturnPage.SuggestLines.Invoke();
        VATReturnPage.Release.Invoke();
        VATReturnPage.Close();
    end;

    local procedure CreateVATReportHeader(var VATReportHeader: Record "VAT Report Header")
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        LibraryVATReport.CreateVATReturn(VATReportHeader);
        VATReportHeader.Validate("Start Date", WorkDate());
        VATReportHeader.Validate("End date", WorkDate() + 1);
        VATStatementName.FindFirst();
        VATReportHeader.Validate("Statement Template Name", VATStatementName."Statement Template Name");
        VATReportHeader.Validate("Statement Name", VATStatementName.Name);
        VATReportHeader.Modify(true);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATStatementRequestPageHandler(var VATReportRequestPage: TestRequestPage "VAT Report Request Page")
    var
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
    begin
        VATReportRequestPage."Start Date".SetValue(LibraryVariableStorage.DequeueDate());
        VATReportRequestPage."End Date".SetValue(LibraryVariableStorage.DequeueDate());
        VATReportRequestPage.Selection.SetValue(Selection::Open);
        VATReportRequestPage.PeriodSelection.SetValue(PeriodSelection::"Within Period");
        VATReportRequestPage.Ok().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;
}

