#if not CLEAN22
codeunit 40024 "Hybrid Upgrade Item Cross Ref"
{
    ObsoleteReason = 'Upgrade completed in earlier version.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    [Obsolete('Upgrade completed in earlier version.', '22.0')]
    procedure UpdateData();
    begin
    end;
}
#endif
