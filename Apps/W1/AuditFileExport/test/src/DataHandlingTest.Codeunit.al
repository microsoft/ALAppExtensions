codeunit 148037 "Data Handling Test" implements "Audit File Export Data Handling"
{
    var
        TypeHelper: Codeunit "Type Helper";
        MasterDataTxt: label 'Master Data';
        GLEntriesTxt: label 'G/L Entries';
        SourceDocsTxt: label 'Source Documents';

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean;
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
        CSVDocContent: Text;
        CRLF: Text[2];
        CSVFieldSeparator: Text[1];
    begin
        CSVFieldSeparator := ';';
        CRLF := TypeHelper.CRLFSeparator();
        CSVDocContent :=
            '1111; Standard Account 1' + CRLF +
            '2222; Standard Account 2' + CRLF +
            '3333; Standard Account 3';
        ImportAuditDataMgt.LoadStandardAccountsFromCSVTextToCSVBuffer(TempCSVBuffer, CSVDocContent, CSVFieldSeparator);
        ImportAuditDataMgt.ImportStandardAccountsFromCSVBuffer(TempCSVBuffer, StandardAccountType);
        exit(true);
    end;

    procedure CreateAuditFileExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        LineNo: Integer;
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.DeleteAll(true);

        // master data
        AuditFileExportMgt.InsertAuditFileExportLine(
            AuditFileExportLine, LineNo, AuditFileExportHeader.ID, "Audit File Export Data Class"::MasterData,
            MasterDataTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");

        // G/L entries
        AuditFileExportMgt.InsertAuditFileExportLine(
            AuditFileExportLine, LineNo, AuditFileExportHeader.ID, "Audit File Export Data Class"::GeneralLedgerEntries,
            GLEntriesTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");

        // source documents
        AuditFileExportMgt.InsertAuditFileExportLine(
            AuditFileExportLine, LineNo, AuditFileExportHeader.ID, "Audit File Export Data Class"::SourceDocuments,
            SourceDocsTxt, AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
    end;

    procedure GenerateFileContentForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: codeunit "Temp Blob")
    var
        BlobOutStream: OutStream;
        CRLF: Text[2];
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(BlobOutStream);
        CRLF := TypeHelper.CRLFSeparator();

        case AuditFileExportLine."Data Class" of
            "Audit File Export Data Class"::MasterData:
                WriteMasterDataFileContent(AuditFileExportLine, TempBlob);
            "Audit File Export Data Class"::GeneralLedgerEntries:
                WriteGLEntryFileContent(AuditFileExportLine, TempBlob);
            "Audit File Export Data Class"::SourceDocuments:
                BlobOutStream.WriteText('Source Document File Content' + CRLF);
            else
                BlobOutStream.WriteText('Unknown File Content' + CRLF);
        end;
    end;

    procedure GetFileNameForAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line") FileName: Text[1024]
    begin
        case AuditFileExportLine."Data Class" of
            "Audit File Export Data Class"::MasterData:
                exit('MasterData.txt');
            "Audit File Export Data Class"::GeneralLedgerEntries:
                exit('GLEntry.txt');
            "Audit File Export Data Class"::SourceDocuments:
                exit('SourceDocument.txt');
            else
                exit('UnknownFile.txt');
        end;
    end;

    procedure InitAuditExportDataTypeSetup()
    begin
    end;

    local procedure WriteMasterDataFileContent(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: codeunit "Temp Blob")
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        CRLF: Text[2];
        BlobOutStream: OutStream;
    begin
        CRLF := TypeHelper.CRLFSeparator();
        TempBlob.CreateOutStream(BlobOutStream);
        AuditFileExportHeader.Get(AuditFileExportLine.ID);
#pragma warning disable AA0217
        BlobOutStream.WriteText(MasterDataTxt + CRLF);
        BlobOutStream.WriteText(StrSubstNo('Header Comment %1', AuditFileExportHeader."Header Comment") + CRLF);
        BlobOutStream.WriteText(StrSubstNo('Contact %2', AuditFileExportHeader.Contact) + CRLF);

        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        GLAccountMappingLine.FindSet();
        repeat
            BlobOutStream.WriteText(StrSubstNo('G/L Account %1 %2', GLAccountMappingLine."G/L Account No.", GLAccountMappingLine."Standard Account No.") + CRLF);
        until GLAccountMappingLine.Next() = 0;
#pragma warning restore
    end;

    local procedure WriteGLEntryFileContent(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: codeunit "Temp Blob")
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GLEntry: Record "G/L Entry";
        CRLF: Text[2];
        BlobOutStream: OutStream;
    begin
        CRLF := TypeHelper.CRLFSeparator();
        TempBlob.CreateOutStream(BlobOutStream);
        AuditFileExportHeader.Get(AuditFileExportLine.ID);

        BlobOutStream.WriteText(GLEntriesTxt + CRLF);
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", AuditFileExportHeader."G/L Account Mapping Code");
        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        GLAccountMappingLine.FindSet();
        repeat
            GLEntry.SetRange("G/L Account No.", GLAccountMappingLine."G/L Account No.");
            GLEntry.FindFirst();
#pragma warning disable AA0217
            BlobOutStream.WriteText(StrSubstNo('G/L Entry %1 %2 %3', GLEntry."G/L Account No.", GLEntry."Document No.", Format(GLEntry.Amount, 0, 9)) + CRLF);
#pragma warning restore
        until GLAccountMappingLine.Next() = 0;
    end;
}