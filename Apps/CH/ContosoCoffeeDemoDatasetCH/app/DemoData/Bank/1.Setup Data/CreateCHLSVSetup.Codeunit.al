codeunit 11626 "Create CH LSV Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCHBank: Codeunit "Contoso CH Bank";
        CreateCHPaymentMethod: Codeunit "Create CH Payment Method";
        CreateCurrency: Codeunit "Create Currency";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateCHESRSetup: Codeunit "Create CH ESR Setup";
    begin
        ContosoCHBank.InsertLSVSetup(GiroBankCode(), LSVCustomerIDLbl, LSVCustomerIDLbl, LSVSenderClearingLbl, CreateCHPaymentMethod.LSV(), CreateCHESRSetup.GiroBankCode(), CreateCurrency.CHF(), 'CH9300762011623852957', LSVCustomerBankCodeLbl, DebitDirectCustomernoLbl, CreateCHGLAccounts.BankCredit(), LSVFileFolderLbl, LSVFilenameLbl, TextLbl, Text2Lbl, ComputerBureauNameLbl, ComputerBureauName2Lbl, ComputerBureauAddressLbl, '8021', ComputerBureauCityLbl, LSVBankNameLbl, LSVBankAddressLbl, '6301', LSVBankCityLbl, LSVBankTransferHyperlinkLbl);
        ContosoCHBank.InsertLSVSetup(WWBEURBankCode(), LSVCustomerIDLbl, LSVCustomerIDLbl, LSVSenderClearingLbl, CreateCHPaymentMethod.LSV(), CreateCHESRSetup.NBLBankCode(), CreateCurrency.EUR(), 'CH9300762011623852957', LSVCustomerBankCodeLbl, DebitDirectCustomernoLbl, CreateCHGLAccounts.BankCredit(), LSVFileFolderLbl, LSVFilenameLbl, TextLbl, Text2Lbl, ComputerBureauNameLbl, ComputerBureauName2Lbl, ComputerBureauAddressLbl, '8021', ComputerBureauCityLbl, LSVBankNameLbl, LSVBankAddressLbl, '6301', LSVBankCityLbl, '');
    end;

    procedure GiroBankCode(): Code[20]
    begin
        exit(GiroBankCodeTok);
    end;

    procedure WWBEURBankCode(): Code[20]
    begin
        exit(WWBEURBankCodeTok);
    end;


    var
        GiroBankCodeTok: Label 'GIRO', MaxLength = 20;
        WWBEURBankCodeTok: Label 'WWB-EUR', MaxLength = 20;
        LSVCustomerIDLbl: Label 'CRON2', MaxLength = 10;
        LSVSenderClearingLbl: Label '100', MaxLength = 5;
        LSVCustomerBankCodeLbl: Label 'LSV', MaxLength = 10;
        DebitDirectCustomernoLbl: Label '909700', MaxLength = 6;
        LSVFileFolderLbl: Label 'C:\', MaxLength = 40;
        LSVFilenameLbl: Label 'DTALSV', MaxLength = 11;
        TextLbl: Label 'Dear Sir or Madam', MaxLength = 250;
        Text2Lbl: Label 'Next year we would like to reduce the administrative costs for payments for you and us.  We ask you to please return this form with the required information included and signed.', MaxLength = 250;
        ComputerBureauNameLbl: Label 'Telekurs Payserv AG', MaxLength = 30;
        ComputerBureauName2Lbl: Label 'Computer Bureau', MaxLength = 30;
        ComputerBureauAddressLbl: Label 'Parcel Post Box', MaxLength = 30;
        ComputerBureauCityLbl: Label 'Zürich 1', MaxLength = 30;
        LSVBankNameLbl: Label 'Credit Suisse', MaxLength = 30;
        LSVBankAddressLbl: Label 'Bahnhofstrasse 17', MaxLength = 30;
        LSVBankCityLbl: Label 'Zug', MaxLength = 30;
        LSVBankTransferHyperlinkLbl: Label 'https://gate.sic.ch', MaxLength = 30;
}