permissionset 7209 "D365 SNAPSHOT DEBUG"
{
    Access = Public;
    Assignable = true;
    Caption = 'Snapshot Debug';

    Permissions = system "Snapshot debugging" = X,
                  tabledata "Published Application" = R;
}
