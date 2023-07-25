// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132517 "AFS File Client Test"
{
    Subtype = Test;

    [Test]
    procedure CreateTextFileTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        FileContentLbl: Label 'Hello World!', Locked = true;
        FilePathLbl: Label 'test.txt', Locked = true;
        FileContentReturn: Text;
    begin
        // [SCENARIO] User wants to send a text file to azure file share.

        // [GIVEN] A storage account
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());

        // [WHEN] The programmer creates a text file in the file share and puts the content in it
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);

        AFSOperationResponse := AFSFileClient.CreateFile(FilePathLbl, StrLen(FileContentLbl));
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        AFSOperationResponse := AFSFileClient.PutFileText(FilePathLbl, FileContentLbl);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The file is created and the content is correct
        AFSOperationResponse := AFSFileClient.GetFileAsText(FilePathLbl, FileContentReturn);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        LibraryAssert.AreEqual(FileContentLbl, FileContentReturn, 'File content mismatch.');
    end;

    [Test]
    procedure CreateTextFileNoParentDirectoryTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        FileContentLbl: Label 'Hello World!', Locked = true;
        FilePathLbl: Label 'parentdir/test.txt', Locked = true;
        ExpectedErrorLbl: Label 'Could not create file %1 in %2..\\Response Code: 404 The specified parent path does not exist.', Comment = '%1 - file name, %2 - file share name';
    begin
        // [SCENARIO] User wants to send a text file to azure file share into the folder that doesn't exist.

        // [GIVEN] A storage account
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());

        // [WHEN] The programmer creates a text file in the file share in the path that doesn't exist
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSOperationResponse := AFSFileClient.CreateFile(FilePathLbl, StrLen(FileContentLbl));
        LibraryAssert.AreEqual(false, AFSOperationResponse.IsSuccessful(), 'The CreateFile operation should return an error.');

        // [THEN] An error is returned
        LibraryAssert.AreEqual(StrSubstNo(ExpectedErrorLbl, FilePathLbl, AzureTestLibrary.GetFileShareName()), AFSOperationResponse.GetError(), 'Error message mismatch.');
    end;

    [Test]
    procedure ListDirectoryTest()
    var
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        // [SCENARIO] User wants to see files in the directory.

        // [GIVEN] A storage account with a file share and a preset file structure
        // -- parentdir
        //    -- test.txt
        //    -- test2.txt
        //    -- deeperdir
        //       -- test3.txt
        //       -- test4.txt
        // -- anotherdir
        //    -- image.jpg
        //    -- document.pdf
        //    -- spreadsheet.xlsx
        //    -- emptydir
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());
        InitializeFileShareStructure();

        // [WHEN] The programmer runs a list operation on the parent directory
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSOperationResponse := AFSFileClient.ListDirectory('', AFSDirectoryContent);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] A correct list of files and/or directories is returned
        LibraryAssert.AreEqual(2, AFSDirectoryContent.Count(), 'Wrong number of files and/or directories returned.');
        AFSDirectoryContent.SetRange("Full Name", 'parentdir');
        LibraryAssert.RecordIsNotEmpty(AFSDirectoryContent);
        AFSDirectoryContent.SetRange("Full Name", 'anotherdir');
        LibraryAssert.RecordIsNotEmpty(AFSDirectoryContent);
    end;

    [Test]
    procedure CreateAndGetFileInDirectoryTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        TempBlob: Codeunit "Temp Blob";
        WriteOutStream: OutStream;
        FileInStream: InStream;
        ReturnInStream: InStream;
        ReturnContent: Text;
        FileContentLbl: Label 'Hello World!', Locked = true;
    begin
        // [SCENARIO] User wants to create a file in a new directory and then download it as stream.

        // [GIVEN] A storage account
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());

        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);

        // [WHEN] The programmer creates a directory and a file in it
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSOperationResponse := AFSFileClient.CreateDirectory('parentdir');
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        AFSOperationResponse := AFSFileClient.CreateFile('parentdir/test.txt', StrLen(FileContentLbl));
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        TempBlob.CreateOutStream(WriteOutStream, TextEncoding::UTF8);
        WriteOutStream.WriteText(FileContentLbl);
        TempBlob.CreateInStream(FileInStream);
        AFSOperationResponse := AFSFileClient.PutFileStream('parentdir/test.txt', FileInStream);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [WHEN] The programmer downloads the file as stream
        AFSFileClient.GetFileAsStream('parentdir/test.txt', ReturnInStream);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The content of the file is correct
        ReturnInStream.ReadText(ReturnContent);
        LibraryAssert.AreEqual(FileContentLbl, ReturnContent, 'File content mismatch.');
    end;

    [Test]
    procedure DeleteFileTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        ReturnContent: Text;
    begin
        // [SCENARIO] User wants to delete an existing file.

        // [GIVEN] A storage account with a file share and a preset file structure
        // -- parentdir
        //    -- test.txt
        //    -- test2.txt
        //    -- deeperdir
        //       -- test3.txt
        //       -- test4.txt
        // -- anotherdir
        //    -- image.jpg
        //    -- document.pdf
        //    -- spreadsheet.xlsx
        //    -- emptydir
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());
        InitializeFileShareStructure();

        // [WHEN] The programmer deletes a file
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSOperationResponse := AFSFileClient.DeleteFile('parentdir/test.txt');
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The operation is succesful and the file is deleted
        AFSOperationResponse := AFSFileClient.GetFileAsText('parentdir/test.txt', ReturnContent);
        LibraryAssert.AreEqual(false, AFSOperationResponse.IsSuccessful(), 'The file should not exist.');
    end;

    [Test]
    procedure DeleteDirectoryTest()
    var
        AFSDirectoryContent: Record "AFS Directory Content";
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        // [SCENARIO] User wants to delete an existing empty directory.

        // [GIVEN] A storage account with a file share and a preset file structure
        // -- parentdir
        //    -- test.txt
        //    -- test2.txt
        //    -- deeperdir
        //       -- test3.txt
        //       -- test4.txt
        // -- anotherdir
        //    -- image.jpg
        //    -- document.pdf
        //    -- spreadsheet.xlsx
        //    -- emptydir
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());
        InitializeFileShareStructure();

        // [WHEN] The programmer deletes a directory
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSOperationResponse := AFSFileClient.DeleteDirectory('anotherdir/emptydir');
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The operation is succesful and the directory is deleted
        AFSOperationResponse := AFSFileClient.ListDirectory('anotherdir/emptydir', AFSDirectoryContent);
        LibraryAssert.AreEqual(false, AFSOperationResponse.IsSuccessful(), 'The directory should not exist.');
    end;

    [Test]
    procedure CopyFileTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpRequestMessage: HttpRequestMessage;
        ReturnContent: Text;
        FileContentLbl: Label 'Hello World!', Locked = true;
        SourceFileURI: Text;
    begin
        // [SCENARIO] User wants to copy an existing file.

        // [GIVEN] A storage account with a file share and an existing file
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());

        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSFileClient.CreateFile('sourcefile.txt', StrLen(FileContentLbl));
        AFSFileClient.PutFileText('sourcefile.txt', FileContentLbl);

        // [WHEN] The programmer copies a file
        // NOTE: When copying a file using shared access signature you need to authorize the source file with the same shared access signature
        SourceFileURI := 'https://' + AzureTestLibrary.GetStorageAccountName() + '.file.core.windows.net/' + AzureTestLibrary.GetFileShareName() + '/sourcefile.txt';
        HttpRequestMessage.SetRequestUri(SourceFileURI);
        SharedKeyAuthorization.Authorize(HttpRequestMessage, AzureTestLibrary.GetStorageAccountName());
        SourceFileURI := HttpRequestMessage.GetRequestUri();
        AFSOperationResponse := AFSFileClient.CopyFile(SourceFileURI, 'targetfile.txt');
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The operation is succesful and the new file is created with the same content
        AFSOperationResponse := AFSFileClient.GetFileAsText('targetfile.txt', ReturnContent);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        LibraryAssert.AreEqual(FileContentLbl, ReturnContent, 'File content mismatch.');
    end;

    [Test]
    procedure FileMetadataTest()
    var
        AFSFileClient: Codeunit "AFS File Client";
        AFSOperationResponse: Codeunit "AFS Operation Response";
        Metadata: Dictionary of [Text, Text];
        ReturnMetadata: Dictionary of [Text, Text];
        KeyText: Text;
    begin
        // [SCENARIO] User wants to set metadata for an existing file.

        // [GIVEN] A storage account with a file share and an existing file
        AzureTestLibrary.ClearFileShare();
        SharedKeyAuthorization := AFSTestLibrary.GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey());

        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSFileClient.CreateFile('sourcefile.txt', 0);

        // [WHEN] The programmer sets some metadata for a file
        Metadata.Add('author', 'John Doe');
        Metadata.Add('scope', 'Public');
        Metadata.Add('importance', 'High');
        AFSOperationResponse := AFSFileClient.SetFileMetadata('sourcefile.txt', Metadata);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());

        // [THEN] The operation is succesful and the file has correct metadata
        AFSOperationResponse := AFSFileClient.GetFileMetadata('sourcefile.txt', ReturnMetadata);
        LibraryAssert.AreEqual(true, AFSOperationResponse.IsSuccessful(), AFSOperationResponse.GetError());
        LibraryAssert.AreEqual(Metadata.Count(), ReturnMetadata.Count(), 'Metadata count mismatch.');
        foreach KeyText in Metadata.Keys() do
            LibraryAssert.AreEqual(Metadata.Get(KeyText), ReturnMetadata.Get(KeyText), 'Metadata value mismatch.');
    end;

    local procedure InitializeFileShareStructure()
    var
        AFSFileClient: Codeunit "AFS File Client";
    begin
        AFSFileClient.Initialize(AzureTestLibrary.GetStorageAccountName(), AzureTestLibrary.GetFileShareName(), SharedKeyAuthorization);
        AFSFileClient.CreateDirectory('parentdir');
        AFSFileClient.CreateFile('parentdir/test.txt', 0);
        AFSFileClient.CreateFile('parentdir/test2.txt', 0);
        AFSFileClient.CreateDirectory('parentdir/deeperdir');
        AFSFileClient.CreateFile('parentdir/deeperdir/test3.txt', 0);
        AFSFileClient.CreateFile('parentdir/deeperdir/test4.txt', 0);
        AFSFileClient.CreateDirectory('anotherdir');
        AFSFileClient.CreateFile('anotherdir/image.jpg', 0);
        AFSFileClient.CreateFile('anotherdir/document.pdf', 0);
        AFSFileClient.CreateFile('anotherdir/spreadsheet.xlsx', 0);
        AFSFileClient.CreateDirectory('anotherdir/emptydir');
    end;

    var
        LibraryAssert: Codeunit "Library Assert";
        AFSTestLibrary: Codeunit "AFS Test Library";
        AzureTestLibrary: Codeunit "Azure Test Library";
        SharedKeyAuthorization: Interface "Storage Service Authorization";
}