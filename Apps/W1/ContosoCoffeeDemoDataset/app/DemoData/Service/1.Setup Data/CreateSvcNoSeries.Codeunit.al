codeunit 5101 "Create Svc No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(ServiceItem(), SeriesServiceItemNosDescTok, 'SV000001', 'SV999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(ServiceOrder(), SeriesServiceOrderNosDescTok, 'SVO000001', 'SVO999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(ServiceInvoice(), SeriesServiceInvoiceNosDescTok, 'SVI000001', 'SVI999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(PostedServiceInvoice(), SeriesPostedServiceInvoiceNosDescTok, 'PSVI000001', 'PSVI999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(PostedServiceShipment(), SeriesPostedServiceShipmentNosDescTok, 'PSVS000001', 'PSVS999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(ServiceContract(), SeriesServiceContractNosDescTok, 'SVC000001', 'SVC999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(ContractInvoice(), SeriesContractInvoiceNosDescTok, 'SVCI000001', 'SVCI999999', '', '', 1, true, true);
        ContosoNoSeries.InsertNoSeries(ContractTemplate(), SeriesContractTemplateLbl, 'TEMPL0001', 'TEMPL9999', '', '', 1, true, true);
    end;

    var
        SeriesServiceItemNosDescTok: Label 'Service Items', MaxLength = 100;
        ServiceItemNosTok: Label 'SVC-ITEM', MaxLength = 20;
        SeriesServiceOrderNosDescTok: Label 'Service Orders', MaxLength = 100;
        ServiceOrderNosTok: Label 'SVC-ORDER', MaxLength = 20;
        SeriesServiceInvoiceNosDescTok: Label 'Service Invoices', MaxLength = 100;
        ServiceInvoiceNosTok: Label 'SVC-INV', MaxLength = 20;
        SeriesPostedServiceInvoiceNosDescTok: Label 'Posted Service Invoices', MaxLength = 100;
        PostedServiceInvoiceNosTok: Label 'SVC-INV+', MaxLength = 20;
        SeriesPostedServiceShipmentNosDescTok: Label 'Posted Service Shipments', MaxLength = 100;
        PostedServiceShipmentNosTok: Label 'SVC-SHIP+', MaxLength = 20;
        SeriesServiceContractNosDescTok: Label 'Service Contracts', MaxLength = 100;
        ServiceContractNosTok: Label 'SVC-CONTR', MaxLength = 20;
        SeriesContractInvoiceNosDescTok: Label 'Contract Invoices', MaxLength = 100;
        ContractInvoiceNosTok: Label 'SVC-CONTR-I', MaxLength = 20;
        ContractTemplateNosTok: Label 'SVC-CONTR-T', MaxLength = 20;
        SeriesContractTemplateLbl: Label 'Templates for Service Contracts', MaxLength = 100;

    procedure ServiceItem(): Code[20]
    begin
        exit(ServiceItemNosTok);
    end;

    procedure ServiceOrder(): Code[20]
    begin
        exit(ServiceOrderNosTok);
    end;

    procedure ServiceInvoice(): Code[20]
    begin
        exit(ServiceInvoiceNosTok);
    end;

    procedure PostedServiceInvoice(): Code[20]
    begin
        exit(PostedServiceInvoiceNosTok);
    end;

    procedure PostedServiceShipment(): Code[20]
    begin
        exit(PostedServiceShipmentNosTok);
    end;

    procedure ServiceContract(): Code[20]
    begin
        exit(ServiceContractNosTok);
    end;

    procedure ContractInvoice(): Code[20]
    begin
        exit(ContractInvoiceNosTok);
    end;

    procedure ContractTemplate(): Code[20]
    begin
        exit(ContractTemplateNosTok);
    end;
}