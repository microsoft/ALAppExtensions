table 40104 MSFTCM20200
{
    ReplicateData = false;
    Extensible = false;
    Permissions = tableData "Bank Account Ledger Entry" = rim;
    DataClassification = CustomerContent;
    Description = 'GP Checkbook Transactions';

    fields
    {
        field(1; CMRECNUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(2; sRecNum; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(3; RCRDSTTS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; CMTrxNum; Text[21])
        {
            DataClassification = CustomerContent;
        }
        ///        1        2        3                  4                    5                  6                  7
        ///     Deposit, Receipt, APCheck, "Withdrawl/Payroll Check", IncreaseAdjustment, DecreaseAdjustment, BankTransfer;
        ///         
        field(6; CMTrxType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; TRXDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; GLPOSTDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(9; TRXAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(11; CMLinkID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; paidtorcvdfrom; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(13; DSCRIPTN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(14; Recond; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; RECONUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; ClrdAmt; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; clearedate; Date)
        {
            DataClassification = CustomerContent;
        }
        field(18; VOIDED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(19; VOIDDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; VOIDPDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(21; VOIDDESC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(22; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; AUDITTRAIL; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(24; DEPTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(25; SOURCDOC; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(26; SRCDOCTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(27; SRCDOCNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(28; POSTEDDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(29; PTDUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; MODIFDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(31; MDFUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(32; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(33; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(34; ORIGAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; Checkbook_Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(36; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(37; EXGTBLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(38; XCHGRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; EXCHDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(40; TIME1; Date)
        {
            DataClassification = CustomerContent;
        }
        field(41; RTCLCMTD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; EXPNDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(43; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(44; DECPLCUR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(45; DENXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; MCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(47; Xfr_Record_Number; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(48; EFTFLAG; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(49; VNDCHKNM; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(50; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CMRECNUM)
        {
            Clustered = true;
        }
    }

    var
        CMTransactionType: Option "",Deposit,Receipt,APCheck,"Withdrawl/Payroll Check",IncreaseAdjustment,DecreaseAdjustment,BankTransfer;
        BankBatchNameTxt: Label 'GPBANK', Locked = true;

    procedure MoveStagingData(BankAccountNo: Code[20]; BankAccPostingGroupCode: Code[20]; CheckbookID: Text[15])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GPVendor: Record "GP Vendor";
        HelperFunctions: Codeunit "Helper Functions";
        JournalTemplateName: Code[10];
        DocumentType: Enum "Gen. Journal Document Type";
        AccountType: Enum "Gen. Journal Account Type";
        NoSeries: Code[20];
        AccountNo: Code[20];
        Amount: Decimal;
    begin
        SetRange(CHEKBKID, CheckbookID);
        if FindSet() then
            repeat
                AccountNo := GetBankAccPostingAccountNo(BankAccPostingGroupCode);
                DocumentType := DocumentType::" ";
                AccountType := AccountType::"G/L Account";
                Amount := TRXAMNT;

                case CMTrxType of
                    CMTransactionType::Deposit, CMTransactionType::Receipt:
                        begin
                            JournalTemplateName := 'CASHRCPT';
                            NoSeries := 'GJNL-RCPT';
                        end;
                    CMTransactionType::APCheck:
                        begin
                            DocumentType := DocumentType::Payment;
                            JournalTemplateName := 'PAYMENT';
                            NoSeries := 'GJNL-PMT';
                            Amount := -TRXAMNT;
                            if GPVendor.Get(CMLinkID) then begin
                                AccountNo := HelperFunctions.GetPostingAccountNumber('PayablesAccount');
                                AccountType := AccountType::Vendor;
                            end;
                        end;
                    else begin
                            JournalTemplateName := 'GENERAL';
                            NoSeries := 'GJNL-GEN';
                            if CMTrxType in [CMTransactionType::"Withdrawl/Payroll Check", CMTransactionType::DecreaseAdjustment] then
                                Amount := -TRXAMNT;
                        end;
                end;

                CreateGeneralJournalBatchIfNeeded(JournalTemplateName, NoSeries);
                CreateGeneralJournalLine(GenJournalLine, DocumentType, JournalTemplateName, AccountType,
                    Format(CMRECNUM), DSCRIPTN, TRXDATE, AccountNo, Amount, BankAccountNo, CMTrxType);

            until Next() = 0;
    end;

    procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type";
                JournalTemplateName: Code[10]; AccountType: Enum "Gen. Journal Account Type"; DocumentNo: Code[20]; Description: Text[50];
                PostingDate: Date; AccountNo: Code[20]; TrxAmount: Decimal; BankAccountNo: Code[20]; CMTrxType: Integer)
    var
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        LineNum: Integer;
    begin
        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCurrent.SetRange("Journal Batch Name", BankBatchNameTxt);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(JournalTemplateName);

        GenJournalLine.Init();
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account Type", AccountType);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate(Amount, TrxAmount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccountNo);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", BankBatchNameTxt);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Insert(true);
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(JournalTemplateName: Code[10]; NoSeries: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange(Name, BankBatchNameTxt);
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalBatch.SetRange("No. Series", NoSeries);

        if not GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate(Name, BankBatchNameTxt);
            GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            GenJournalBatch.Validate("No. Series", NoSeries);

            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Insert(true);
        end;
    end;

    local procedure GetBankAccPostingAccountNo(BankAccPostingGroup: Code[20]): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        if BankAccountPostingGroup.Get(BankAccPostingGroup) then
            exit(BankAccountPostingGroup."G/L Account No.");

        exit('InvalidAccount');
    end;
}