#if not CLEAN17
codeunit 11728 "UPG Sales and Rec Setup CZ"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
    end;

    // the one field that was copied here was obsoleted in 16.0 and removed with 19.0
}
#endif
