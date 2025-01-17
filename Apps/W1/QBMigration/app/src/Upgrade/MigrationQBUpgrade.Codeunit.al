codeunit 1831 "MigrationQB Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    begin
        NavApp.DeleteArchiveData(1911);
        NavApp.DeleteArchiveData(1912);
        NavApp.DeleteArchiveData(1913);
        NavApp.DeleteArchiveData(1914);
        NavApp.DeleteArchiveData(1915);
        NavApp.DeleteArchiveData(1916);
        NavApp.DeleteArchiveData(1917);
        NavApp.DeleteArchiveData(1918);
    end;

    trigger OnUpgradePerDatabase();
    begin
    end;
}