#if not CLEAN20
xmlport 20100 "AMC Bank Export CreditTransfer"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation in V19.1 of Export Credit transfer.';
    ObsoleteTag = '20.0';

    Caption = 'AMC Banking Export CreditTransfer';
    Namespaces = ns1 = 'http://nav03.soap.xml.link.amc.dk/';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = TableData "Data Exch." = r,
                  TableData "Data Exch. Field" = r,
                  TableData "Data Exch. Column Def" = r;
    UseDefaultNamespace = false;
    UseRequestPage = false;

    schema
    {
        textelement(paymentExportBank)
        {
            NamespacePrefix = 'ns1';
            tableelement("Company Information"; "Company Information")
            {
                MaxOccurs = Once;
                XmlName = 'amcpaymentreq';
                NamespacePrefix = '';

                textelement(version)
                {
                    MaxOccurs = Once;

                    trigger OnBeforePassVariable();
                    begin
                        version := AMCBankServMgt.ApiVersion();
                    end;
                }
                textelement(clientcode)
                {
                    MaxOccurs = Once;

                    trigger OnBeforePassVariable();
                    begin
                        clientcode := AMCBankServMgt.GetAMCClientCode();
                    end;
                }
                textelement(banktransjournal)
                {
                    textelement(bankagreementlevel1)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            bankagreementlevel1 := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(bankagreementlevel2)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            bankagreementlevel2 := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(batchData)
                    {

                        trigger OnBeforePassVariable();
                        begin
                            batchData := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(edireceiverid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.SKIP();
                        end;
                    }
                    textelement(edireceivertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.SKIP();
                        end;
                    }
                    textelement(edisenderid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.SKIP();
                        end;
                    }
                    textelement(edisendertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.SKIP();
                        end;
                    }
                    textelement(erpsystem)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            erpsystem := AMCBankServMgt.GetAMCClientCode();
                        end;
                    }
                    textelement(journalname)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            journalname := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(journalnumber)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            journalnumber := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    fieldelement(legalregistrationnumber; "Company Information"."VAT Registration No.")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                    }
                    textelement(messageref)
                    {

                        trigger OnBeforePassVariable();
                        begin
                            messageref := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(transmissionref1)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            transmissionref1 := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    textelement(transmissionref2)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.SKIP();
                        end;
                    }
                    textelement(jnluniqueid)
                    {
                        XmlName = 'uniqueid';

                        trigger OnBeforePassVariable();
                        begin
                            JnlUniqueId := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                        end;
                    }
                    tableelement("Data Exch. Field"; "Data Exch. Field")
                    {
                        XmlName = 'banktransus';
                        textelement(bankaccountcurrency)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                bankaccountcurrency := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(bankspecific1us)
                        {
                            MinOccurs = Zero;
                            XmlName = 'bankspecific1';

                            trigger OnBeforePassVariable();
                            begin
                                bankspecific1us := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(bankspecific2us)
                        {
                            MinOccurs = Zero;
                            XmlName = 'bankspecific2';

                            trigger OnBeforePassVariable();
                            begin
                                bankspecific2us := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(countryoforigin)
                        {
                            MaxOccurs = Unbounded;
                            MinOccurs = Once;

                            trigger OnBeforePassVariable();
                            begin
                                countryoforigin := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(messagetoownbank)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                messagetoownbank := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(ownreference)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                ownreference := COPYSTR(GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No."), 1, 40);
                            end;
                        }
                        textelement(transusuniqueid)
                        {
                            XmlName = 'uniqueid';

                            trigger OnBeforePassVariable();
                            begin
                                TransUsUniqueId := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(banktransthem)
                        {
                            textelement(bankspecific1them)
                            {
                                MinOccurs = Zero;
                                XmlName = 'bankspecific1';

                                trigger OnBeforePassVariable();
                                begin
                                    bankspecific1them := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(bankspecific2them)
                            {
                                MinOccurs = Zero;
                                XmlName = 'bankspecific2';

                                trigger OnBeforePassVariable();
                                begin
                                    bankspecific2them := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(customerid)
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    customerid := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(reference)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    reference := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(shortadvice)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    shortadvice := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(transthemuniqueid)
                            {
                                XmlName = 'uniqueid';

                                trigger OnBeforePassVariable();
                                begin
                                    TransThemUniqueId := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(regulatoryreporting)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(regrepcode)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Once;
                                    XmlName = 'code';

                                    trigger OnBeforePassVariable();
                                    begin
                                        regrepcode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(regrepdate)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'date';

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (RegRepDate = '') then
                                            currXMLport.SKIP();
                                    end;
                                }
                                textelement(regreptext)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'text';

                                    trigger OnBeforePassVariable();
                                    begin
                                        RegRepText := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    RegRepCode := '';
                                    RegRepDate := '';
                                    RegRepText := '';
                                end;
                            }
                            textelement(receiversaddress)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(address1)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        address1 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(address2)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        address2 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(city)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        city := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(countryiso)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        countryiso := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(name)
                                {

                                    trigger OnBeforePassVariable();
                                    begin
                                        name := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverState := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(zipcode)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        zipcode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(paymenttypecode_sec) // Only for NA, webservice is setting a default value
                            {
                                MinOccurs = Zero;
                                XmlName = 'paymenttypecode';
                                textelement(paymenttype_code_sec)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'code';

                                    trigger OnBeforePassVariable();
                                    begin
                                        paymenttype_code_SEC := 'SEC';
                                    end;
                                }
                                textelement(paymenttype_text_sec)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'text';
                                }

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    currXMLport.SKIP();
                                end;
                            }
                            textelement(paymenttypecode_atc) // Only for NA, webservice is setting a default value
                            {
                                MinOccurs = Zero;
                                XmlName = 'paymenttypecode';
                                textelement(paymenttype_code_atc)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'code';

                                    trigger OnBeforePassVariable();
                                    begin
                                        paymenttype_code_ATC := 'ATC';
                                    end;
                                }
                                textelement(paymenttype_text_atc)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'text';
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.SKIP();
                                end;
                            }
                            tableelement("Credit Transfer Entry"; "Credit Transfer Entry")
                            {
                                MinOccurs = Zero;
                                XmlName = 'banktransspec';

                                textelement(cardref)
                                {
                                    MaxOccurs = Unbounded;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.SKIP();
                                    end;
                                }
                                textelement(discountused)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        discountused := FORMAT("Credit Transfer Entry"."Pmt. Disc. Possible", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                    end;
                                }
                                textelement(invoiceref)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (CVLedgEntryBuffer."Entry No." <> 0) then
                                            invoiceref := CVLedgEntryBuffer.Description
                                        else
                                            invoiceref := "Credit Transfer Entry"."Message to Recipient";
                                    end;
                                }
                                textelement(origamount)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (CVLedgEntryBuffer."Entry No." <> 0) then
                                            origamount := FORMAT(-CVLedgEntryBuffer."Original Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces())
                                        else
                                            origamount := FORMAT("Credit Transfer Entry"."Transfer Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                    end;
                                }
                                textelement(origdate)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    var
                                        DateVar: Variant;
                                        DateTimeValue: DateTime;
                                    begin
                                        if (CVLedgEntryBuffer."Entry No." <> 0) then
                                            DateVar := CVLedgEntryBuffer."Document Date"
                                        else
                                            DateVar := "Credit Transfer Entry"."Transfer Date";

                                        EVALUATE(DateTimeValue, FORMAT(DateVar, 0, 9), 9);
                                        DateVar := DateTimeValue;
                                        origDate := FORMAT(DateVar, 0, 9);
                                    end;
                                }
                                textelement(otherref)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.SKIP();
                                    end;
                                }
                                textelement(transspecuniqueid)
                                {
                                    XmlName = 'uniqueid';

                                    trigger OnBeforePassVariable();
                                    begin
                                        TransSpecUniqueId := FORMAT(CREATEGUID());
                                    end;
                                }
                                textelement(transspecamtdetails)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'amountdetails';
                                    textelement(transspecamtvalue)
                                    {
                                        XmlName = 'payamount';

                                        trigger OnBeforePassVariable();
                                        begin
                                            TransSpecAmtValue := FORMAT("Credit Transfer Entry"."Transfer Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                        end;
                                    }
                                    textelement(transspecamtcurrency)
                                    {
                                        XmlName = 'paycurrency';

                                        trigger OnBeforePassVariable();
                                        begin
                                            TransSpecAmtCurrency := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(transspecamtdate)
                                    {
                                        XmlName = 'paydate';

                                        trigger OnBeforePassVariable();
                                        begin
                                            TransSpecAmtDate := origdate;
                                        end;
                                    }
                                }

                                trigger OnAfterGetRecord();
                                begin
                                    GetCVLedgerEntryBuffer(CVLedgEntryBuffer, "Credit Transfer Entry");
                                end;

                                trigger OnPreXmlItem();
                                var
                                begin
                                    ManualMessage := false;
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Data Exch. Entry No.", "Data Exch. Field"."Data Exch. No.");
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Transaction ID", TransThemUniqueId);
                                    if ("Credit Transfer Entry".Count() = 0) then begin
                                        ManualMessage := true;
                                        currXMLport.skip();
                                    end;
                                end;

                            }
                            textelement(emailadvice)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(subject)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        subject := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(recipient)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        recipient := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(emailpaymentmessage)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'paymentmessage';
                                    textelement(emaillinenum)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;
                                        XmlName = 'linenum';

                                        trigger OnBeforePassVariable();
                                        begin
                                            EmailLineNum := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(emailtext)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;
                                        XmlName = 'text';

                                        trigger OnBeforePassVariable();
                                        begin
                                            EmailText := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                }
                            }
                            textelement(paymentmessage) //Only Skip if banktransspec hold info about payments, otherwise output
                            {
                                MinOccurs = Zero;
                                textelement(pmtlinenum)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'linenum';

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (ManualMessage) then
                                            pmtlinenum := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.")
                                        else
                                            currXMLport.SKIP()
                                    end;
                                }
                                textelement(pmtmsgtext)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'text';

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (ManualMessage) then
                                            pmtmsgtext := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.")
                                        else
                                            currXMLport.SKIP()
                                    end;
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    if (not ManualMessage) then
                                        currXMLport.SKIP();
                                end;
                            }
                            textelement(chequeinfo)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(chequenum)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        chequenum := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(dispatchbranch)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        dispatchbranch := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(voideddate)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        voideddate := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(crossed)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        crossed := 'Not_Crossed';
                                    end;
                                }
                                textelement(dispatch)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        dispatch := 'ChequeToOurselves';
                                    end;
                                }
                                textelement(chequehandle)
                                {

                                    trigger OnBeforePassVariable();
                                    begin
                                        chequehandle := LOWERCASE(GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No."));
                                    end;
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    chequeinfo := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    if (chequeinfo = 'FALSE') then
                                        currXMLport.Skip()
                                    else
                                        chequeinfo := '';
                                end;
                            }
                            textelement(amountdetails)
                            {
                                MaxOccurs = Once;
                                textelement(amtvalue)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'payamount';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AmtValue := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(amtcurrency)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paycurrency';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AmtCurrency := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(amtdate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paydate';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AmtDate := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(correspondentbankaccount)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(correspbankaccount)
                                {
                                    XmlName = 'bankaccount';
                                }
                                textelement(correspintregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregno';
                                }
                                textelement(correspswiftcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'swiftcode';
                                }
                                textelement(correspintregnotype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregnotype';
                                }
                                textelement(correspbankaccaddress)
                                {
                                    XmlName = 'bankaccountaddress';
                                    textelement(correspbankaddress1)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address1';
                                    }
                                    textelement(correspbankaddress2)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address2';
                                    }
                                    textelement(correspbankcity)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'city';
                                    }
                                    textelement(correspbankctry)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'countryiso';
                                    }
                                    textelement(correspbankname)
                                    {
                                        XmlName = 'name';
                                    }
                                    textelement(correspbankstate)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'state';
                                    }
                                    textelement(correspbankzipcode)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'zipcode';
                                    }
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.SKIP();
                                end;
                            }
                            textelement(receiversbankaccount)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(receiverbankaccount)
                                {
                                    XmlName = 'bankaccount';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverBankAccount := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverintregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregno';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverIntRegNo := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverswiftcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'swiftcode';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverSWIFTCode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverintregnotype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregnotype';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverIntRegNoType := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(recbankaccaddress)
                                {
                                    XmlName = 'bankaccountaddress';
                                    textelement(recbankaccaddress1)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address1';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccAddress1 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccaddress2)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address2';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccAddress2 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankacccity)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'city';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccCity := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccctry)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'countryiso';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccCtry := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccname)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'name';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccName := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccstate)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'state';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccState := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankacczipcode)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'zipcode';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccZipcode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                        end;
                                    }
                                }
                            }
                            textelement(paymenttype)
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    paymenttype := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(costs)
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    costs := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(messagestructure)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    if (not ManualMessage) then
                                        messagestructure := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.")
                                    else
                                        messagestructure := 'manual';
                                end;
                            }
                        }
                        textelement(ownbankaccount)
                        {
                            textelement(senderbankaccount)
                            {
                                XmlName = 'bankaccount';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderBankAccount := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderintregno)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregno';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderIntRegNo := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderswiftcode)
                            {
                                MinOccurs = Zero;
                                XmlName = 'swiftcode';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderSWIFTCode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderintregnotype)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregnotype';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderIntRegNoType := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(bankaccountaddress)
                            {
                                textelement(bankaccaddress1)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'address1';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccAddress1 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccaddress2)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'address2';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccAddress2 := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankacccity)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'city';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccCity := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccctry)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'countryiso';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccCtry := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccname)
                                {
                                    XmlName = 'name';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccName := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable();
                                    var
                                    begin
                                        bankaccstate := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankacczipcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'zipcode';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccZipcode := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                        }
                        textelement(ownaddress)
                        {
                            fieldelement(address1; "Company Information".Address)
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(address2; "Company Information"."Address 2")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(city; "Company Information".City)
                            {
                                MinOccurs = Zero;
                            }
                            textelement(owncountryiso)
                            {
                                MinOccurs = Zero;
                                XmlName = 'countryiso';

                                trigger OnBeforePassVariable();
                                var
                                    CountryRegion: Record "Country/Region";
                                begin
                                    Clear(CountryRegion);
                                    clear(owncountryiso);
                                    if ("Company Information"."Country/Region Code" <> '') then
                                        if (CountryRegion.Get("Company Information"."Country/Region Code")) then
                                            owncountryiso := CountryRegion."ISO Code";

                                end;
                            }
                            fieldelement(name; "Company Information".Name)
                            {
                            }
                            fieldelement(state; "Company Information".County)
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(zipcode; "Company Information"."Post Code")
                            {
                                MinOccurs = Zero;
                            }
                        }
                        textelement(ownaddressinfo)
                        {

                            trigger OnBeforePassVariable();
                            begin
                                ownaddressinfo := GetValue("Data Exch. Field"."Data Exch. No.", "Data Exch. Field"."Line No.");
                            end;
                        }

                        trigger OnAfterGetRecord();
                        begin
                            if "Data Exch. Field"."Line No." <> CurrentLineNo then
                                CurrentLineNo := "Data Exch. Field"."Line No."
                            else
                                currXMLport.SKIP();
                        end;
                    }

                    trigger OnBeforePassVariable();
                    begin
                        DataExchField.COPYFILTERS("Data Exch. Field");
                        if DataExchField.FINDFIRST() then;
                    end;
                }
            }
            textelement(bank)
            {
                MaxOccurs = Once;

                trigger OnBeforePassVariable();
                begin
                    bank := GetValue(DataExchField."Data Exch. No.", DataExchField."Line No.");
                end;
            }
            textelement(language)
            {

                trigger OnBeforePassVariable();
                begin
                    language := GetLanguage();
                end;
            }
        }
    }

    trigger OnPreXmlPort();
    begin
        InitializeGlobals();
    end;

    var
        DataExchField: Record "Data Exch. Field";
        DataExch: Record "Data Exch.";
        CVLedgEntryBuffer: Record "CV Ledger Entry Buffer";
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        TypeHelper: Codeunit "Type Helper";
        DataExchFieldDetails: Query "Data Exch. Field Details";
        DataExchEntryNo: Integer;
        CurrentLineNo: Integer;
        ManualMessage: Boolean;

    local procedure InitializeGlobals();
    begin
        DataExchEntryNo := "Data Exch. Field".GETRANGEMIN("Data Exch. No.");
        DataExch.GET(DataExchEntryNo);
        CurrentLineNo := 0;
    end;

    local procedure GetValue(DataExchNo: Integer; LineNo: Integer): Text;
    begin
        DataExchFieldDetails.SETRANGE(Data_Exch_No, DataExchNo);
        DataExchFieldDetails.SETRANGE(Line_No, LineNo);
        DataExchFieldDetails.SETRANGE(Path, currXMLport.CURRENTPATH());
        DataExchFieldDetails.OPEN();
        if DataExchFieldDetails.READ() then
            if DataExchFieldDetails.FieldValue <> '' then
                exit(DataExchFieldDetails.FieldValue);

        currXMLport.SKIP();
    end;

    local procedure GetLanguage(): Text[3];
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.GET(GLOBALLANGUAGE());
        exit(WindowsLanguage."Abbreviated Name");
    end;

    local procedure GetCVLedgerEntryBuffer(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CreditTransferEntry: Record "Credit Transfer Entry");
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        EmplLedgEntry: Record "Employee Ledger Entry";
    begin
        Clear(CVLedgerEntryBuffer);
        if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Vendor) then begin
            VendLedgEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
            if (VendLedgEntry.get(CreditTransferEntry."Applies-to Entry No.")) then begin
                CVLedgerEntryBuffer.CopyFromVendLedgEntry(VendLedgEntry);
                if (VendLedgEntry."External Document No." <> '') then
                    CVLedgerEntryBuffer.Description := VendLedgEntry."External Document No." //1. Prio
                else
                    CVLedgerEntryBuffer.Description := VendLedgEntry.Description; //2. Prio
            end
        end
        else
            if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Customer) then begin
                CustLedgEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                if (CustLedgEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                    CVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgEntry);
                    if (CustLedgEntry."Document Date" <> 0D) then
                        CVLedgerEntryBuffer."Document Date" := CustLedgEntry."Document Date"
                    else
                        CVLedgerEntryBuffer."Document Date" := CustLedgEntry."Posting Date";
                end
            end
            else
                if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Employee) then begin
                    EmplLedgEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                    if (EmplLedgEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                        CVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmplLedgEntry);
                        CVLedgerEntryBuffer."Document Date" := EmplLedgEntry."Posting Date";
                    end;
                end;
    end;
}

#endif