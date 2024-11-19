codeunit 12208 "Create ABI CAB Code IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoABICABIT: Codeunit "Contoso ABI CAB IT";
    begin
        ContosoABICABIT.InsertABICABCode('05428', '11101');
        ContosoABICABIT.InsertABICABCode('12345', '22224');
        ContosoABICABIT.InsertABICABCode('12350', '45680');
        ContosoABICABIT.InsertABICABCode('25100', '32100');
        ContosoABICABIT.InsertABICABCode('33350', '44450');
        ContosoABICABIT.InsertABICABCode('33577', '05423');
        ContosoABICABIT.InsertABICABCode('36558', '22508');
        ContosoABICABIT.InsertABICABCode('45100', '22550');
        ContosoABICABIT.InsertABICABCode('52001', '56300');
        ContosoABICABIT.InsertABICABCode('52714', '10180');
        ContosoABICABIT.InsertABICABCode('56000', '85456');
        ContosoABICABIT.InsertABICABCode('56200', '45007');
        ContosoABICABIT.InsertABICABCode('56220', '11101');
        ContosoABICABIT.InsertABICABCode('56220', '22224');
        ContosoABICABIT.InsertABICABCode('56220', '24452');
        ContosoABICABIT.InsertABICABCode('58600', '12004');
        ContosoABICABIT.InsertABICABCode('85400', '45600');
    end;
}