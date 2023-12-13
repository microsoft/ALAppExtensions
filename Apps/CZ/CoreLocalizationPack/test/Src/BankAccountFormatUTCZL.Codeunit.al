codeunit 148082 "Bank Account Format UT CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
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

    [Test]
    [Scope('OnPrem')]
    procedure ValidFormatBankAccountNo()
    var
        BankAccount: Record "Bank Account";
    begin
        // [SCENARIO] Positive test of valid bank account no.

        // [GIVEN] Setup Company Information
        SetupCompanyInformation();

        // [GIVEN] Bank Account Initialization
        BankAccount.Init();
        BankAccount."Country/Region Code" := '';

        // [WHEN] Validate bank account no. field 
        BankAccount.Validate("Bank Account No.", GetBankAccountNo());

        // [THEN] No error will occur

        // TEARDOWN
        TearDownCompanyInformation();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithInvalidCharacters()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with invalid characters
        BankAccountNoWithInvalidFormat(StrSubstNo(InvalidCharactersErr, '*'));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooLongNumber()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with number greater than 22
        BankAccountNoWithInvalidFormat(BankAccountNoTooLongErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooShortNumber()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with number less than 7
        BankAccountNoWithInvalidFormat(BankAccountNoTooShortErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithMissingSlash()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with missing slash
        BankAccountNoWithInvalidFormat(BankCodeSlashMissingErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooLongBankCode()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with too long bank code
        BankAccountNoWithInvalidFormat(BankCodeTooLongErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooShortBankCode()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with too short bank code
        BankAccountNoWithInvalidFormat(BankCodeTooShortErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooLongPrefix()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with too long prefix
        BankAccountNoWithInvalidFormat(PrefixTooLongErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithIncorrectCheckSumOfPrefix()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with incorrect check sum of prefix
        BankAccountNoWithInvalidFormat(PrefixIncorrectChecksumErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooLongIdentification()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with too long identification
        BankAccountNoWithInvalidFormat(IdentificationTooLongErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithTooShortIdentification()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with too short identification
        BankAccountNoWithInvalidFormat(IdentificationTooShortErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithoutNonZeroDigits()
    begin
        // [SCENARIO] Negative test of invalid bank account no. without non zero digits
        BankAccountNoWithInvalidFormat(IdentificationNonZeroDigitsErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithIncorrectCheckSumOfIdentification()
    begin
        // [SCENARIO] Negative test of invalid bank account no. without non zero digits
        BankAccountNoWithInvalidFormat(IdentificationIncorrectChecksumErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    [Scope('OnPrem')]
    procedure BankAccountNoWithFirstHyphen()
    begin
        // [SCENARIO] Negative test of invalid bank account no. with first minus
        BankAccountNoWithInvalidFormat(FirstHyphenErr);
    end;

    local procedure BankAccountNoWithInvalidFormat(Error: Text)
    var
        BankAccount: Record "Bank Account";
    begin
        // [GIVEN] Setup Company Information
        SetupCompanyInformation();

        // [GIVEN] Bank Account Initialization
        BankAccount.Init();
        BankAccount."Country/Region Code" := '';

        // [WHEN] Validate bank account no. field
        asserterror BankAccount.Validate("Bank Account No.", GetBankAccountNoCausingError(Error));

        // [THEN] The error will occur
        Assert.ExpectedError(Error);

        // TEARDOWN
        TearDownCompanyInformation();
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

    local procedure SetupCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account Format Check CZL" := true;
        CompanyInformation.Modify();
    end;

    local procedure TearDownCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account Format Check CZL" := false;
        CompanyInformation.Modify();
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ErrorMessagesHandler(var ErrorMessages: TestPage "Error Messages")
    begin
        Error(ErrorMessages.Description.Value);
    end;
}