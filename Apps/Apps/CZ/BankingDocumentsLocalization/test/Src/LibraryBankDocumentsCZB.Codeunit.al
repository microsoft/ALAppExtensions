codeunit 148005 "Library - Bank Documents CZB"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        InvalidCharactersErr: Label 'Bank account no. contains invalid characters "%1".', Comment = '%1 = invalid characters';
        BankAccountNoTooLongErr: Label 'Bank account no. is too long.';
        BankAccountNoTooShortErr: Label 'Bank account no. is too short.';
        BankCodeSlashMissingErr: Label 'Bank code must be separated by a slash.';
        BankCodeTooLongErr: Label 'Bank code is too long.';
        BankCodeTooShortErr: Label 'Bank code is too short.';
        PrefixTooLongErr: Label 'Bank account prefix is too long.';
        PrefixIncorrectChecksumErr: Label 'Bank account prefix has incorrect checksum.';
        IdentificationTooLongErr: Label 'Bank account identification is too long.';
        IdentificationTooShortErr: Label 'Bank account identification is too short.';
        IdentificationNonZeroDigitsErr: Label 'Bank account identification must contain at least two non-zero digits.';
        IdentificationIncorrectChecksumErr: Label 'Bank account identification has incorrect checksum.';
        FirstHyphenErr: Label 'Bank account no. must not start with character "-".';

    procedure UpdateBankAccount(WithSearchRule: Boolean)
    var
        BankAccount: Record "Bank Account";
        BaseCalendar: Record "Base Calendar";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        SearchRuleCZB: Record "Search Rule CZB";
    begin
        FindBankAccount(BankAccount);
        FindBaseCalendar(BaseCalendar);

        // Change bank account no. to czech format
        BankAccount.Validate("Bank Account No.", GetBankAccountNo());
        BankAccount.Validate("Non Assoc. Payment Account CZB", GetGLAccountNo());
        BankAccount.Validate("Check CZ Format on Issue CZB", true);
        BankAccount.Validate("Base Calendar Code CZB", BaseCalendar.Code);
        BankAccount.Validate("Domestic Payment Order ID CZB", Report::"Iss. Payment Order CZB");
        BankAccount.Validate("Foreign Payment Order ID CZB", Report::"Iss. Payment Order CZB");
        BankAccount.Validate("Post Per Line CZB", true);
        BankAccount.Validate("Variable S. to Variable S. CZB", true);
        BankAccount.Validate("Payment Order Nos. CZB", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("Issued Payment Order Nos. CZB", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("Bank Statement Nos. CZB", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("Issued Bank Statement Nos. CZB", LibraryERM.CreateNoSeriesCode());

        if WithSearchRule then begin
            LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
            GenJournalTemplate.Type := GenJournalTemplate.Type::Payments;
            GenJournalTemplate.Modify();
            BankAccount.Validate("Payment Jnl. Template Name CZB", GenJournalTemplate.Name);

            LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
            GenJournalBatch."Bal. Account Type" := GenJournalBatch."Bal. Account Type"::"Bank Account";
            GenJournalBatch."Bal. Account No." := BankAccount."No.";
            GenJournalBatch."Allow Payment Export" := true;
            GenJournalBatch.Modify();
            BankAccount.Validate("Payment Jnl. Batch Name CZB", GenJournalBatch.Name);

            CreateSearchRule(SearchRuleCZB);
            BankAccount.Validate("Search Rule Code CZB", SearchRuleCZB.Code);
        end;
        BankAccount.Modify(true);
    end;

    procedure CreateSearchRule(var SearchRuleCZB: Record "Search Rule CZB")
    begin
        SearchRuleCZB.Init();
        SearchRuleCZB.Validate(SearchRuleCZB.Code,
          LibraryUtility.GenerateRandomCode(SearchRuleCZB.FieldNo(SearchRuleCZB.Code), Database::"Search Rule CZB"));
        SearchRuleCZB.Validate(SearchRuleCZB.Description, SearchRuleCZB.Code);
        SearchRuleCZB.Insert(true);

        SearchRuleCZB.CreateDefaultLines();
    end;

    procedure CreateBankStatementHeader(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    var
        BankAccount: Record "Bank Account";
    begin
        FindBankAccount(BankAccount);

        BankStatementHeaderCZB.Init();
        BankStatementHeaderCZB.Validate("Bank Account No.", BankAccount."No.");
        BankStatementHeaderCZB.Validate("Document Date", WorkDate());
        BankStatementHeaderCZB.Insert(true);
        BankStatementHeaderCZB.Validate("External Document No.", BankStatementHeaderCZB."No.");
        BankStatementHeaderCZB.Modify(true);
    end;

    procedure CreateBankStatementLine(var BankStatementLineCZB: Record "Bank Statement Line CZB"; BankStatementHeaderCZB: Record "Bank Statement Header CZB"; Type: Enum "Banking Line Type CZB"; No: Code[20]; Amount: Decimal; VariableSymbol: Code[10])
    var
        RecordRef: RecordRef;
    begin
        BankStatementLineCZB.Init();
        BankStatementLineCZB.Validate("Bank Statement No.", BankStatementHeaderCZB."No.");
        RecordRef.GetTable(BankStatementLineCZB);
        BankStatementLineCZB.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, BankStatementLineCZB.FieldNo("Line No.")));
        BankStatementLineCZB.Insert(true);

        BankStatementLineCZB.Validate(Type, Type);
        BankStatementLineCZB.Validate("No.", No);
        if Amount = 0 then
            BankStatementLineCZB.Validate(Amount, LibraryRandom.RandInt(1000))
        else
            BankStatementLineCZB.Validate(Amount, Amount);
        if VariableSymbol = '' then
            BankStatementLineCZB.Validate("Variable Symbol", GenerateVariableSymbol())
        else
            BankStatementLineCZB.Validate("Variable Symbol", VariableSymbol);
        BankStatementLineCZB.Modify(true);
    end;

    procedure CreateConstantSymbolCZL(var ConstantSymbolCZL: Record "Constant Symbol CZL")
    begin
        ConstantSymbolCZL.Init();
        ConstantSymbolCZL.Validate(Code, LibraryUtility.GenerateRandomCode(ConstantSymbolCZL.FieldNo(Code), Database::"Constant Symbol CZL"));
        ConstantSymbolCZL.Validate(Description, ConstantSymbolCZL.Code);
        ConstantSymbolCZL.Insert(true)
    end;

    procedure CreatePaymentOrderHeader(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.FindBankAccount(BankAccount);

        PaymentOrderHeaderCZB.Init();
        PaymentOrderHeaderCZB.Validate("Bank Account No.", BankAccount."No.");
        PaymentOrderHeaderCZB.Validate("Document Date", WorkDate());
        PaymentOrderHeaderCZB.Insert(true);
    end;

    procedure CreatePaymentOrderLine(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; Type: Enum "Banking Line Type CZB"; No: Code[20]; Amount: Decimal)
    var
        RecordRef: RecordRef;
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate("Payment Order No.", PaymentOrderHeaderCZB."No.");
        RecordRef.GetTable(PaymentOrderLineCZB);
        PaymentOrderLineCZB.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, PaymentOrderLineCZB.FieldNo("Line No.")));
        PaymentOrderLineCZB.Insert(true);

        PaymentOrderLineCZB.Validate(Type, Type);
        PaymentOrderLineCZB.Validate("No.", No);
        PaymentOrderLineCZB.Validate(Amount, Amount);
        PaymentOrderLineCZB.Validate("Variable Symbol", GenerateVariableSymbol());
        PaymentOrderLineCZB.Modify(true);
    end;

    procedure SuggestPayments(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        SuggestPaymentsCZB: Report "Suggest Payments CZB";
    begin
        Commit();
        SuggestPaymentsCZB.SetPaymentOrder(PaymentOrderHeaderCZB);
        SuggestPaymentsCZB.RunModal();
    end;

    procedure CopyPaymentOrder(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    var
        CopyPaymentOrderCZB: Report "Copy Payment Order CZB";
    begin
        Commit();
        CopyPaymentOrderCZB.SetBankStatementHeader(BankStatementHeaderCZB);
        CopyPaymentOrderCZB.RunModal();
    end;

    procedure PrintPaymentOrder(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB"; ShowReqForm: Boolean)
    begin
        IssPaymentOrderHeaderCZB.PrintRecords(ShowReqForm);
    end;

    procedure IssuePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
    end;

    procedure IssueBankStatementAndPrint(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
        Codeunit.Run(Codeunit::"Issue Bank Statement Print CZB", BankStatementHeaderCZB);
    end;

    procedure GetBankAccountNo(): Text[30]
    begin
        exit('1111111111/0100');
    end;

    procedure GetBankAccountNoCausingError(Error: Text): Text[30]
    begin
        case Error of
            StrSubstNo(InvalidCharactersErr, '*'):
                exit('*'); // star is invalid char
            BankAccountNoTooLongErr:
                exit('123456789012345678/0123'); // bank account no. is greater than 22
            BankAccountNoTooShortErr:
                exit('/2345'); // bank account no. is less than 7
            BankCodeSlashMissingErr:
                exit('1234567'); // slash is missing
            BankCodeTooLongErr:
                exit('1234567890/12345'); // bank code is greater than 4
            BankCodeTooShortErr:
                exit('1234567890/123'); // bank code is less than 4
            PrefixTooLongErr:
                exit('1234567-51/1234'); // prefix is greater than 6
            PrefixIncorrectChecksumErr:
                exit('123456-51/1234'); // check sum of prefix is not valid
            IdentificationTooLongErr:
                exit('12345678901/1234'); // identification is greater than 10
            IdentificationTooShortErr:
                exit('123456-1/1234'); // identification is less than 2
            IdentificationNonZeroDigitsErr:
                exit('0000000000/1234'); // identification does not contains non zero characters
            IdentificationIncorrectChecksumErr:
                exit('1234567890/1234'); // check sum of identification is not valid
            FirstHyphenErr:
                exit('-51/1234'); // hyphen is first character
        end;
    end;

    procedure GetInvalidBankAccountNo(): Text[30]
    begin
        exit(GetBankAccountNoCausingError(IdentificationIncorrectChecksumErr));
    end;

    procedure GenerateVariableSymbol(): Code[10]
    begin
        exit(BankOperationsFunctionsCZL.CreateVariableSymbol(IncStr(LibraryUtility.GenerateGUID())));
    end;

    procedure FindBankAccount(var BankAccount: Record "Bank Account")
    begin
        LibraryERM.FindBankAccount(BankAccount);
    end;

    procedure FindBaseCalendar(var BaseCalendar: Record "Base Calendar")
    begin
        BaseCalendar.FindFirst();
    end;

    procedure GetGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        FindGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    local procedure FindGLAccount(var GLAccount: Record "G/L Account")
    begin
        LibraryERM.FindGLAccount(GLAccount);
    end;
}
