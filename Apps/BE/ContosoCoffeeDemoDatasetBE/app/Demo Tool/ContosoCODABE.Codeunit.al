codeunit 11414 "Contoso CODA BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "CODA Statement" = rim,
        tabledata "CODA Statement Line" = rim,
        tabledata "Transaction Coding" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCodedTransaction(BankAccountNo: Code[20]; TransactionFamily: Integer; Transaction: Integer; TransactionCategory: Integer; GlobalisationCode: Option; AccountType: Option; AccountNo: Code[20]; Description: Text[50])
    var
        TransactionCoding: Record "Transaction Coding";
        Exists: Boolean;
    begin
        if TransactionCoding.Get(BankAccountNo, TransactionFamily, Transaction, TransactionCategory) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TransactionCoding.Validate("Bank Account No.", BankAccountNo);
        TransactionCoding.Validate("Transaction Family", TransactionFamily);
        TransactionCoding.Validate(Transaction, Transaction);
        TransactionCoding.Validate("Transaction Category", TransactionCategory);
        TransactionCoding.Insert(true);

        TransactionCoding.Validate("Globalisation Code", GlobalisationCode);
        TransactionCoding.Validate("Account Type", AccountType);
        TransactionCoding.Validate("Account No.", AccountNo);
        TransactionCoding.Validate(Description, Description);

        if Exists then
            TransactionCoding.Insert(true)
        else
            TransactionCoding.Modify(true);
    end;

    procedure InsertCodedBankAccStatement(BankAccountNo: Code[20]; StatementNo: Code[20]; EndingBalance: Decimal; StatementDate: Date; BalanceLastStatement: Decimal)
    var
        CodBankAccStatement: Record "CODA Statement";
        Exists: Boolean;
    begin
        if CodBankAccStatement.Get(BankAccountNo, StatementNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CodBankAccStatement.Validate("Bank Account No.", BankAccountNo);
        CodBankAccStatement.Validate("Statement No.", StatementNo);
        CodBankAccStatement.Validate("Statement Ending Balance", EndingBalance);
        CodBankAccStatement.Validate("Statement Date", StatementDate);
        CodBankAccStatement.Validate("Balance Last Statement", BalanceLastStatement);

        if Exists then
            CodBankAccStatement.Modify(true)
        else
            CodBankAccStatement.Insert(true);
    end;

    procedure InsertCodedBankAccStatLine(BankAccountNo: Code[20]; StatementNo: Code[20]; StatementLineNo: Integer; StatementId: Option; StatType: Option; BankReferenceNo: Text[21]; StatementAmount: Decimal; TransactionDate: Date; TransactionType: Integer; TransactionFamily: Integer; StatementTransaction: Integer; TransactionCategory: Integer; MessageType: Option; TypeStandardFormatMessage: Integer; StatementMessage: Text[250]; PostingDate: Date; BankAccNoOtherParty: Text[34]; NameOtherParty: Text[35]; AddressOtherParty: Text[35]; CityOtherParty: Text[35]; AttachedToLineNo: Integer; DocumentNo: Code[20])
    var
        CodBankAccStatLine: Record "CODA Statement Line";
    begin
        CodBankAccStatLine.Validate("Bank Account No.", BankAccountNo);
        CodBankAccStatLine.Validate("Statement No.", StatementNo);
        CodBankAccStatLine.Validate("Statement Line No.", StatementLineNo);
        CodBankAccStatLine.Validate(ID, StatementId);
        CodBankAccStatLine.Validate(Type, StatType);
        CodBankAccStatLine.Validate("Bank Reference No.", BankReferenceNo);
        CodBankAccStatLine.Validate("Statement Amount", StatementAmount);
        CodBankAccStatLine.Validate("Transaction Date", TransactionDate);
        CodBankAccStatLine.Validate("Transaction Type", TransactionType);
        CodBankAccStatLine.Validate("Transaction Family", TransactionFamily);
        CodBankAccStatLine.Validate(Transaction, StatementTransaction);
        CodBankAccStatLine.Validate("Transaction Category", TransactionCategory);
        CodBankAccStatLine.Validate("Message Type", MessageType);
        CodBankAccStatLine.Validate("Type Standard Format Message", TypeStandardFormatMessage);
        CodBankAccStatLine.Validate("Statement Message", StatementMessage);
        CodBankAccStatLine.Validate("Posting Date", PostingDate);
        CodBankAccStatLine.Validate("Bank Account No. Other Party", BankAccNoOtherParty);
        CodBankAccStatLine.Validate("Name Other Party", NameOtherParty);
        CodBankAccStatLine.Validate("Address Other Party", AddressOtherParty);
        CodBankAccStatLine.Validate("City Other Party", CityOtherParty);
        CodBankAccStatLine.Validate("Attached to Line No.", AttachedToLineNo);
        CodBankAccStatLine.Validate("Document No.", DocumentNo);
        CodBankAccStatLine.Insert(true);

        if StatementAmount <> 0 then begin
            CodBankAccStatLine.Validate("Unapplied Amount", StatementAmount);
            CodBankAccStatLine.Modify(true)
        end;
    end;

    var
        OverwriteData: Boolean;
}

