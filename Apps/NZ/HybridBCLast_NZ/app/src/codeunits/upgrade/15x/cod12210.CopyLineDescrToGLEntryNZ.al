codeunit 12210 "Copy Line Des. To G/L Entry NZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for APAC.
        // Matching file: .\App\Layers\APAC\BaseApp\Upgrade\CopyLineDescrToGLEntry.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        SetCopyLineDescrToGLEntries();
    end;

    local procedure SetCopyLineDescrToGLEntries()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        if SalesSetup.Get() and not SalesSetup."Copy Line Descr. to G/L Entry" then begin
            SalesSetup."Copy Line Descr. to G/L Entry" := true;
            SalesSetup.Modify();
        end;

        if ServiceMgtSetup.Get() and not ServiceMgtSetup."Copy Line Descr. to G/L Entry" then begin
            ServiceMgtSetup."Copy Line Descr. to G/L Entry" := true;
            ServiceMgtSetup.Modify();
        end;

        if PurchSetup.Get() and not PurchSetup."Copy Line Descr. to G/L Entry" then begin
            PurchSetup."Copy Line Descr. to G/L Entry" := true;
            PurchSetup.Modify();
        end;
    end;
}

