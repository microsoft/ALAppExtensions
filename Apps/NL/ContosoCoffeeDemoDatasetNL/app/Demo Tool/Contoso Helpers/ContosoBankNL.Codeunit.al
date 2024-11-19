codeunit 11519 "Contoso Bank NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
            tabledata "Bank Account" = rim,
            tabledata "Freely Transferable Maximum" = rim,
            tabledata "Elec. Tax Declaration Setup" = rim,
            tabledata "Elec. Tax Decl. VAT Category" = rim,
            tabledata "Import Protocol" = rim,
            tabledata "Export Protocol" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertBankAccount(No: Code[20]; Name: Text[100]; Address: Text[100]; City: Text[30]; Contact: Text[100]; BankAccountNo: Text[30]; BankAccPostingGroup: Code[20]; OurContactCode: Code[20]; PostCode: Code[20]; BankBranchNo: Text[20]; CurrencyCode: Code[20]; IBANNo: Code[50]; AccountHolderName: Text[100]; AccountHolderAddress: Text[100]; AccountHolderCity: Text[30]; AccountHolderPostCode: Code[20]; AccountHolderCountryRegionCode: Code[10])
    var
        BankAccount: Record "Bank Account";
        Exists: Boolean;
    begin
        if BankAccount.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankAccount.Validate("No.", No);
        BankAccount.Validate(Name, Name);
        BankAccount.Validate(Address, Address);
        BankAccount.Validate(City, City);
        BankAccount.Validate(Contact, Contact);
        BankAccount.Validate("Bank Account No.", BankAccountNo);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccPostingGroup);
        BankAccount.Validate("Our Contact Code", OurContactCode);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Validate(IBAN, IBANNo);
        BankAccount.Validate("Account Holder Name", AccountHolderName);
        BankAccount.Validate("Account Holder Address", AccountHolderAddress);
        BankAccount.Validate("Account Holder City", AccountHolderCity);
        BankAccount.Validate("Account Holder Post Code", AccountHolderPostCode);
        BankAccount."Acc. Hold. Country/Region Code" := AccountHolderCountryRegionCode;

        if Exists then
            BankAccount.Modify(true)
        else
            BankAccount.Insert(true);
    end;


    procedure InsertBankAccountPostingGroup(Code: Code[20]; GLAccountNo: Code[20]; AccNoPmtRcptinProcess: Code[20])
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        Exists: Boolean;
    begin
        if BankAccountPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankAccountPostingGroup.Validate(Code, Code);
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
        BankAccountPostingGroup.Validate("Acc.No. Pmt./Rcpt. in Process", AccNoPmtRcptinProcess);

        if Exists then
            BankAccountPostingGroup.Modify(true)
        else
            BankAccountPostingGroup.Insert(true);
    end;

    procedure InsertFreelyTransferableMaximum(CountryRegionCode: Code[20]; CurrencyCode: Text[30]; Amount: Decimal)
    var
        FreelyTransferableMaximum: Record "Freely Transferable Maximum";
        Exists: Boolean;
    begin
        if FreelyTransferableMaximum.Get(CountryRegionCode, CurrencyCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FreelyTransferableMaximum.Validate("Country/Region Code", CountryRegionCode);
        if CurrencyCode <> '' then
            FreelyTransferableMaximum.Validate("Currency Code", CurrencyCode);
        FreelyTransferableMaximum.Validate(Amount, Amount);

        if Exists then
            FreelyTransferableMaximum.Modify(true)
        else
            FreelyTransferableMaximum.Insert(true);
    end;

    procedure InsertElecTaxDeclarationSetup(VATDeclarationNos: Code[20]; ICPDeclarationNos: Code[20]; TaxPayerContactName: Text[35]; TaxPayerContactPhoneNo: Text[25])
    var
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
    begin
        if not ElecTaxDeclarationSetup.Get() then
            ElecTaxDeclarationSetup.Insert();

        ElecTaxDeclarationSetup.Validate("VAT Declaration Nos.", VATDeclarationNos);
        ElecTaxDeclarationSetup.Validate("ICP Declaration Nos.", ICPDeclarationNos);
        ElecTaxDeclarationSetup.Validate("Tax Payer Contact Name", TaxPayerContactName);
        ElecTaxDeclarationSetup.Validate("Tax Payer Contact Phone No.", TaxPayerContactPhoneNo);
        ElecTaxDeclarationSetup.Modify(true);
    end;

    procedure InsertElecTaxDeclVATCategory(Code: Code[10]; Category: Option; ByUsDomestic: Option; ToUsDomestic: Option; ByUsForeign: Option; ToUsForeign: Option; Calculation: Option; Optional: Boolean)
    var
        ElecTaxDeclVATCategory: Record "Elec. Tax Decl. VAT Category";
        Exists: Boolean;
    begin
        if ElecTaxDeclVATCategory.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ElecTaxDeclVATCategory.Validate(Code, Code);
        ElecTaxDeclVATCategory.Validate(Category, Category);
        ElecTaxDeclVATCategory.Validate("By Us (Domestic)", ByUsDomestic);
        ElecTaxDeclVATCategory.Validate("To Us (Domestic)", ToUsDomestic);
        ElecTaxDeclVATCategory.Validate("By Us (Foreign)", ByUsForeign);
        ElecTaxDeclVATCategory.Validate("To Us (Foreign)", ToUsForeign);
        ElecTaxDeclVATCategory.Validate(Calculation, Calculation);
        ElecTaxDeclVATCategory.Validate(Optional, Optional);

        if Exists then
            ElecTaxDeclVATCategory.Modify(true)
        else
            ElecTaxDeclVATCategory.Insert(true);
    end;

    procedure InsertImportProtocol(Code: Code[20]; ImportType: Option; ImportID: Integer; Description: Text[100]; AutomaticReconciliation: Boolean)
    var
        ImportProtocol: Record "Import Protocol";
        Exists: Boolean;
    begin
        if ImportProtocol.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ImportProtocol.Validate(Code, Code);
        ImportProtocol.Validate("Import Type", ImportType);
        ImportProtocol.Validate("Import ID", ImportID);
        ImportProtocol.Validate(Description, Description);
        ImportProtocol.Validate("Automatic Reconciliation", AutomaticReconciliation);

        if Exists then
            ImportProtocol.Modify(true)
        else
            ImportProtocol.Insert(true);
    end;

    procedure InsertExportProtocol(Code: Code[20]; Description: Text[100]; ExportObjectType: Option; CheckID: Integer; ExportID: Integer; DocketID: Integer; DefaultFileNames: Text[250]; ExportName: Text[30]; ChecksumAlgorithm: Option)
    var
        ExportProtocol: Record "Export Protocol";
        Exists: Boolean;
    begin
        if ExportProtocol.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ExportProtocol.Validate(Code, Code);
        ExportProtocol.Validate(Description, Description);
        ExportProtocol.Validate("Export Object Type", ExportObjectType);
        ExportProtocol.Validate("Check ID", CheckID);
        ExportProtocol.Validate("Export ID", ExportID);
        ExportProtocol.Validate("Docket ID", DocketID);
        if DefaultFileNames <> '' then
            ExportProtocol.Validate("Default File Names", DefaultFileNames);
        ExportProtocol.Validate("Export Name", ExportName);
        ExportProtocol.Validate("Checksum Algorithm", ChecksumAlgorithm);

        if Exists then
            ExportProtocol.Modify(true)
        else
            ExportProtocol.Insert(true);
    end;

    procedure InsertTransactionMode(AccountType: Option; Code: Code[20]; Description: Text[80]; Order: Option; IncludeInPaymentProposal: Boolean; BankAccountNo: Code[20]; CombineEntries: Boolean; ExportProtocol: Code[20]; PmtDiscPossible: Boolean; RunNoSeries: Code[20]; SourceCode: Code[10]; PostingNoSeries: Code[20]; AccNoPmtRcptInProcess: Code[20]; CorrectionPostingNoSeries: Code[20]; CorrectionSourceCode: Code[10]; IdentificationNoSeries: Code[20])
    var
        TransactionMode: Record "Transaction Mode";
        Exists: Boolean;
    begin
        if TransactionMode.Get(AccountType, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TransactionMode.Validate("Account Type", AccountType);
        TransactionMode.Validate(Code, Code);
        TransactionMode.Validate(Description, Description);
        TransactionMode.Validate(Order, Order);
        TransactionMode.Validate("Include in Payment Proposal", IncludeInPaymentProposal);
        TransactionMode.Validate("Our Bank", BankAccountNo);
        TransactionMode.Validate("Combine Entries", CombineEntries);
        TransactionMode.Validate("Export Protocol", ExportProtocol);
        TransactionMode.Validate("Pmt. Disc. Possible", PmtDiscPossible);
        TransactionMode.Validate("Run No. Series", RunNoSeries);
        TransactionMode.Validate("Source Code", SourceCode);
        TransactionMode.Validate("Posting No. Series", PostingNoSeries);
        TransactionMode.Validate("Acc. No. Pmt./Rcpt. in Process", AccNoPmtRcptInProcess);
        TransactionMode.Validate("Correction Posting No. Series", CorrectionPostingNoSeries);
        TransactionMode.Validate("Correction Source Code", CorrectionSourceCode);
        TransactionMode.Validate("Identification No. Series", IdentificationNoSeries);

        if Exists then
            TransactionMode.Modify(true)
        else
            TransactionMode.Insert(true);
    end;
}
