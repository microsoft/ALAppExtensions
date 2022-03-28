table 40101 "GP Checkbook Transactions"
{
    ReplicateData = false;
    Extensible = false;
    Permissions = tableData "Bank Account Ledger Entry" = rim;

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
        field(40; TIME1; Time)
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
        key(PK; CMRECNUM)
        {
            Clustered = true;
        }
    }

    var
        CashReceiptTypeId: Integer;

    procedure MoveStagingData(BankAccountNo: Code[20]; BankAccPostingGroupCode: Code[20]; CheckbookID: Text[15])
    var
        GenJournalLine: Record "Gen. Journal Line";
        AccountNo: Code[20];
    begin
        CashReceiptTypeId := 2;
        SetRange(CHEKBKID, CheckbookID);
        if FindSet() then
            repeat
                if CMTrxType = CashReceiptTypeId then
                    AccountNo := GetBankAccPostingAccountNo(BankAccPostingGroupCode) /* GL Account Number based off of account index */
                else
                    AccountNo := CMLinkID;  /* Vendor ID */

                CreateGeneralJournalLine(GenJournalLine,
                    Format(CMRECNUM),
                    DSCRIPTN,
                    TRXDATE,
                    AccountNo,
                    TRXAMNT,
                    BankAccountNo,
                    CMTrxType
                );

            until Next() = 0;
    end;

    procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20]; Description: Text[50]; PostingDate: Date; AccountNo: Code[20]; TrxAmount: Decimal; BankAccountNo: Code[20]; CMTrxType: Integer)
    var
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
        DocumentType: Enum "Gen. Journal Document Type";
        LineNum: Integer;
    begin
        CreateGeneralJournalBatchIfNeeded(CMTrxType);

        /*  
            GP CMTrxType we support
            -- 2 = cash receipt
            -- 3 = payment
        */
        if CMTrxType = CashReceiptTypeId then begin
            DocumentType := DocumentType::" ";
            JournalTemplateName := 'CASHRCPT';
            AccountType := AccountType::"G/L Account"
            /* AccountNo will be GL Account number -- offset account */
        end else begin
            DocumentType := DocumentType::Payment;
            JournalTemplateName := 'PAYMENT';
            AccountType := AccountType::Vendor;
            /* AccountNo will be Vendor account number */
        end;

        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCurrent.SetRange("Journal Batch Name", 'GPBANK');
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
        GenJournalLine.Validate("Journal Batch Name", 'GPBANK');
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Insert(true);
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(TrxType: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange(Name, 'GPBANK');

        if TrxType = 2 then begin
            GenJournalBatch.SetRange("Journal Template Name", 'CASHRCPT');
            GenJournalBatch.SetRange("No. Series", 'GJNL-RCPT');
        end else begin
            GenJournalBatch.SetRange("Journal Template Name", 'PAYMENT');
            GenJournalBatch.SetRange("No. Series", 'GJNL-PMT');
        end;

        if not GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate(Name, 'GPBANK');

            if TrxType = CashReceiptTypeId then begin
                GenJournalBatch.Validate("Journal Template Name", 'CASHRCPT');
                GenJournalBatch.Validate("No. Series", 'GJNL-RCPT');
            end else begin
                GenJournalBatch.Validate("Journal Template Name", 'PAYMENT');
                GenJournalBatch.Validate("No. Series", 'GJNL-PMT');
            end;

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