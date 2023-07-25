codeunit 139512 "SAF-T Tests Helper"
{
    EventSubscriberInstance = Manual;

    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        DefaultSAFTLbl: label 'DEFAULT SAF-T';

    procedure SetupSAFT()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATReportingCode: Record "VAT Reporting Code";
        CompanyInformation: Record "Company Information";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        CreateStandDataSAFTTest: Codeunit "Create Stand. Data SAF-T Test";
    begin
        AuditFileExportSetup.InitSetup(Enum::"Audit File Export Format"::SAFT);
        AuditFileExportSetup.UpdateStandardAccountType("Standard Account Type"::"Standard Account SAF-T");
        AuditFileExportSetup.Get();
        AuditFileExportSetup.Validate("SAF-T Modification", Enum::"SAF-T Modification"::Test);
        AuditFileExportSetup.Modify(true);

        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::GeneralLedgerAccounts, "Audit File Export Data Class"::MasterData);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Customers, "Audit File Export Data Class"::MasterData);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Suppliers, "Audit File Export Data Class"::MasterData);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::TaxTable, "Audit File Export Data Class"::MasterData);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::GeneralLedgerEntries, "Audit File Export Data Class"::GeneralLedgerEntries);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::SalesInvoices, "Audit File Export Data Class"::SourceDocuments);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::PurchaseInvoices, "Audit File Export Data Class"::SourceDocuments);
        EnableAuditFileExportDataTypeSetup(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Payments, "Audit File Export Data Class"::SourceDocuments);

        CompanyInformation.Get();
        CompanyInformation.Validate("Contact No. SAF-T", LibraryHumanResource.CreateEmployeeNo());
        CompanyInformation.Modify(true);

        AuditFileExportFormatSetup.InitSetup("Audit File Export Format"::SAFT, SAFTDataMgt.GetZipFileName(), true);

        CreateStandDataSAFTTest.LoadStandardTaxCodes();
        VATPostingSetup.FindFirst();
        VATReportingCode.FindFirst();
        VATPostingSetup.Validate("Sale VAT Reporting Code", VATReportingCode.Code);
        VATPostingSetup.Modify(true);
    end;

    local procedure EnableAuditFileExportDataTypeSetup(AuditFileExportFormat: Enum "Audit File Export Format"; ExportDataType: Enum "Audit File Export Data Type"; ExportDataClass: Enum "Audit File Export Data Class")
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.Validate("Audit File Export Format", AuditFileExportFormat);
        AuditExportDataTypeSetup.Validate("Export Data Type", ExportDataType);
        AuditExportDataTypeSetup.Validate("Export Data Class", ExportDataClass);
        AuditExportDataTypeSetup.Validate("Export Enabled", true);
        AuditExportDataTypeSetup.Insert(true);
    end;

    procedure CreateGLAccMappingWithLine(var GLAccountMappingLine: Record "G/L Account Mapping Line")
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        CreateStandDataSAFTTest: Codeunit "Create Stand. Data SAF-T Test";
        StandardAccountType: enum "Standard Account Type";
        GLAccountNo: Code[20];
    begin
        StandardAccountType := "Standard Account Type"::"Standard Account SAF-T";

        GLAccountMappingHeader.SetRange(Code, DefaultSAFTLbl);
        GLAccountMappingHeader.DeleteAll(true);

        // create Standard Account for each G/L Account. StandardAccount."No."" = GLAccount."No."
        CreateStandDataSAFTTest.LoadStandardAccounts("Standard Account Type"::"Standard Account SAF-T");

        GLAccountMappingHeader.Init();
        GLAccountMappingHeader.Validate(Code, DefaultSAFTLbl);
        GLAccountMappingHeader.Validate("Standard Account Type", StandardAccountType);
        GLAccountMappingHeader.Validate("Accounting Period", CalcDate('<-CY>', WorkDate()));
        GLAccountMappingHeader.Insert(true);

        GLAccountNo := LibraryERM.CreateGLAccountNo();
        CreateStandardAccount(StandardAccountType, GLAccountNo, 'Test Account');

        // create mapping lines with empty Standard Account No.
        AuditMappingHelper.Run(GLAccountMappingHeader);

        // map all accounts - set Standard Account No. for each mapping line
        AuditMappingHelper.MatchChartOfAccounts(GLAccountMappingHeader);
        GLAccountMappingLine.Get(GLAccountMappingHeader.Code, GLAccountNo);
    end;

    procedure CreateAuditFileExportDoc(var AuditFileExportHeader: Record "Audit File Export Header"; StartingDate: Date; EndingDate: Date; ArchiveToZip: Boolean)
    begin
        AuditFileExportHeader.Init();
        AuditFileExportHeader.Insert(true);
        AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::SAFT);
        AuditFileExportHeader.Validate("G/L Account Mapping Code", DefaultSAFTLbl);
        AuditFileExportHeader.Validate("Starting Date", StartingDate);
        AuditFileExportHeader.Validate("Ending Date", EndingDate);
        AuditFileExportHeader.Validate("Header Comment", LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate(Contact, LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate("Parallel Processing", false);
        AuditFileExportHeader.Validate("Split By Date", false);
        AuditFileExportHeader.Validate("Split By Month", false);
        AuditFileExportHeader.Validate("Export Currency Information", true);
        AuditFileExportHeader.Validate("Archive to Zip", ArchiveToZip);
        AuditFileExportHeader.Modify(true);
    end;

    procedure CreateStandardAccount(StandardAccountType: Enum "Standard Account Type"; StandardAccountNo: Code[20]; StandardAccountDescription: Text[250])
    var
        StandardAccount: Record "Standard Account";
    begin
        StandardAccount.Init();
        StandardAccount.Type := StandardAccountType;
        StandardAccount."No." := StandardAccountNo;
        StandardAccount.Description := StandardAccountDescription;
        StandardAccount.Insert();
    end;

    procedure StartExport(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
    end;
#if not CLEAN23
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnInitializeFeatureDataUpdateStatus', '', false, false)]
    local procedure EnableSIEFeatureOnInitializeFeatureDataUpdateStatus(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; var InitializeHandled: Boolean)
    var
        FeatureKey: Record "Feature Key";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> SAFTDataMgt.GetSAFTAuditFileExportFeatureKeyId() then
            exit;

        if FeatureDataUpdateStatus."Company Name" <> CopyStr(CompanyName(), 1, MaxStrLen(FeatureDataUpdateStatus."Company Name")) then
            exit;

        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Enabled;

        FeatureKey.Get(FeatureDataUpdateStatus."Feature Key");
        FeatureKey.Enabled := FeatureKey.Enabled::"All Users";
        FeatureKey.Modify();
        InitializeHandled := true;
    end;
#endif
}