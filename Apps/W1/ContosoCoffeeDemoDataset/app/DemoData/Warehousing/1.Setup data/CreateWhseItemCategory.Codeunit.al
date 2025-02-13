codeunit 5145 "Create Whse Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(Beans(), BeansLbl, '');
    end;

    var
        BeansTok: Label 'BEANS', MaxLength = 10;
        BeansLbl: Label 'Beans', MaxLength = 100;

    procedure Beans(): Code[20]
    begin
        exit(BeansTok);
    end;
}