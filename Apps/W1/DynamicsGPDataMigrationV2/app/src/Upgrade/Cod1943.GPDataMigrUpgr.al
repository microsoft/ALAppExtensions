codeunit 1943 "MigrationGP Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    begin
        NavApp.DeleteArchiveData(1931);
        NavApp.DeleteArchiveData(1939);
        NavApp.DeleteArchiveData(1943);
        NavApp.DeleteArchiveData(1932);
        NavApp.DeleteArchiveData(1933);
        NavApp.DeleteArchiveData(1936);
        NavApp.DeleteArchiveData(1937);
        NavApp.DeleteArchiveData(1938);
        NavApp.DeleteArchiveData(1940);
        NavApp.DeleteArchiveData(1941);
        NavApp.DeleteArchiveData(1934);
        NavApp.DeleteArchiveData(1935);
        NavApp.DeleteArchiveData(1820);
    end;

    trigger OnUpgradePerDatabase();
    begin
    end;
}
