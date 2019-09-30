// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148028 "Test Bank Imp. Bank Rec. Line"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        RandNoGen: Codeunit "Library - Random";
        AssertMsg: Label '%1 Field:"%2" different from expected.', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure TestDanskeBankSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        BankAccNo: Code[20];
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,280499,290499,+9120.63,"Entry text",+2820209.01');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,280499,280499,+3443.75,"Entry text",+2823652.76');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,280499,280499,+9593.51," Entry text",+2833246.27');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,280499,280499,+540.00,"Entry text",+2833786.27');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,280499,280499,+177.50,"Entry text",+2833963.77');
        // Extra lines
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,230115,280499,67.16,GU00004799,+2833786.27');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,230115,280499,-167.16,GU00004799,+2833786.27');
        WriteLine(OutStream, '"CMKV",9906141048,9906140001,1111111111,230115,280499,13.88,"Any text, ÆØÅ",+2833963.77');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('DANSKEBANK-CMKV', TempBlobANSI);

        BankAccNo := CreateBankAcc('DANSKEBANK-CMKV');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'DANSKEBANK-CMKV');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'DANSKEBANK-CMKV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 1, LineNo * 1, DMY2DATE(28, 4, 1999), DMY2DATE(29, 4, 1999), 'Entry text',
          9120.63);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 2, LineNo * 2, DMY2DATE(28, 4, 1999), DMY2DATE(28, 4, 1999), 'Entry text',
          3443.75);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 3, LineNo * 3, DMY2DATE(28, 4, 1999), DMY2DATE(28, 4, 1999), 'Entry text',
          9593.51);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 4, LineNo * 4, DMY2DATE(28, 4, 1999), DMY2DATE(28, 4, 1999), 'Entry text',
          540.0);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 5, LineNo * 5, DMY2DATE(28, 4, 1999), DMY2DATE(28, 4, 1999), 'Entry text',
          177.5);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 6, LineNo * 6, DMY2DATE(23, 1, 2015), DMY2DATE(28, 4, 1999), 'GU00004799',
          67.16);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 7, LineNo * 7, DMY2DATE(23, 1, 2015), DMY2DATE(28, 4, 1999), 'GU00004799',
          -167.16);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 8, LineNo * 8, DMY2DATE(23, 1, 2015), DMY2DATE(28, 4, 1999), 'Any text, ÆØÅ',
          13.88);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestDanskeBankCorpSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        BankAccNo: Code[20];
        SampleLine1Txt: Label '"CMKXKSX",0901060939,0901060016,1111111111,081208,081208,"DKK",-0.33,"",,"Short advice","",+0.00,-0.33","Extended advice 1","Extended advice 2"';
        SampleLine2Txt: Label '"CMKXKSX",0901060939,0901060016,1111111111,051208,081208,"DKK",+125.00,"",,"Short advice","",+0.00,+125.00"';
        SampleLine3Txt: Label '"CMKXKSX",0901060939,0901060016,1111111111,091208,091208,"DKK",+0.01,"",,"Short advice","",+0.00,+0.02","Extended advice 1","Extended advice 2","Extended advice 3","Extended advice 4","Extended advice 5","Extended advice 6","Extended advice 7","Extended advice 8","Extended advice 9","Extended advice 10","","Extended advice 12","","Extended advice 14","","Extended advice 16","","Extended advice 18"';
        ValidationExtendedAdvice1Txt: Label 'Extended advice 1 Extended advice 2';
        ValidationExtendedAdvice3Txt: Label 'Extended advice 1 Extended advice 2 Extended advice 3 Extended advice 4 Extended advice 5 Extended advice 6 Extended advice 7 Extended advice 8 Extended advice 9 Extended advice 10 Extended advice 12 Extended advice 14 Extended advice 16 Extended adv';
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, SampleLine1Txt);
        WriteLine(OutStream, SampleLine2Txt);
        WriteLine(OutStream, SampleLine3Txt);
        // Extra lines
        WriteLine(
          OutStream, '"CMKXKSX",0901060939,0901060016,1111111111,060615,070715,"DKK",+67.16,"",,"Short advice^2","",+0.00,+125.00","Extended Advice 1 ÆØÅ","Extended Advice 2 æøå"');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('DANSKEBANK-CMKXKSX', TempBlobANSI);

        BankAccNo := CreateBankAcc('DANSKEBANK-CMKXKSX');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'DANSKEBANK-CMKXKSX');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'DANSKEBANK-CMKXKSX');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 1, LineNo * 1, DMY2DATE(8, 12, 2008), DMY2DATE(8, 12, 2008), 'Short advice',
          ValidationExtendedAdvice1Txt, '', -0.33);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 2, LineNo * 2, DMY2DATE(5, 12, 2008), DMY2DATE(8, 12, 2008), 'Short advice',
          '', '', 125.0);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 3, LineNo * 3, DMY2DATE(9, 12, 2008), DMY2DATE(9, 12, 2008), 'Short advice',
          ValidationExtendedAdvice3Txt, '', 0.01);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 4, LineNo * 4, DMY2DATE(6, 6, 2015), DMY2DATE(7, 7, 2015), 'Short advice^2',
          'Extended Advice 1 ÆØÅ Extended Advice 2 æøå', '', 67.16);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestNordeaSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        BankAccNo: Code[20];
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, 'Bogført;Tekst;Rentedato;Beløb;Saldo');
        WriteLine(OutStream, '02-01-2013;Dankort-nota PLANTESKOLE RIN 3495;02-01-2013;-2032,48;32761,23');
        WriteLine(OutStream, '02-01-2013;Dankort-nota Lyngby Storcen 37821;02-01-2013;-15;34793,71');
        WriteLine(OutStream, '02-01-2013;"Dankort-nota INSPIRATION   14236";02-01-2013;-200;34808,71');
        WriteLine(OutStream, '28-12-2012;Dankort-nota Blomsterbergs  37789;28-12-2012;-104;35008,71');
        WriteLine(OutStream, '28-12-2012;Dankort-nota Parkering Kbh  29396;28-12-2012;-80,5;35112,71');
        // Extra lines
        WriteLine(OutStream, '28-12-2012;"Dankort-nota ÆØÅ;Blomsterbergs 37789";28-12-2012;104;35112,71');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('NORDEA-ERHVERV-CSV', TempBlobANSI);

        BankAccNo := CreateBankAcc('NORDEA-ERHVERV-CSV');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        BankAccRecon.ImportBankStatement();
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'NORDEA-ERHVERV-CSV');
        DataExch.SETRANGE("Data Exch. Def Code", 'NORDEA-ERHVERV-CSV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 1, LineNo * 1, DMY2DATE(2, 1, 2013), DMY2DATE(2, 1, 2013),
          'Dankort-nota PLANTESKOLE RIN 3495', -2032.48);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 2, LineNo * 2, DMY2DATE(2, 1, 2013), DMY2DATE(2, 1, 2013),
          'Dankort-nota Lyngby Storcen 37821', -15);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 3, LineNo * 3, DMY2DATE(2, 1, 2013), DMY2DATE(2, 1, 2013),
          'Dankort-nota INSPIRATION 14236', -200);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 4, LineNo * 4, DMY2DATE(28, 12, 2012), DMY2DATE(28, 12, 2012),
          'Dankort-nota Blomsterbergs 37789', -104);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 5, LineNo * 5, DMY2DATE(28, 12, 2012), DMY2DATE(28, 12, 2012),
          'Dankort-nota Parkering Kbh 29396', -80.5);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 6, LineNo * 6, DMY2DATE(28, 12, 2012), DMY2DATE(28, 12, 2012),
          'Dankort-nota ÆØÅ;Blomsterbergs 37789', 104);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestNordeaCorpSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        BankAccNo: Code[20];
        NordeaCorpSample1Txt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Testkunde","","20030221","20030221","15757.25","+","15757.25","","68","","OVERFØRSEL MEDDELNR 2001219","4","500","MEDDELNR 2001219","0","99999999999903","501","","502","KON konto 0979999035","0","","0","","0","","","","","","","266787.12","+","266787.12","","","Driftskonto","DK3420009999940560","N","Test Testsen","Testvej 10","9999 Testrup","","","","Ordrenr. 65656","99999999999903","1170200109040120000018","7","Betaling af følgende fakturaer:","Fakturanr. Beløb:","12345 2500,35","22345 1265,66","32345 5825,00","42345 3635,88","52345 2530,36","","","","","","","","","","","","","","","","","","","","","","","",""';
        NordeaCorpSample2Txt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Testkunde","","20030221","20030221","-10220.07","-","10220.07","","358","","UNITEL 17001394","4","502","17001394","0","03520580000012843","155","00000000047278743","502","KON konto 0979999035","0","","0","","0","","","","","","","-64653.28","-","64653.28","","","Kassekredit","DK3420009999940560","N","","","","","","","","","2999200109040120000125","0","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""';
        NordeaCorpTemplateTxt: Label '"NDEADKKKXXX","2999","9999940560","DKK","%1","","%2","%3","%4%5","%4","%5","","358","","%6","4","502","17001394","0","03520580000012843","155","00000000047278743","502","KON konto 0979999035","0","","0","","0","","","","","","","-64653.28","-","64653.28","","","Kassekredit","DK3420009999940560","N","","","","","","","","","2999200109040120000125","0","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""';
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, NordeaCorpSample1Txt);
        WriteLine(OutStream, NordeaCorpSample2Txt);
        // Extra lines
        WriteLine(OutStream, STRSUBSTNO(NordeaCorpTemplateTxt, 'Customer', '20131015', '20131015', '-', '100', 'Description'));
        WriteLine(
          OutStream, STRSUBSTNO(NordeaCorpTemplateTxt, 'J & V v.o.s.', '20131015', '20131016', '+', '12,543.54', 'Any Description, with ÆØÅ'));

        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('NORDEA-UNITEL-V3', TempBlobANSI);

        BankAccNo := CreateBankAcc('NORDEA-UNITEL-V3');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'NORDEA-UNITEL-V3');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'NORDEA-UNITEL-V3');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 1, LineNo * 1, DMY2DATE(21, 2, 2003), DMY2DATE(21, 2, 2003),
          'OVERFØRSEL MEDDELNR 2001219', 'Testkunde', 'Ordrenr. 65656', 15757.25);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 2, LineNo * 2, DMY2DATE(21, 2, 2003), DMY2DATE(21, 2, 2003),
          'UNITEL 17001394', 'Testkunde', '', -10220.07);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 3, LineNo * 3, DMY2DATE(15, 10, 2013), DMY2DATE(15, 10, 2013), 'Description',
          'Customer', '', -100);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 4, LineNo * 4, DMY2DATE(15, 10, 2013), DMY2DATE(16, 10, 2013),
          'Any Description, with ÆØÅ', 'J & V v.o.s.', '', 12543.54);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestBECSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        BankAccNo: Code[20];
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, '"Dato";"Tekst";"Beløb";"Saldo";"Valørdato";"Type";"Adviseringer";');
        WriteLine(OutStream, '05-04-2006;"OVERFØRSEL rha1";-1,00; 343,04;"05-04-2006";');
        WriteLine(OutStream, '05-04-2006;"OVERFØRSEL rha1";-21,00; 322,04;"05-04-2006";');
        WriteLine(OutStream, '06-04-2006;"RETUR"; 1,00; 246,04;"07-04-2006";"OVF.";"navn og adresse på indbetaler";');
        WriteLine(OutStream, '27-04-2006;"FRA PETER (PHC)"; 28,00; 231,48;"28-04-2006";"OVF.";"PETER H. CHRISTIANSEN ";');
        WriteLine(OutStream, '28-04-2006;"MODTAGET RETUR"; 7,00; 238,48;"01-05-2006";"OVF.";"Der er forgæves forsøgt overført et beløb til følgende konto: xxx";');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('BEC-CSV', TempBlobANSI);

        BankAccNo := CreateBankAcc('BEC-CSV');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'BEC-CSV');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'BEC-CSV');
        DataExch.FINDLAST();

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 1, LineNo * 1, DMY2DATE(5, 4, 2006), DMY2DATE(5, 4, 2006),
          'OVERFØRSEL rha1', -1);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 2, LineNo * 2, DMY2DATE(5, 4, 2006), DMY2DATE(5, 4, 2006),
          'OVERFØRSEL rha1', -21);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 3, LineNo * 3, DMY2DATE(6, 4, 2006), DMY2DATE(7, 4, 2006),
          'RETUR', 1);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 4, LineNo * 4, DMY2DATE(27, 4, 2006), DMY2DATE(28, 4, 2006),
          'FRA PETER (PHC)', 28);
        CreateLine(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 5, LineNo * 5, DMY2DATE(28, 4, 2006), DMY2DATE(1, 5, 2006),
          'MODTAGET RETUR', 7);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestBankDataSampleImport();
    var
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        DataExch: Record "Data Exch.";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        BankAccNo: Code[20];
        BankDataHeaderSampleTxt: Label '"ED000000000003","20130128","125352"';
        BankDataSample1Txt: Label '"ED010103000003","5","20120227","-32,00","2","080790002010094","20120227","99932981,40","test ik aftale","0","","","","","","Creditor ID","","","","","701205828770497959","DKK","","0,00","0,00","","","0,00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""';
        BankDataSample2Txt: Label '"ED010103000003","10","20120227","9000,00","2","080790002010094","20120227","99957978,46","240212 Indbet.ID=0000000000000018^2","0","","","","","","","","","PK test FI 75 sumbetalinger","","721205800344032009","DKK","","0,00","0,00","","","0,00","Payer Info","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""';
        BankDataFooterSampleTxt: Label '"ED999999999999","20130128","125352","11","48574,25"';
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, BankDataHeaderSampleTxt);
        WriteLine(OutStream, BankDataSample1Txt);
        WriteLine(OutStream, BankDataSample2Txt);
        WriteLine(OutStream, BankDataFooterSampleTxt);
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('BANKDATA-V3', TempBlobANSI);

        BankAccNo := CreateBankAcc('BANKDATA-V3');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'BANKDATA-V3');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'BANKDATA-V3');
        DataExch.FINDLAST();

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 1, LineNo * 1, DMY2DATE(27, 2, 2012), DMY2DATE(27, 2, 2012),
          'test ik aftale', 'Creditor ID', '', -32.0);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, DataExch."Entry No.", 2, LineNo * 2, DMY2DATE(27, 2, 2012), DMY2DATE(27, 2, 2012),
          '240212 Indbet.ID=0000000000000018^2', '', 'Payer Info', 9000.0);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    [Test]
    procedure TestSDCSampleImport();
    var
        DataExch: Record "Data Exch.";
        BankAccRecon: Record "Bank Acc. Reconciliation";
        BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line";
        TempExpdBankAccRecLine: Record "Bank Acc. Reconciliation Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        BankAccNo: Code[20];
        SDCSamplePosTxt: Label '0400 4010393855;30-01-2013;30-01-2013;26239,15;DKK;26239,15;DKK;;LØNOVERFØRSEL;;Q000004890;;;;;Skandinavisk Data Center A/S;Borupvang 1;2750  Ballerup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;';
        SDCSampleNeg1Txt: Label '0400 4010393855;07-01-2013;07-01-2013;-135,5;DKK;-135,5;DKK;;Dankort Kringleriet Nota 109850;;1537416545;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;';
        SDCSampleNeg2Txt: Label '0400 4010393855;07-01-2013;07-01-2013;-1840;DKK;-1840;DKK;;Betalingsservice CENTRALREGISTRET FOR MOTORKØRETØJER Aftalenr. 800441095;;306463112;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;';
        SDCTemplateTxt: Label '0400 4010393855;%1;%2;%3;DKK;%3;DKK;;%4;%5;306463112;;%6;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;';
        SDCHeaderTxt: Label 'Kontonr.;Dato;Valørdato;Beløb;Valuta;Oprindeligt beløb;Oprindelig valuta;Mod-konto;Tekst;Ekstern reference;Bankens reference;Samlepost;Betalt fra/til;Kortart;Betaler-id;Navn-adresse 1;Navn-adresse 2;Navn-adresse 3;Navn-adresse 4;Navn-adresse 5;Advis 1;Advis 2;Advis 3;Advis 4;Advis 5;Advis 6;Advis 7;Advis 8;Advis 9;Advis 10;Advis 11;Advis 12;Advis 13;Advis 14;Advis 15;Advis 16;Advis 17;Advis 18;Advis 19;Advis 20;Advis 21;Advis 22;Advis 23;Advis 24;Advis 25;Advis 26;Advis 27;Advis 28;Advis 29;Advis 30;Advis 31;Advis 32;Advis 33;Advis 34;Advis 35;Advis 36;Advis 37;Advis 38;Advis 39;Advis 40;Advis 41';
        Amount: Decimal;
        Description: Code[10];
        ExtDocNo: Code[10];
        PayerInfo: Code[10];
        WorkDateTxt: Text;
        NextDateTxt: Text;
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, SDCHeaderTxt);
        WriteLine(OutStream, SDCSampleNeg1Txt);
        WriteLine(OutStream, SDCSampleNeg2Txt);
        WriteLine(OutStream, SDCHeaderTxt);
        WriteLine(OutStream, SDCSamplePosTxt);
        // Extra lines
        Amount := RandNoGen.RandDec(10000, 2);
        Description := LibraryUtility.GenerateGUID();
        ExtDocNo :=
          LibraryUtility.GenerateRandomCode(BankAccReconLineTemplate.FIELDNO("Document No."), DATABASE::"Bank Acc. Reconciliation Line");
        PayerInfo :=
          LibraryUtility.GenerateRandomCode(
            BankAccReconLineTemplate.FIELDNO("Related-Party Name"), DATABASE::"Bank Acc. Reconciliation Line");
        WorkDateTxt := FORMAT(WORKDATE(), 0, '<Day,2>-<Month,2>-<Year4>');
        NextDateTxt := FORMAT(CALCDATE('<1D>', WORKDATE()), 0, '<Day,2>-<Month,2>-<Year4>');
        WriteLine(OutStream, SDCHeaderTxt);
        WriteLine(
          OutStream,
          STRSUBSTNO(
            SDCTemplateTxt, WorkDateTxt, NextDateTxt, FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,,>'), Description,
            ExtDocNo, PayerInfo));
        WriteLine(
          OutStream,
          STRSUBSTNO(
            SDCTemplateTxt, WorkDateTxt, NextDateTxt, FORMAT(-Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,,>'), Description,
            ExtDocNo, PayerInfo));

        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('SDC-CSV', TempBlobANSI);

        BankAccNo := CreateBankAcc('SDC-CSV');
        LibraryERM.CreateBankAccReconciliation(BankAccRecon, BankAccNo, BankAccRecon."Statement Type"::"Bank Reconciliation");

        // Exercise
        CreateBankAccReconTemplateWithFilter(BankAccReconLineTemplate, BankAccRecon);
        // ImportBankStmt.ImportBankStatementBankRec(BankAccRecon,'',TempBlobANSI,'SDC-CSV');
        BankAccRecon.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'SDC-CSV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := BankAccReconLineTemplate."Statement Line No.";
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 1, LineNo * 1, DMY2DATE(7, 1, 2013), DMY2DATE(7, 1, 2013),
          'Dankort Kringleriet Nota 109850', '', '', -135.5);
        CreateLineExt(TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 2, LineNo * 2, DMY2DATE(7, 1, 2013), DMY2DATE(7, 1, 2013),
          'Betalingsservice CENTRALREGISTRET FOR MOTORKØRETØJER Aftalenr. 800441095', '', '', -1840);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 3, LineNo * 3, DMY2DATE(30, 1, 2013), DMY2DATE(30, 1, 2013), 'LØNOVERFØRSEL',
          '', '', 26239.15);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 4, LineNo * 4, WORKDATE(), CALCDATE('<1D>', WORKDATE()), Description,
          PayerInfo, ExtDocNo, Amount);
        CreateLineExt(
          TempExpdBankAccRecLine, BankAccReconLineTemplate, EntryNo, 5, LineNo * 5, WORKDATE(), CALCDATE('<1D>', WORKDATE()), Description,
          PayerInfo, ExtDocNo, -Amount);

        AssertDataInTable(TempExpdBankAccRecLine, BankAccReconLineTemplate, '');
    end;

    local procedure CreateBankAcc(BankFormat: Code[20]): Code[20];
    var
        BankAcc: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc."Last Statement No." := GetRandomStatementNo(DATABASE::"Bank Account", BankAcc.FIELDNO("Last Statement No."));
        BankAcc."Bank Statement Import Format" := BankFormat;
        BankAcc.MODIFY(TRUE);
        EXIT(BankAcc."No.")
    end;

    procedure CreateBankAccReconTemplateWithFilter(var BankAccReconLineTemplate: Record "Bank Acc. Reconciliation Line"; BankAccRecon: Record "Bank Acc. Reconciliation");
    begin
        LibraryERM.CreateBankAccReconciliationLn(BankAccReconLineTemplate, BankAccRecon);

        BankAccReconLineTemplate.DELETE(TRUE); // The template needs to removed to not skew when comparing testresults.

        BankAccReconLineTemplate.SETRANGE("Bank Account No.", BankAccRecon."Bank Account No.");
        BankAccReconLineTemplate.SETRANGE("Statement No.", BankAccRecon."Statement No.");
    end;

    local procedure CreateLineExt(var TempBankReconLine: Record "Bank Acc. Reconciliation Line" TEMPORARY; BankReconLineTemplate: Record "Bank Acc. Reconciliation Line"; DataExchEntryNo: Integer; DataExchLineNo: Integer; LineNo: Integer; TransactionDate: Date; ValueDate: Date; TransactionText: Text[140]; PayerInfo: Text[250]; TransactionInfo: Text[50]; Amount: Decimal);
    begin
        TempBankReconLine.COPY(BankReconLineTemplate);
        TempBankReconLine.VALIDATE("Data Exch. Entry No.", DataExchEntryNo);
        TempBankReconLine.VALIDATE("Data Exch. Line No.", DataExchLineNo);
        TempBankReconLine.VALIDATE("Statement Line No.", LineNo);
        TempBankReconLine.VALIDATE("Transaction Date", TransactionDate);
        TempBankReconLine.VALIDATE("Transaction Text", TransactionText);
        TempBankReconLine.VALIDATE("Related-Party Name", PayerInfo);
        TempBankReconLine.VALIDATE("Additional Transaction Info", TransactionInfo);
        TempBankReconLine.VALIDATE("Statement Amount", Amount);
        TempBankReconLine.VALIDATE("Value Date", ValueDate);
        TempBankReconLine.INSERT();
    end;

    local procedure CreateLine(var TempBankReconLine: Record "Bank Acc. Reconciliation Line" TEMPORARY; BankReconLineTemplate: Record "Bank Acc. Reconciliation Line"; DataExchEntryNo: Integer; DataExchLineNo: Integer; LineNo: Integer; TransactionDate: Date; ValueDate: Date; Description: Text[50]; Amount: Decimal);
    begin
        CreateLineExt(
          TempBankReconLine, BankReconLineTemplate, DataExchEntryNo, DataExchLineNo, LineNo, TransactionDate, ValueDate, Description, '', '',
          Amount);
    end;

    local procedure GetRandomStatementNo(TableNo: Integer; FieldNo: Integer): Code[20];
    begin
        EXIT(COPYSTR(LibraryUtility.GenerateRandomCode(FieldNo, TableNo), 1, LibraryUtility.GetFieldLength(TableNo, FieldNo)))
    end;

    local procedure AssertDataInTable(var Expected: Record "Bank Acc. Reconciliation Line" TEMPORARY; var Actual: Record "Bank Acc. Reconciliation Line"; Msg: Text);
    var
        LineNo: Integer;
    begin
        Expected.FINDFIRST();
        Actual.FINDFIRST();
        REPEAT
            LineNo += 1;
            AreEqualRecords(Expected, Actual, Msg + 'Line:' + FORMAT(LineNo) + ' ');
        UNTIL (Expected.NEXT() = 0) OR (Actual.NEXT() = 0);
        Assert.AreEqual(Expected.COUNT(), Actual.COUNT(), 'Row count does not match');
    end;

    local procedure WriteLine(OutStream: OutStream; Text: Text);
    begin
        OutStream.WRITETEXT(Text);
        OutStream.WRITETEXT();
    end;

    procedure AreEqualRecords(ExpectedRecord: Variant; ActualRecord: Variant; Msg: Text);
    var
        ExpectedRecRef: RecordRef;
        ActualRecRef: RecordRef;
        i: Integer;
    begin
        ExpectedRecRef.GETTABLE(ExpectedRecord);
        ActualRecRef.GETTABLE(ActualRecord);

        Assert.AreEqual(ExpectedRecRef.NUMBER(), ActualRecRef.NUMBER(), 'Tables are not the same');

        FOR i := 1 TO ExpectedRecRef.FIELDCOUNT() DO
            IF IsSupportedType(ExpectedRecRef.FIELDINDEX(i).VALUE()) THEN
                Assert.AreEqual(ExpectedRecRef.FIELDINDEX(i).VALUE(), ActualRecRef.FIELDINDEX(i).VALUE(),
                  STRSUBSTNO(AssertMsg, Msg, ExpectedRecRef.FIELDINDEX(i).NAME()));
    end;

    local procedure IsSupportedType(Value: Variant): Boolean;
    begin
        EXIT(Value.ISBOOLEAN() OR
          Value.ISOPTION() OR
          Value.ISINTEGER() OR
          Value.ISDECIMAL() OR
          Value.ISTEXT() OR
          Value.ISCODE() OR
          Value.ISDATE() OR
          Value.ISTIME());
    end;

    LOCAL PROCEDURE ConvertOEMToANSI(SourceTempBlob: Codeunit "Temp Blob"; VAR DestinationTempBlob: Codeunit "Temp Blob");
    var
        InStreamObj: InStream;
        OutStreamObj: OutStream;
        ParsedText: Text;
    BEGIN
        SourceTempBlob.CreateInStream(InStreamObj);
        DestinationTempBlob.CreateOutStream(OutStreamObj, TextEncoding::Windows);

        WHILE NOT InStreamObj.EOS() DO begin
            InStreamObj.ReadText(ParsedText);
            OutStreamObj.WriteText(ParsedText);
            OutStreamObj.WriteText();
        END;
    end;

    local procedure SetupSourceMock(DataExchDefCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlobList: Codeunit "Temp Blob List";
        ErmPeSourceTestMock: Codeunit "ERM PE Source test mock";
    begin
        TempBlobList.Add(TempBlob);
        ErmPeSourceTestMock.SetTempBlobList(TempBlobList);

        DataExchDef.GET(DataExchDefCode);
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"ERM PE Source test mock";
        DataExchDef.MODIFY();
    end;
}



