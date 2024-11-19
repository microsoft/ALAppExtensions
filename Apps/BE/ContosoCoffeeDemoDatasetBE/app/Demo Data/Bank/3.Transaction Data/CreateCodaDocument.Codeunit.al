codeunit 11415 "Create Coda Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        CodedTransactions();
        CodedBankAccStatement();
    end;

    local procedure CodedTransactions()
    var
        ContosoCODABE: Codeunit "Contoso CODA BE";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoCODABE.InsertCodedTransaction('', 0, 0, 0, 0, 1, CreateBEGLAccount.CodaTemporaryAccount(), DefaultPostingLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 1, 0, 0, 3, '', YourSingleTransferOrdersLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 5, 0, 0, 1, CreateGLAccount.Wages(), WagesLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 7, 0, 0, 1, CreateBEGLAccount.BankProcessing(), YourCollectiveTransferOrdersLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 37, 0, 0, 1, CreateBEGLAccount.BankCharges(), GlobalBankChargesLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 37, 6, 0, 1, CreateBEGLAccount.BankCharges(), NetBankChargesLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 37, 11, 0, 1, CreateBEGLAccount.VatRecoverable(), BankChargesVATLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 50, 0, 0, 2, '', TransferToYourAccountLbl);
        ContosoCODABE.InsertCodedTransaction('', 1, 52, 0, 0, 2, '', PaymentInYourFavourLbl);
        ContosoCODABE.InsertCodedTransaction('', 3, 1, 0, 0, 1, CreateBEGLAccount.CodaTemporaryAccount(), YourCheckPaymentLbl);
        ContosoCODABE.InsertCodedTransaction('', 3, 52, 0, 0, 1, CreateBEGLAccount.CodaTemporaryAccount(), CheckRemittanceLbl);
        ContosoCODABE.InsertCodedTransaction('', 5, 1, 0, 0, 3, '', PaymentOfDomiciledInvoiceLbl);
        ContosoCODABE.InsertCodedTransaction('', 5, 3, 0, 0, 2, '', UnpaidDebtDueLbl);
        ContosoCODABE.InsertCodedTransaction('', 5, 5, 0, 0, 2, '', ReimbursementLbl);
        ContosoCODABE.InsertCodedTransaction('', 11, 1, 0, 0, 1, CreateBEGLAccount.StockBuyIn(), StockBuyInLbl);
        ContosoCODABE.InsertCodedTransaction('', 11, 1, 100, 0, 1, CreateBEGLAccount.StockBuyIn(), StockBuyInGrossAmountLbl);
        ContosoCODABE.InsertCodedTransaction('', 11, 1, 426, 0, 1, CreateBEGLAccount.Brokerage(), BrokerageOnStocksLbl);
        ContosoCODABE.InsertCodedTransaction('', 11, 1, 427, 0, 1, CreateBEGLAccount.StockExchangeTurnoverTax(), StockExchangeTurnoverTaxLbl);
        ContosoCODABE.InsertCodedTransaction('', 13, 11, 0, 0, 1, CreateBEGLAccount.RedemptionOfLoan(), TermedLoanLbl);
        ContosoCODABE.InsertCodedTransaction('', 13, 11, 2, 0, 1, CreateGLAccount.InterestonBankBalances(), FinanceChargesOnLoansLbl);
        ContosoCODABE.InsertCodedTransaction('', 13, 11, 55, 0, 1, CreateBEGLAccount.RedemptionOfLoan(), RedemptionOfLoanLbl);
        ContosoCODABE.InsertCodedTransaction('', 30, 54, 0, 1, 1, CreateBEGLAccount.Transfers(), CapitalFinChargesInvestmentsLbl);
        ContosoCODABE.InsertCodedTransaction('', 30, 54, 1, 0, 1, CreateBEGLAccount.IncomeFromLoans(), FinanceChargesReceivedLbl);
        ContosoCODABE.InsertCodedTransaction('', 30, 54, 51, 0, 1, CreateGLAccount.InterestonBankBalances(), WithholdingTaxOnIncomeLbl);
        ContosoCODABE.InsertCodedTransaction('', 41, 37, 0, 1, 1, CreateBEGLAccount.BankCharges(), ForeignTransferCostsLbl);
        ContosoCODABE.InsertCodedTransaction('', 41, 37, 11, 1, 1, CreateBEGLAccount.VatRecoverable(), ForeignTransferVATLbl);
        ContosoCODABE.InsertCodedTransaction('', 41, 37, 13, 1, 1, CreateBEGLAccount.BankCharges(), ForeignTransfPaymCommisionLbl);
        ContosoCODABE.InsertCodedTransaction('', 41, 37, 39, 1, 1, CreateGLAccount.PhoneandFax(), ForeignTransferPhoneCostsLbl);
        ContosoCODABE.InsertCodedTransaction('', 41, 37, 100, 1, 1, CreateBEGLAccount.BankCharges(), ForeignTransferGrossAmountLbl);
    end;

    local procedure CodedBankAccStatement()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        ContosoCODABE: Codeunit "Contoso CODA BE";
        CreateBankAccountBE: Codeunit "Create Bank Account BE";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendor: Codeunit "Create Vendor";
        CustomerName: Text[35];
        CustomerAddress: Text[35];
        CustomerCity: Text[35];
        VendorName: Text[35];
        VendorAddress: Text[35];
        VendorCity: Text[35];
    begin
        ContosoCODABE.InsertCodedBankAccStatement(CreateBankAccountBE.NBLBank(), StatementNoLbl, 1853323, 20010216D, 983935);

        Customer.Get(CreateCustomer.DomesticAdatumCorporation());
        CustomerName := CopyStr(Customer.Name, 1, 35);
        CustomerAddress := CopyStr(Customer.Address, 1, 35);
        CustomerCity := CopyStr(Customer.City, 1, 35);
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 10000, CodId::Movement, CodType::Global, '230058315713', 498297, 20080217D, 0, 1, 50, 0, MessType::"Non standard format", 0, '*** 00/9906/86864***', 20080217D, '230058315713', CustomerName, CustomerAddress, CustomerCity, 0, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 20000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, 'REF. 850719730107                             + 498.297 EUR', 0D, '', '', '', '', 10000, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 30000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, ByOrderOfLbl + '               ' + '230-0583157-13', 0D, '', '', '', '', 10000, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 40000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, CustomerName + '    ' + CustomerAddress, 0D, '', '', '', '', 10000, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 50000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, CustomerCity, 0D, '', '', '', '', 10000, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 60000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, '*** 00/9906/103001***', 0D, '', '', '', '', 10000, '216/1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 70000, CodId::Movement, CodType::Global, '4850743000074', 6967, 20080217D, 2, 1, 50, 0, MessType::"Non standard format", 0, 'REF. **/36.9288', 20080217D, '', '', '', '', 0, '216/2');

        Customer.Get(CreateCustomer.EUAlpineSkiHouse());
        CustomerName := CopyStr(Customer.Name, 1, 35);
        CustomerAddress := CopyStr(Customer.Address, 1, 35);
        CustomerCity := CopyStr(Customer.City, 1, 35);

        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 80000, CodId::Movement, CodType::Global, '230058315713', 100200, 20080217D, 0, 1, 50, 0, MessType::"Non standard format", 0, '*** 00/9906/84037***', 20080217D, '310054005646', CustomerName, CustomerAddress, CustomerCity, 0, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 90000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, 'REF. 850719730107                             + 100.200 EUR', 0D, '', '', '', '', 80000, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 100000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, ByOrderOfLbl + '               ' + '310-0540056-46', 0D, '', '', '', '', 80000, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 110000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, CustomerName + '     ' + CustomerAddress, 0D, '', '', '', '', 80000, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 120000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, CustomerCity, 0D, '', '', '', '', 80000, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 130000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, PrepaymentShipmentLbl, 0D, '', '', '', '', 80000, '216/3');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 140000, CodId::Movement, CodType::Global, '4850750705981', -1208, 20010216D, 0, 3, 3, 0, MessType::"Standard format", 107, '4001969689460002 00001602010000 ARAL MECHELEN    MECHELEN', 20080217D, '', '', '', '', 0, '216/4');

        Customer.Get(CreateCustomer.DomesticTreyResearch());
        CustomerName := CopyStr(Customer.Name, 1, 35);
        CustomerAddress := CopyStr(Customer.Address, 1, 35);
        CustomerCity := CopyStr(Customer.City, 1, 35);

        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 150000, CodId::Movement, CodType::Global, '788535710831', 426053, 20080217D, 0, 1, 50, 0, MessType::"Standard format", 101, '000010300285', 20080217D, '788535710831', CustomerName, CustomerAddress, CustomerCity, 0, '216/5');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 160000, CodId::Movement, CodType::Global, '4866447710582', -182, 20080217D, 3, 41, 37, 0, MessType::"Non standard format", 0, '', 20080217D, '', '', '', '', 0, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 170000, CodId::Information, CodType::Global, '4866447710582', 0, 0D, 3, 41, 37, 0, MessType::"Non standard format", 0, RabobankLbl, 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 180000, CodId::Information, CodType::Global, '4866447710582', 0, 0D, 3, 41, 37, 0, MessType::"Non standard format", 0, TransferOrderChargesLbl + '                        EUR         5550,00', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 190000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, 'REF. 866447710582                                 FOLIO 01', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 200000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, TransferOrderChargesLbl, 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 210000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, 'EUR               5550,00 O.REF. :  0298077832710582 2311', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 220000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, CorrespondentLbl + '   ' + RabobankLbl, 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 230000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, ChargesToYourDebitInEURLbl, 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 240000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, PaymentCommissionLbl + '                 150,00', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 250000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, VATTaxableLbl + '       150,00 VAT   21,00%            32,00', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 260000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, TotalToYourDebitLbl + '     VAL. 15.02 EUR              182,00', 0D, '', '', '', '', 160000, '216/6');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 270000, CodId::Movement, CodType::Detail, '4866447710582', -32, 20080217D, 8, 41, 37, 11, MessType::"Standard format", 106, '0000000000320000000150000002100000000 000000000032000', 20080217D, '', '', '', '', 160000, '216/6-1');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 280000, CodId::Movement, CodType::Detail, '4866447710582', -150, 20080217D, 8, 41, 37, 13, MessType::"Non standard format", 0, '', 20080217D, '', '', '', '', 160000, '216/6-2');

        Vendor.Get(CreateVendor.EUGraphicDesign());
        VendorName := CopyStr(Vendor.Name, 1, 35);
        VendorAddress := CopyStr(Vendor.Address, 1, 35);
        VendorCity := CopyStr(Vendor.City, 1, 35);

        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 290000, CodId::Movement, CodType::Global, '4850659338955', -220099, 20080217D, 0, 1, 1, 0, MessType::"Non standard format", 0, '101000010802665', 20080217D, '431068010811', VendorName, VendorAddress, VendorCity, 0, '216/7');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 300000, CodId::Movement, CodType::Global, '4850836332760', -1700, 20080217D, 0, 1, 1, 0, MessType::"Standard format", 101, '198411561414', 20080217D, '431068011114', MillersAndCoLbl, '', '', 0, '216/8');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 310000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, AsOfDateYouAreInvitedToLbl, 0D, '', '', '', '', 0, '216/0');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 320000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, NewGovernmentLoanUsingRefLbl, 0D, '', '', '', '', 0, '216/0');
        ContosoCODABE.InsertCodedBankAccStatLine(CreateBankAccountBE.NBLBank(), StatementNoLbl, 330000, CodId::"Free Message", CodType::Global, '', 0, 0D, 0, 0, 0, 0, MessType::"Non standard format", 0, PleaseContactYourBankManagerLbl, 0D, '', '', '', '', 0, '216/0');
    end;

    var
        StatementNoLbl: Label '216', MaxLength = 20;
        MessType: Option "Non standard format","Standard format";
        CodId: Option ,,Movement,Information,"Free Message";
        CodType: Option Global,Detail;
        RedemptionOfLoanLbl: Label 'Redemption of Loan', MaxLength = 50;
        StockBuyInLbl: Label 'Stock Buy In', MaxLength = 50;
        StockExchangeTurnoverTaxLbl: Label 'Stock Exchange Turnover Tax', MaxLength = 50;
        DefaultPostingLbl: Label 'Default Posting', MaxLength = 50;
        YourSingleTransferOrdersLbl: Label 'Your single Transfer Orders', MaxLength = 50;
        WagesLbl: Label 'Wages', MaxLength = 50;
        YourCollectiveTransferOrdersLbl: Label 'Your collective Transfer Orders', MaxLength = 50;
        GlobalBankChargesLbl: Label 'Global Bank Charges', MaxLength = 50;
        NetBankChargesLbl: Label 'Net Bank Charges', MaxLength = 50;
        BankChargesVATLbl: Label 'Bank Charges VAT', MaxLength = 50;
        TransferToYourAccountLbl: Label 'Transfer to your Account', MaxLength = 50;
        PaymentInYourFavourLbl: Label 'Payment in your Favour', MaxLength = 50;
        YourCheckPaymentLbl: Label 'Your Check Payment', MaxLength = 50;
        CheckRemittanceLbl: Label 'Check Remittance', MaxLength = 50;
        PaymentOfDomiciledInvoiceLbl: Label 'Payment of Domiciled Invoice', MaxLength = 50;
        UnpaidDebtDueLbl: Label 'Unpaid Debt Due', MaxLength = 50;
        ReimbursementLbl: Label 'Reimbursement', MaxLength = 50;
        StockBuyInGrossAmountLbl: Label 'Stock Buy In Gross Amount', MaxLength = 50;
        BrokerageOnStocksLbl: Label 'Brokerage on Stocks', MaxLength = 50;
        TermedLoanLbl: Label 'Termed Loan', MaxLength = 50;
        FinanceChargesOnLoansLbl: Label 'Finance Charges on Loans', MaxLength = 50;
        CapitalFinChargesInvestmentsLbl: Label 'Capital/Finance Charges Investments', MaxLength = 50;
        FinanceChargesReceivedLbl: Label 'Finance Charges Received', MaxLength = 50;
        WithholdingTaxOnIncomeLbl: Label 'Withholding Tax on Income', MaxLength = 50;
        ForeignTransferCostsLbl: Label 'Foreign Transfer Costs', MaxLength = 50;
        ForeignTransferVATLbl: Label 'Foreign Transfer VAT', MaxLength = 50;
        ForeignTransfPaymCommisionLbl: Label 'Foreign Transfer Payment Commision', MaxLength = 50;
        ForeignTransferPhoneCostsLbl: Label 'Foreign Transfer Phone Costs', MaxLength = 50;
        ForeignTransferGrossAmountLbl: Label 'Foreign Transfer Gross Amount', MaxLength = 50;
        ByOrderOfLbl: Label 'BY ORDER OF :', MaxLength = 50;
        PrepaymentShipmentLbl: Label 'PREPAYMENT SHIPMENT OF 10/12/99', MaxLength = 50;
        RabobankLbl: Label 'RABOBANK NETHERLANDS', MaxLength = 50;
        TransferOrderChargesLbl: Label 'TRANSFER ORDER CHARGES :', MaxLength = 50;
        CorrespondentLbl: Label 'CORRESPONDENT', MaxLength = 50;
        ChargesToYourDebitInEURLbl: Label 'CHARGES TO YOUR DEBIT IN EUR :', MaxLength = 50;
        PaymentCommissionLbl: Label 'PAYMENT COMMISSION', MaxLength = 50;
        VATTaxableLbl: Label 'VAT TAXABLE', MaxLength = 50;
        TotalToYourDebitLbl: Label 'TOTAL TO YOUR DEBIT :', MaxLength = 50;
        MillersAndCoLbl: Label 'MILLERS & CO', MaxLength = 35;
        AsOfDateYouAreInvitedToLbl: Label 'AS OF 03/03 YOU ARE INVITED TO SUBSCRIBE TO THE', MaxLength = 250;
        NewGovernmentLoanUsingRefLbl: Label 'NEW GOVERNMENT LOAN USING REF. 45/66392', MaxLength = 250;
        PleaseContactYourBankManagerLbl: Label 'PLEASE CONTACT YOUR BANK MANAGER FOR MORE INFORMATION.', MaxLength = 250;
}