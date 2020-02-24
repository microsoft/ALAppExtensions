codeunit 130102 "Library - Payment AMC"
{

    trigger OnRun()
    begin
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        LocalhostURLTxt: Label 'https://localhost:8080/', Locked = true;
        DemoFileLine01Txt: Label '<paymentExportBank xmlns="%1"><amcpaymentreq><banktransjournal>', Locked = true;
        DemoFileLine02Txt: Label '<journalname>200106</journalname><journalnumber>journal-02</journalnumber><transmissionref1>01</transmissionref1><uniqueid>DE-01</uniqueid>', Locked = true;
        DemoFileLine03Txt: Label '<banktransus><countryoforigin>DE</countryoforigin><uniqueid>DE01US</uniqueid><ownaddress><address1>Grundtvigsvej 29</address1>', Locked = true;
        DemoFileLine04Txt: Label '<address2></address2><city></city><countryiso>DK</countryiso><name>AMC</name></ownaddress>', Locked = true;
        DemoFileLine05Txt: Label '<banktransthem><uniqueid>DE01TH</uniqueid><receiversaddress><countryiso>DE</countryiso><name>Tysk kreditor 1</name></receiversaddress>', Locked = true;
        DemoFileLine06Txt: Label '<paymenttype>DomAcc2Acc</paymenttype><costs>Shared</costs>', Locked = true;
        DemoFileLine07Txt: Label '<banktransspec><discountused>0.0</discountused><invoiceref>6541695</invoiceref><uniqueid>DE01SP</uniqueid><amountdetails><payamount>0.08</payamount>', Locked = true;
        DemoFileLine08Txt: Label '<paycurrency>EUR</paycurrency><paydate>20140529</paydate></amountdetails></banktransspec>', Locked = true;
        DemoFileLine09Txt: Label '<banktransspec><discountused>0.0</discountused><invoiceref>6541654</invoiceref><uniqueid>DE02SP</uniqueid><amountdetails><payamount>0.02</payamount>', Locked = true;
        DemoFileLine10Txt: Label '<paycurrency>EUR</paycurrency><paydate>20140529</paydate></amountdetails></banktransspec>', Locked = true;
        DemoFileLine11Txt: Label '<amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>20140529</paydate></amountdetails><receiversbankaccount>', Locked = true;
        DemoFileLine12Txt: Label '<bankaccount>0011350044</bankaccount><intregno>51420600</intregno><intregnotype>GermanBankleitzahl</intregnotype></receiversbankaccount></banktransthem>', Locked = true;
        DemoFileLine13Txt: Label '<bankaccountident><bankaccount>0011350034</bankaccount><swiftcode>HANDDEFF</swiftcode></bankaccountident>', Locked = true;
        DemoFileLine14Txt: Label '</banktransus></banktransjournal></amcpaymentreq><bank>AMC Demo Bank GB</bank><language>EN</language></paymentExportBank>', Locked = true;
        SampleFileLine01Txt: Label '<paymentExportBank xmlns="%1">', Locked = true;
        SampleFileLine02Txt: Label '<amcpaymentreq><banktransjournal><erpsystem>HelloFromCAL</erpsystem><journalname>Test 012</journalname><transmissionref1>01</transmissionref1>', Locked = true;
        SampleFileLine03Txt: Label '<uniqueid>Test01Id</uniqueid><banktransus><countryoforigin>DE</countryoforigin><ownreference>AMC0001TEST</ownreference><uniqueid>DE01US</uniqueid>', Locked = true;
        SampleFileLine04Txt: Label '<banktransthem><customerid>Kreditor 1</customerid><uniqueid>DE01TH</uniqueid><receiversaddress><address1>German vendor 1</address1><countryiso>DE</countryiso>', Locked = true;
        SampleFileLine05Txt: Label '<name>Vendor name</name></receiversaddress><banktransspec><discountused>0.0</discountused><invoiceref>654123</invoiceref><origamount>0.20</origamount>', Locked = true;
        SampleFileLine06Txt: Label '<uniqueid>DE01SP</uniqueid><amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>20120101</paydate></amountdetails></banktransspec>', Locked = true;
        SampleFileLine07Txt: Label '<amountdetails><payamount>0.10</payamount><paycurrency>EUR</paycurrency><paydate>20081218</paydate></amountdetails><receiversbankaccount><bankaccount>', Locked = true;
        SampleFileLine08Txt: Label '0011350044</bankaccount><intregno>51420600</intregno><intregnotype>GermanBankleitzahl</intregnotype></receiversbankaccount><paymenttype>DomAcc2Acc</paymenttype>', Locked = true;
        SampleFileLine09Txt: Label '<costs>PayerPaysAll</costs></banktransthem><bankaccountident><bankaccount>11350034</bankaccount><swiftcode>HANDDEFF</swiftcode></bankaccountident>', Locked = true;
        SampleFileLine10Txt: Label '<ownaddress><address1>Grundtvigsvej 29</address1><countryiso>DE</countryiso><name>AMC Consult A/S</name></ownaddress><ownaddressinfo>frombank</ownaddressinfo>', Locked = true;
        SampleFileLine11Txt: Label '</banktransus></banktransjournal></amcpaymentreq><bank xmlns="">Handels EDI DE</bank></paymentExportBank>', Locked = true;

    [Scope('OnPrem')]
    procedure EnableTestServiceSetup(var TempAMCBankingSetup: Record "AMC Banking Setup" temporary) OldPassword: Text
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        OldPassword := AMCBankingSetup.GetPassword();

        TempAMCBankingSetup.Init();
        TempAMCBankingSetup."User Name" := AMCBankingSetup."User Name";
        TempAMCBankingSetup."Service URL" := AMCBankingSetup."Service URL";

        AMCBankingSetup."User Name" := 'demouser';
        AMCBankingSetup.SavePassword('DemoPassword');
        AMCBankingSetup."Service URL" := LocalhostURLTxt;
        AMCBankingSetup.Modify();
    end;

    [Scope('OnPrem')]
    procedure RestoreServiceSetup(TempAMCBankingSetup: Record "AMC Banking Setup" temporary; PasswordText: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        AMCBankingSetup."User Name" := TempAMCBankingSetup."User Name";
        AMCBankingSetup.SavePassword(PasswordText);
        AMCBankingSetup."Service URL" := TempAMCBankingSetup."Service URL";
        AMCBankingSetup.Modify();
    end;

    [Scope('OnPrem')]
    procedure PrepareAMCSampleBody(var BodyTempBlob: Codeunit "Temp Blob")
    var
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream);
        BodyOutputStream.WriteText(StrSubstNo(SampleFileLine01Txt, AMCBankingMgt.GetNamespace()));
        BodyOutputStream.WriteText(SampleFileLine02Txt);
        BodyOutputStream.WriteText(SampleFileLine03Txt);
        BodyOutputStream.WriteText(SampleFileLine04Txt);
        BodyOutputStream.WriteText(SampleFileLine05Txt);
        BodyOutputStream.WriteText(SampleFileLine06Txt);
        BodyOutputStream.WriteText(SampleFileLine07Txt);
        BodyOutputStream.WriteText(SampleFileLine08Txt);
        BodyOutputStream.WriteText(SampleFileLine09Txt);
        BodyOutputStream.WriteText(SampleFileLine10Txt);
        BodyOutputStream.WriteText(SampleFileLine11Txt);
    end;

    [Scope('OnPrem')]
    procedure PrepareAMCDemoBody(var BodyTempBlob: Codeunit "Temp Blob")
    var
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream);
        BodyOutputStream.WriteText(StrSubstNo(DemoFileLine01Txt, AMCBankingMgt.GetNamespace()));
        BodyOutputStream.WriteText(DemoFileLine02Txt);
        BodyOutputStream.WriteText(DemoFileLine03Txt);
        BodyOutputStream.WriteText(DemoFileLine04Txt);
        BodyOutputStream.WriteText(DemoFileLine05Txt);
        BodyOutputStream.WriteText(DemoFileLine06Txt);
        BodyOutputStream.WriteText(DemoFileLine07Txt);
        BodyOutputStream.WriteText(DemoFileLine08Txt);
        BodyOutputStream.WriteText(DemoFileLine09Txt);
        BodyOutputStream.WriteText(DemoFileLine10Txt);
        BodyOutputStream.WriteText(DemoFileLine11Txt);
        BodyOutputStream.WriteText(DemoFileLine12Txt);
        BodyOutputStream.WriteText(DemoFileLine13Txt);
        BodyOutputStream.WriteText(DemoFileLine14Txt);
    end;
}

