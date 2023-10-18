codeunit 148016 "SIE Test Helper"
{
    EventSubscriberInstance = Manual;

    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        DefaultLbl: label 'DEFAULT';

    procedure SetupSIE()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        SIEManagement: Codeunit "SIE Management";
        DataHandlingSIE: Codeunit "Data Handling SIE";
    begin
        AuditFileExportSetup.InitSetup("Audit File Export Format"::SIE);
        AuditFileExportSetup.UpdateStandardAccountType("Standard Account Type"::"Four Digit Standard Account (SRU)");
        AuditFileExportFormatSetup.InitSetup("Audit File Export Format"::SIE, SIEManagement.GetAuditFileName(), false);
        DataHandlingSIE.LoadStandardAccounts("Standard Account Type"::"Four Digit Standard Account (SRU)");
    end;

    procedure CreateGLAccMappingWithLine(var GLAccountMappingLine: Record "G/L Account Mapping Line")
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        StandardAccount: Record "Standard Account";
        StandardAccountType: enum "Standard Account Type";
        GLAccountNo: Code[20];
    begin
        StandardAccountType := "Standard Account Type"::"Four Digit Standard Account (SRU)";

        GLAccountMappingHeader.Init();
        GLAccountMappingHeader.Validate(Code, DefaultLbl);
        GLAccountMappingHeader.Validate("Standard Account Type", StandardAccountType);
        GLAccountMappingHeader.Validate("Accounting Period", CalcDate('<-CY>', WorkDate()));
        GLAccountMappingHeader.Insert(true);

        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // create mapping lines
        AuditMappingHelper.Run(GLAccountMappingHeader);

        // map one line
        StandardAccount.SetRange(Type, StandardAccountType);
        StandardAccount.FindFirst();
        GLAccountMappingLine.Get(GLAccountMappingHeader.Code, GLAccountNo);
        GLAccountMappingLine.Validate("Standard Account No.", StandardAccount."No.");
        GLAccountMappingLine.Modify(true);
    end;

    procedure CreateAuditFileExportDoc(var AuditFileExportHeader: Record "Audit File Export Header"; StartingDate: Date; EndingDate: Date; FileType: enum "File Type SIE"; GLAccountFilter: Text[1024])
    begin
        AuditFileExportHeader.Init();
        AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::SIE);
        AuditFileExportHeader.Validate("G/L Account Mapping Code", DefaultLbl);
        AuditFileExportHeader.Validate("Starting Date", StartingDate);
        AuditFileExportHeader.Validate("Ending Date", EndingDate);
        AuditFileExportHeader.Validate("Header Comment", LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate(Contact, LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate("File Type", FileType);
        AuditFileExportHeader.Validate("G/L Account Filter Expression", GLAccountFilter);
        AuditFileExportHeader.Validate("Parallel Processing", false);
        AuditFileExportHeader.Insert(true);
    end;
#if not CLEAN22
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnInitializeFeatureDataUpdateStatus', '', false, false)]
    local procedure EnableSIEFeatureOnInitializeFeatureDataUpdateStatus(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; var InitializeHandled: Boolean)
    var
        FeatureKey: Record "Feature Key";
        SIEManagement: Codeunit "SIE Management";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> SIEManagement.GetSIEAuditFileExportFeatureKeyId() then
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