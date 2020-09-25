codeunit 1919 "MigrationQB Data Reader"
{
    TableNo = "MigrationQB Config";

    trigger OnRun();
    begin
        ProcessZipFile(Rec."Zip File");
    end;

    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        SomethingWentWrongErr: Label 'Something went wrong.\Please try again later.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';
        ZipExtractionErrorTxt: Label 'There was an error on extracting the zip file.';
        EmptyZipFileErr: Label 'The zip file does not contain any files.';
        FileMissingErr: Label 'Unable to process files from the zip file.';

    local procedure ProcessZipFile(FileName: Text)
    var
        MigrationQBConfig: Record "MigrationQB Config";
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        MigrationQBConfig.GetSingleInstance();
        MigrationQBConfig.Validate("Zip File", FileName);
        MigrationQBConfig.Modify();
        UnzipFile(NameValueBuffer);
        ReadRecordCounts(NameValueBuffer);
    end;

    procedure GetNumberOfAccounts(): Integer;
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.GetSingleInstance();
        exit(MigrationQBConfig."Total Accounts");
    end;

    procedure GetNumberOfItems(): Integer;
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.GetSingleInstance();
        exit(MigrationQBConfig."Total Items");
    end;

    procedure GetNumberOfCustomers(): Integer;
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.GetSingleInstance();
        exit(MigrationQBConfig."Total Customers");
    end;

    procedure GetNumberOfVendors(): Integer;
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.GetSingleInstance();
        exit(MigrationQBConfig."Total Vendors");
    end;

    local procedure UnzipFile(var NameValueBuffer: Record "Name/Value Buffer")
    var
        MigrationQBConfig: Record "MigrationQB Config";
        FileManagement: Codeunit "File Management";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        UnzipLocation: Text;
    begin
        MigrationQBConfig.GetSingleInstance();
        if not FileManagement.ServerFileExists(MigrationQBConfig."Zip File") then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;

        UnzipLocation := FileManagement.ServerCreateTempSubDirectory();
        if not FileManagement.ServerDirectoryExists(UnzipLocation) then begin
            OnExtractFolderMissing();
            Error(SomethingWentWrongErr);
        end;

        ConfPersonalizationMgt.ExtractZipFile(MigrationQBConfig."Zip File", UnzipLocation);
        FileManagement.GetServerDirectoryFilesListInclSubDirs(NameValueBuffer, UnzipLocation);
        if NameValueBuffer.FindFirst() then begin
            MigrationQBConfig."Unziped Folder" := CopyStr(FileManagement.GetDirectoryName(NameValueBuffer.Name), 1, 250);
            MigrationQBConfig.Modify();
        end else begin
            OnEmptyZipFile();
            Error(EmptyZipFileErr);
        end;
    end;

    local procedure ReadRecordCounts(var NameValueBuffer: Record "Name/Value Buffer")
    var
        MigrationQBConfig: Record "MigrationQB Config";
        Number: Integer;
    begin
        MigrationQBConfig.GetSingleInstance();
        NameValueBuffer.SetFilter(Name, '*.txt');
        if not NameValueBuffer.FindSet() then begin
            OnFileMissing();
            Error(FileMissingErr);
        end;

        HelperFunctions.GetObjectCount('Account', Number);
        MigrationQBConfig."Total Accounts" := Number;
        HelperFunctions.GetObjectCount('Item', Number);
        MigrationQBConfig."Total Items" := Number;
        HelperFunctions.GetObjectCount('Customer', Number);
        MigrationQBConfig."Total Customers" := Number;
        HelperFunctions.GetObjectCount('Vendor', Number);
        MigrationQBConfig."Total Vendors" := Number;
        MigrationQBConfig.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnZipFileMissing()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExtractFolderMissing()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEmptyZipFile()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFileMissing()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationQB Data Reader", 'OnZipFileMissing', '', false, false)]
    local procedure OnZipFileMissingSubscriber()
    begin
        SendTraceTag('00001OE', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Warning, ZipFileMissingErrorTxt, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationQB Data Reader", 'OnExtractFolderMissing', '', false, false)]
    local procedure OnExtractFolderMissingSubscriber()
    begin
        SendTraceTag('00001OF', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Warning, ZipExtractionErrorTxt, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationQB Data Reader", 'OnEmptyZipFile', '', false, false)]
    local procedure OnEmptyZipFileSubscriber()
    begin
        SendTraceTag('00001OG', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Warning, EmptyZipFileErr, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationQB Data Reader", 'OnFileMissing', '', false, false)]
    local procedure OnFileMissinggSubscriber()
    begin
        SendTraceTag('00001OH', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Warning, FileMissingErr, DataClassification::SystemMetadata);
    end;
}

