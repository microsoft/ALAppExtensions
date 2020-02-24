// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148026 "Test Bank Imp. Gen. Jnl. Line"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        RandNoGen: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        TempBlobList: Codeunit "Temp Blob List";
        AssertMsg: Label '%1 Field:"%2" different from expected.', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure TestDanskeBankSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
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

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'DANSKEBANK-CMKV');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'DANSKEBANK-CMKV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(28, 4, 1999), 'Entry text', -9120.63);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(28, 4, 1999), 'Entry text', -3443.75);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(28, 4, 1999), 'Entry text', -9593.51);
        CreateLine(TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 4, LineNo * 4, IncCode(3, DocNo), DMY2DATE(28, 4, 1999), 'Entry text', -540.0);
        CreateLine(TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 5, LineNo * 5, IncCode(4, DocNo), DMY2DATE(28, 4, 1999), 'Entry text', -177.5);
        CreateLine(TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 6, LineNo * 6, IncCode(5, DocNo), DMY2DATE(23, 1, 2015), 'GU00004799', -67.16);
        CreateLine(TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 7, LineNo * 7, IncCode(6, DocNo), DMY2DATE(23, 1, 2015), 'GU00004799', 167.16);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 8, LineNo * 8, IncCode(7, DocNo), DMY2DATE(23, 1, 2015), 'Any text, ÆØÅ', -13.88);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestNordeaSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
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

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'NORDEA-ERHVERV-CSV');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'NORDEA-ERHVERV-CSV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(2, 1, 2013),
          'Dankort-nota PLANTESKOLE RIN 3495', 2032.48);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(2, 1, 2013),
          'Dankort-nota Lyngby Storcen 37821', 15);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(2, 1, 2013),
          'Dankort-nota INSPIRATION 14236', 200);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 4, LineNo * 4, IncCode(3, DocNo), DMY2DATE(28, 12, 2012),
          'Dankort-nota Blomsterbergs 37789', 104);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 5, LineNo * 5, IncCode(4, DocNo), DMY2DATE(28, 12, 2012),
          'Dankort-nota Parkering Kbh 29396', 80.5);
        CreateLine(TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 6, LineNo * 6, IncCode(5, DocNo), DMY2DATE(28, 12, 2012), 'Dankort-nota ÆØÅ;Blomsterbergs 37789', -104);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestBECSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        DocNo: Code[20];
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

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'BEC-CSV');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'BEC-CSV');
        DataExch.FINDLAST();

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, DataExch."Entry No.", 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(5, 4, 2006),
          'OVERFØRSEL rha1', 1);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, DataExch."Entry No.", 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(5, 4, 2006),
          'OVERFØRSEL rha1', 21);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, DataExch."Entry No.", 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(6, 4, 2006), 'RETUR', -1);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, DataExch."Entry No.", 4, LineNo * 4, IncCode(3, DocNo), DMY2DATE(27, 4, 2006),
          'FRA PETER (PHC)', -28);
        CreateLine(
          TempExpdGenJnlLine, GenJnlLineTemplate, DataExch."Entry No.", 5, LineNo * 5, IncCode(4, DocNo), DMY2DATE(28, 4, 2006),
          'MODTAGET RETUR', -7);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestDanskeBankCorpSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
        DBCorpSample1Txt: Label '"CMKXKSX",0901060939,0901060016,1111111111,091208,091208,"DKK",+0.01,"",,"Short Advice","",+0.00,+0.01","Extended advice 1","Extended advice 2","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",', Locked = true;
        DBCorpSample2Txt: Label '"CMKXKSX",0901060939,0901060016,1111111111,051208,081208,"DKK",-125.00,"",,"Short Advice","",+0.00,+0.00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",', Locked = true;
        DBCorpSampleTemplateTxt: Label '"CMKXKSX",0901060939,0901060016,1111111111,%1,%2,"DKK",%3,"",,%4,"",+0.00,+0.00",%5,%6,"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",', Locked = true;
    begin
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, DBCorpSample1Txt);
        WriteLine(OutStream, DBCorpSample2Txt);
        // Extra lines
        WriteLine(OutStream, STRSUBSTNO(DBCorpSampleTemplateTxt, '081208', '081208', '+1000.00', 'Short Advice æøå', 'Extended Advice^d', ''));
        WriteLine(OutStream, STRSUBSTNO(DBCorpSampleTemplateTxt, '311208', '010109', '-493.00', 'Short Advice ÆØÅ', '', ''));

        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('DANSKEBANK-CMKXKSX', TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'DANSKEBANK-CMKXKSX');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'DANSKEBANK-CMKXKSX');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(9, 12, 2008), 'Short Advice',
          'Extended advice 1 Extended advice 2', '', -0.01);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(5, 12, 2008), 'Short Advice', '', '', 125.0);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(8, 12, 2008), 'Short Advice æøå',
          'Extended Advice^d', '', -1000.0);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 4, LineNo * 4, IncCode(3, DocNo), DMY2DATE(31, 12, 2008), 'Short Advice ÆØÅ', '', '',
          493.0);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestNordeaCorpSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
        NordeaCorpSample1Txt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Testkunde","","20030221","20030221","15757.25","+","15757.25","","68","","OVERFØRSEL MEDDELNR 2001219","4","500","MEDDELNR 2001219","0","99999999999903","501","","502","KON konto 0979999035","0","","0","","0","","","","","","","266787.12","+","266787.12","","","Driftskonto","DK3420009999940560","N","Test Testsen","Testvej 10","9999 Testrup","","","","Ordrenr. 65656","99999999999903","1170200109040120000018","7","Betaling af følgende fakturaer:","Fakturanr. Beløb:","12345 2500,35","22345 1265,66","32345 5825,00","42345 3635,88","52345 2530,36","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        NordeaCorpSample2Txt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Testkunde","","20030221","20030221","-10220.07","-","10220.07","","358","","UNITEL 17001394","4","502","17001394","0","03520580000012843","155","00000000047278743","502","KON konto 0979999035","0","","0","","0","","","","","","","-64653.28","-","64653.28","","","Kassekredit","DK3420009999940560","N","","","","","","","","","2999200109040120000125","0","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        NordeaCorpTemplateTxt: Label '"NDEADKKKXXX","2999","9999940560","DKK","%1","","%2","%3","%4%5","%4","%5","","358","","%6","4","502","17001394","0","03520580000012843","155","00000000047278743","502","KON konto 0979999035","0","","0","","0","","","","","","","-64653.28","-","64653.28","","","Kassekredit","DK3420009999940560","N","","","","","","","","","2999200109040120000125","0","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
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

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'NORDEA-UNITEL-V3');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'NORDEA-UNITEL-V3');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(21, 2, 2003),
          'OVERFØRSEL MEDDELNR 2001219', 'Testkunde', 'Ordrenr. 65656', -15757.25);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(21, 2, 2003), 'UNITEL 17001394',
          'Testkunde', '', 10220.07);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(15, 10, 2013), 'Description', 'Customer', '',
          100);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 4, LineNo * 4, IncCode(3, DocNo), DMY2DATE(15, 10, 2013), 'Any Description, with ÆØÅ',
          'J & V v.o.s.', '', -12543.54);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestBankDataSampleImport();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        DataExch: Record "Data Exch.";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
        BankDataHeaderSampleTxt: Label '"ED000000000003","20130128","125352"', Locked = true;
        BankDataSample1Txt: Label '"ED010103000003","5","20120227","-32,00","2","080790002010094","20120227","99932981,40","test ik aftale","0","","","","","","Creditor ID","","","","","701205828770497959","DKK","","0,00","0,00","","","0,00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        BankDataSample2Txt: Label '"ED010103000003","10","20120227","9000,00","2","080790002010094","20120227","99957978,46","240212 Indbet.ID=0000000000000018^2","0","","","","","","","","","PK test FI 75 sumbetalinger","","721205800344032009","DKK","","0,00","0,00","","","0,00","Payer Info","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        BankDataFooterSampleTxt: Label '"ED999999999999","20130128","125352","11","48574,25"', Locked = true;
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

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'BANKDATA-V3');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'BANKDATA-V3');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(27, 2, 2012), 'test ik aftale',
          'Creditor ID', '', 32.0);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(27, 2, 2012),
          '240212 Indbet.ID=0000000000000018^2', '', 'Payer Info', -9000.0);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestSDCSampleImport();
    var
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" TEMPORARY;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
        SDCSamplePosTxt: Label '0400 4010393855;30-01-2013;30-01-2013;26239,15;DKK;26239,15;DKK;;LØNOVERFØRSEL;;Q000004890;;;;;Skandinavisk Data Center A/S;Borupvang 1;2750  Ballerup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;', Locked = true;
        SDCSampleNeg1Txt: Label '0400 4010393855;07-01-2013;07-01-2013;-135,5;DKK;-135,5;DKK;;Dankort Kringleriet Nota 109850;;1537416545;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;', Locked = true;
        SDCSampleNeg2Txt: Label '0400 4010393855;07-01-2013;07-01-2013;-1840;DKK;-1840;DKK;;Betalingsservice CENTRALREGISTRET FOR MOTORKØRETØJER Aftalenr. 800441095;;306463112;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;', Locked = true;
        SDCTemplateTxt: Label '0400 4010393855;%1;%2;%3;DKK;%3;DKK;;%4;%5;306463112;;%6;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;', Locked = true;
        SDCHeaderTxt: Label 'Kontonr.;Dato;Valørdato;Beløb;Valuta;Oprindeligt beløb;Oprindelig valuta;Mod-konto;Tekst;Ekstern reference;Bankens reference;Samlepost;Betalt fra/til;Kortart;Betaler-id;Navn-adresse 1;Navn-adresse 2;Navn-adresse 3;Navn-adresse 4;Navn-adresse 5;Advis 1;Advis 2;Advis 3;Advis 4;Advis 5;Advis 6;Advis 7;Advis 8;Advis 9;Advis 10;Advis 11;Advis 12;Advis 13;Advis 14;Advis 15;Advis 16;Advis 17;Advis 18;Advis 19;Advis 20;Advis 21;Advis 22;Advis 23;Advis 24;Advis 25;Advis 26;Advis 27;Advis 28;Advis 29;Advis 30;Advis 31;Advis 32;Advis 33;Advis 34;Advis 35;Advis 36;Advis 37;Advis 38;Advis 39;Advis 40;Advis 41', Locked = true;
        Amount: Decimal;
        Description: Code[10];
        ExtDocNo: Code[10];
        PayerInfo: Code[10];
        WorkDateTxt: Text;
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
        ExtDocNo := LibraryUtility.GenerateRandomCode(GenJnlLineTemplate.FIELDNO("Document No."), DATABASE::"Gen. Journal Line");
        PayerInfo := LibraryUtility.GenerateRandomCode(GenJnlLineTemplate.FIELDNO("Payer Information"), DATABASE::"Gen. Journal Line");
        WorkDateTxt := FORMAT(WORKDATE(), 0, '<Day,2>-<Month,2>-<Year4>');
        WriteLine(OutStream, SDCHeaderTxt);
        WriteLine(
          OutStream,
          STRSUBSTNO(
            SDCTemplateTxt, WorkDateTxt, CALCDATE('<1D>', WORKDATE()), FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,,>'),
            Description, ExtDocNo, PayerInfo));
        WriteLine(
          OutStream,
          STRSUBSTNO(
            SDCTemplateTxt, WorkDateTxt, CALCDATE('<1D>', WORKDATE()), FORMAT(-Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,,>'),
            Description, ExtDocNo, PayerInfo));

        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('SDC-CSV', TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate, 'SDC-CSV');
        GenJnlLineTemplate.ImportBankStatement();
        DataExch.SETRANGE("Data Exch. Def Code", 'SDC-CSV');
        DataExch.FINDLAST();
        EntryNo := DataExch."Entry No.";

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 1, LineNo * 1, IncCode(0, DocNo), DMY2DATE(7, 1, 2013),
          'Dankort Kringleriet Nota 109850', '', '', 135.5);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 2, LineNo * 2, IncCode(1, DocNo), DMY2DATE(7, 1, 2013),
          'Betalingsservice CENTRALREGISTRET FOR MOTORKØRETØJER Aftalenr. 800441095', '', '', 1840);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 3, LineNo * 3, IncCode(2, DocNo), DMY2DATE(30, 1, 2013), 'LØNOVERFØRSEL', '', '',
          -26239.15);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 4, LineNo * 4, IncCode(3, DocNo), WORKDATE(), Description, PayerInfo, ExtDocNo, -Amount);
        CreateLineExt(
          TempExpdGenJnlLine, GenJnlLineTemplate, EntryNo, 5, LineNo * 5, IncCode(4, DocNo), WORKDATE(), Description, PayerInfo, ExtDocNo, Amount);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    procedure CreateGenJnlLineTemplateWithFilter(var GenJnlLineTemplate: Record "Gen. Journal Line"; DataExchDefCode: Code[20]);
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
    begin
        CreateBankAccWithBankStatementSetup(BankAccount, DataExchDefCode);
        LibraryERM.CreateGenJournalTemplate(GenJnlTemplate);
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, GenJnlTemplate.Name);
        GenJnlBatch."Bal. Account Type" := GenJnlBatch."Bal. Account Type"::"Bank Account";
        GenJnlBatch."Bal. Account No." := BankAccount."No.";
        GenJnlBatch.MODIFY();

        LibraryERM.CreateGeneralJnlLine(
          GenJnlLineTemplate, GenJnlTemplate.Name, GenJnlBatch.Name, GenJnlLineTemplate."Document Type"::Payment,
          GenJnlLineTemplate."Account Type"::"G/L Account", '', 0);
        GenJnlLineTemplate.VALIDATE("External Document No.", ''); // External Doc. No. is ignored. The user has to specify a value.
        GenJnlLineTemplate.MODIFY(TRUE);
        GenJnlLineTemplate.DELETE(TRUE); // The template needs to removed to not skew when comparing testresults.

        GenJnlLineTemplate.SETRANGE("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLineTemplate.SETRANGE("Journal Batch Name", GenJnlBatch.Name);
    end;

    local procedure CreateLineExt(var TempGenJnlLine: Record "Gen. Journal Line" TEMPORARY; GenJnlLineTemplate: Record "Gen. Journal Line"; DataExchEntryNo: Integer; DataExchLineNo: Integer; LineNo: Integer; DocumentNo: Code[20]; PostingDate: Date; Description: Text[100]; PayerInfo: Text[50]; TransactionInfo: Text[50]; Amount: Decimal);
    begin
        TempGenJnlLine.COPY(GenJnlLineTemplate);
        TempGenJnlLine.VALIDATE("Data Exch. Entry No.", DataExchEntryNo);
        TempGenJnlLine.VALIDATE("Data Exch. Line No.", DataExchLineNo);
        TempGenJnlLine.VALIDATE("Line No.", LineNo);
        TempGenJnlLine.VALIDATE("Document No.", DocumentNo);
        TempGenJnlLine.VALIDATE("Posting Date", PostingDate);
        TempGenJnlLine.VALIDATE(Description, Description);
        TempGenJnlLine.VALIDATE("Payer Information", PayerInfo);
        TempGenJnlLine.VALIDATE("Transaction Information", TransactionInfo);
        TempGenJnlLine.VALIDATE(Amount, Amount);
        TempGenJnlLine.INSERT();
    end;

    local procedure CreateLine(var TempGenJnlLine: Record "Gen. Journal Line" TEMPORARY; GenJnlLineTemplate: Record "Gen. Journal Line"; DataExchEntryNo: Integer; DataExchLineNo: Integer; LineNo: Integer; DocumentNo: Code[20]; PostingDate: Date; Description: Text[100]; Amount: Decimal);
    begin
        CreateLineExt(
          TempGenJnlLine, GenJnlLineTemplate, DataExchEntryNo, DataExchLineNo, LineNo, DocumentNo, PostingDate, Description, '', '', Amount);
    end;

    local procedure AssertDataInTable(var Expected: Record "Gen. Journal Line" TEMPORARY; var Actual: Record "Gen. Journal Line"; Msg: Text);
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

    local procedure IncCode(IncrementCount: Integer; TextToIncrement: Code[20]): Code[20];
    var
        i: Integer;
    begin
        FOR i := 1 TO IncrementCount DO
            TextToIncrement := INCSTR(TextToIncrement);

        EXIT(TextToIncrement);
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

    END;

    local procedure CreateBankAccWithBankStatementSetup(var BankAccount: Record "Bank Account"; DataExchDefCode: Code[20]);
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.INIT();
        BankExportImportSetup.Code :=
          LibraryUtility.GenerateRandomCode(BankExportImportSetup.FIELDNO(Code), DATABASE::"Bank Export/Import Setup");
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        IF DataExchDefCode <> '' THEN
            BankExportImportSetup."Data Exch. Def. Code" := DataExchDefCode;
        BankExportImportSetup.INSERT();

        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.VALIDATE("Last Statement No.",
          LibraryUtility.GenerateRandomCode(BankAccount.FIELDNO("Last Statement No."), DATABASE::"Bank Account"));
        BankAccount."Bank Statement Import Format" := BankExportImportSetup.Code;
        BankAccount.MODIFY(TRUE);
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



