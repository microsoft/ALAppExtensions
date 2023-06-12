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
        IsHandled: Boolean;
    begin
        if not ServiceMgtSetup.Get() then begin
            ServiceMgtSetup.Init();
            ServiceMgtSetup.Insert(true);
        end;
        OnBeforePopulateServiceSetupFields(ServiceMgtSetup, IsHandled);
        if IsHandled then
            exit;
        ServiceMgtSetup."Service Item Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Service Item Nos.", ServiceItemNos, SeriesServiceItemNosDescTok, SeriesServiceItemNosStartTok, SeriesServiceItemNosEndTok);
        ServiceMgtSetup."Service Order Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Service Order Nos.", ServiceOrderNos, SeriesServiceOrderNosDescTok, SeriesServiceOrderNosStartTok, SeriesServiceOrderNosEndTok);
        ServiceMgtSetup."Service Invoice Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Service Invoice Nos.", ServiceInvoiceNos, SeriesServiceInvoiceNosDescTok, SeriesServiceInvoiceNosStartTok, SeriesServiceInvoiceNosEndTok);
        ServiceMgtSetup."Posted Service Invoice Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Posted Service Invoice Nos.", PostedServiceInvoiceNos, SeriesPostedServiceInvoiceNosDescTok, SeriesPostedServiceInvoiceNosStartTok, SeriesPostedServiceInvoiceNosEndTok);
        ServiceMgtSetup."Posted Service Shipment Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Posted Service Shipment Nos.", PostedServiceShipmentNos, SeriesPostedServiceShipmentNosDescTok, SeriesPostedServiceShipmentNosStartTok, SeriesPostedServiceShipmentNosEndTok);
        ServiceMgtSetup."Loaner Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Loaner Nos.", LoanerNos, SeriesLoanerNosDescTok, SeriesLoanerNosStartTok, SeriesLoanerNosEndTok);
        ServiceMgtSetup."Service Contract Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Service Contract Nos.", ServiceContractNos, SeriesServiceContractNosDescTok, SeriesServiceContractNosStartTok, SeriesServiceContractNosEndTok);
        ServiceMgtSetup."Contract Invoice Nos." := CheckNoSeriesSetup(ServiceMgtSetup."Contract Invoice Nos.", ContractInvoiceNos, SeriesContractInvoiceNosDescTok, SeriesContractInvoiceNosStartTok, SeriesContractInvoiceNosEndTok);
        if BaseCalendar.FindFirst() then
            ServiceMgtSetup."Base Calendar Code" := BaseCalendar.Code
        else
            ServiceMgtSetup."Base Calendar Code" := CreateBaseCalendar();
        ServiceMgtSetup."Contract Serv. Ord.  Max. Days" := 366;
        ServiceMgtSetup.Modify(true);
    end;

    local procedure CheckNoSeriesSetup(CurrentSetupField: Code[20]; NumberSeriesCode: Code[20]; SeriesDescription: Text[100]; StartNo: Code[20]; EndNo: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if CurrentSetupField <> '' then
            exit(CurrentSetupField);

        OnBeforeConfirmNoSeriesExists(NumberSeriesCode);
        if not NoSeries.Get(NumberSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NumberSeriesCode;
            NoSeries.Description := SeriesDescription;
            NoSeries."Manual Nos." := true;
            NoSeries.Validate("Default Nos.", true);
            OnBeforeInsertNoSeries(NoSeries);
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NumberSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine.Insert(true);
            NoSeriesLine.Validate("Starting No.", StartNo);
            NoSeriesLine.Validate("Ending No.", EndNo);
            NoSeriesLine.Validate("Increment-by No.", 1);
            NoSeriesLine.Validate("Allow Gaps in Nos.", true);
            OnBeforeModifyNoSeriesLine(NoSeries, NoSeriesLine);
            NoSeriesLine.Modify(true);
        end;

        exit(NumberSeriesCode);
    end;

    local procedure CreateSkillCodes()
    var
        SkillCode: Record "Skill Code";
    begin
        // Create a Skill Code for both LARGE and SMALL Commercial Units
        if not SkillCode.Get(SkillCodeLargeTok) then begin
            SkillCode.Init();
            SkillCode.Code := SkillCodeLargeTok;
            SkillCode.Description := SkillCodeLargeDescTok;
            SkillCode.Insert(true);
        end;
        if not SkillCode.Get(SkillCodeSmallTok) then begin
            SkillCode.Init();
            SkillCode.Code := SkillCodeSmallTok;
            SkillCode.Description := SkillCodeSmallDescTok;
            SkillCode.Insert(true);
        end;
    end;

    local procedure CreateServiceZones()
    var
        ServiceZone: Record "Service Zone";
    begin
        // Create zones for both LOCAL and REMOTE work
        if not ServiceZone.Get(ServiceZoneLocalTok) then begin
            ServiceZone.Init();
            ServiceZone.Code := ServiceZoneLocalTok;
            ServiceZone.Description := AdjustSvcDemoData.TitleCase(ServiceZoneLocalTok);
            ServiceZone.Insert(true);
        end;
        if not ServiceZone.Get(ServiceZoneRemoteTok) then begin
            ServiceZone.Init();
            ServiceZone.Code := ServiceZoneRemoteTok;
            ServiceZone.Description := AdjustSvcDemoData.TitleCase(ServiceZoneRemoteTok);
            ServiceZone.Insert(true);
        end;
    end;

    local procedure CreateServiceOrderTypes()
    var
        ServiceOrderType: Record "Service Order Type";
    begin
        // Create Service Order Types for MAINT or BREAKFIX orders
        if not ServiceOrderType.Get(ServiceOrderTypeMaintTok) then begin
            ServiceOrderType.Init();
            ServiceOrderType.Code := ServiceOrderTypeMaintTok;
            ServiceOrderType.Description := AdjustSvcDemoData.TitleCase(ServiceOrderTypeMaintTok);
            ServiceOrderType.Insert(true);
        end;
        if not ServiceOrderType.Get(ServiceOrderTypeBreakFixTok) then begin
            ServiceOrderType.Init();
            ServiceOrderType.Code := ServiceOrderTypeBreakFixTok;
            ServiceOrderType.Description := AdjustSvcDemoData.TitleCase(ServiceOrderTypeBreakFixTok);
            ServiceOrderType.Insert(true);
        end;
    end;

    local procedure CreateFaultReasonCodes()
    var
        FaultReasonCode: Record "Fault Reason Code";
    begin
        // Create Fault Reason Codes for DEFECT and USERFAULT
        if not FaultReasonCode.Get(FaultReasonCodeDefectTok) then begin
            FaultReasonCode.Init();
            FaultReasonCode.Code := FaultReasonCodeDefectTok;
            FaultReasonCode.Description := AdjustSvcDemoData.TitleCase(FaultReasonCodeDefectTok);
            FaultReasonCode.Insert(true);
        end;
        if not FaultReasonCode.Get(FaultReasonCodeUserFaultTok) then begin
            FaultReasonCode.Init();
            FaultReasonCode.Code := FaultReasonCodeUserFaultTok;
            FaultReasonCode.Description := AdjustSvcDemoData.TitleCase(FaultReasonCodeUserFaultTok);
            FaultReasonCode.Insert(true);
        end;
    end;

    local procedure CreateServiceItemGroups()
    var
        ServiceItemGroup: Record "Service Item Group";
    begin
        // Create a COMMERCIAL service item group
        if not ServiceItemGroup.Get(ServiceItemGroupCommercialTok) then begin
            ServiceItemGroup.Init();
            ServiceItemGroup.Code := ServiceItemGroupCommercialTok;
            ServiceItemGroup.Description := AdjustSvcDemoData.TitleCase(ServiceItemGroupCommercialTok);
            ServiceItemGroup."Create Service Item" := true;
            ServiceItemGroup.Insert(true);
        end;
    end;

    local procedure CreateBaseCalendar(): Code[10]
    var
        BaseCalendar: Record "Base Calendar";
    begin
        // Create a Base Calendar for the Service Order
        if not BaseCalendar.Get(BaseCalendarTok) then begin
            BaseCalendar.Init();
            BaseCalendar.Code := BaseCalendarTok;
            BaseCalendar.Name := CopyStr(AdjustSvcDemoData.TitleCase(BaseCalendarTok), 1, MaxStrLen(BaseCalendar.Name));
            BaseCalendar.Insert(true);
        end;

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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmNoSeriesExists(var NumberSeriesCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNoSeries(var NoSeries: Record "No. Series")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyNoSeriesLine(var NoSeries: Record "No. Series"; var NoSeriesLine: Record "No. Series Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePopulateServiceSetupFields(var ServiceMgtSetup: Record "Service Mgt. Setup"; var IsHandled: Boolean)
    begin
    end;
}