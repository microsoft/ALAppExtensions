// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148009 "C5 Custom Schema Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        CRLF: Text[2];

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestImportSuccessfully()
    var
        C5Centre: Record "C5 Centre";
        TempBlob: Record TempBlob temporary;
        CentreXmlPort: XmlPort "C5 Centre";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] CSV data is in a valid format.
        // [GIVEN] C5 Data Migration extension is installed
        Initialize();
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText('"1f1","1f2","1991/01/01"' + CRLF);
        OutStream.WriteText('"2f1","2f2","1992/02/02"' + CRLF);
        OutStream.WriteText('"3f1","3f2","1993/03/03"' + CRLF);
        TempBlob.Blob.CreateInStream(InStream);

        // [WHEN] Importing data from CSV using XML Port
        CentreXmlPort.SetSource(InStream);
        CentreXmlPort.Import();

        // [THEN] All data is imported properly.
        Assert.RecordCount(C5Centre, 3);
        C5Centre.FindFirst();
        Assert.AreEqual(1, C5Centre.RecId, 'Wrong data');
        Assert.AreEqual(UpperCase('1f1'), C5Centre.Centre, 'Wrong data'); // Uppercase since it's Code field.
        Assert.AreEqual('1f2', C5Centre.Name, 'Wrong data');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDataContainsExtraFields()
    var
        C5Centre: Record "C5 Centre";
        TempBlob: Record TempBlob temporary;
        CentreXmlPort: XmlPort "C5 Centre";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] CSV data contains extra fields.
        // [GIVEN] C5 Data Migration extension is installed
        Initialize();
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText('"1f1","1f2","cf1","cf2","cf3","cf4","cf5","cf6","cf7","cf8","cf9","cf10","cf11","cf12","extra40","extra39","extra38","extra37","extra36","extra35","extra34","extra33","extra32","extra31","extra30","extra29","extra28","extra27","extra26","extra25","extra24","extra23","extra22","extra21","extra20","extra19","extra18","extra17","extra16","extra15","extra14","extra13","extra12","extra11","extra10","extra9","extra8","extra7","extra6","extra5","extra4","extra3","extra2","extra1",1,"1991/01/01"' + CRLF);
        OutStream.WriteText('"2f1","2f2","cf1","cf2","cf3","cf4","cf5","cf6","cf7","cf8","cf9","cf10","cf11","cf12","extra40","extra39","extra38","extra37","extra36","extra35","extra34","extra33","extra32","extra31","extra30","extra29","extra28","extra27","extra26","extra25","extra24","extra23","extra22","extra21","extra20","extra19","extra18","extra17","extra16","extra15","extra14","extra13","extra12","extra11","extra10","extra9","extra8","extra7","extra6","extra5","extra4","extra3","extra2","extra1",2,"1992/02/02"' + CRLF);
        OutStream.WriteText('"3f1","3f2","cf1","cf2","cf3","cf4","cf5","cf6","cf7","cf8","cf9","cf10","cf11","cf12","extra40","extra39","extra38","extra37","extra36","extra35","extra34","extra33","extra32","extra31","extra30","extra29","extra28","extra27","extra26","extra25","extra24","extra23","extra22","extra21","extra20","extra19","extra18","extra17","extra16","extra15","extra14","extra13","extra12","extra11","extra10","extra9","extra8","extra7","extra6","extra5","extra4","extra3","extra2","extra1",3,"1993/03/03"' + CRLF);
        TempBlob.Blob.CreateInStream(InStream);

        // [WHEN] Importing data from CSV using XML Port
        CentreXmlPort.SetSource(InStream);
        CentreXmlPort.Import();

        // [THEN] All data is imported properly. Extra fields are ignored
        Assert.RecordCount(C5Centre, 3);
        C5Centre.FindFirst();
        Assert.AreEqual(1, C5Centre.RecId, 'Wrong data');
        Assert.AreEqual(UpperCase('1f1'), C5Centre.Centre, 'Wrong data'); // Uppercase since it's Code field.
        Assert.AreEqual('1f2', C5Centre.Name, 'Wrong data');
    end;

    local procedure Initialize()
    var
        C5Center: Record "C5 Centre";
    begin
        C5Center.DeleteAll();

        if IsInitialized then
            exit;

        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        IsInitialized := TRUE;
    end;
}
