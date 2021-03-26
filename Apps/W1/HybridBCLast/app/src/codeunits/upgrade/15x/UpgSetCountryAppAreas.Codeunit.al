codeunit 4053 "Upg Mig Set Country App Areas"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
        // Matching file: .\App\Layers\W1\BaseApp\Upgrade\UpgSetCountryAppAreas.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        MoveGLBankAccountNoToGLAccountNo();
    end;

    local procedure MoveGLBankAccountNoToGLAccountNo()
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.SetFilter("G/L Bank Account No.", '<>%1', '');
        if BankAccountPostingGroup.FindSet(true) then
            repeat
                BankAccountPostingGroup."G/L Account No." := BankAccountPostingGroup."G/L Bank Account No.";
                BankAccountPostingGroup.Modify();
            until BankAccountPostingGroup.Next() = 0;
    end;
}

