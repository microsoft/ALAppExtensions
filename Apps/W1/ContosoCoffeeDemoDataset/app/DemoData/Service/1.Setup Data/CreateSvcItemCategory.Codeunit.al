codeunit 5106 "Create Svc Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(Service(), ServicesDescTok, '');

        ContosoItem.InsertItemCategory(EM(), EspressoMachinesTok, '');

        ContosoItem.InsertItemCategory(EMCommercial(), CommercialModelsTok, EM());
    end;

    var
        ServicesTok: Label 'SERVICES', MaxLength = 20;
        ServicesDescTok: Label 'Services', MaxLength = 100;
        EMTok: Label 'EM', MaxLength = 20;
        EspressoMachinesTok: Label 'Espresso Machines', MaxLength = 100;
        EMCommerTok: Label 'EM_Commer', MaxLength = 20;
        CommercialModelsTok: Label 'Commercial Models', MaxLength = 100;

    procedure Service(): Code[20]
    begin
        exit(ServicesTok);
    end;

    procedure EM(): Code[20]
    begin
        exit(EMTok);
    end;

    procedure EMCommercial(): Code[20]
    begin
        exit(EMCommerTok);
    end;
}