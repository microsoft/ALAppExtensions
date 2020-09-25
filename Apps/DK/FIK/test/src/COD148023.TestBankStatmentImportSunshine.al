// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148023 "Bank Statement Import Sunshine"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        TempBlobList: Codeunit "Temp Blob List";
        FileExtentionTxt: Label 'csv';
        ImportLineTxt: Label 'CMKV,%1,%2,%3,%4,%5,%6,%7,%8';
        RecordsMismatchErr: Label '%1 records on %2 %3 do not match.', Comment = '%1=Table;%2=Table;%3=Field';

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure ImportExistingGenJournalLine();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Amount: Decimal;
        "Count": Integer;
        Description: Text[100];
        FileName: Text;
    begin
        // Pre-Setup
        CreateGenJnlBatchWithBalBankAcc(GenJnlBatch);
        CreateGenJnlLine(GenJnlLine, GenJnlBatch);

        // Setup
        FileName := WriteRecordToFile(GenJnlLine);

        // Post-Setup
        Amount := GenJnlLine.Amount;
        Description := GenJnlLine.Description;

        // Exercise
        Count := ImportBankStmtFile(GenJnlLine, FileName);

        // Verify
        ValidateImportedLines(GenJnlBatch, Amount, Description, Count + 1);
    end;

    local procedure CreateBankAccount(): Code[20];
    var
        BankAcc: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.INIT();
        BankExportImportSetup.Code :=
          LibraryUtility.GenerateRandomCode(BankExportImportSetup.FIELDNO(Code), DATABASE::"Bank Export/Import Setup");
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        BankExportImportSetup."Data Exch. Def. Code" := FindDataExchDef();
        BankExportImportSetup.INSERT();

        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        BankAcc.VALIDATE(
          "Bank Account No.", STRSUBSTNO('%1%2', LibraryRandom.RandIntInRange(11111, 99999), LibraryRandom.RandIntInRange(11111, 99999)));
        BankAcc."Bank Statement Import Format" := BankExportImportSetup.Code;
        BankAcc.MODIFY(TRUE);
        EXIT(BankAcc."No.");
    end;

    local procedure CreateGenJnlBatchWithBalBankAcc(var GenJnlBatch: Record "Gen. Journal Batch");
    begin
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, LibraryERM.SelectGenJnlTemplate());
        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", CreateBankAccount());
        GenJnlBatch.MODIFY(TRUE);
    end;

    local procedure CreateGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; GenJnlBatch: Record "Gen. Journal Batch");
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE(Description, LibraryUtility.GenerateGUID());
        GenJnlLine.MODIFY(TRUE);
    end;

    local procedure FindDataExchDef(): Code[20];
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        WITH DataExchDef DO BEGIN
            SETRANGE(Type, Type::"Bank Statement Import");
            SETRANGE("Reading/Writing XMLport", XMLPORT::"Data Exch. Import - CSV");
            SETRANGE("Header Lines", 0);
            FINDFIRST();
            EXIT(Code);
        END;
    end;

    local procedure ImportBankStmtFile(GenJnlLine: Record "Gen. Journal Line"; FileName: Text) "Count": Integer;
    var
        TempBlob: Codeunit "Temp Blob";
        FileManageMent: Codeunit "File Management";
        Index: Integer;
    begin
        FileManageMent.BLOBImportFromServerFile(TempBlob, FileName);
        SetupSourceMock(FindDataExchDef(), TempBlob);
        Count := LibraryRandom.RandIntInRange(2, 10);
        FOR Index := 1 TO Count DO
            GenJnlLine.ImportBankStatement();
    end;

    local procedure ValidateImportedLines(GenJnlBatch: Record "Gen. Journal Batch"; ExpectedAmount: Decimal; ExpectedDescription: Text[100]; ExpectedCount: Integer);
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        WITH GenJnlLine DO BEGIN
            SETRANGE("Journal Template Name", GenJnlBatch."Journal Template Name");
            SETRANGE("Journal Batch Name", GenJnlBatch.Name);
            SETRANGE("Posting Date", WORKDATE());
            SETRANGE(Amount, ExpectedAmount);
            SETRANGE(Description, ExpectedDescription);
            Assert.AreEqual(ExpectedCount, COUNT(), STRSUBSTNO(RecordsMismatchErr, TABLECAPTION(), GenJnlBatch.TABLECAPTION(), GenJnlBatch.Name));
        END;
    end;

    local procedure WriteRecordToFile(GenJnlLine: Record "Gen. Journal Line") FileName: Text;
    var
        FileMgt: Codeunit "File Management";
        TempFile: File;
    begin
        FileName := FileMgt.ServerTempFileName(FileExtentionTxt);
        TempFile.WRITEMODE := TRUE;
        TempFile.TEXTMODE := TRUE;
        TempFile.CREATE(FileName);
        TempFile.WRITE(
          STRSUBSTNO(ImportLineTxt,
            LibraryRandom.RandIntInRange(111111111, 999999999), LibraryRandom.RandIntInRange(111111111, 999999999),
            LibraryRandom.RandIntInRange(111111111, 999999999), FORMAT(WORKDATE(), 0, '<Day,2><Month,2><Year>'),
            FORMAT(WORKDATE(), 0, '<Day,2><Month,2><Year>'), FORMAT(-GenJnlLine.Amount, 0, 2), GenJnlLine.Description,
            LibraryRandom.RandDecInRange(1111, 9999, 2)));
        TempFile.CLOSE();
    end;

    local procedure SetupSourceMock(DataExchDefCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    var
        DataExchDef: Record "Data Exch. Def";
        ErmPeSourceTestMock: Codeunit "ERM PE Source test mock";
    begin
        TempBlobList.Add(TempBlob);
        ErmPeSourceTestMock.SetTempBlobList(TempBlobList);
        DataExchDef.GET(DataExchDefCode);
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"ERM PE Source test mock";
        DataExchDef.MODIFY();
    end;
}



