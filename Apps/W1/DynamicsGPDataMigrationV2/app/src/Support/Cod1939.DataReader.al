codeunit 1939 "MigrationGP Data Reader"
{
    TableNo = "MigrationGP Config";

    trigger OnRun();
    begin
        ProcessZipFile(Rec."Zip File");
    end;

    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        SomethingWentWrongErr: Label 'Something went wrong.\Please try again later.';
        ZipFileMissingErrorTxt: Label 'There was an error on uploading the zip file.';
        ZipExtractionErrorTxt: Label 'There was an error on extracting the zip file.';
        EmptyZipFileErr: Label 'The zip file does not contain any files.';
        FileMissingErr: Label 'Unable to process files from the zip file.';

    local procedure ProcessZipFile(FileName: Text)
    var
        MigrationGPConfig: Record "MigrationGP Config";
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig.Validate("Zip File", FileName);
        MigrationGPConfig.Modify();
        UnzipFile(NameValueBuffer);
        ReadRecordCounts(NameValueBuffer);
    end;

    procedure GetNumberOfAccounts(): Integer;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."Total Accounts");
    end;

    procedure GetNumberOfItems(): Integer;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."Total Items");
    end;

    procedure GetNumberOfCustomers(): Integer;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."Total Customers");
    end;

    procedure GetNumberOfVendors(): Integer;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."Total Vendors");
    end;

    local procedure UnzipFile(var NameValueBuffer: Record "Name/Value Buffer")
    var
        MigrationGPConfig: Record "MigrationGP Config";
        FileManagement: Codeunit "File Management";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        UnzipLocation: Text;
    begin
        MigrationGPConfig.GetSingleInstance();
        if not FileManagement.ServerFileExists(MigrationGPConfig."Zip File") then begin
            OnZipFileMissing();
            Error(SomethingWentWrongErr);
        end;

        UnzipLocation := FileManagement.ServerCreateTempSubDirectory();
        if not FileManagement.ServerDirectoryExists(UnzipLocation) then begin
            OnExtractFolderMissing();
            Error(SomethingWentWrongErr);
        end;

        ConfPersonalizationMgt.ExtractZipFile(MigrationGPConfig."Zip File", UnzipLocation);
        FileManagement.GetServerDirectoryFilesListInclSubDirs(NameValueBuffer, UnzipLocation);
        if NameValueBuffer.FindFirst() then begin
            MigrationGPConfig."Unziped Folder" := CopyStr(FileManagement.GetDirectoryName(NameValueBuffer.Name), 1, 250);
            MigrationGPConfig.Modify();
        end else begin
            OnEmptyZipFile();
            Error(EmptyZipFileErr);
        end;
    end;

    local procedure ReadRecordCounts(var NameValueBuffer: Record "Name/Value Buffer")
    var
        MigrationGPConfig: Record "MigrationGP Config";
        Number: Integer;
    begin
        MigrationGPConfig.GetSingleInstance();
        NameValueBuffer.SetFilter(Name, '*.txt');
        if not NameValueBuffer.FindSet() then begin
            OnFileMissing();
            Error(FileMissingErr);
        end;

        if HelperFunctions.IsUsingNewAccountFormat() then
            HelperFunctions.GetObjectCount('Account2', Number)
        else
            HelperFunctions.GetObjectCount('Account', Number);

        MigrationGPConfig."Total Accounts" := Number;
        HelperFunctions.GetObjectCount('Item', Number);
        MigrationGPConfig."Total Items" := Number;
        HelperFunctions.GetObjectCount('Customer', Number);
        MigrationGPConfig."Total Customers" := Number;
        HelperFunctions.GetObjectCount('Vendor', Number);
        MigrationGPConfig."Total Vendors" := Number;
        MigrationGPConfig.Modify();
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationGP Data Reader", 'OnZipFileMissing', '', false, false)]
    local procedure OnZipFileMissingSubscriber()
    begin
        Session.LogMessage('00001OE', ZipFileMissingErrorTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationGP Data Reader", 'OnExtractFolderMissing', '', false, false)]
    local procedure OnExtractFolderMissingSubscriber()
    begin
        Session.LogMessage('00001OF', ZipExtractionErrorTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationGP Data Reader", 'OnEmptyZipFile', '', false, false)]
    local procedure OnEmptyZipFileSubscriber()
    begin
        Session.LogMessage('00001OG', EmptyZipFileErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MigrationGP Data Reader", 'OnFileMissing', '', false, false)]
    local procedure OnFileMissinggSubscriber()
    begin
        Session.LogMessage('00001OH', FileMissingErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;
}

