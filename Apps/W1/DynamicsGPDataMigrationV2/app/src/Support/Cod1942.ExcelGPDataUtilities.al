codeunit 1942 "Excel GP Data Utilities"
{

    trigger OnRun()
    begin
    end;

    var
        ConfigPackageManagement: Codeunit "Config. Package Management";
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        PackageCodeTxt: Label 'GP.MIGRATION.EXCEL';
        PackageNameTxt: Label 'GP Excel Data Migration';
        ImportingMsg: Label 'Importing Data...';
        ImportFromExcelTxt: Label 'Import from Excel';
        ExcelFileExtensionTok: Label '*.xlsx';
        ExcelValidationErr: Label 'The file that you imported is corrupted. It contains columns that cannot be mapped to %1.', Comment = '%1 - product name';
        ExcelFileNameTok: Label 'DataImport_Dynamics365%1.xlsx', Comment = '%1 = String generated from current datetime to make sure file names are unique ';

    [Scope('OnPrem')]
    procedure ImportExcelData(): Boolean
    var
        FileManagement: Codeunit "File Management";
        ServerFile: Text;
    begin
        OnUploadFile(ServerFile);
        if ServerFile = '' then
            ServerFile := CopyStr(FileManagement.UploadFile(CopyStr(ImportFromExcelTxt, 1, 50), ExcelFileExtensionTok),
                1, MaxStrLen(ServerFile));

        if ServerFile <> '' then begin
            ImportExcelDataByFileName(CopyStr(ServerFile, 1, 250));
            exit(true);
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ImportExcelDataByFileName(FileName: Text[250])
    var
        FileManagement: Codeunit "File Management";
        Window: Dialog;
    begin
        Window.Open(ImportingMsg);

        FileManagement.ValidateFileExtension(FileName, ExcelFileExtensionTok);
        CreatePackageMetadata();
        ValidateTemplateAndImportData(FileName);

        Window.Close();
    end;

    [Scope('Cloud')]
    procedure ImportExcelDataStream(): Boolean
    var
        FileManagement: Codeunit "File Management";
        FileStream: InStream;
        Name: Text;
    begin
        ClearLastError();

        // There is no way to check if NVInStream is null before using it after calling the
        // UPLOADINTOSTREAM therefore if result is false this is the only way we can throw the error.
        Name := ExcelFileExtensionTok;

        if not UploadIntoStream(ImportFromExcelTxt, '', FileManagement.GetToFilterText('', '.xlsx'), Name, FileStream) then
            exit(false);
        ImportExcelDataByStream(FileStream);
        exit(true);
    end;

    [Scope('Cloud')]
    procedure ImportExcelDataByStream(FileStream: InStream)
    var
        Window: Dialog;
    begin
        Window.Open(ImportingMsg);

        CreatePackageMetadata();
        ValidateTemplateAndImportDataStream(FileStream);

        Window.Close();
    end;

    [Scope('OnPrem')]
    procedure ExportExcelTemplate(): Boolean
    var
        FileName: Text;
        HideDialog: Boolean;
    begin
        OnDownloadTemplate(HideDialog);
        exit(ExportExcelTemplateByFileName(FileName, HideDialog));
    end;

    [Scope('OnPrem')]
    procedure ExportExcelTemplateByFileName(var FileName: Text; HideDialog: Boolean): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        if FileName = '' then
            FileName :=
              StrSubstNo(ExcelFileNameTok, Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>'));

        CreatePackageMetadata();
        ConfigPackageTable.SetRange("Package Code", PackageCodeTxt);
        ConfigExcelExchange.SetHideDialog(HideDialog);
        exit(ConfigExcelExchange.ExportExcel(FileName, ConfigPackageTable, false, false));
    end;

    [Scope('Cloud')]
    procedure GetPackageCode(): Code[20]
    begin
        exit(CopyStr(PackageCodeTxt, 1, 20));
    end;

    local procedure CreatePackageMetadata()
    var
        ConfigPackage: Record "Config. Package";
        Language: Codeunit Language;
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        ConfigPackage.SetRange(Code, PackageCodeTxt);
        ConfigPackage.DeleteAll(true);

        ConfigPackageManagement.InsertPackage(ConfigPackage, CopyStr(PackageCodeTxt, 1, 20), CopyStr(PackageNameTxt, 1, 50), false);
        ConfigPackage."Language ID" := Language.GetDefaultApplicationLanguageId();
        ConfigPackage."Product Version" :=
          CopyStr(ApplicationSystemConstants.ApplicationVersion(), 1, STRLEN(ConfigPackage."Product Version"));
        ConfigPackage.Modify();

        InsertPackageTables();
        InsertPackageFields();
    end;

    local procedure InsertPackageTables()
    var
        ConfigPackageField: Record "Config. Package Field";
        DataMigrationSetup: Record "Data Migration Setup";
    begin
        if not DataMigrationSetup.Get() then begin
            DataMigrationSetup.Init();
            DataMigrationSetup.Insert();
        end;

        InsertPackageTableAccount(DataMigrationSetup);

        ConfigPackageField.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageField.ModifyAll("Include Field", false);
    end;

    local procedure InsertPackageFields()
    begin
        InsertPackageFieldsAccount();
    end;

    local procedure InsertPackageTableAccount(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, CopyStr(PackageCodeTxt, 1, 20), Database::"MigrationGP Account");
    end;

    local procedure InsertPackageFieldsAccount()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageField.SetRange("Table ID", Database::"MigrationGP Account");
        ConfigPackageField.DeleteAll(true);

        InsertPackageField(Database::"MigrationGP Account", 1, 1);    // AcctNum
        InsertPackageField(Database::"MigrationGP Account", 2, 2);    // AcctIndex
        InsertPackageField(Database::"MigrationGP Account", 3, 3);    // Name
        InsertPackageField(Database::"MigrationGP Account", 5, 4);    // AccountCategory
        InsertPackageField(Database::"MigrationGP Account", 13, 5);   // AcctNumNew
    end;

    local procedure InsertPackageField(TableNo: Integer; FieldNo: Integer; ProcessingOrderNo: Integer)
    var
        ConfigPackageField: Record "Config. Package Field";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.Open(TableNo);
        FieldRef := RecordRef.Field(FieldNo);

        ConfigPackageManagement.InsertPackageField(ConfigPackageField, CopyStr(PackageCodeTxt, 1, 20), TableNo,
          FieldRef.NUMBER(), CopyStr(FieldRef.NAME(), 1, 30), CopyStr(FieldRef.CAPTION(), 1, 250), true, true, false, false);
        ConfigPackageField.Validate("Processing Order", ProcessingOrderNo);
        ConfigPackageField.Modify(true);
    end;

    local procedure GetCodeunitNumber(): Integer
    begin
        exit(codeunit::"Excel GP Data Utilities");
    end;

    local procedure ValidateTemplateAndImportData(FileName: Text)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackage.Get(PackageCodeTxt);
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);

        if ConfigPackageTable.FindSet() then
            repeat
                ConfigPackageField.Reset();

                // Check if Excel file contains data sheets with the supported master tables (Customer, Vendor, Item)
                if IsTableInExcel(TempExcelBuffer, FileName, ConfigPackageTable) then
                    ValidateTemplateAndImportDataCommon(TempExcelBuffer, ConfigPackageField, ConfigPackageTable)
                else begin
                    // Table is removed from the configuration package because it doen't exist in the Excel file
                    TempExcelBuffer.CloseBook();
                    ConfigPackageTable.Delete(true);
                end;
            until ConfigPackageTable.Next() = 0;
    end;

    local procedure ValidateTemplateAndImportDataStream(FileStream: InStream)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackage.Get(PackageCodeTxt);
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);

        if ConfigPackageTable.FindSet() then
            repeat
                ConfigPackageField.Reset();

                // Check if Excel file contains data sheets with the supported master tables (Customer, Vendor, Item)
                if IsTableInExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable) then
                    ValidateTemplateAndImportDataCommon(TempExcelBuffer, ConfigPackageField, ConfigPackageTable)
                else begin
                    // Table is removed from the configuration package because it doen't exist in the Excel file
                    TempExcelBuffer.CloseBook();
                    ConfigPackageTable.Delete(true);
                end;
            until ConfigPackageTable.Next() = 0;
    end;

    local procedure ValidateTemplateAndImportDataCommon(var TempExcelBuffer: Record "Excel Buffer" temporary; var ConfigPackageField: Record "Config. Package Field"; var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageRecord: Record "Config. Package Record";
        ColumnHeaderRow: Integer;
        ColumnCount: Integer;
        RecordNo: Integer;
        FieldID: array[250] of Integer;
        I: Integer;
    begin
        ColumnHeaderRow := 3; // Data is stored in the Excel sheets starting from row 3

        TempExcelBuffer.ReadSheet();
        // Jump to the Columns' header row
        TempExcelBuffer.SetFilter("Row No.", '%1..', ColumnHeaderRow);

        ConfigPackageField.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageField.SetRange("Table ID", ConfigPackageTable."Table ID");

        ColumnCount := 0;

        if TempExcelBuffer.FindSet() then
            repeat
                if TempExcelBuffer."Row No." = ColumnHeaderRow then begin // Columns' header row
                    ConfigPackageField.SetRange("Field Caption", TempExcelBuffer."Cell Value as Text");

                    // Column can be mapped to a field, data will be imported to NAV
                    if ConfigPackageField.FindFirst() then begin
                        FieldID[TempExcelBuffer."Column No."] := ConfigPackageField."Field ID";
                        ConfigPackageField."Include Field" := true;
                        ConfigPackageField.Modify();
                        ColumnCount += 1;
                    end else // Error is thrown when the template is corrupted (i.e., there are columns in Excel file that cannot be mapped to NAV)
                        LogInternalError(ExcelValidationErr, PRODUCTNAME.MARKETING(), DataClassification::SystemMetadata, Verbosity::Error);
                end else begin // Read data row by row
                               // A record is created with every new row
                    ConfigPackageManagement.InitPackageRecord(ConfigPackageRecord, CopyStr(PackageCodeTxt, 1, 20),
                      ConfigPackageTable."Table ID");
                    RecordNo := ConfigPackageRecord."No.";
                    for I := 1 to ColumnCount do
                        if TempExcelBuffer.Get(TempExcelBuffer."Row No.", I) then
                            // Fields are populated in the record created
                            InsertFieldData(
                              ConfigPackageTable."Table ID", RecordNo, FieldID[I], TempExcelBuffer."Cell Value as Text")
                        else
                            InsertFieldData(
                              ConfigPackageTable."Table ID", RecordNo, FieldID[I], '');

                    // Go to next line
                    TempExcelBuffer.SetFilter("Row No.", '%1..', TempExcelBuffer."Row No." + 1);
                end;
            until TempExcelBuffer.Next() = 0;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.CloseBook();
    end;

    local procedure IsTableInExcel(var TempExcelBuffer: Record "Excel Buffer" temporary; FileName: Text; ConfigPackageTable: Record "Config. Package Table"): Boolean
    begin
        ConfigPackageTable.CalcFields("Table Name", "Table Caption");

        TryOpenExcel(TempExcelBuffer, FileName, ConfigPackageTable."Table Name");
        Exit(true);
    end;

    [TryFunction]
    local procedure TryOpenExcel(var TempExcelBuffer: Record "Excel Buffer" temporary; FileName: Text; SheetName: Text[250])
    begin
        TempExcelBuffer.OpenBook(FileName, SheetName);
    end;

    local procedure IsTableInExcelStream(var TempExcelBuffer: Record "Excel Buffer" temporary; FileStream: InStream; ConfigPackageTable: Record "Config. Package Table"): Boolean
    begin
        ConfigPackageTable.CalcFields("Table Name", "Table Caption");

        if OpenExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable."Table Name") = '' then
            exit(true);
        if OpenExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable."Table Caption") = '' then
            exit(true);
        exit(false);
    end;

    local procedure OpenExcelStream(var TempExcelBuffer: Record "Excel Buffer" temporary; FileStream: InStream; SheetName: Text[250]): Text
    begin
        exit(TempExcelBuffer.OpenBookStream(FileStream, SheetName));
    end;

    local procedure InsertFieldData(TableNo: Integer; RecordNo: Integer; FieldNo: Integer; Value: Text[250])
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        ConfigPackageManagement.InsertPackageData(ConfigPackageData, CopyStr(PackageCodeTxt, 1, 20),
          TableNo, RecordNo, FieldNo, Value, false);
    end;

    local procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity")
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackage.Get(PackageCodeTxt);
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
        DataMigrationEntity.DeleteAll();

        with ConfigPackageTable do
            if FindSet() then
                repeat
                    CalcFields("No. of Package Records");
                    DataMigrationEntity.InsertRecord("Table ID", "No. of Package Records");
                until Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Cloud')]
    local procedure OnUploadFile(var ServerFileName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Cloud')]
    local procedure OnDownloadTemplate(var HideDialog: Boolean)
    begin
    end;
}

