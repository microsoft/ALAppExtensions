codeunit 148036 "Audit File Export Test Helper"
{
    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        DefaultLbl: label 'DEFAULT';
        StandardAccNoTxt: label '%1%1%1%1', Comment = '%1 - 1 or 2 or 3';

    procedure SetupTestFormat()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        DataHandlingTest: Codeunit "Data Handling Test";
    begin
        AuditFileExportSetup.InitSetup("Audit File Export Format"::TEST);
        AuditFileExportSetup.UpdateStandardAccountType("Standard Account Type"::"Standard Account Test");
        AuditFileExportFormatSetup.InitSetup("Audit File Export Format"::TEST, 'test.txt', false);
        DataHandlingTest.LoadStandardAccounts("Standard Account Type"::"Standard Account Test");
    end;

    procedure CreateGLAccMappingWithLines(var GLAccountMappingHeader: Record "G/L Account Mapping Header"; var MappedGLAccountNos: List of [Code[20]])
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        StandardAccountType: enum "Standard Account Type";
        i: Integer;
    begin
        StandardAccountType := "Standard Account Type"::"Standard Account Test";

        GLAccountMappingHeader.SetRange(Code, DefaultLbl);
        GLAccountMappingHeader.DeleteAll(true);

        // Standard Account Type and Audit File Export Format are taken from Audit File Export Setup
        GLAccountMappingHeader.Init();
        GLAccountMappingHeader.Validate(Code, DefaultLbl);
        GLAccountMappingHeader.Validate("Accounting Period", CalcDate('<-CY>', WorkDate()));
        GLAccountMappingHeader.Insert(true);

        // create three G/L Accounts
        MappedGLAccountNos.AddRange(LibraryERM.CreateGLAccountNo(), LibraryERM.CreateGLAccountNo(), LibraryERM.CreateGLAccountNo());

        // create mapping lines
        AuditMappingHelper.Run(GLAccountMappingHeader);

        // map three lines
        for i := 1 to MappedGLAccountNos.Count do begin
            StandardAccount.Get(StandardAccountType, '', StrSubstNo(StandardAccNoTxt, i));
            GLAccountMappingLine.Get(GLAccountMappingHeader.Code, MappedGLAccountNos.Get(i));
            GLAccountMappingLine.Validate("Standard Account No.", StandardAccount."No.");
            GLAccountMappingLine.Modify(true);
        end;
    end;

    procedure CreateAuditFileExportDoc(var AuditFileExportHeader: Record "Audit File Export Header"; StartingDate: Date; EndingDate: Date; ArchiveToZip: Boolean)
    begin
        AuditFileExportHeader.Init();
        AuditFileExportHeader.Insert(true);
        AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::TEST);
        AuditFileExportHeader.Validate("G/L Account Mapping Code", DefaultLbl);
        AuditFileExportHeader.Validate("Starting Date", StartingDate);
        AuditFileExportHeader.Validate("Ending Date", EndingDate);
        AuditFileExportHeader.Validate("Header Comment", LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate(Contact, LibraryUtility.GenerateGUID());
        AuditFileExportHeader.Validate("Parallel Processing", false);
        AuditFileExportHeader.Validate("Archive to Zip", ArchiveToZip);
        AuditFileExportHeader.Modify(true);
    end;

    procedure StartExport(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
    end;
}