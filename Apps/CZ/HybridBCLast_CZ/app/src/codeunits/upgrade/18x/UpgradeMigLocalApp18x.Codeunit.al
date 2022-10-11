#if not CLEAN19
codeunit 11801 "Upgrade Mig Local App 18x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';

    trigger OnRun()
    begin
    end;
}

#endif