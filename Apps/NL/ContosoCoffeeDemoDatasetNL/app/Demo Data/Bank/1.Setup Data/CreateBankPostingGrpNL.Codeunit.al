codeunit 11518 "Create Bank Posting Grp NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ContosoBankNL.InsertBankAccountPostingGroup(ABN(), CreateNLGLAccounts.BusinessaccountOperatingDomestic(), CreateNLGLAccounts.PaymtsRecptsinProcess());
        ContosoBankNL.InsertBankAccountPostingGroup(ABNUSD(), CreateNLGLAccounts.PettyCash(), CreateNLGLAccounts.PaymtsRecptsinProcess());
        ContosoBankNL.InsertBankAccountPostingGroup(PostBank(), CreateNLGLAccounts.BusinessaccountOperatingForeign(), CreateNLGLAccounts.PaymtsRecptsinProcess());
        ContosoBankNL.InsertBankAccountPostingGroup(RaboLeen(), CreateNLGLAccounts.PettyCash(), '');
        ContosoBankNL.InsertBankAccountPostingGroup(RaboUSD(), CreateNLGLAccounts.PettyCash(), '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccountingpostingGrp(var Rec: Record "Bank Account Posting Group")
    var
        CreateBankAccPostingGroup: Codeunit "Create Bank Acc. Posting Grp";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case Rec.Code of
            CreateBankAccPostingGroup.Operating(),
            CreateBankAccPostingGroup.Cash():
                ValidateBankAccountingpostingGrp(Rec, CreateNLGLAccounts.PettyCash());
            CreateBankAccPostingGroup.Checking():
                ValidateBankAccountingpostingGrp(Rec, CreateNLGLAccounts.BusinessaccountOperatingDomestic());
            CreateBankAccPostingGroup.Savings():
                ValidateBankAccountingpostingGrp(Rec, CreateNLGLAccounts.BusinessaccountOperatingForeign());
        end;
    end;

    local procedure ValidateBankAccountingpostingGrp(var BankAccountPostingGrp: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGrp.Validate("G/L Account No.", GLAccountNo);
    end;

    procedure ABN(): Code[20]
    begin
        exit(ABNTok);
    end;

    procedure ABNUSD(): Code[20]
    begin
        exit(ABNUsdTok);
    end;

    procedure PostBank(): Code[20]
    begin
        exit(PostbankTok);
    end;

    procedure RaboLeen(): Code[20]
    begin
        exit(RaboLeenTok);
    end;

    procedure RaboUSD(): Code[20]
    begin
        exit(RaboUsdTok);
    end;


    var
        ABNTok: Label 'ABN', MaxLength = 20, Locked = true;
        ABNUsdTok: Label 'ABN-USD', MaxLength = 20, Locked = true;
        PostbankTok: Label 'POSTBANK', MaxLength = 20, Locked = true;
        RaboLeenTok: Label 'RABO-LEEN', MaxLength = 20, Locked = true;
        RaboUsdTok: Label 'RABO-USD', MaxLength = 20, Locked = true;
}