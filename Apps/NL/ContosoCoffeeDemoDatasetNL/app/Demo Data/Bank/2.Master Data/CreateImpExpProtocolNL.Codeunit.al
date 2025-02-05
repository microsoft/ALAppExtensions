codeunit 11539 "Create Imp./Exp. Protocol NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        InsertImportProtocol();
        InsertExportProtocol();
        InsertTransactionMode();
    end;

    procedure BBV(): Code[20]
    begin
        exit(BBVTok);
    end;

    procedure BTL91(): Code[20]
    begin
        exit(BTL91Tok);
    end;

    procedure GenericSEPA(): Code[20]
    begin
        exit(GenericSEPATok);
    end;

    procedure GenericSEPA09(): Code[20]
    begin
        exit(GenericSEPA09Tok);
    end;

    procedure PAYMUL(): Code[20]
    begin
        exit(PAYMULTok);
    end;

    procedure RABOMUTASC(): Code[20]
    begin
        exit(RABOMUTASCTok);
    end;

    procedure RABOVVMUTASC(): Code[20]
    begin
        exit(RABOVVMUTASCTok);
    end;

    local procedure InsertImportProtocol()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        CreateDataExchange: Codeunit "Create Data Exchange";
        ImportType: Option "TableData","Table",Form,"Report",,"Codeunit","XMLport",MenuSuite,"Page";
    begin
        ContosoBankNL.InsertImportProtocol(RABOMUTASC(), ImportType::Report, Report::"Import Rabobank mut.asc", RABOTelebankingDomesticLbl, true);
        ContosoBankNL.InsertImportProtocol(RABOVVMUTASCTok, ImportType::Report, Report::"Import Rabobank vvmut.asc", RABOTelebankingForeignLbl, true);
        ContosoBankNL.InsertImportProtocol(CreateDataExchange.SEPACAMT(), ImportType::Codeunit, Codeunit::"Import SEPA CAMT", SEPACAMTBankStatementsLbl, true);
    end;

    local procedure InsertExportProtocol()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        ExportObjectType: Option "Report","XMLPort";
        ChecksumAlgorithm: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        ContosoBankNL.InsertExportProtocol(BBV(), BBVDescLbl, ExportObjectType::Report, 11000008, 11000008, 11000004, BBVDefaultFileNameLbl, BBVExportFileNameLbl, ChecksumAlgorithm::MD5);
        ContosoBankNL.InsertExportProtocol(BTL91(), BTL91DesLbl, ExportObjectType::Report, 11000007, 11000007, 11000004, Btl91DefaultFileNameLbl, BTL91ExportFileNameLbl, ChecksumAlgorithm::MD5);
        ContosoBankNL.InsertExportProtocol(GenericSEPA(), GenericPaymentFileDesLbl, ExportObjectType::Report, 11000007, 11000012, 11000004, '', GenericSEPAExportFileNameLbl, ChecksumAlgorithm::MD5);
        ContosoBankNL.InsertExportProtocol(GenericSEPA09(), GenericSEPA09DescLbl, ExportObjectType::Report, 11000007, 11000014, 11000004, '', GenericSEPA09ExportFileNameLbl, ChecksumAlgorithm::MD5);
        ContosoBankNL.InsertExportProtocol(PAYMUL(), PAYMULTok, ExportObjectType::Report, 11000009, 11000009, 11000004, '', PAYMULExportFileNameLbl, ChecksumAlgorithm::MD5);
    end;

    local procedure InsertTransactionMode()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
        CreateNoSeriesNL: Codeunit "Create No. Series NL";
        CreateSourceCodeNL: Codeunit "Create Source Code NL";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
        AccountType: Option Customer,Vendor,Employee;
        Order: Option ,Debit,Credit;
    begin
        ContosoBankNL.InsertTransactionMode(AccountType::Customer, CreateBankAccountNL.ABN(), CollectionCustomersDescLbl, Order::Credit, true, CreateBankAccountNL.ABN(), true, BTL91(), true, CreateNoSeriesNL.TelebankingRunNos(), CreateSourceCodeNL.RecptsProc(), CreateNoSeriesNL.ReceiptsProcess(), CreateNLGLAccounts.CollectioninProcess(), CreateNoSeriesNL.ReceiptsProcess(), CreateSourceCodeNL.RecptsProc(), CreateNoSeriesNL.TelebankingIdentification());
        ContosoBankNL.InsertTransactionMode(AccountType::Vendor, CreateBankAccountNL.ABN(), PaymentVendorDescLbl, Order::Debit, true, CreateBankAccountNL.ABN(), true, BTL91(), true, CreateNoSeriesNL.TelebankingRunNos(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.PaymentsProcess(), CreateNLGLAccounts.PaymentsinProcess(), CreateNoSeriesNL.PaymentsProcess(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.TelebankingIdentification());
        ContosoBankNL.InsertTransactionMode(AccountType::Vendor, 'ABN-BTL', PaymentVendorDescLbl, Order::Debit, true, CreateBankAccountNL.ABN(), true, BTL91(), true, CreateNoSeriesNL.TelebankingRunNos(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.PaymentsProcess(), CreateNLGLAccounts.PaymentsinProcess(), CreateNoSeriesNL.PaymentsProcess(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.TelebankingIdentification());
        ContosoBankNL.InsertTransactionMode(AccountType::Vendor, CreateBankAccountNL.PostBank(), PaymentVendorDescLbl, Order::Debit, true, CreateBankAccountNL.PostBank(), true, BTL91(), true, CreateNoSeriesNL.TelebankingRunNos(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.PaymentsProcess(), CreateNLGLAccounts.PaymentsinProcess(), CreateNoSeriesNL.PaymentsProcess(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.TelebankingIdentification());
        ContosoBankNL.InsertTransactionMode(AccountType::Vendor, 'RABO-BBV', PaymentVendorDescLbl, Order::Debit, true, CreateBankAccountNL.ABNUSD(), true, BBV(), true, CreateNoSeriesNL.TelebankingRunNos(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.PaymentsProcess(), CreateNLGLAccounts.PaymentsinProcess(), CreateNoSeriesNL.PaymentsProcess(), CreateSourceCodeNL.PaymtProc(), CreateNoSeriesNL.TelebankingIdentification());
    end;

    var
        RABOMUTASCTok: Label 'RABO MUT.ASC', MaxLength = 20, Locked = true;
        RABOVVMUTASCTok: Label 'RABO VVMUT.ASC', MaxLength = 20, Locked = true;
        RABOTelebankingDomesticLbl: Label 'RABO Telebanking (Domestic)', MaxLength = 100;
        RABOTelebankingForeignLbl: Label 'RABO Telebanking (Foreign)', MaxLength = 100;
        SEPACAMTBankStatementsLbl: Label 'SEPA CAMT Bank Statements', MaxLength = 100;
        BBVTok: Label 'BBV', MaxLength = 20, Locked = true;
        BBVDescLbl: Label 'RABO Foreign Payments', MaxLength = 100;
        BTL91Tok: Label 'BTL91', MaxLength = 20, Locked = true;
        BTL91DesLbl: Label 'ABN-AMRO Foreign Payments', MaxLength = 100, Locked = true;
        GenericSEPATok: Label 'GENERIC SEPA', MaxLength = 20, Locked = true;
        GenericPaymentFileDesLbl: Label 'Generic Payment File', MaxLength = 100, Locked = true;
        GenericSEPA09Tok: Label 'GENERIC SEPA09', MaxLength = 20, Locked = true;
        GenericSEPA09DescLbl: Label 'SEPA CT pain.001.001.09', MaxLength = 100;
        PAYMULTok: Label 'PAYMUL', MaxLength = 20, Locked = true;
        BBVDefaultFileNameLbl: Label 'c:\temp\bbv%1.txt', Comment = '%1 is bbv default file path', MaxLength = 250;
        Btl91DefaultFileNameLbl: Label 'c:\temp\btl%1.txt', Comment = '%1 is btl default file path', MaxLength = 250;
        BBVExportFileNameLbl: Label 'Export BBV', MaxLength = 30;
        BTL91ExportFileNameLbl: Label 'Export BTL91-ABN AMRO', MaxLength = 30;
        GenericSEPAExportFileNameLbl: Label 'SEPA ISO20022 Pain 01.01.03', MaxLength = 30;
        GenericSEPA09ExportFileNameLbl: Label 'SEPA ISO20022 Pain 01.01.09', MaxLength = 30;
        PAYMULExportFileNameLbl: Label 'Export PAYMUL', MaxLength = 30;
        CollectionCustomersDescLbl: Label 'Collection Customers', MaxLength = 80;
        PaymentVendorDescLbl: Label 'Payment Vendor', MaxLength = 80;
}