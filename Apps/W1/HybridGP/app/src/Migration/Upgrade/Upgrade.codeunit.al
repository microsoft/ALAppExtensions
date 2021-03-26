codeunit 4036 "GP Intelligent Cloud Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany();
    begin
        NavApp.DeleteArchiveData(4015);
        NavApp.DeleteArchiveData(4024);
        NavApp.DeleteArchiveData(4025);
        NavApp.DeleteArchiveData(4026);
        NavApp.DeleteArchiveData(4027);
        NavApp.DeleteArchiveData(4028);
        NavApp.DeleteArchiveData(4031);
        NavApp.DeleteArchiveData(4040);
        NavApp.DeleteArchiveData(4044);
        NavApp.DeleteArchiveData(4090);
        NavApp.DeleteArchiveData(4091);
        NavApp.DeleteArchiveData(4092);
        NavApp.DeleteArchiveData(4093);
        NavApp.DeleteArchiveData(4094);
        NavApp.DeleteArchiveData(4095);
        NavApp.DeleteArchiveData(4096);
        NavApp.DeleteArchiveData(4097);
    end;

    trigger OnUpgradePerDatabase();
    begin
    end;
}
