codeunit 5103 "Create Svc Setup"
{
    Permissions = tabledata "Service Mgt. Setup" = rim,
        tabledata "No. Series" = rim,
        tabledata "No. Series Line" = rim,
        tabledata "Skill Code" = rim,
        tabledata "Service Zone" = rim,
        tabledata "Service Order Type" = rim,
        tabledata "Fault Reason Code" = rim,
        tabledata "Service Item Group" = rim,
        tabledata "Base Calendar" = rim,
        tabledata "G/L Account" = rim,
        tabledata "Service Contract Account Group" = rim;

    var
        SvcDemoAccount: Record "Svc Demo Account";
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";
        SvcDemoAccounts: Codeunit "Svc Demo Accounts";
        SeriesServiceItemNosDescTok: Label 'Service Items', MaxLength = 100;
        SeriesServiceItemNosStartTok: Label 'SV000001', MaxLength = 20;
        SeriesServiceItemNosEndTok: Label 'SV999999', MaxLength = 20;
        ServiceItemNosTok: Label 'SVC-ITEM', MaxLength = 20;
        SeriesServiceOrderNosDescTok: Label 'Service Orders', MaxLength = 100;
        SeriesServiceOrderNosStartTok: Label 'SVO000001', MaxLength = 20;
        SeriesServiceOrderNosEndTok: Label 'SVO999999', MaxLength = 20;
        ServiceOrderNosTok: Label 'SVC-ORDER', MaxLength = 20;
        SeriesServiceInvoiceNosDescTok: Label 'Service Invoices', MaxLength = 100;
        SeriesServiceInvoiceNosStartTok: Label 'SVI000001', MaxLength = 20;
        SeriesServiceInvoiceNosEndTok: Label 'SVI999999', MaxLength = 20;
        ServiceInvoiceNosTok: Label 'SVC-INV', MaxLength = 20;
        SeriesPostedServiceInvoiceNosDescTok: Label 'Posted Service Invoices', MaxLength = 100;
        SeriesPostedServiceInvoiceNosStartTok: Label 'PSVI000001', MaxLength = 20;
        SeriesPostedServiceInvoiceNosEndTok: Label 'PSVI999999', MaxLength = 20;
        PostedServiceInvoiceNosTok: Label 'SVC-INV+', MaxLength = 20;
        SeriesPostedServiceShipmentNosDescTok: Label 'Posted Service Shipments', MaxLength = 100;
        SeriesPostedServiceShipmentNosStartTok: Label 'PSVS000001', MaxLength = 20;
        SeriesPostedServiceShipmentNosEndTok: Label 'PSVS999999', MaxLength = 20;
        PostedServiceShipmentNosTok: Label 'SVC-SHIP+', MaxLength = 20;
        SeriesLoanerNosDescTok: Label 'Loaner', MaxLength = 100;
        SeriesLoanerNosStartTok: Label 'LOAN000001', MaxLength = 20;
        SeriesLoanerNosEndTok: Label 'LOAN999999', MaxLength = 20;
        LoanerNosTok: Label 'SVC-LOAN', MaxLength = 20;
        SeriesServiceContractNosDescTok: Label 'Service Contracts', MaxLength = 100;
        SeriesServiceContractNosStartTok: Label 'SVC000001', MaxLength = 20;
        SeriesServiceContractNosEndTok: Label 'SVC999999', MaxLength = 20;
        ServiceContractNosTok: Label 'SVC-CONTR', MaxLength = 20;
        SeriesContractInvoiceNosDescTok: Label 'Contract Invoices', MaxLength = 100;
        SeriesContractInvoiceNosStartTok: Label 'SVCI000001', MaxLength = 20;
        SeriesContractInvoiceNosEndTok: Label 'SVCI999999', MaxLength = 20;
        ContractInvoiceNosTok: Label 'SVC-CONTR-I', MaxLength = 20;
        SkillCodeLargeTok: Label 'LARGE', MaxLength = 10;
        SkillCodeLargeDescTok: Label 'Large Commecial Unit', MaxLength = 100;
        SkillCodeSmallTok: Label 'SMALL', MaxLength = 10;
        SkillCodeSmallDescTok: Label 'Small Commecial Unit', MaxLength = 100;
        ServiceZoneLocalTok: Label 'LOCAL', MaxLength = 10;
        ServiceZoneRemoteTok: Label 'REMOTE', MaxLength = 10;
        ServiceOrderTypeMaintTok: Label 'MAINT', MaxLength = 10;
        ServiceOrderTypeBreakfixTok: Label 'BREAKFIX', MaxLength = 10;
        FaultReasonCodeDefectTok: Label 'DEFECT', MaxLength = 10;
        FaultReasonCodeUserFaultTok: Label 'USERFAULT', MaxLength = 10;
        BaseCalendarTok: Label 'BASE';
        ServiceContractAccountGroupBasicTok: Label 'BASIC';
        ServiceItemGroupCommercialTok: Label 'COMMERCIAL', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateServiceSetup(
            ServiceItemNosTok,
            ServiceOrderNosTok,
            ServiceInvoiceNosTok,
            PostedServiceInvoiceNosTok,
            PostedServiceShipmentNosTok,
            LoanerNosTok,
            ServiceContractNosTok,
            ContractInvoiceNosTok);
        CreateServiceGLAccounts();
        CreateSkillCodes();
        CreateServiceZones();
        CreateServiceOrderTypes();
        CreateFaultReasonCodes();
        CreateServiceItemGroups();
        CreateServiceContractAccountGroups();
    end;

    local procedure CreateServiceSetup(
        ServiceItemNos: Code[20];
        ServiceOrderNos: Code[20];
        ServiceInvoiceNos: Code[20];
        PostedServiceInvoiceNos: Code[20];
        PostedServiceShipmentNos: Code[20];
        LoanerNos: Code[20];
        ServiceContractNos: Code[20];
        ContractInvoiceNos: Code[20])
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        BaseCalendar: Record "Base Calendar";
    begin
        if not ServiceMgtSetup.Get() then begin
            ServiceMgtSetup.Init();
            ServiceMgtSetup.Insert(true);
        end;
        ServiceMgtSetup."Service Item Nos." := SetupNoSeries(ServiceMgtSetup."Service Item Nos.", ServiceItemNos, SeriesServiceItemNosDescTok, SeriesServiceItemNosStartTok, SeriesServiceItemNosEndTok);
        ServiceMgtSetup."Service Order Nos." := SetupNoSeries(ServiceMgtSetup."Service Order Nos.", ServiceOrderNos, SeriesServiceOrderNosDescTok, SeriesServiceOrderNosStartTok, SeriesServiceOrderNosEndTok);
        ServiceMgtSetup."Service Invoice Nos." := SetupNoSeries(ServiceMgtSetup."Service Invoice Nos.", ServiceInvoiceNos, SeriesServiceInvoiceNosDescTok, SeriesServiceInvoiceNosStartTok, SeriesServiceInvoiceNosEndTok);
        ServiceMgtSetup."Posted Service Invoice Nos." := SetupNoSeries(ServiceMgtSetup."Posted Service Invoice Nos.", PostedServiceInvoiceNos, SeriesPostedServiceInvoiceNosDescTok, SeriesPostedServiceInvoiceNosStartTok, SeriesPostedServiceInvoiceNosEndTok);
        ServiceMgtSetup."Posted Service Shipment Nos." := SetupNoSeries(ServiceMgtSetup."Posted Service Shipment Nos.", PostedServiceShipmentNos, SeriesPostedServiceShipmentNosDescTok, SeriesPostedServiceShipmentNosStartTok, SeriesPostedServiceShipmentNosEndTok);
        ServiceMgtSetup."Loaner Nos." := SetupNoSeries(ServiceMgtSetup."Loaner Nos.", LoanerNos, SeriesLoanerNosDescTok, SeriesLoanerNosStartTok, SeriesLoanerNosEndTok);
        ServiceMgtSetup."Service Contract Nos." := SetupNoSeries(ServiceMgtSetup."Service Contract Nos.", ServiceContractNos, SeriesServiceContractNosDescTok, SeriesServiceContractNosStartTok, SeriesServiceContractNosEndTok);
        ServiceMgtSetup."Contract Invoice Nos." := SetupNoSeries(ServiceMgtSetup."Contract Invoice Nos.", ContractInvoiceNos, SeriesContractInvoiceNosDescTok, SeriesContractInvoiceNosStartTok, SeriesContractInvoiceNosEndTok);
        if BaseCalendar.FindFirst() then
            ServiceMgtSetup."Base Calendar Code" := BaseCalendar.Code
        else
            ServiceMgtSetup."Base Calendar Code" := CreateBaseCalendar();
        ServiceMgtSetup."Contract Serv. Ord.  Max. Days" := 366;
        ServiceMgtSetup.Modify(true);
    end;

    local procedure SetupNoSeries(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text[100]; StartNo: Code[20]; EndNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if CurrentSetupField <> '' then
            exit(CurrentSetupField);

        if NoSeries.Get(NumberSeriesCode) then
            exit(NumberSeriesCode);

        NoSeries.Init();
        NoSeries.Code := NumberSeriesCode;
        NoSeries.Description := SeriesDescription;
        NoSeries."Manual Nos." := true;
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NumberSeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);
        NoSeriesLine.Validate("Starting No.", StartNo);
        NoSeriesLine.Validate("Ending No.", EndNo);
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify(true);

        exit(NumberSeriesCode);
    end;

    local procedure CreateSkillCodes()
    begin
        // Create a Skill Code for both LARGE and SMALL Commercial Units
        CreateSkillCode(SkillCodeLargeTok, SkillCodeLargeDescTok);
        CreateSkillCode(SkillCodeSmallTok, SkillCodeSmallDescTok);
    end;

    local procedure CreateSkillCode(NewSkillCode: Code[10]; NewSkillDescription: Text[100])
    var
        SkillCode: Record "Skill Code";
    begin
        if SkillCode.Get(SkillCodeLargeTok) then
            exit;
        SkillCode.Init();
        SkillCode.Code := NewSkillCode;
        SkillCode.Description := NewSkillDescription;
        SkillCode.Insert(true);
    end;

    local procedure CreateServiceZones()
    var
        ServiceZone: Record "Service Zone";
    begin
        // Create zones for both LOCAL and REMOTE work
        CreateServiceZone(ServiceZoneLocalTok, AdjustSvcDemoData.TitleCase(ServiceZoneLocalTok));
        CreateServiceZone(ServiceZoneRemoteTok, AdjustSvcDemoData.TitleCase(ServiceZoneRemoteTok));
    end;

    local procedure CreateServiceZone(NewZoneCode: Code[10]; NewZoneDescription: Text[100])
    var
        ServiceZone: Record "Service Zone";
    begin
        if ServiceZone.Get(NewZoneCode) then
            exit;
        ServiceZone.Init();
        ServiceZone.Code := NewZoneCode;
        ServiceZone.Description := NewZoneDescription;
        ServiceZone.Insert(true);
    end;

    local procedure CreateServiceOrderTypes()
    begin
        // Create Service Order Types for MAINT or BREAKFIX orders
        CreateServiceOrderType(ServiceOrderTypeMaintTok, AdjustSvcDemoData.TitleCase(ServiceOrderTypeMaintTok));
        CreateServiceOrderType(ServiceOrderTypeBreakFixTok, AdjustSvcDemoData.TitleCase(ServiceOrderTypeBreakFixTok));
    end;

    local procedure CreateServiceOrderType(NewOrderTypeCode: Code[10]; NewOrderTypeDescription: Text[100])
    var
        ServiceOrderType: Record "Service Order Type";
    begin
        if ServiceOrderType.Get(NewOrderTypeCode) then
            exit;
        ServiceOrderType.Init();
        ServiceOrderType.Code := NewOrderTypeCode;
        ServiceOrderType.Description := NewOrderTypeDescription;
        ServiceOrderType.Insert(true);
    end;

    local procedure CreateFaultReasonCodes()
    var
        FaultReasonCode: Record "Fault Reason Code";
    begin
        // Create Fault Reason Codes for DEFECT and USERFAULT
        CreateFaultReasonCode(FaultReasonCodeDefectTok, AdjustSvcDemoData.TitleCase(FaultReasonCodeDefectTok));
        CreateFaultReasonCode(FaultReasonCodeUserFaultTok, AdjustSvcDemoData.TitleCase(FaultReasonCodeUserFaultTok));
    end;

    local procedure CreateFaultReasonCode(NewFaultReasonCode: Code[10]; NewFaultReasonDescription: Text[100])
    var
        FaultReasonCode: Record "Fault Reason Code";
    begin
        if FaultReasonCode.Get(NewFaultReasonCode) then
            exit;
        FaultReasonCode.Init();
        FaultReasonCode.Code := NewFaultReasonCode;
        FaultReasonCode.Description := NewFaultReasonDescription;
        FaultReasonCode.Insert(true);
    end;

    local procedure CreateServiceItemGroups()
    var
        ServiceItemGroup: Record "Service Item Group";
    begin
        // Create a COMMERCIAL service item group
        if ServiceItemGroup.Get(ServiceItemGroupCommercialTok) then
            exit;
        ServiceItemGroup.Init();
        ServiceItemGroup.Code := ServiceItemGroupCommercialTok;
        ServiceItemGroup.Description := AdjustSvcDemoData.TitleCase(ServiceItemGroupCommercialTok);
        ServiceItemGroup."Create Service Item" := true;
        ServiceItemGroup.Insert(true);
    end;

    local procedure CreateBaseCalendar(): Code[10]
    var
        BaseCalendar: Record "Base Calendar";
    begin
        // Create a Base Calendar for the Service Order
        if BaseCalendar.Get(BaseCalendarTok) then
            exit(BaseCalendarTok);
        BaseCalendar.Init();
        BaseCalendar.Code := BaseCalendarTok;
        BaseCalendar.Name := CopyStr(AdjustSvcDemoData.TitleCase(BaseCalendarTok), 1, MaxStrLen(BaseCalendar.Name));
        BaseCalendar.Insert(true);

        exit(BaseCalendarTok);
    end;

    local procedure CreateServiceGLAccounts()
    var
        GLAccount: Record "G/L Account";
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        SvcDemoAccount.ReturnAccountKey(true);

        InsertGLAccount(SvcDemoAccount.Contract(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement");

        // For the Service scenarios, we need to be able to charge Sales directly to the Contract G/L account
        SvcDemoAccount.ReturnAccountKey(false);
        GLAccount.Get(SvcDemoAccount.Contract());
        GLAccount."Gen. Bus. Posting Group" := SvcDemoDataSetup."Cust. Gen. Bus. Posting Group";
        GLAccount."Gen. Prod. Posting Group" := SvcDemoDataSetup."Svc. Gen. Prod. Posting Group";
        GLAccount.Modify(true);

        SvcDemoAccount.ReturnAccountKey(false);
        GLAccountIndent.Indent();
    end;

    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance")
    var
        GLAccount: Record "G/L Account";
    begin
        SvcDemoAccount := SvcDemoAccounts.GetDemoAccount("No.");

        if GLAccount.Get(SvcDemoAccount."Account Value") then
            exit;

        GLAccount.Init();
        GLAccount.Validate("No.", SvcDemoAccount."Account Value");
        GLAccount.Validate(Name, SvcDemoAccount."Account Description");
        GLAccount.Validate("Account Type", AccountType);
        GLAccount.Validate("Income/Balance", "Income/Balance");
        GLAccount.Insert(true);
    end;

    local procedure CreateServiceContractAccountGroups()
    var
        ServiceContractAccountGroup: Record "Service Contract Account Group";
    begin
        SvcDemoAccount.ReturnAccountKey(false);
        if not ServiceContractAccountGroup.Get(ServiceContractAccountGroupBasicTok) then begin
            ServiceContractAccountGroup.Init();
            ServiceContractAccountGroup.Code := ServiceContractAccountGroupBasicTok;
            ServiceContractAccountGroup.Description := AdjustSvcDemoData.TitleCase(ServiceContractAccountGroupBasicTok);
            ServiceContractAccountGroup."Non-Prepaid Contract Acc." := SvcDemoAccount.Contract();
            ServiceContractAccountGroup."Prepaid Contract Acc." := SvcDemoAccount.Contract();
            ServiceContractAccountGroup.Insert(true);
        end;
    end;



    procedure GetSkillCodeLargeTok(): Code[10]
    begin
        exit(SkillCodeLargeTok);
    end;

    procedure GetSkillCodeSmallTok(): Code[10]
    begin
        exit(SkillCodeSmallTok);
    end;

    procedure GetServiceZoneLocalTok(): Code[10]
    begin
        exit(ServiceZoneLocalTok);
    end;

    procedure GetServiceZoneRemoteTok(): Code[10]
    begin
        exit(ServiceZoneRemoteTok);
    end;

    procedure GetServiceOrderTypeMaintTok(): Code[10]
    begin
        exit(ServiceOrderTypeMaintTok);
    end;

    procedure GetServiceOrderTypeBreakFixTok(): Code[10]
    begin
        exit(ServiceOrderTypeBreakFixTok);
    end;

    procedure GetFaultReasonCodeDefectTok(): Code[10]
    begin
        exit(FaultReasonCodeDefectTok);
    end;

    procedure GetFaultReasonCodeUserFaultTok(): Code[10]
    begin
        exit(FaultReasonCodeUserFaultTok);
    end;

    procedure GetServiceItemGroupCommercialTok(): Code[10]
    begin
        exit(ServiceItemGroupCommercialTok);
    end;
}