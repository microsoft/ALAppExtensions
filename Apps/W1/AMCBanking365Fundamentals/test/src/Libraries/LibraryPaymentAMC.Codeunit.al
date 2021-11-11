codeunit 130102 "Library - Payment AMC"
{

    trigger OnRun()
    begin
    end;

    var
        LocalhostURLTxt: Label 'https://localhost:8080/', Locked = true;

    [Scope('OnPrem')]
    procedure EnableTestServiceSetup(var TempAMCBankingSetup: Record "AMC Banking Setup" temporary) OldPassword: Text
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        OldPassword := AMCBankingSetup.GetPassword();

        TempAMCBankingSetup.Init();
        TempAMCBankingSetup."User Name" := AMCBankingSetup."User Name";
        TempAMCBankingSetup."Service URL" := AMCBankingSetup."Service URL";

        AMCBankingSetup."User Name" := 'demouser';
        AMCBankingSetup.SavePassword('Demo Password');
        AMCBankingSetup."Service URL" := LocalhostURLTxt;
        AMCBankingSetup.Modify();
    end;

    [Scope('OnPrem')]
    procedure RestoreServiceSetup(TempAMCBankingSetup: Record "AMC Banking Setup" temporary; PasswordText: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        AMCBankingSetup."User Name" := TempAMCBankingSetup."User Name";
        AMCBankingSetup.SavePassword(PasswordText);
        AMCBankingSetup."Service URL" := TempAMCBankingSetup."Service URL";
        AMCBankingSetup.Modify();
    end;

}

