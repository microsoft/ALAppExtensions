// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148007 "C5 Schema Reader Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    procedure TestProcessZipFile()
    var
        TempSchemaParameters: Record "C5 Schema Parameters" temporary;
        C5SchemaReader: Codeunit "C5 Schema Reader";
        FileManagement: Codeunit "File Management";
    begin
        // [SCENARIO] C5 files are in the root directory of the zip. The zip is extracted and the right values are read from the definition file

        // [GIVEN] The zip file exists
        CopyZipFileAndSavePath('Data.zip', TempSchemaParameters);

        // [WHEN] Schema Reader codeunit is run
        Codeunit.Run(Codeunit::"C5 Schema Reader", TempSchemaParameters);

        // [THEN] Then the Codeunit C5SchemaReader returns the right values from the definition file
        Assert.AreEqual(C5SchemaReader.GetNumberOfAccounts(), 247, 'A different number of Accounts was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfItems(), 45, 'A different number of Items was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfVendors(), 14, 'A different number of Vendors was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfCustomers(), 28, 'A different number Customers was expected');

        // [THEN] Verify the zipfile has been deleted as no longer needed
        Assert.IsFalse(FileManagement.ServerFileExists(TempSchemaParameters."Zip File"), 'Zip file was expected to be deleted.');
    end;

    [Test]
    procedure TestFilesAreIncludedInSubfolder()
    var
        TempSchemaParameters: Record "C5 Schema Parameters" temporary;
        C5SchemaReader: Codeunit "C5 Schema Reader";
        FileManagement: Codeunit "File Management";
    begin
        // [SCENARIO] C5 files are under a subdirectory of the zip. The zip is extracted and the right values are read from the definition file

        // [GIVEN] The zip file exists
        CopyZipFileAndSavePath('FilesInSubfolder.zip', TempSchemaParameters);

        // [WHEN] Schema Reader codeunit is run
        Codeunit.Run(Codeunit::"C5 Schema Reader", TempSchemaParameters);

        // [THEN] Then the Codeunit C5SchemaReader returns the right values from the definition file
        Assert.AreEqual(C5SchemaReader.GetNumberOfAccounts(), 247, 'A different number of Accounts was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfItems(), 45, 'A different number of Items was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfVendors(), 14, 'A different number of Vendors was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfCustomers(), 28, 'A different number Customers was expected');

        // [THEN] Verify the zipfile has been deleted as no longer needed
        Assert.IsFalse(FileManagement.ServerFileExists(TempSchemaParameters."Zip File"), 'Zip file was expected to be deleted.');
    end;

    [Test]
    procedure TestFilesAreMissingFromTheZip()
    var
        TempSchemaParameters: Record "C5 Schema Parameters" temporary;
        C5SchemaReader: Codeunit "C5 Schema Reader";
        FileManagement: Codeunit "File Management";
    begin
        // [SCENARIO] Files might be missing from the zip file, but not the definition file. 

        // [GIVEN] The zip file exists and some files are missing
        CopyZipFileAndSavePath('FilesMissing.zip', TempSchemaParameters);

        // [WHEN] Schema Reader codeunit is run
        Codeunit.Run(Codeunit::"C5 Schema Reader", TempSchemaParameters);

        // [THEN] Then the Codeunit C5SchemaReader returns the right values from the definition file
        Assert.AreEqual(C5SchemaReader.GetNumberOfAccounts(), 247, 'A different number of Accounts was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfItems(), 45, 'A different number of Items was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfVendors(), 14, 'A different number of Vendors was expected');
        Assert.AreEqual(C5SchemaReader.GetNumberOfCustomers(), 28, 'A different number Customers was expected');

        // [THEN] Verify the zipfile has been deleted as no longer needed
        Assert.IsFalse(FileManagement.ServerFileExists(TempSchemaParameters."Zip File"), 'Zip file was expected to be deleted.');

        TempSchemaParameters.Delete();

        // [GIVEN] The zip file exists and the definition file is missing
        CopyZipFileAndSavePath('DefFileMissing.zip', TempSchemaParameters);

        // [WHEN] Schema Reader codeunit is run
        // [THEN] An error is expected
        asserterror Codeunit.Run(Codeunit::"C5 Schema Reader", TempSchemaParameters);
        Assert.ExpectedError('Oops, it seems the definition file (exp00000.def) was missing from the zip file.');

        FileManagement.DeleteServerFile(TempSchemaParameters."Zip File")
    end;

    [Test]
    procedure TestZipFileMissing()
    var
        TempSchemaParameters: Record "C5 Schema Parameters" temporary;
    begin
        // [SCENARIO] A "nice" error should thrown if the zip file does not exist

        // [WHEN] ProcessZipFile is called
        // [THEN] A "nice" error is thrown
        TempSchemaParameters.Init();
        TempSchemaParameters."Zip File" := 'Non_existing_file.zip';
        TempSchemaParameters.Insert();

        // [WHEN] Schema Reader codeunit is run
        // [THEN] An error is expected
        asserterror Codeunit.Run(Codeunit::"C5 Schema Reader", TempSchemaParameters);
        Assert.ExpectedError(SomethingWentWrongErr);
    end;

    local procedure CopyZipFileAndSavePath(FileName: Text; var C5SchemaParametersOut: Record "C5 Schema Parameters")
    var
        FileManagement: Codeunit "File Management";
        TempFilePath: Text;
    begin
        TempFilePath := FileManagement.ServerTempFileName('zip');
        FileManagement.CopyServerFile(GetInetRoot() + '\App\ExtensionV2\C52012DataMigration\test\' + FileName, TempFilePath, true);

        C5SchemaParametersOut.Init();
        C5SchemaParametersOut."Zip File" := CopyStr(TempFilePath, 1, 250);
        C5SchemaParametersOut.Insert();
    end;

    local procedure GetInetRoot(): Text
    begin
        exit(ApplicationPath() + '\..\..\');
    end;
}
