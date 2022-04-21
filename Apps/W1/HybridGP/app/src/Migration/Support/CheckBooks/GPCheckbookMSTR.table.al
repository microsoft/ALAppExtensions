table 40099 "GP Checkbook MSTR"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; DSCRIPTN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; BANKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(4; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; BNKACTNM; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(7; NXTCHNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(8; Next_Deposit_Number; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(9; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; DYDEPCLR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(11; XCDMCHPW; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(12; MXCHDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; DUPCHNUM; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; OVCHNUM1; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; LOCATNID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(16; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; CMUSRDF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(18; CMUSRDF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(19; Last_Reconciled_Date; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; Last_Reconciled_Balance; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; CURRBLNC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; CREATDDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(23; MODIFDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(24; Recond; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(25; Reconcile_In_Progress; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(26; Deposit_In_Progress; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(27; CHBKPSWD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(28; CURNCYPD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(29; CRNCYRCD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; ADPVADLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; ADPVAPWD; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(32; DYCHTCLR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; CMPANYID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; CHKBKTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; DDACTNUM; Text[17])
        {
            DataClassification = CustomerContent;
        }
        field(36; DDINDNAM; Text[23])
        {
            DataClassification = CustomerContent;
        }
        field(37; DDTRANS; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(38; PaymentRateTypeID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(39; DepositRateTypeID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(40; CashInTransAcctIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; CHEKBKID)
        {
            Clustered = true;
        }
    }

    procedure MoveStagingData()
    var
        BankAccount: Record "Bank Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        MigrateInactiveCheckbooks: Boolean;
    begin
        MigrateInactiveCheckbooks := false;
        if GPCompanyAdditionalSettings.Get(CompanyName()) then
            MigrateInactiveCheckbooks := GPCompanyAdditionalSettings."Migrate Inactive Checkbooks";

        if FindSet() then
            repeat
                if not BankAccount.Get(CHEKBKID) then
                    if MigrateInactiveCheckbooks or not INACTIVE then begin
                        BankAccount.Init();
                        BankAccount."No." := DelChr(CHEKBKID, '>', ' ');
                        BankAccount.Name := DelChr(DSCRIPTN, '>', ' ');
                        BankAccount."Bank Account No." := DelChr(BNKACTNM, '>', ' ');
                        BankAccount."Last Check No." := GetLastCheckNumber(NXTCHNUM);
                        BankAccount."Balance Last Statement" := Last_Reconciled_Balance;
                        BankAccount."Bank Acc. Posting Group" := GetBankAccPostingGroup(ACTINDX);
                        UpdateBankInfo(DelChr(BANKID, '>', ' '), BankAccount);
                        BankAccount.Insert(true);
                    end;
            until Next() = 0;
    end;

    local procedure UpdateBankInfo(BankId: Text[15]; var BankAccount: Record "Bank Account")
    var
        CMBankMSTR: Record "GP Bank MSTR";
    begin
        if CMBankMSTR.Get(BankId) then begin
            BankAccount.Address := DelChr(CMBankMSTR.ADDRESS1, '>', ' ');
            BankAccount."Address 2" := CopyStr(DelChr(CMBankMSTR.ADDRESS2, '>', ' '), 1, 50);
            BankAccount.City := CopyStr(DelChr(CMBankMSTR.CITY, '>', ' '), 1, 30);
            BankAccount."Phone No." := DelChr(CMBankMSTR.PHNUMBR1, '>', ' ');
            BankAccount."Transit No." := DelChr(CMBankMSTR.TRNSTNBR, '>', ' ');
            BankAccount."Fax No." := DelChr(CMBankMSTR.FAXNUMBR, '>', ' ');
            BankAccount.County := DelChr(CMBankMSTR.STATE, '>', ' ');
            BankAccount."Post Code" := DelChr(CMBankMSTR.ZIPCODE, '>', ' ');
            BankAccount."Bank Branch No." := CopyStr(DelChr(CMBankMSTR.BNKBRNCH, '>', ' '), 1, 20);
        end;
    end;

    local procedure GetBankAccPostingGroup(AcctIndex: Integer): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GPAccount: Record "GP Account";
    begin
        if GPAccount.Get(AcctIndex) then begin
            // If a posting group already exists for this GL account use it.
            BankAccountPostingGroup.SetRange("G/L Account No.", CopyStr(GPAccount.AcctNum, 1, 20));
            if BankAccountPostingGroup.FindFirst() then
                exit(BankAccountPostingGroup.Code);

            BankAccountPostingGroup.Reset();
            BankAccountPostingGroup.Init();
            BankAccountPostingGroup.Code := 'GP' + Format(GetNextPostingGroupNumber());
            BankAccountPostingGroup."G/L Account No." := CopyStr(GPAccount.AcctNum, 1, 20);
            BankAccountPostingGroup.Insert(true);
            exit(BankAccountPostingGroup.Code);
        end;
    end;

    local procedure GetNextPostingGroupNumber(): Integer
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.SetFilter(Code, 'GP' + '*');
        if BankAccountPostingGroup.IsEmpty then
            exit(1);

        exit(BankAccountPostingGroup.Count + 1);
    end;

    local procedure GetLastCheckNumber(NextCheckNumber: Text[21]): Code[20]
    var
        NextCheck: Integer;
        LastCheckNumber: Integer;
    begin
        if not Evaluate(NextCheck, CopyStr(DelChr(NextCheckNumber, '>', ' '), 1, 20)) then
            exit('');

        if NextCheck <= 0 then
            exit(Format(0));

        LastCheckNumber := NextCheck - 1;
        exit(Format(LastCheckNumber));
    end;
}