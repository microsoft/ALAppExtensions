codeunit 130103 "Library - Amc Web Service"
{

    trigger OnRun()
    begin
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        LocalhostURLTxt: Label 'https://localhost:8080/', Locked = true;
        DemoFileLine01_EncodUTF8Txt: Label '<paymentExportBank xmlns="%1"><amcpaymentreq xmlns=''''><banktransjournal>', Locked = true;
        DemoFileLine02_EncodUTF8Txt: Label '<journalname>200106</journalname><journalnumber>journal-02</journalnumber><transmissionref1>01</transmissionref1><uniqueid>DE-01</uniqueid>', Locked = true;
        DemoFileLine03_EncodUTF8Txt: Label '<banktransus><countryoforigin>DE</countryoforigin><uniqueid>DE01US</uniqueid><ownaddress><address1>Grundtvigsvej 29</address1>', Locked = true;
        DemoFileLine04_EncodUTF8Txt: Label '<address2></address2><city></city><countryiso>DK</countryiso><name>AMC</name></ownaddress>', Locked = true;
        DemoFileLine05_EncodUTF8Txt: Label '<banktransthem><uniqueid>DE01TH</uniqueid><receiversaddress><countryiso>DE</countryiso><name>Tysk kreditor 1</name></receiversaddress>', Locked = true;
        DemoFileLine06_EncodUTF8Txt: Label '<paymenttype>DomAcc2Acc</paymenttype><costs>Shared</costs>', Locked = true;
        DemoFileLine07_EncodUTF8Txt: Label '<banktransspec><discountused>0.0</discountused><invoiceref>6541695</invoiceref><uniqueid>DE01SP</uniqueid><amountdetails><payamount>0.08</payamount>', Locked = true;
        DemoFileLine08_EncodUTF8Txt: Label '<paycurrency>EUR</paycurrency><paydate>%1</paydate></amountdetails></banktransspec>', Locked = true;
        DemoFileLine09_EncodUTF8Txt: Label '<banktransspec><discountused>0.0</discountused><invoiceref>6541654</invoiceref><uniqueid>DE02SP</uniqueid><amountdetails><payamount>0.02</payamount>', Locked = true;
        DemoFileLine10_EncodUTF8Txt: Label '<paycurrency>EUR</paycurrency><paydate>%1</paydate></amountdetails></banktransspec>', Locked = true;
        DemoFileLine11_EncodUTF8Txt: Label '<amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>2014-05-29</paydate></amountdetails><receiversbankaccount>', Locked = true;
        DemoFileLine12_EncodUTF8Txt: Label '<bankaccount>0011350044</bankaccount><intregno>51420600</intregno><intregnotype>GermanBankleitzahl</intregnotype></receiversbankaccount></banktransthem>', Locked = true;
        DemoFileLine13_EncodUTF8Txt: Label '<ownbankaccount><bankaccount>0011350034</bankaccount><swiftcode>HANDDEFF</swiftcode></ownbankaccount>', Locked = true;
        DemoFileLine14_EncodUTF8Txt: Label '</banktransus></banktransjournal></amcpaymentreq><bank xmlns=''''>Handels EDI DE</bank><language xmlns=''''>ENU</language></paymentExportBank>', Locked = true;
        NordeaCorporate_EncodUTF8Txt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Demo User","","20030221","20030221","15757.25","+","15757.25","","68","","Order 12345","4","500","MEDDELNR 2001219","0","99999999999903","501","","502","KON konto 0979999035","0","","0","","0","","","","","","","266787.12","+","266787.12","","","Driftskonto","DK3420009999940560","N","Test Testsen","Testvej 10","9999 Testrup","","","","Ordrenr. 65656","99999999999903","1170200109040120000018","7","Betaling af f¹lgende fakturaer:","Fakturanr. Bel¹b:","12345 2500,35","22345 1265,66","32345 5825,00","42345 3635,88","52345 2530,36","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        SampleFileLine01_EncodUTF8Txt: Label '<paymentExportBank xmlns="%1">', Locked = true;
        SampleFileLine02_EncodUTF8Txt: Label '<amcpaymentreq><banktransjournal><erpsystem>HelloFromCAL</erpsystem><journalname>Test 012</journalname><transmissionref1>01</transmissionref1>', Locked = true;
        SampleFileLine03_EncodUTF8Txt: Label '<uniqueid>%1</uniqueid><banktransus><countryoforigin>DE</countryoforigin><ownreference>AMC0001TEST</ownreference><uniqueid>DE01US</uniqueid>', Locked = true;
        SampleFileLine04_EncodUTF8Txt: Label '<banktransthem><customerid>Kreditor 1</customerid><uniqueid>DE01TH</uniqueid><receiversaddress><address1>German vendor 1</address1><countryiso>DE</countryiso>', Locked = true;
        SampleFileLine05_EncodUTF8Txt: Label '<name>Vendor name</name></receiversaddress><banktransspec><discountused>0.0</discountused><invoiceref>654123</invoiceref><origamount>0.20</origamount>', Locked = true;
        SampleFileLine06_EncodUTF8Txt: Label '<uniqueid>DE01SP</uniqueid><amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>%1</paydate></amountdetails></banktransspec>', Locked = true;
        SampleFileLine07_EncodUTF8Txt: Label '<amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>%1</paydate></amountdetails><receiversbankaccount><bankaccount>', Locked = true;
        SampleFileLine08_EncodUTF8Txt: Label '1111350044</bankaccount><intregno>51420600</intregno><intregnotype>GermanBankleitzahl</intregnotype></receiversbankaccount><paymenttype>DomAcc2Acc</paymenttype>', Locked = true;
        SampleFileLine09_EncodUTF8Txt: Label '<costs>PayerPaysAll</costs></banktransthem><ownbankaccount><bankaccount>1111350034</bankaccount><swiftcode>HANDDEFF</swiftcode></ownbankaccount>', Locked = true;
        SampleFileLine10_EncodUTF8Txt: Label '<ownaddress><address1>Grundtvigsvej 29</address1><countryiso>DE</countryiso><name>AMC Consult A/S</name></ownaddress><ownaddressinfo>frombank</ownaddressinfo>', Locked = true;
        SampleFileLine11_EncodUTF8Txt: Label '</banktransus></banktransjournal></amcpaymentreq><bank xmlns="">Handels EDI DE</bank><language xmlns=''''>ENU</language></paymentExportBank>', Locked = true;
        SampleFileCDataLine01_EncodUTF8Txt: Label '<paymentExportBank xmlns="%1">', Locked = true;
        SampleFileCDataLine02_EncodUTF8Txt: Label '<amcpaymentreq xmlns=""><version /><banktransjournal><erpsystem>Microsoft Dynamics NAV</erpsystem><journalname>PAYMENT</journalname><journalnumber>BANK</journalnumber><legalregistrationnumber>GB777777777</legalregistrationnumber><messageref>1004</messageref><transmissionref1>1004</transmissionref1>', Locked = true;
        SampleFileCDataLine03_EncodUTF8Txt: Label '<uniqueid>1004</uniqueid><banktransus><bankaccountcurrency>GBP</bankaccountcurrency><countryoforigin>GB</countryoforigin><messagetoownbank>1</messagetoownbank><ownreference>1</ownreference><uniqueid>%1</uniqueid>', Locked = true;
        SampleFileCDataLine04_EncodUTF8Txt: Label '<banktransthem><customerid>10000</customerid><uniqueid>1004-TH</uniqueid><regulatoryreporting /><receiversaddress><address1>10 North Lake Avenue</address1><city>London</city><name>London Postmaster</name><countryiso>GB</countryiso>', Locked = true;
        SampleFileCDataLine05_EncodUTF8Txt: Label '<zipcode>N12 5XY</zipcode></receiversaddress><banktransspec><cardref /><discountused /><origamount>0</origamount>', Locked = true;
        SampleFileCDataLine06_EncodUTF8Txt: Label '<uniqueid>1004-SP</uniqueid><amountdetails><payamount>134.56</payamount><paycurrency>GBP</paycurrency><paydate>%1</paydate></amountdetails></banktransspec>', Locked = true;
        SampleFileCDataLine07_EncodUTF8Txt: Label '<emailadvice><recipient>london.postmaster@contoso.com</recipient><paymentmessage><linenum>1</linenum></paymentmessage></emailadvice><paymentmessage><linenum>1</linenum></paymentmessage><amountdetails><payamount>134.56</payamount><paycurrency>GBP</paycurrency><paydate>%1</paydate></amountdetails>', Locked = true;
        SampleFileCDataLine08_EncodUTF8Txt: Label '<receiversbankaccount><bankaccount>01234599445670</bankaccount><bankaccountaddress><address1>Anchor House 43</address1><city>Birmingham</city><name>ECA Bank</name><zipcode>B27 4KT</zipcode></bankaccountaddress></receiversbankaccount><paymenttype>DomAcc2Acc</paymenttype><costs>Shared</costs><messagestructure>manual</messagestructure></banktransthem>', Locked = true;
        SampleFileCDataLine09_EncodUTF8Txt: Label '<ownbankaccount><bankaccount>01234599445670</bankaccount><bankaccountaddress><address1>1 High Holborn</address1><city>London</city><name>World Wide Bank</name><countryiso>GB</countryiso><zipcode>WC1 3DG</zipcode></bankaccountaddress></ownbankaccount>', Locked = true;
        SampleFileCDataLine10_EncodUTF8Txt: Label '<ownaddress><address1>5 The Ring</address1><address2>Westminster</address2><city>London</city><name>CRONUS International Ltd.</name><countryiso>GB</countryiso><zipcode>W2 8HG</zipcode></ownaddress><ownaddressinfo>frombank</ownaddressinfo></banktransus></banktransjournal></amcpaymentreq>', Locked = true;
        SampleFileCDataLine11_EncodUTF8Txt: Label '<bank xmlns="">Barclays GB</bank><language xmlns="">ENU</language></paymentExportBank>', Locked = true;
        SEPACAMTHeaderLine1Txt: Label '<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02"><BkToCstmrStmt><GrpHdr><MsgId>IdGeneratedByBank</MsgId><CreDtTm>2013-06-', Locked = true;
        SEPACAMTHeaderLine2Txt: Label '28T12:21:01.495+03:00</CreDtTm><AdditionalInformation>/EODY/</AdditionalInformation></GrpHdr><Stmt><Id>IdGeneratedByBank</Id>', Locked = true;
        SEPACAMTHeaderLine3Txt: Label '<ElctrncSeqNb>001</ElctrncSeqNb><CreDtTm>2013-06-28T12:21:01.495+03:00</CreDtTm><FrToDt><FrDtTm>2013-06-28T12:21:01.495+03:00</FrDtTm><ToDtTm>2013-06-28T12:21:01.495+03:00</ToDtTm></FrToDt>', Locked = true;
        SEPACAMTHeaderLine4Txt: Label '<Acct><Id><IBAN>NL91ABNA0417164299</IBAN></Id><Tp><Cd>CASH</Cd></Tp><Ccy>EUR</Ccy><Ownr><Nm>Dutch Company</Nm></Ownr><Svcr><FinInstnId><BIC>DEUTNLNL</BIC></FinInstnId></Svcr></Acct>', Locked = true;
        SEPACAMTBal1Txt: Label '<Bal><Tp><CdOrPrtry><Cd>OPBD</Cd></CdOrPrtry><SubTp><Prtry>OpeningBooked</Prtry></SubTp></Tp><CdtLine><Incl>false</Incl></CdtLine><Amt Ccy="EUR">2000000</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2013-06-28</Dt></Dt></Bal>', Locked = true;
        SEPACAMTBal2Txt: Label '<Bal><Tp><CdOrPrtry><Cd>CLBD</Cd></CdOrPrtry><SubTp><Prtry>ClosingBooked</Prtry></SubTp></Tp><CdtLine><Incl>false</Incl></CdtLine><Amt Ccy="EUR">1000000</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2013-06-28</Dt></Dt></Bal>', Locked = true;
        SEPACAMTBal3Txt: Label '<Bal><Tp><CdOrPrtry><Cd>CLAV</Cd></CdOrPrtry><SubTp><Prtry>ClosingAvailable</Prtry></SubTp></Tp><CdtLine><Incl>false</Incl></CdtLine><Amt Ccy="EUR">1000000</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2013-06-28</Dt></Dt></Bal>', Locked = true;
        SEPACAMTBal4Txt: Label '<Bal><Tp><CdOrPrtry><Cd>FWAV</Cd></CdOrPrtry><SubTp><Prtry>ForwardAvailable</Prtry></SubTp></Tp><CdtLine><Incl>false</Incl></CdtLine><Amt Ccy="EUR">1000000</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2013-06-28</Dt></Dt></Bal>', Locked = true;
        SEPACAMTTxsSummaryTxt: Label '<TxsSummry><TtlNtries><NbOfNtries>1000</NbOfNtries><Sum>1000000.00</Sum><TtlNetNtryAmt>1000000.00</TtlNetNtryAmt><CdtDbtInd>DBIT</CdtDbtInd></TtlNtries></TxsSummry>', Locked = true;
        SEPACAMTEntry1Txt: Label '<Ntry><Amt Ccy="EUR">1000.00</Amt><CdtDbtInd>DBIT</CdtDbtInd><Sts>BOOK</Sts><BookgDt><Dt>2013-06-28</Dt></BookgDt><ValDt><Dt>2013-06-28</Dt></ValDt><AcctSvcrRef>ReferenceGeneratedByBank</AcctSvcrRef>', Locked = true;
        SEPACAMTEntry2Txt: Label '<BkTxCd><Domn><Cd>PMNT</Cd><Fmly><Cd>ICDT</Cd><SubFmlyCd>ESCT</SubFmlyCd></Fmly></Domn></BkTxCd><NtryDtls><Btch><MsgId>M0000000000000000000000000000448808</MsgId><PmtInfId>M000000000448807</PmtInfId><NbOfTxs>1</NbOfTxs><CdtDbtInd>DBIT</CdtDbtInd></Btch>', Locked = true;
        SEPACAMTEntry3Txt: Label '<TxDtls><Refs><MsgId>M0000000000000000000000000000448808</MsgId><AcctSvcrRef>ReferenceGeneratedByBank</AcctSvcrRef><PmtInfId>M000000000448807</PmtInfId><InstrId>testing payment reference</InstrId><EndToEndId>testing receiver reference</EndToEndId></Refs>', Locked = true;
        SEPACAMTEntry4Txt: Label '<AmtDtls><TxAmt><Amt Ccy="EUR">1000.00</Amt></TxAmt></AmtDtls><BkTxCd><Domn><Cd>PMNT</Cd><Fmly><Cd>ICDT</Cd><SubFmlyCd>ESCT</SubFmlyCd></Fmly></Domn></BkTxCd>', Locked = true;
        SEPACAMTEntry5Txt: Label '<RltdPties><Cdtr><Nm>test</Nm><PstlAdr><Ctry>NL</Ctry></PstlAdr></Cdtr><CdtrAcct><Id><IBAN>NL91ABNA0417164299</IBAN></Id></CdtrAcct></RltdPties><RltdAgts><CdtrAgt><FinInstnId><BIC>DEUTNLNL</BIC></FinInstnId></CdtrAgt></RltdAgts>', Locked = true;
        SEPACAMTEntry6Txt: Label '<RmtInf><Ustrd>testing the remittance information</Ustrd></RmtInf></TxDtls></NtryDtls></Ntry>', Locked = true;
        SEPACAMTClosingTxt: Label '</Stmt></BkToCstmrStmt></Document>', Locked = true;

    [Scope('OnPrem')]
    procedure PrepareAMCSampleBody(var BodyTempBlob: Codeunit "Temp Blob"; UniqueIdentifier: Text)
    var
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream, TEXTENCODING::UTF8);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileLine01_EncodUTF8Txt, AMCBankingMgt.GetNamespace()));
        BodyOutputStream.WriteText(SampleFileLine02_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileLine03_EncodUTF8Txt, UniqueIdentifier));
        BodyOutputStream.WriteText(SampleFileLine04_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileLine05_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileLine06_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(StrSubstNo(SampleFileLine07_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(SampleFileLine08_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileLine09_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileLine10_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileLine11_EncodUTF8Txt);
    end;

    [Scope('OnPrem')]
    procedure PrepareAMCDemoBody(var BodyTempBlob: Codeunit "Temp Blob")
    var
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream, TEXTENCODING::UTF8);
        BodyOutputStream.WriteText(StrSubstNo(DemoFileLine01_EncodUTF8Txt, AMCBankingMgt.GetNamespace()));
        BodyOutputStream.WriteText(DemoFileLine02_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine03_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine04_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine05_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine06_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine07_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(DemoFileLine08_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(DemoFileLine09_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(DemoFileLine10_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(DemoFileLine11_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine12_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine13_EncodUTF8Txt);
        BodyOutputStream.WriteText(DemoFileLine14_EncodUTF8Txt);
    end;

    [Scope('OnPrem')]
    procedure PrepareAMCBodyForConversion(var BodyTempBlob: Codeunit "Temp Blob"; UniqueIdentifier: Text)
    var
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream, TEXTENCODING::UTF8);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileCDataLine01_EncodUTF8Txt, AMCBankingMgt.GetNamespace()));
        BodyOutputStream.WriteText(SampleFileCDataLine02_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileCDataLine03_EncodUTF8Txt, UniqueIdentifier));
        BodyOutputStream.WriteText(SampleFileCDataLine04_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileCDataLine05_EncodUTF8Txt);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileCDataLine06_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(StrSubstNo(SampleFileCDataLine07_EncodUTF8Txt, Format(Today(), 0, 9)));
        BodyOutputStream.WriteText(SampleFileCDataLine08_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileCDataLine09_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileCDataLine10_EncodUTF8Txt);
        BodyOutputStream.WriteText(SampleFileCDataLine11_EncodUTF8Txt);
    end;

    [Scope('OnPrem')]
    procedure PrepareSEPACAMTFile(var BankStmtTempBlob: Codeunit "Temp Blob"; NoOfLines: Integer)
    var
        BankStmtOutStream: OutStream;
        i: Integer;
    begin
        Clear(BankStmtTempBlob);
        BankStmtTempBlob.CreateOutStream(BankStmtOutStream, TEXTENCODING::UTF8);
        BankStmtOutStream.WriteText(SEPACAMTHeaderLine1Txt);
        BankStmtOutStream.WriteText(SEPACAMTHeaderLine2Txt);
        BankStmtOutStream.WriteText(SEPACAMTHeaderLine3Txt);
        BankStmtOutStream.WriteText(SEPACAMTHeaderLine4Txt);
        BankStmtOutStream.WriteText(SEPACAMTBal1Txt);
        BankStmtOutStream.WriteText(SEPACAMTBal2Txt);
        BankStmtOutStream.WriteText(SEPACAMTBal3Txt);
        BankStmtOutStream.WriteText(SEPACAMTBal4Txt);
        BankStmtOutStream.WriteText(SEPACAMTTxsSummaryTxt);

        for i := 1 to NoOfLines do begin
            BankStmtOutStream.WriteText(SEPACAMTEntry1Txt);
            BankStmtOutStream.WriteText(SEPACAMTEntry2Txt);
            BankStmtOutStream.WriteText(SEPACAMTEntry3Txt);
            BankStmtOutStream.WriteText(SEPACAMTEntry4Txt);
            BankStmtOutStream.WriteText(SEPACAMTEntry5Txt);
            BankStmtOutStream.WriteText(SEPACAMTEntry6Txt);
        end;

        BankStmtOutStream.WriteText(SEPACAMTClosingTxt);
    end;

    [Scope('OnPrem')]
    procedure PrepareNordeaFile(var BankStmtTempBlob: Codeunit "Temp Blob"; NoOfLines: Integer)
    var
        BankStmtOutStream: OutStream;
        i: Integer;
    begin
        Clear(BankStmtTempBlob);
        BankStmtTempBlob.CreateOutStream(BankStmtOutStream, TEXTENCODING::UTF8);

        for i := 1 to NoOfLines do begin
            BankStmtOutStream.WriteText(NordeaCorporate_EncodUTF8Txt);
            BankStmtOutStream.WriteText();
        end;
    end;

    [Scope('OnPrem')]
    procedure SetupDefaultService()
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
    begin
        if AMCBankServiceSetup.Get() then
            exit;

        AMCBankServiceSetup.Init();
        AMCBankServiceSetup.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure SetServiceCredentials(UserName: Text[50]; Password: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        AMCBankingSetup."User Name" := UserName;
        AMCBankingSetup.SavePassword(Password);
        AMCBankingSetup.Modify();
    end;

    [Scope('OnPrem')]
    procedure SetServiceCredentialsToDemo()
    begin
        SetServiceCredentials('demouser', 'DemoPassword');
    end;

    [Scope('OnPrem')]
    procedure SetServiceCredentialsToTest()
    begin
        SetServiceCredentials('demouser', 'DemoPassword');
    end;

    [Scope('OnPrem')]
    procedure SetServiceUrl(ServiceURL: Text[250])
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        AMCBankingSetup."Service URL" := ServiceURL;
        AMCBankingSetup.Modify();
    end;

    [Scope('OnPrem')]
    procedure SetServiceUrlToTest()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        SetServiceUrl(LocalhostURLTxt);
    end;

    [Scope('OnPrem')]
    procedure SetupAMCBankingDataExch(DataExchCode: Code[20]);
    var
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        BasisSetupRunOK: Boolean;
    begin
        //Get data exchange from localhost test webservice

        if (DataExchCode = AMCBankingMgt.GetDataExchDef_STMT()) and
           (not DataExchDefExists(DataExchCode)) then
            BasisSetupRunOK := AMCBankAssistedMgt.RunBasisSetup(true, true, '', LocalhostURLTxt, '', false, false, '', '',
                                                                true, false, false, true, false, '', '',
                                                                false, false, TempOnlineBankAccLink, false);

        if (DataExchCode = AMCBankingMgt.GetDataExchDef_CT()) and
           (not DataExchDefExists(DataExchCode)) then
            BasisSetupRunOK := AMCBankAssistedMgt.RunBasisSetup(true, true, '', LocalhostURLTxt, '', false, false, '', '',
                                                                true, true, false, false, false, '', '',
                                                                false, false, TempOnlineBankAccLink, false);

    end;

    [Scope('OnPrem')]
    procedure CleanupAMCBankingDataExch(DataExchCode: Code[20]);
    var
        DataExchDef: Record "Data Exch. Def";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (DataExchDef.get(DataExchCode)) then begin

            BankExportImportSetup.SetFilter(BankExportImportSetup."Data Exch. Def. Code", DataExchCode);
            if (BankExportImportSetup.FindSet()) then
                BankExportImportSetup.DeleteAll(true);

            DataExchDef.Delete(true);
        end;
    end;

    local procedure DataExchDefExists(DataExchDef: Code[20]): Boolean;
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        "Data Exch. Def": Record "Data Exch. Def";
    begin

        if (BankExportImportSetup.Get(DataExchDef)) then
            if ("Data Exch. Def".Get(BankExportImportSetup."Data Exch. Def. Code")) then
                exit(true);

        exit(false);
    end;

}

