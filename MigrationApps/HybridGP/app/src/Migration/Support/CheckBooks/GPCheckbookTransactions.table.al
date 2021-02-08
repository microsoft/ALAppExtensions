table 40101 "GP Checkbook Transactions"
{
    ReplicateData = false;

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
        PostingGroupCodeTxt: Label 'GP', Locked = true;

    procedure MoveStagingData(CheckbookId: Code[15]; PostingGroup: Code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BatchCounter: Integer;
    begin
        BatchCounter := 0;
        SetRange(CHEKBKID, CheckbookId);
        if FindSet() then
            repeat
                BankAccountLedgerEntry.Init();
                BankAccountLedgerEntry."Entry No." := CMRECNUM;
                BankAccountLedgerEntry."Document No." := Format(CMRECNUM);
                BankAccountLedgerEntry."Transaction No." := CMRECNUM;
                BankAccountLedgerEntry."Bank Account No." := CHEKBKID;
                BankAccountLedgerEntry."Posting Date" := TRXDATE;
                BankAccountLedgerEntry.Description := paidtorcvdfrom;
                BankAccountLedgerEntry."Bank Acc. Posting Group" := PostingGroup;
                BankAccountLedgerEntry.Open := true;
                BankAccountLedgerEntry."Closed by Entry No." := 0;

                if StrLen(CHEKBKID.Trim()) <= 8 then
                    BankAccountLedgerEntry."Journal Batch Name" := PostingGroupCodeTxt + CopyStr(CHEKBKID.Trim(), 1, 8)
                else
                    BankAccountLedgerEntry."Journal Batch Name" := GetJournalBatchName(CHEKBKID, BatchCounter);

                BankAccountLedgerEntry."Bal. Account No." := CMLinkID;
                BankAccountLedgerEntry."Statement Status" := 0;
                BankAccountLedgerEntry."Statement Line No." := 0;
                BankAccountLedgerEntry."Document Date" := TRXDATE;
                BankAccountLedgerEntry."External Document No." := SRCDOCNUM;

                /*  
                    GP CMTrxType we support
                    -- 2 = cash receipt
                    -- 3 = payment
                */
                if CMTrxType = 2 then begin
                    BankAccountLedgerEntry."Document Type" := BankAccountLedgerEntry."Document Type"::" ";
                    BankAccountLedgerEntry.Amount := TRXAMNT;
                    BankAccountLedgerEntry."Remaining Amount" := TRXAMNT;
                    BankAccountLedgerEntry."Amount (LCY)" := TRXAMNT;
                    BankAccountLedgerEntry."Source Code" := 'CASHRECJNL';
                    BankAccountLedgerEntry.Positive := true;
                    BankAccountLedgerEntry."Bal. Account Type" := BankAccountLedgerEntry."Bal. Account Type"::Customer;
                    BankAccountLedgerEntry."Debit Amount" := TRXAMNT;
                    BankAccountLedgerEntry."Debit Amount (LCY)" := TRXAMNT;
                end else begin
                    BankAccountLedgerEntry."Document Type" := BankAccountLedgerEntry."Document Type"::Payment;
                    BankAccountLedgerEntry.Amount := -TRXAMNT;
                    BankAccountLedgerEntry."Remaining Amount" := -TRXAMNT;
                    BankAccountLedgerEntry."Amount (LCY)" := -TRXAMNT;
                    BankAccountLedgerEntry."Source Code" := 'PAYMENTJNL';
                    BankAccountLedgerEntry.Positive := false;
                    BankAccountLedgerEntry."Bal. Account Type" := BankAccountLedgerEntry."Bal. Account Type"::Vendor;
                    BankAccountLedgerEntry."Credit Amount" := TRXAMNT;
                    BankAccountLedgerEntry."Credit Amount (LCY)" := TRXAMNT;
                end;

                BankAccountLedgerEntry.Insert(true);
            until Next() = 0;
    end;

    local procedure GetJournalBatchName(CheckBookId: Text[15]; var Counter: Integer): Code[10]
    var
        Name: Text[8];
    begin
        Counter := Counter + 1;

        if Counter < 10 then
            Name := CopyStr(CheckBookId.Trim(), 1, 7) + Format(Counter);

        if (Counter > 9) and (Counter < 100) then
            Name := CopyStr(CheckBookId.Trim(), 1, 6) + Format(Counter);

        if (Counter > 99) and (Counter < 1000) then
            Name := CopyStr(CheckBookId.Trim(), 1, 5) + Format(Counter);

        exit(PostingGroupCodeTxt + Name);
    end;
}