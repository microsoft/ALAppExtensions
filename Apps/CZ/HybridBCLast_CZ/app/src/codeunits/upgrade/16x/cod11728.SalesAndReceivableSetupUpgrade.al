codeunit 11728 "UPG Sales and Rec Setup CZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        SetCopyLineDescrToGLEntry();
    end;

    local procedure SetCopyLineDescrToGLEntry()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // This code is based on app upgrade logic for CZ.
        // Matching file: .\App\Layers\CZ\BaseApp\Upgrade\UpgradeLocalApp.Codeunit.al
        // Based on commit: 2c1c901e
        if SalesSetup.Get() then begin
            SalesSetup."Copy Line Descr. to G/L Entry" := SalesSetup."G/L Entry as Doc. Lines (Acc.)";
            SalesSetup.Modify();
        end;
    end;
}

