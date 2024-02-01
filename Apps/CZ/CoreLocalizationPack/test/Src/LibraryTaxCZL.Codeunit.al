Codeunit 148003 "Library - Tax CZL"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";

    procedure CloseVATControlReportLines(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        VATCtrlReportHeaderCZL.CloseLines();
    end;

    procedure CreateCommodity(var CommodityCZL: Record "Commodity CZL")
    begin
        CommodityCZL.Init();
        CommodityCZL.Code := LibraryUtility.GenerateRandomCode(CommodityCZL.FieldNo(Code), Database::"Commodity CZL");
        CommodityCZL.Description := CommodityCZL.Code;
        CommodityCZL.Insert(true);
    end;

    procedure CreateCommoditySetup(var CommoditySetupCZL: Record "Commodity Setup CZL"; CommodityCode: Code[10]; ValidFrom: Date; ValidTo: Date; LimitAmount: Decimal)
    begin
        CommoditySetupCZL.Init();
        CommoditySetupCZL."Commodity Code" := CommodityCode;
        CommoditySetupCZL."Valid From" := ValidFrom;
        CommoditySetupCZL."Valid To" := ValidTo;
        CommoditySetupCZL."Commodity Limit Amount LCY" := LimitAmount;
        CommoditySetupCZL.Insert(true);
    end;

    procedure CreateDefaultVATControlReportSections(Force: Boolean)
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if Force then
            VATCtrlReportSectionCZL.DeleteAll();
        CreateDefaultVATControlReportSections();
    end;

    procedure CreateDefaultVATControlReportSections()
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if not VATCtrlReportSectionCZL.IsEmpty then
            exit;

        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'A1', VATCtrlReportSectionCZL."Group By"::"Document No.", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'A2', VATCtrlReportSectionCZL."Group By"::"External Document No.", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'A3', VATCtrlReportSectionCZL."Group By"::"Document No.", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'A5', VATCtrlReportSectionCZL."Group By"::"Section Code", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'A4', VATCtrlReportSectionCZL."Group By"::"Document No.", 'A5');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'B1', VATCtrlReportSectionCZL."Group By"::"External Document No.", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'B3', VATCtrlReportSectionCZL."Group By"::"Section Code", '');
        CreateVATControlReportSection(
          VATCtrlReportSectionCZL, 'B2', VATCtrlReportSectionCZL."Group By"::"External Document No.", 'B3');
    end;

    procedure CreateUnrelPayerServiceSetup()
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
    begin
        UnrelPayerServiceSetupCZL.Reset();
        if not UnrelPayerServiceSetupCZL.FindFirst() then begin
            UnrelPayerServiceSetupCZL.Init();
            UnrelPayerServiceSetupCZL.Insert();
        end;
    end;

    procedure CreateTariffNumber(var TariffNumber: Record "Tariff Number")
    begin
        TariffNumber.Init();
        TariffNumber."No." := LibraryUtility.GenerateRandomCode(TariffNumber.FieldNo("No."), Database::"Tariff Number");
        TariffNumber.Description := TariffNumber."No.";
        TariffNumber.Insert(true);
    end;

    procedure CreateVATAttributeCode(var VATAttributeCodeCZL: Record "VAT Attribute Code CZL"; VATStmtTempName: Code[10])
    var
        AttributeDescriptionTxt: Label '%1 %2', Comment = '%1 = VAT Statement Template Name;%2 = Code', Locked = true;
    begin
        VATAttributeCodeCZL.Init();
        VATAttributeCodeCZL."VAT Statement Template Name" := VATStmtTempName;
        VATAttributeCodeCZL.Code :=
          LibraryUtility.GenerateRandomCode(VATAttributeCodeCZL.FieldNo(Code), Database::"VAT Attribute Code CZL");
        VATAttributeCodeCZL.Description :=
          StrSubstNo(AttributeDescriptionTxt, VATAttributeCodeCZL."VAT Statement Template Name", VATAttributeCodeCZL.Code);
        VATAttributeCodeCZL.Insert(true);
    end;

    procedure CreateVATClause(var VATClause: Record "VAT Clause")
    begin
        VATClause.Init();
        VATClause.Code := LibraryUtility.GenerateRandomCode(VATClause.FieldNo(Code), Database::"VAT Clause");
        VATClause.Validate(Description, LibraryUtility.GenerateRandomText(20));
        VATClause.Validate("Description 2", LibraryUtility.GenerateRandomText(50));
        VATClause.Insert(true);
    end;

    procedure CreateVATControlReport(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        VATCtrlReportHeaderCZL.Init();
        VATCtrlReportHeaderCZL.Insert(true);
    end;

    procedure CreateVATControlReportWithPeriod(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; PeriodNo: Integer; PeriodYear: Integer)
    begin
        CreateVATControlReport(VATCtrlReportHeaderCZL);
        VATCtrlReportHeaderCZL.Validate("Period No.", PeriodNo);
        VATCtrlReportHeaderCZL.Validate(Year, PeriodYear);
        VATCtrlReportHeaderCZL.Modify(true);
    end;

    procedure CreateVATControlReportSection(var VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL"; VATControlReportSectionCode: Code[20]; GroupBy: Option; SectionCode: Code[20])
    begin
        VATCtrlReportSectionCZL.Init();
        VATCtrlReportSectionCZL.Code := VATControlReportSectionCode;
        VATCtrlReportSectionCZL.Description := VATControlReportSectionCode;
        VATCtrlReportSectionCZL."Group By" := GroupBy;
        VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := SectionCode;
        VATCtrlReportSectionCZL.Insert(true);
    end;

    procedure CreateVIESDeclarationHeader(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL.Insert(true);
    end;

    procedure CreateStatReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Reset();
        if not StatutoryReportingSetupCZL.FindFirst() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;
    end;

    procedure GetCompanyOfficialsNo(): Code[20]
    var
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        FindCompanyOfficials(CompanyOfficialCZL);
        exit(CompanyOfficialCZL."No.");
    end;

    procedure GetDateFromLastOpenVATPeriod(): Date
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        FindLastOpenVATPeriod(VATPeriodCZL);
        exit(VATPeriodCZL."Starting Date");
    end;

    procedure GetInvalidVATRegistrationNo(): Text[20]
    begin
        exit('CZ11111111');
    end;

    procedure GetNotPublicBankAccountNo(): Code[30]
    begin
        exit('14-123123123/0100');
    end;

    procedure GetPublicBankAccountNo(): Code[30]
    begin
        exit('86-5211550267/0100');
    end;

    procedure GetSimplifiedTaxDocumentLimit(): Decimal
    var
        StatutoryReportingSetup: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetup.Get();
        exit(StatutoryReportingSetup."Simplified Tax Document Limit");
    end;

    procedure GetValidVATRegistrationNo(): Text[20]
    begin
        exit('CZ25820826'); // Konica Minolta IT Solutions Czech a.s.
    end;

    procedure GetVATPeriodStartingDate(): Date
    var
        VATPeriodCZL: Record "VAT Period CZL";
        VATEntry: Record "VAT Entry";
    begin
        FindFirstOpenVATPeriod(VATPeriodCZL);
        FindFirstOpenVATEntry(VATEntry);

        if VATPeriodCZL."Starting Date" > VATEntry."Posting Date" then
            exit(VATPeriodCZL."Starting Date");
        exit(VATEntry."Posting Date");
    end;

    procedure ExportVIESDeclaration(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"): Text
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        TempVIESDeclarationLineCZL: Record "VIES Declaration Line CZL" temporary;
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        VIESDeclarationCZL: XMLport "VIES Declaration CZL";
        BlobOutStream: OutStream;
    begin
        TempVIESDeclarationLineCZL.DeleteAll();
        TempVIESDeclarationLineCZL.Reset();
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL.FindSet() then
            repeat
                TempVIESDeclarationLineCZL := VIESDeclarationLineCZL;
                TempVIESDeclarationLineCZL.Insert();
            until VIESDeclarationLineCZL.Next() = 0;

        TempBlob.CreateOutStream(BlobOutStream);
        VIESDeclarationCZL.SetHeader(VIESDeclarationHeaderCZL);
        VIESDeclarationCZL.SetLines(TempVIESDeclarationLineCZL);
        VIESDeclarationCZL.SetDestination(BlobOutStream);
        VIESDeclarationCZL.Export();

        exit(FileManagement.BLOBExport(TempBlob, 'Default.xml', false));
    end;

    procedure FindCompanyOfficials(var CompanyOfficialCZL: Record "Company Official CZL")
    begin
        CompanyOfficialCZL.Reset();
        CompanyOfficialCZL.FindFirst();
    end;

    local procedure FindFirstOpenVATEntry(var VATEntry: Record "VAT Entry")
    begin
        VATEntry.Reset();
        VATEntry.SetRange(Closed, false);
        VATEntry.FindFirst();
    end;

    procedure FindFirstOpenVATPeriod(var VATPeriodCZL: Record "VAT Period CZL")
    begin
        VATPeriodCZL.Reset();
        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindFirst();
    end;

    procedure FindLastOpenVATPeriod(var VATPeriodCZL: Record "VAT Period CZL")
    begin
        VATPeriodCZL.Reset();
        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindLast();
    end;

    procedure FindVATStatementTemplate(var VATStatementTemplate: Record "VAT Statement Template")
    begin
        VATStatementTemplate.Reset();
        VATStatementTemplate.FindFirst();
    end;

    procedure PrintDocumentationForVAT(ShowRequestPage: Boolean)
    begin
        Commit();
        Report.Run(Report::"Documentation for VAT CZL", ShowRequestPage, false);
    end;

    procedure PrintVATStatement(var VATStatementLine: Record "VAT Statement Line"; ShowRequestPage: Boolean)
    begin
        Report.Run(Report::"VAT Statement", ShowRequestPage, false, VATStatementLine);
    end;

    procedure PrintTestVATControlReport(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        Commit();
        VATCtrlReportHeaderCZL.PrintTestReport();
    end;

    procedure PrintTestVIESDeclaration(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        Commit();
        VIESDeclarationHeaderCZL.PrintTestReport();
    end;

    procedure ReleaseVATControlReport(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        Codeunit.Run(Codeunit::"VAT Ctrl. Report Release CZL", VATCtrlReportHeaderCZL);
    end;

    procedure ReleaseVIESDeclaration(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        Codeunit.Run(Codeunit::"Release VIES Declaration CZL", VIESDeclarationHeaderCZL);
    end;

    procedure ReopenVATPeriod(StartingDate: Date)
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.Reset();
        VATPeriodCZL.Get(StartingDate);
        VATPeriodCZL.Validate(Closed, false);
        VATPeriodCZL.Modify();
    end;

    procedure ReopenVIESDeclaration(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    var
        ReleaseVIESDeclarationCZL: Codeunit "Release VIES Declaration CZL";
    begin
        ReleaseVIESDeclarationCZL.Reopen(VIESDeclarationHeaderCZL);
    end;

    procedure RunCreateVATPeriod()
    begin
        Commit();
        Report.Run(Report::"Create VAT Period CZL", true, false);
    end;

    procedure RunExportVATCtrlReport(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempBlob: Codeunit "Temp Blob")
    begin
        VATCtrlReportHeaderCZL.ExportToXMLBlobCZL(TempBlob);
    end;

    procedure RunExportVATStatement(StmtTempName: Code[10]; StmtName: Code[10]; var TempBlob: Codeunit "Temp Blob")
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        VATStatementName.SetRange("Statement Template Name", StmtTempName);
        VATStatementName.SetRange(Name, StmtName);
        VATStatementName.FindFirst();
        VATStatementName.ExportToXMLBlobCZL(TempBlob);
    end;

    procedure RunGetCorrectionVIESDeclarationLines(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    var
        VIESDeclarationLinesCZL: Page "VIES Declaration Lines CZL";
    begin
        VIESDeclarationLinesCZL.SetToDeclaration(VIESDeclarationHeaderCZL);
        VIESDeclarationLinesCZL.LookupMode := true;
        if VIESDeclarationLinesCZL.RunModal() = Action::LookupOK then
            VIESDeclarationLinesCZL.CopyLineToDeclaration();
    end;

    procedure RunnreliablePayerGetAll()
    begin
        Commit();
        Report.Run(Report::"Unreliable Payer Get All CZL");
    end;

    procedure RunSuggestVIESDeclarationLines(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        Commit();
        VIESDeclarationHeaderCZL.SetRecFilter();
        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);
    end;

    procedure RunUnreliablePayerStatusForVendor(var Vendor: Record Vendor)
    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        UnreliablePayerMgtCZL.ImportUnrPayerStatusForVendor(Vendor);
    end;

    procedure SelectVATStatementName(var VATStatementName: Record "VAT Statement Name")
    var
        VATStatementTemplate: Code[10];
    begin
        VATStatementTemplate := SelectVATStatementTemplate();
        SelectVATStatementName(VATStatementName, VATStatementTemplate);
    end;

    procedure SelectVATStatementName(var VATStatementName: Record "VAT Statement Name"; VATStatementTemplate: Code[10])
    begin
        VATStatementName.SetRange("Statement Template Name", VATStatementTemplate);

        if not VATStatementName.FindFirst() then
            LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate);
    end;


    procedure SelectVATStatementTemplate(): Code[10]
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.SetRange("Page ID", PAGE::"VAT Statement");

        if not VATStatementTemplate.FindFirst() then
            LibraryERM.CreateVATStatementTemplate(VATStatementTemplate);

        exit(VATStatementTemplate.Name);
    end;

    procedure SetAttributeCode(var VATStatementLine: Record "VAT Statement Line"; AttributeCode: Code[20])
    begin
        VATStatementLine."Attribute Code CZL" := AttributeCode;
        VATStatementLine.Modify();
    end;

    procedure SetCompanyType(CompanyType: Option)
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL."Company Type" := CompanyType;
        StatutoryReportingSetupCZL.Modify();
    end;

    procedure SetVATControlReportInformation()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL."VAT Control Report XML Format" := Enum::"VAT Ctrl. Report Format CZL"::"03_01_03";
        StatutoryReportingSetupCZL."VAT Control Report Nos." := LibraryERM.CreateNoSeriesCode();
        StatutoryReportingSetupCZL."Simplified Tax Document Limit" := 10000;
        StatutoryReportingSetupCZL.Modify();
    end;

    procedure SetVATStatementInformation()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No." := GetCompanyOfficialsNo();
        StatutoryReportingSetupCZL."VAT Stat. Filled Employee No." := GetCompanyOfficialsNo();
        StatutoryReportingSetupCZL."VAT Statement Country Name" := 'CESKO';
        StatutoryReportingSetupCZL.Modify();
    end;

    procedure SetVIESStatementInformation()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL."Tax Office Number" := '461';
        StatutoryReportingSetupCZL."Tax Office Region Number" := '3003';
        StatutoryReportingSetupCZL."VIES Declaration Nos." := LibraryERM.CreateNoSeriesCode();
        StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Corporate;
        StatutoryReportingSetupCZL."Tax Payer Status" := StatutoryReportingSetupCZL."Tax Payer Status"::Payer;
        StatutoryReportingSetupCZL."VIES Number of Lines" := 20;
        StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
        StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";
        StatutoryReportingSetupCZL.Modify();
    end;

    procedure SetUnreliablePayerWebService()
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        UnrelPayerServiceSetupCZL.Get();
        UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" := UnreliablePayerMgtCZL.GetUnreliablePayerServiceURL();
        UnrelPayerServiceSetupCZL.Modify();
    end;

    procedure SetUseVATDate(UseVATDate: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
#if not CLEAN22
#pragma warning disable AL0432
        GeneralLedgerSetup."Use VAT Date CZL" := UseVATDate;
#pragma warning restore AL0432
#endif
        GeneralLedgerSetup."VAT Reporting Date Usage" := Enum::"VAT Reporting Date Usage"::Disabled;
        if UseVATDate then
            GeneralLedgerSetup."VAT Reporting Date Usage" := Enum::"VAT Reporting Date Usage"::Enabled;
        GeneralLedgerSetup.Modify();
    end;

    procedure SetXMLFormat(var VATStatementTemplate: Record "VAT Statement Template"; XMLFormat: Enum "VAT Statement XML Format CZL")
    begin
        VATStatementTemplate."XML Format CZL" := XMLFormat;
        VATStatementTemplate.Modify();
    end;

    procedure SuggestVATControlReportLines(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        VATCtrlReportHeaderCZL.SuggestLines();
    end;
}

