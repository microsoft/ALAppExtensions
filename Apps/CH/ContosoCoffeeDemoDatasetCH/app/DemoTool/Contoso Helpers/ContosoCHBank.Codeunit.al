codeunit 11627 "Contoso CH Bank"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "LSV Setup" = rim,
        tabledata "ESR Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertLSVSetup(BankCode: Code[20]; LSVCustomerID: Code[10]; LSVSenderID: Code[10]; LSVSenderClearing: Code[5]; LSVPaymentMethodCode: Code[10]; ESRBankCode: Code[20]; LSVCurrencyCode: Code[10]; LSVSenderIBAN: Code[50]; LSVCustomerBankCode: Code[10]; DebitDirectCustomerno: Code[6]; BalAccountNo: Code[20]; LSVFileFolder: Code[40]; LSVFilename: Code[11]; TextVar: Text[250]; Text2: Text[250]; ComputerBureauName: Text[30]; ComputerBureauName2: Text[30]; ComputerBureauAddress: Text[30]; ComputerBureauPostCode: Code[20]; ComputerBureauCity: Text[30]; LSVBankName: Text[30]; LSVBankAddress: Text[30]; LSVBankPostCode: Code[20]; LSVBankCity: Text[30]; LSVBankTransferHyperlink: Text[50])
    var
        LSVSetup: Record "LSV Setup";
        Exists: Boolean;
    begin
        if LSVSetup.Get(BankCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        LSVSetup.Validate("Bank Code", BankCode);
        LSVSetup.Validate("LSV Customer ID", LSVCustomerID);
        LSVSetup.Validate("LSV Sender ID", LSVSenderID);
        LSVSetup."LSV Sender Clearing" := LSVSenderClearing;
        LSVSetup.Validate("LSV Payment Method Code", LSVPaymentMethodCode);
        LSVSetup.Validate("ESR Bank Code", ESRBankCode);
        LSVSetup.Validate("LSV Currency Code", LSVCurrencyCode);
        LSVSetup.Validate("LSV Sender IBAN", LSVSenderIBAN);
        LSVSetup.Validate("LSV Customer Bank Code", LSVCustomerBankCode);
        LSVSetup.Validate("DebitDirect Customerno.", DebitDirectCustomerno);
        LSVSetup.Validate("Bal. Account No.", BalAccountNo);
        LSVSetup.Validate("LSV File Folder", LSVFileFolder);
        LSVSetup.Validate("LSV Filename", LSVFilename);
        LSVSetup.Validate(Text, TextVar);
        LSVSetup.Validate("Text 2", Text2);
        LSVSetup.Validate("Computer Bureau Name", ComputerBureauName);
        LSVSetup.Validate("Computer Bureau Name 2", ComputerBureauName2);
        LSVSetup.Validate("Computer Bureau Address", ComputerBureauAddress);
        LSVSetup.Validate("Computer Bureau Post Code", ComputerBureauPostCode);
        LSVSetup.Validate("Computer Bureau City", ComputerBureauCity);
        LSVSetup.Validate("LSV Bank Name", LSVBankName);
        LSVSetup.Validate("LSV Bank Address", LSVBankAddress);
        LSVSetup.Validate("LSV Bank Post Code", LSVBankPostCode);
        LSVSetup.Validate("LSV Bank City", LSVBankCity);
        LSVSetup.Validate("LSV Bank Transfer Hyperlink", LSVBankTransferHyperlink);

        if Exists then
            LSVSetup.Modify(true)
        else
            LSVSetup.Insert(true);
    end;

    procedure InsertESRSetup(BankCode: Code[20]; BalAccountNo: Code[20]; ESRFileName: Text[50]; BESRCustomerID: Code[11]; ESRAccountNo: Code[11]; ESRCurrencyCode: Code[10]; ESRMemberName1: Text[30]; ESRMemberName2: Text[30]; ESRMemberName3: Text[30]; BeneficiaryText: Text[30]; Beneficiary: Text[30]; Beneficiary2: Text[30]; Beneficiary3: Text[30]; ESRPaymentMethodCode: Code[10]; ESRMainBank: Boolean)
    var
        ESRSetup: Record "ESR Setup";
        Exists: Boolean;
    begin
        if ESRSetup.Get(BankCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ESRSetup.Validate("Bank Code", BankCode);
        ESRSetup.Validate("ESR System", ESRSetup."ESR System"::ESR);
        ESRSetup.Validate("Bal. Account Type", ESRSetup."Bal. Account Type"::"G/L Account");
        ESRSetup.Validate("Bal. Account No.", BalAccountNo);
        ESRSetup.Validate("ESR Filename", ESRFileName);
        ESRSetup.Validate("BESR Customer ID", BESRCustomerID);
        ESRSetup.Validate("ESR Account No.", ESRAccountNo);
        ESRSetup.Validate("ESR Currency Code", ESRCurrencyCode);
        ESRSetup.Validate("ESR Member Name 1", ESRMemberName1);
        ESRSetup.Validate("ESR Member Name 2", ESRMemberName2);
        ESRSetup.Validate("ESR Member Name 3", ESRMemberName3);
        ESRSetup.Validate("Beneficiary Text", BeneficiaryText);
        ESRSetup.Validate(Beneficiary, Beneficiary);
        ESRSetup.Validate("Beneficiary 2", Beneficiary2);
        ESRSetup.Validate("Beneficiary 3", Beneficiary3);
        ESRSetup.Validate("ESR Payment Method Code", ESRPaymentMethodCode);
        ESRSetup.Validate("ESR Main Bank", ESRMainBank);

        if Exists then
            ESRSetup.Modify(true)
        else
            ESRSetup.Insert(true);
    end;
}