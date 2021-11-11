xmlport 20101 "AMC Bank Export CT"
{
    Caption = 'AMC Banking Export CreditTransfer';
    Namespaces = ns1 = 'http://api04.soap.xml.link.amc.dk/';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = TableData "Data Exch." = r,
                  TableData "Payment Export Data" = r;
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
                        version := AMCBankingMgt.ApiVersion();
                    end;
                }
                textelement(clientcode)
                {
                    MaxOccurs = Once;

                    trigger OnBeforePassVariable();
                    begin
                        clientcode := AMCBankingMgt.GetAMCClientCode();
                    end;
                }
                textelement(banktransjournal)
                {
                    textelement(bankagreementlevel1)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(bankagreementlevel2)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(batchposting)
                    {
                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(edireceiverid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(edireceivertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(edisenderid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(edisendertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            currXMLport.Skip();
                        end;
                    }
                    textelement(erpsystem)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            erpsystem := AMCBankingMgt.GetAMCClientCode();
                        end;
                    }
                    textelement(journalname)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            journalname := GetValue(RecordRef, PaymentExportData.FieldNo("General Journal Template"));
                        end;
                    }
                    textelement(journalnumber)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable();
                        begin
                            journalnumber := GetValue(RecordRef, PaymentExportData.FieldNo("Importing Description"));
                        end;
                    }
                    textelement(jnluniqueid)
                    {
                        XmlName = 'uniqueid';

                        trigger OnBeforePassVariable();
                        begin
                            JnlUniqueId := GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                            ;
                        end;
                    }
                    tableelement("Payment Export Data"; "Payment Export Data")
                    {
                        XmlName = 'banktransus';

                        textelement(bankspecific1us)
                        {
                            MinOccurs = Zero;
                            XmlName = 'bankspecific1';

                            trigger OnBeforePassVariable();
                            begin
                                currXMLport.skip();
                            end;
                        }
                        textelement(bankspecific2us)
                        {
                            MinOccurs = Zero;
                            XmlName = 'bankspecific2';

                            trigger OnBeforePassVariable();
                            begin
                                currXMLport.skip();
                            end;
                        }
                        textelement(messagetoownbank)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                currXMLport.Skip();
                            end;
                        }
                        textelement(ownreference)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                ownreference := COPYSTR(GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Name")), 1, 40);
                            end;
                        }
                        textelement(paymentinstruction1)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                currXMLport.Skip();
                            end;
                        }
                        textelement(paymentinstruction2)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable();
                            begin
                                currXMLport.Skip();
                            end;
                        }
                        textelement(transusuniqueid)
                        {
                            XmlName = 'uniqueid';

                            trigger OnBeforePassVariable();
                            begin
                                transusuniqueid := COPYSTR(GetValue(RecordRef, "Payment Export Data".FieldNo("End-to-End ID")), 1, 40);
                            end;
                        }
                        textelement(ownbankaccount)
                        {
                            textelement(senderbankaccount)
                            {
                                XmlName = 'bankaccount';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderBankAccount := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Account No."));
                                end;
                            }
                            textelement(sendercurrency)
                            {
                                XmlName = 'currency';

                                trigger OnBeforePassVariable();
                                begin
                                    sendercurrency := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Account Currency"));
                                end;
                            }
                            textelement(senderintregno)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregno';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderIntRegNo := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Clearing Code"));
                                end;
                            }
                            textelement(senderintregnotype)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregnotype';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderIntRegNoType := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Clearing Std."));
                                end;
                            }
                            textelement(senderswiftcode)
                            {
                                MinOccurs = Zero;
                                XmlName = 'swiftcode';

                                trigger OnBeforePassVariable();
                                begin
                                    SenderSWIFTCode := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank BIC"));
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
                                        BankAccAddress1 := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Address"));
                                    end;
                                }
                                textelement(bankaccaddress2)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'address2';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(bankacccity)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'city';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccCity := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank City"));
                                    end;
                                }
                                textelement(bankacccontactemail)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'contactemail';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(bankacccontactname)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'contactname';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(bankaccctry)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'countryiso';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccCtry := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Country/Region"));
                                    end;
                                }
                                textelement(bankacclegalregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'legalregistrationnumber';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(bankaccname)
                                {
                                    XmlName = 'name';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccName := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Name"));
                                    end;
                                }
                                textelement(bankaccstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable();
                                    var
                                    begin
                                        bankaccstate := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank County"));
                                    end;
                                }
                                textelement(bankaccidentitytype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'identitytype';

                                    trigger OnBeforePassVariable();
                                    var
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(bankacczipcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'zipcode';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BankAccZipcode := GetValue(RecordRef, "Payment Export Data".FieldNo("Sender Bank Post Code"));
                                    end;
                                }
                            }
                        }
                        textelement(banktransthem)
                        {
                            textelement(agreedcontractidthem)
                            {
                                MinOccurs = Zero;
                                XmlName = 'agreedcontractid';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();
                                end;
                            }
                            textelement(agreedexchangeratethem)
                            {
                                MinOccurs = Zero;
                                XmlName = 'agreedexchangerate';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();
                                end;
                            }
                            textelement(bankspecific1them)
                            {
                                MinOccurs = Zero;
                                XmlName = 'bankspecific1';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();
                                end;
                            }
                            textelement(bankspecific2them)
                            {
                                MinOccurs = Zero;
                                XmlName = 'bankspecific2';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();
                                end;
                            }
                            textelement(customerid)
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    customerid := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient ID"));
                                end;
                            }
                            textelement(paymenttype)
                            {
                                trigger OnBeforePassVariable();
                                begin
                                    paymenttype := GetValue(RecordRef, "Payment Export Data".FieldNo("Payment Type"));
                                end;
                            }
                            textelement(reference)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    reference := GetValue(RecordRef, "Payment Export Data".FieldNo("Payment Reference"));
                                end;
                            }
                            textelement(shortadvice)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    shortadvice := GetValue(RecordRef, "Payment Export Data".FieldNo("Applies-to Ext. Doc. No."));
                                end;
                            }
                            textelement(transthemuniqueid)
                            {
                                XmlName = 'uniqueid';

                                trigger OnBeforePassVariable();
                                begin
                                    TransThemUniqueId := GetValue(RecordRef, "Payment Export Data".FieldNo("Payment Information ID"));
                                end;
                            }
                            textelement(emailadvice)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(recipient)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        recipient := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Email Address"));
                                    end;
                                }
                                textelement(subject)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        subject := GetValue(RecordRef, "Payment Export Data".FieldNo("Applies-to Ext. Doc. No."));
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
                                            EmailLineNum := GetValue(RecordRef, "Payment Export Data".FieldNo("Line No."));
                                        end;
                                    }
                                    textelement(emailtext)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;
                                        XmlName = 'text';

                                        trigger OnBeforePassVariable();
                                        begin
                                            EmailText := GetValue(RecordRef, "Payment Export Data".FieldNo("Message to Recipient 1"));
                                        end;
                                    }
                                }
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
                                        if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            invoiceref := CVLedgerEntryBuffer.Description
                                        else
                                            invoiceref := "Credit Transfer Entry"."Message to Recipient";
                                    end;
                                }
                                textelement(origamount)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            origamount := FORMAT(-CVLedgerEntryBuffer."Original Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces())
                                        else
                                            origamount := FORMAT("Credit Transfer Entry"."Transfer Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                    end;
                                }
                                textelement(origcurrency)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            origcurrency := CVLedgerEntryBuffer."Currency Code"
                                        else
                                            origcurrency := "Credit Transfer Entry"."Currency Code";
                                    end;
                                }
                                textelement(origdate)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    var
                                        DateVariant: Variant;
                                        DateTimeValue: DateTime;
                                    begin
                                        if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            DateVariant := CVLedgerEntryBuffer."Document Date"
                                        else
                                            DateVariant := "Credit Transfer Entry"."Transfer Date";

                                        EVALUATE(DateTimeValue, FORMAT(DateVariant, 0, 9), 9);
                                        DateVariant := DateTimeValue;
                                        origDate := FORMAT(DateVariant, 0, 9);
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
                                            TransSpecAmtCurrency := GetValue(RecordRef, "Payment Export Data".FieldNo("Currency Code"));
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
                                    textelement(transspecvatvalue)
                                    {
                                        XmlName = 'vatamount';

                                        trigger OnBeforePassVariable();
                                        var
                                        begin
                                            if (not VATEntry.IsEmpty()) then
                                                transspecvatvalue := FORMAT(VATEntry.Amount, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces())
                                            else
                                                transspecvatvalue := FORMAT(0, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                        end;
                                    }
                                }

                                trigger OnAfterGetRecord();
                                begin
                                    GetCVLedgerEntryBuffer(CVLedgerEntryBuffer, "Credit Transfer Entry");
                                end;

                                trigger OnPreXmlItem();
                                var
                                begin
                                    ManualMessage := false;
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Data Exch. Entry No.", "Payment Export Data"."Data Exch Entry No.");
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Transaction ID", TransThemUniqueId);
                                    if ("Credit Transfer Entry".Count() = 0) then begin
                                        ManualMessage := true;
                                        currXMLport.skip();
                                    end;
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
                                        chequenum := GetValue(RecordRef, "Payment Export Data".FieldNo("Document No."));
                                    end;
                                }
                                textelement(dispatchbranch)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(voideddate)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
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
                                        currXMLport.Skip();
                                    end;
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    chequeinfo := GetValue(RecordRef, "Payment Export Data".FieldNo("Importing Code"));
                                    if (chequeinfo = 'FALSE') then
                                        currXMLport.Skip()
                                    else
                                        chequeinfo := '';
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
                                        ReceiverBankAccount := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Acc. No."));
                                    end;
                                }
                                textelement(receivercurrency)
                                {
                                    XmlName = 'currency';

                                    trigger OnBeforePassVariable();
                                    begin
                                        receivercurrency := GetValue(RecordRef, "Payment Export Data".FieldNo("AMC Recip. Bank Acc. Currency"));
                                    end;
                                }
                                textelement(receiverintregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregno';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverIntRegNo := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Clearing Code"));
                                    end;
                                }
                                textelement(receiverintregnotype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregnotype';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverIntRegNoType := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Clearing Std."));
                                    end;
                                }
                                textelement(receiverswiftcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'swiftcode';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverSWIFTCode := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank BIC"));
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
                                            RecBankAccAddress1 := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Address"));
                                        end;
                                    }
                                    textelement(recbankaccaddress2)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address2';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(recbankacccity)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'city';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccCity := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank City"));
                                        end;
                                    }
                                    textelement(recbankacccontactemail)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'contactemail';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(recbankacccontactname)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'contactname';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(recbankaccctry)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'countryiso';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccCtry := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Country/Region"));
                                        end;
                                    }
                                    textelement(recbankacclegalregno)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'legalregistrationnumber';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(recbankaccname)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'name';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccName := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Name"));
                                        end;
                                    }
                                    textelement(recbankaccstate)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'state';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccState := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank County"));
                                        end;
                                    }
                                    textelement(recbankaccidentitytype)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'identitytype';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(recbankacczipcode)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'zipcode';

                                        trigger OnBeforePassVariable();
                                        begin
                                            RecBankAccZipcode := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Bank Post Code"));
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
                                            pmtlinenum := GetValue(RecordRef, "Payment Export Data".FieldNo("Line No."))
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
                                            pmtmsgtext := GetValue(RecordRef, "Payment Export Data".FieldNo("Message to Recipient 1"))
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
                            textelement(messagestructure)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    if (not ManualMessage) then
                                        messagestructure := GetValue(RecordRef, "Payment Export Data".FieldNo("Message Structure"))
                                    else
                                        messagestructure := 'manual';
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
                                        if (regrepcode = '') then
                                            currXMLport.Skip();
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
                                        if (RegRepText = '') then
                                            currXMLport.Skip();
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
                            textelement(costs)
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    costs := GetValue(RecordRef, "Payment Export Data".FieldNo("Costs Distribution"));
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
                                        AmtValue := GetValue(RecordRef, "Payment Export Data".FieldNo(Amount));
                                    end;
                                }
                                textelement(amtcurrency)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paycurrency';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AmtCurrency := GetValue(RecordRef, "Payment Export Data".FieldNo("Currency Code"));
                                    end;
                                }
                                textelement(amtdate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paydate';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AmtDate := GetValue(RecordRef, "Payment Export Data".FieldNo("Transfer Date"));
                                    end;
                                }
                                textelement(amtvatamount)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'vatamount';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
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
                                        address1 := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Address"));
                                    end;
                                }
                                textelement(address2)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(city)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        city := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient City"));
                                    end;
                                }
                                textelement(contactemail)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(contactname)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(countryiso)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        countryiso := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Country/Region Code"));
                                    end;
                                }
                                textelement(legalregistrationnumber)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(name)
                                {

                                    trigger OnBeforePassVariable();
                                    begin
                                        name := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Name"));
                                    end;
                                }
                                textelement(receiverstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable();
                                    begin
                                        ReceiverState := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient County"));
                                    end;
                                }
                                textelement(identitytype)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                                textelement(zipcode)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        zipcode := GetValue(RecordRef, "Payment Export Data".FieldNo("Recipient Post Code"));
                                    end;
                                }
                            }

                        }
                        textelement(ownaddressinfo)
                        {

                            trigger OnBeforePassVariable();
                            begin
                                ownaddressinfo := GetValue(RecordRef, PaymentExportData.FieldNo("Own Address Info."));
                            end;
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
                            textelement(owncontactemail)
                            {
                                MinOccurs = Zero;
                                XmlName = 'contactemail';

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    if ("Company Information"."E-Mail" <> '') then
                                        owncontactemail := "Company Information"."E-Mail"
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(owncontactname)
                            {
                                MinOccurs = Zero;
                                XmlName = 'contactname';

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    if ("Company Information"."Contact Person" <> '') then
                                        owncontactname := "Company Information"."Contact Person"
                                    else
                                        currXMLport.Skip();
                                end;
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
                            textelement(ownlegalregno)
                            {
                                MinOccurs = Zero;
                                XmlName = 'legalregistrationnumber';

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    if ("Company Information".GetRegistrationNumber() <> '') then
                                        ownlegalregno := "Company Information".GetRegistrationNumber()
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            fieldelement(name; "Company Information".Name)
                            {
                            }
                            fieldelement(state; "Company Information".County)
                            {
                                MinOccurs = Zero;
                            }
                            textelement(ownidentitytype)
                            {
                                MinOccurs = Zero;
                                XmlName = 'identitytype';

                                trigger OnBeforePassVariable();
                                var
                                begin
                                    currXMLport.Skip();
                                end;
                            }
                            fieldelement(zipcode; "Company Information"."Post Code")
                            {
                                MinOccurs = Zero;
                            }
                        }

                        trigger OnAfterGetRecord();
                        begin
                            if "Payment Export Data"."Line No." <> CurrentLineNo then begin
                                RecordRef.GetTable("Payment Export Data");
                                CurrentLineNo := "Payment Export Data"."Line No.";
                            end
                            else
                                currXMLport.SKIP();
                        end;
                    }

                    trigger OnBeforePassVariable();
                    begin
                        PaymentExportData.COPYFILTERS("Payment Export Data");
                        if PaymentExportData.FINDFIRST() then;
                        RecordRef.GetTable(PaymentExportData);
                    end;
                }
            }
            textelement(bank)
            {
                MaxOccurs = Once;

                trigger OnBeforePassVariable();
                begin
                    bank := GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name - Data Conv."));
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
        PaymentExportData: Record "Payment Export Data";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        VATEntry: Record "VAT Entry"; //V17.5
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
        CurrentLineNo: Integer;
        ManualMessage: Boolean;

    local procedure InitializeGlobals();
    begin
        CurrentLineNo := 0;
    end;

    local procedure GetLanguage(): Text[3];
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.GET(GLOBALLANGUAGE());
        exit(WindowsLanguage."Abbreviated Name");
    end;

    local procedure GetCVLedgerEntryBuffer(var CopyCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CreditTransferEntry: Record "Credit Transfer Entry");
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
    begin
        Clear(CopyCVLedgerEntryBuffer);
        clear(VATEntry);
        if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Vendor) then begin
            VendorLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
            if (VendorLedgerEntry.get(CreditTransferEntry."Applies-to Entry No.")) then begin
                CopyCVLedgerEntryBuffer.CopyFromVendLedgEntry(VendorLedgerEntry);
                if (VendorLedgerEntry."External Document No." <> '') then
                    CopyCVLedgerEntryBuffer.Description := VendorLedgerEntry."External Document No." //1. Prio
                else
                    CopyCVLedgerEntryBuffer.Description := VendorLedgerEntry.Description; //2. Prio

                //Get sum of vat entries
            end
        end
        else
            if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Customer) then begin
                CustLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                if (CustLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                    CopyCVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgerEntry);
                    if (CustLedgerEntry."Document Date" <> 0D) then
                        CopyCVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Document Date"
                    else
                        CopyCVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Posting Date";
                end
            end
            else
                if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Employee) then begin
                    EmployeeLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                    if (EmployeeLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                        CopyCVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmployeeLedgerEntry);
                        CopyCVLedgerEntryBuffer."Document Date" := EmployeeLedgerEntry."Posting Date";
                    end;
                end;

        //-> V17.5
        if (not CopyCVLedgerEntryBuffer.IsEmpty) then begin
            VATEntry.SetCurrentKey("Posting Date", "Document Date");
            VATEntry.SetRange("Posting Date", CopyCVLedgerEntryBuffer."Posting Date");
            VATEntry.SetRange("Document Date", CopyCVLedgerEntryBuffer."Document Date");
            VATEntry.SetRange("Document No.", CopyCVLedgerEntryBuffer."Document No.");
            VATEntry.SetRange("Document Type", CopyCVLedgerEntryBuffer."Document Type");
            VATEntry.CalcSums(VATEntry.Amount);
        end;
        //<- V17.5
    end;

    local procedure GetValue(RecordRef: RecordRef; FieldNo: Integer): Text;
    var
        TransformedValue: Text;
    begin

        TransformedValue := AMCBankingMgt.GetFieldValue(RecordRef, FieldNo);

        if (TransformedValue <> '') then
            exit(TransformedValue)
        else
            currXMLport.Skip();

    end;
}

