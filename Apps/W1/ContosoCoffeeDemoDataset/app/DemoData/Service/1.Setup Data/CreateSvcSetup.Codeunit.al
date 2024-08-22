codeunit 5103 "Create Svc Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Service Mgt. Setup" = rim;

    var
        ContosoService: Codeunit "Contoso Service";
        SkillElectricalTok: Label 'ELECTR', MaxLength = 10;
        SkillElectricalLbl: Label 'Electrical', MaxLength = 100;
        SkillPlumbingTok: Label 'PLUMBING', MaxLength = 10;
        SkillPlumbingLbl: Label 'Plumbing', MaxLength = 100;
        ServiceOrderTypeMaintenanceTok: Label 'MAINTEN', MaxLength = 10;
        ServiceOrderTypeMaintenanceLbl: Label 'Maintenance', MaxLength = 100;
        ServiceOrderTypeRepairTok: Label 'REPAIR', MaxLength = 10;
        ServiceOrderTypeRepairLbl: Label 'Repair', MaxLength = 100;
        FaultReasonCodeDefectTok: Label 'DEFECT', MaxLength = 10;
        FaultReasonCodeDefectDescriptionLbl: Label 'Defect', MaxLength = 100;
        FaultReasonCodeUserFaultTok: Label 'USERFAULT', MaxLength = 10;
        FaultReasonCodeUserFaultDescriptionLbl: Label 'User Fault', MaxLength = 100;
        BaseCalendarTok: Label 'BASE', MaxLength = 10;
        ServiceContractAccountGroupBasicTok: Label 'BASIC', MaxLength = 10;
        ServiceContractAccountGroupBasicLbl: Label 'Basic', MaxLength = 100;
        ServiceItemGroupTok: Label 'SERVICE', MaxLength = 10;

    trigger OnRun()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoService.InsertBaseCalendar(DefaultBaseCalendar(), DefaultBaseCalendar());

        CreateServiceSetup();
        CreateInventoryPostingSetup();

        CreateSkillCodes();
        CreateServiceOrderTypes();
        CreateFaultReasonCodes(); //TODO: move to fault reason code ?

        ContosoService.InsertServiceItemGroup(DefaultServiceItemGroup(), DefaultServiceItemGroup(), true);

        ContosoService.InsertServiceContractAccountGroup(BasicServiceContractAccountGroup(), ServiceContractAccountGroupBasicLbl, SvcGLAccount.ServiceContractSale(), SvcGLAccount.ServiceContractSale());
    end;

    local procedure CreateServiceSetup()
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        SevNoSeries: Codeunit "Create Svc No Series";
    begin
        if not ServiceMgtSetup.Get() then begin
            ServiceMgtSetup.Init();
            ServiceMgtSetup.Insert(true);
        end;

        if ServiceMgtSetup."Service Item Nos." = '' then
            ServiceMgtSetup.Validate("Service Item Nos.", SevNoSeries.ServiceItem());
        if ServiceMgtSetup."Service Order Nos." = '' then
            ServiceMgtSetup.Validate("Service Order Nos.", SevNoSeries.ServiceOrder());
        if ServiceMgtSetup."Service Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Service Invoice Nos.", SevNoSeries.ServiceInvoice());
        if ServiceMgtSetup."Posted Service Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Posted Service Invoice Nos.", SevNoSeries.PostedServiceInvoice());
        if ServiceMgtSetup."Posted Service Shipment Nos." = '' then
            ServiceMgtSetup.Validate("Posted Service Shipment Nos.", SevNoSeries.PostedServiceShipment());
        if ServiceMgtSetup."Service Contract Nos." = '' then
            ServiceMgtSetup.Validate("Service Contract Nos.", SevNoSeries.ServiceContract());
        if ServiceMgtSetup."Contract Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Contract Invoice Nos.", SevNoSeries.ContractInvoice());
        if ServiceMgtSetup."Contract Template Nos." = '' then
            ServiceMgtSetup.Validate("Contract Template Nos.", SevNoSeries.ContractTemplate());
        if ServiceMgtSetup."Service Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Service Credit Memo Nos.", SevNoSeries.ServiceCreditMemo());
        if ServiceMgtSetup."Posted Serv. Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Posted Serv. Credit Memo Nos.", SevNoSeries.PostedServiceCreditMemo());

        ServiceMgtSetup.Validate("Base Calendar Code", DefaultBaseCalendar());

        ServiceMgtSetup.Validate("Contract Serv. Ord.  Max. Days", 366);
        Evaluate(ServiceMgtSetup."Default Warranty Duration", '<2Y>');
        ServiceMgtSetup.Modify(true);
    end;

    local procedure CreateInventoryPostingSetup()
    var
        SvcDemoDataSetup: Record "Service Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        SvcDemoDataSetup.Get();

        ContosoPostingSetup.InsertInventoryPostingSetup(SvcDemoDataSetup."Service Location", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
    end;

    local procedure CreateSkillCodes()
    begin
        // Create a Skill Code for both LARGE and SMALL Commercial Units
        ContosoService.InsertSkillCode(SkillElectrical(), SkillElectricalLbl);
        ContosoService.InsertSkillCode(SkillPlumbing(), SkillPlumbingLbl);
    end;

    local procedure CreateServiceOrderTypes()
    begin
        // Create Service Order Types for MAINT or BREAKFIX orders
        ContosoService.InsertServiceOrderType(ServiceOrderTypeMaintenance(), ServiceOrderTypeMaintenanceLbl);
        ContosoService.InsertServiceOrderType(ServiceOrderTypeRepairTok, ServiceOrderTypeRepairLbl);
    end;

    local procedure CreateFaultReasonCodes()
    begin
        // Create Fault Reason Codes for DEFECT and USERFAULT
        ContosoService.InsertFaultReasonCode(FaultReasonCodeDefectTok, FaultReasonCodeDefectDescriptionLbl);
        ContosoService.InsertFaultReasonCode(FaultReasonCodeUserFaultTok, FaultReasonCodeUserFaultDescriptionLbl);
    end;

    procedure DefaultBaseCalendar(): Code[10]
    begin
        exit(BaseCalendarTok);
    end;

    procedure SkillElectrical(): Code[10]
    begin
        exit(SkillElectricalTok);
    end;

    procedure SkillPlumbing(): Code[10]
    begin
        exit(SkillPlumbingTok);
    end;

    procedure ServiceOrderTypeMaintenance(): Code[10]
    begin
        exit(ServiceOrderTypeMaintenanceTok);
    end;

    procedure DefaultServiceItemGroup(): Code[10]
    begin
        exit(ServiceItemGroupTok);
    end;

    procedure BasicServiceContractAccountGroup(): Code[10]
    begin
        exit(ServiceContractAccountGroupBasicTok);
    end;
}