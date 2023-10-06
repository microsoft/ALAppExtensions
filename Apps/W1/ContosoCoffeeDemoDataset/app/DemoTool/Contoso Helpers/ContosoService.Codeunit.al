codeunit 5125 "Contoso Service"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Skill Code" = rim,
        tabledata "Service Order Type" = rim,
        tabledata "Fault Reason Code" = rim,
        tabledata "Service Item Group" = rim,
        tabledata "Base Calendar" = rim,
        tabledata "Service Contract Account Group" = rim,
        tabledata "Loaner" = rim,
        tabledata "Standard Service Code" = rim,
        tabledata "Standard Service Line" = rim,
        tabledata "Standard Service Item Gr. Code" = rim,
        tabledata "Service Contract Template" = rim,
        tabledata "Symptom Code" = rim,
        tabledata "Resolution Code" = rim,
        tabledata "Fault Code" = rim,
        tabledata "Troubleshooting Header" = rim,
        tabledata "Troubleshooting Line" = rim,
        tabledata "Troubleshooting Setup" = rim,
        tabledata "Service Status Priority Setup" = rim,
        tabledata "Repair Status" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertSkillCode(NewSkillCode: Code[10]; Description: Text[100])
    var
        SkillCode: Record "Skill Code";
        Exists: Boolean;
    begin
        if SkillCode.Get(NewSkillCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SkillCode.Validate(Code, NewSkillCode);
        SkillCode.Validate(Description, Description);

        if Exists then
            SkillCode.Modify(true)
        else
            SkillCode.Insert(true);
    end;


    procedure InsertServiceOrderType(OrderTypeCode: Code[10]; Description: Text[100])
    var
        ServiceOrderType: Record "Service Order Type";
        Exists: Boolean;
    begin
        if ServiceOrderType.Get(OrderTypeCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceOrderType.Validate(Code, OrderTypeCode);
        ServiceOrderType.Validate(Description, Description);

        if Exists then
            ServiceOrderType.Modify(true)
        else
            ServiceOrderType.Insert(true);
    end;

    procedure InsertFaultReasonCode(NewFaultReasonCode: Code[10]; Description: Text[100])
    var
        FaultReasonCode: Record "Fault Reason Code";
        Exists: Boolean;
    begin
        if FaultReasonCode.Get(NewFaultReasonCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FaultReasonCode.Validate(Code, NewFaultReasonCode);
        FaultReasonCode.Validate(Description, Description);

        if Exists then
            FaultReasonCode.Modify(true)
        else
            FaultReasonCode.Insert(true);
    end;

    procedure InsertServiceItemGroup(GroupCode: Code[10]; Description: Text[100]; CreateServiceItem: Boolean)
    var
        ServiceItemGroup: Record "Service Item Group";
        Exists: Boolean;
    begin
        if ServiceItemGroup.Get(GroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceItemGroup.Validate(Code, GroupCode);
        ServiceItemGroup.Validate(Description, Description);
        ServiceItemGroup.Validate("Create Service Item", CreateServiceItem);

        if Exists then
            ServiceItemGroup.Modify(true)
        else
            ServiceItemGroup.Insert(true);
    end;

    procedure InsertBaseCalendar(CalendarCode: Code[10]; Name: Text[30])
    var
        BaseCalendar: Record "Base Calendar";
        Exists: Boolean;
    begin
        if BaseCalendar.Get(CalendarCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BaseCalendar.Validate(Code, CalendarCode);
        BaseCalendar.Validate(Name, Name);

        if Exists then
            BaseCalendar.Modify(true)
        else
            BaseCalendar.Insert(true);
    end;

    procedure InsertServiceContractAccountGroup(GroupCode: Code[10]; Description: Text[100]; NonPrepaidAccount: Code[20]; PrepaidAccount: Code[20])
    var
        ServiceContractAccountGroup: Record "Service Contract Account Group";
        Exists: Boolean;
    begin
        if ServiceContractAccountGroup.Get(GroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceContractAccountGroup.Validate(Code, GroupCode);
        ServiceContractAccountGroup.Validate(Description, Description);
        ServiceContractAccountGroup.Validate("Non-Prepaid Contract Acc.", NonPrepaidAccount);
        ServiceContractAccountGroup.Validate("Prepaid Contract Acc.", PrepaidAccount);

        if Exists then
            ServiceContractAccountGroup.Modify(true)
        else
            ServiceContractAccountGroup.Insert(true);
    end;

    procedure InsertLoaner(LoanerNo: Code[20]; ItemNo: Code[20])
    var
        Loaner: Record "Loaner";
        Exists: Boolean;
    begin
        if Loaner.Get(LoanerNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Loaner.Validate("No.", LoanerNo);
        Loaner.Validate("Description", LoanerNo);
        Loaner.Validate("Item No.", ItemNo);

        if Exists then
            Loaner.Modify(true)
        else
            Loaner.Insert(true);
    end;

    procedure InsertStandardServiceCode(ServiceCode: Code[10]; Description: Text[100])
    var
        StandardServiceCode: Record "Standard Service Code";
        Exists: Boolean;
    begin
        if StandardServiceCode.Get(ServiceCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        StandardServiceCode.Validate(Code, ServiceCode);
        StandardServiceCode.Validate(Description, Description);

        if Exists then
            StandardServiceCode.Modify(true)
        else
            StandardServiceCode.Insert(true);
    end;

    procedure InsertStandardServiceLine(ServiceCode: Code[10]; ServiceLineType: Enum "Service Line Type"; Number: Code[20]; Quantity: Decimal)
    var
        StandardServiceLine: Record "Standard Service Line";
    begin
        StandardServiceLine.Validate("Standard Service Code", ServiceCode);
        StandardServiceLine.Validate(Type, ServiceLineType);
        StandardServiceLine.Validate("No.", Number);
        StandardServiceLine.Validate("Line No.", GetNextStandardServiceLineNo(ServiceCode));
        StandardServiceLine.Validate(Quantity, Quantity);
        StandardServiceLine.Insert(true);
    end;

    local procedure GetNextStandardServiceLineNo(ServiceCode: Code[10]): Integer
    var
        StandardServiceLine: Record "Standard Service Line";
    begin
        StandardServiceLine.SetRange("Standard Service Code", ServiceCode);
        StandardServiceLine.SetCurrentKey("Line No.");

        if StandardServiceLine.FindLast() then
            exit(StandardServiceLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertStandardServiceItemGroup(ServiceItemGroupCode: Code[10]; StandardServiceCode: Code[10])
    var
        StandardServiceItemGroupCode: Record "Standard Service Item Gr. Code";
        Exists: Boolean;
    begin
        if StandardServiceItemGroupCode.Get(ServiceItemGroupCode, StandardServiceCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        StandardServiceItemGroupCode.Validate("Service Item Group Code", ServiceItemGroupCode);
        StandardServiceItemGroupCode.Validate(Code, StandardServiceCode);

        if Exists then
            StandardServiceItemGroupCode.Modify(true)
        else
            StandardServiceItemGroupCode.Insert(true);
    end;

    procedure InsertServiceContractTemplates(Description: Text[100]; Prepaid: Boolean; InvoicePeriod: Option; ServicePeriod: Code[10]; ServiceContractAccountGroupCode: Code[10])
    var
        ServiceContractTemplate: Record "Service Contract Template";
    begin
        ServiceContractTemplate.Validate(Description, Description);

        if Prepaid then
            ServiceContractTemplate.Validate(Prepaid, true)
        else
            ServiceContractTemplate.Validate("Invoice after Service", true);

        ServiceContractTemplate.Validate("Invoice Period", InvoicePeriod);
        Evaluate(ServiceContractTemplate."Default Service Period", ServicePeriod);
        ServiceContractTemplate.Validate("Serv. Contract Acc. Gr. Code", ServiceContractAccountGroupCode);

        ServiceContractTemplate.Insert(true);
    end;

    procedure InsertSymptom(SymptomCode: Code[10]; Description: Text[100])
    var
        Symptom: Record "Symptom Code";
        Exists: Boolean;
    begin
        if Symptom.Get(SymptomCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Symptom.Validate(Code, SymptomCode);
        Symptom.Validate(Description, Description);

        if Exists then
            Symptom.Modify(true)
        else
            Symptom.Insert(true);
    end;

    procedure InsertResolution(ResolutionCode: Code[10]; Description: Text[80])
    var
        Resolution: Record "Resolution Code";
        Exists: Boolean;
    begin
        if Resolution.Get(ResolutionCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Resolution.Validate(Code, ResolutionCode);
        Resolution.Validate(Description, Description);

        if Exists then
            Resolution.Modify(true)
        else
            Resolution.Insert(true);
    end;

    procedure InsertFaultCode(FaultAreaCode: Code[10]; SymptomCode: Code[10]; FaultCode: Code[10]; Description: Text[80])
    var
        Fault: Record "Fault Code";
        Exists: Boolean;
    begin
        if Fault.Get(FaultAreaCode, SymptomCode, FaultCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Fault.Validate("Fault Area Code", FaultAreaCode);
        Fault.Validate("Symptom Code", SymptomCode);
        Fault.Validate(Code, FaultCode);
        Fault.Validate(Description, Description);

        if Exists then
            Fault.Modify(true)
        else
            Fault.Insert(true);
    end;

    procedure InsertTroubleshootingHeader(HeaderNo: Code[20]; Description: Text[100])
    var
        TroubleshootingHeader: Record "Troubleshooting Header";
        Exists: Boolean;
    begin
        if TroubleshootingHeader.Get(HeaderNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TroubleshootingHeader.Validate("No.", HeaderNo);
        TroubleshootingHeader.Validate("Description", Description);

        if Exists then
            TroubleshootingHeader.Modify(true)
        else
            TroubleshootingHeader.Insert(true);
    end;

    procedure InsertTroubleshootingLine(HeaderNo: Code[20]; Comment: Text[80])
    var
        TroubleshootingLine: Record "Troubleshooting Line";
    begin
        TroubleshootingLine.Validate("No.", HeaderNo);
        TroubleshootingLine.Validate("Line No.", GetNextTroubleshootingLineNo(HeaderNo));
        TroubleshootingLine.Validate(Comment, Comment);
        TroubleshootingLine.Insert(true);
    end;

    local procedure GetNextTroubleshootingLineNo(HeaderNo: Code[20]): Integer
    var
        TroubleshootingLine: Record "Troubleshooting Line";
    begin
        TroubleshootingLine.SetRange("No.", HeaderNo);
        TroubleshootingLine.SetCurrentKey("Line No.");

        if TroubleshootingLine.FindLast() then
            exit(TroubleshootingLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertTroubleshootingSetup(SetupNo: Code[20]; Type: Enum "Troubleshooting Item Type"; TroubleshootingNo: Code[20])
    var
        TroubleshootingSetup: Record "Troubleshooting Setup";
        Exists: Boolean;
    begin
        if TroubleshootingSetup.Get(Type, SetupNo, TroubleshootingNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TroubleshootingSetup.Validate(Type, Type);
        TroubleshootingSetup.Validate("No.", SetupNo);
        TroubleshootingSetup.Validate("Troubleshooting No.", TroubleshootingNo);

        if Exists then
            TroubleshootingSetup.Modify(true)
        else
            TroubleshootingSetup.Insert(true);
    end;

    procedure InsertServiceStatusPrioritySetup(OrderStatus: Enum "Service Document Status"; Priority: Option)
    var
        ServiceStatusPrioritySetup: Record "Service Status Priority Setup";
        Exists: Boolean;
    begin
        if ServiceStatusPrioritySetup.Get(OrderStatus) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ServiceStatusPrioritySetup.Validate("Service Order Status", OrderStatus);
        ServiceStatusPrioritySetup.Validate(Priority, Priority);

        if Exists then
            ServiceStatusPrioritySetup.Modify(true)
        else
            ServiceStatusPrioritySetup.Insert(true);
    end;

    procedure InsertRepairStatusSetup(RepairStatusCode: Code[10]; RepairStatusDesc: Text[100]; OrderStatus: Enum "Service Document Status"; Initial: Boolean; InProcess: Boolean; Finished: Boolean; PartlyServiced: Boolean; Referred: Boolean; SpOrdered: Boolean; SpReceieved: Boolean; Wait: Boolean; Quote: Boolean; PostAllowed: Boolean; PendStatAllowed: Boolean; InProcStatAllowed: Boolean; FinishedStatAllowed: Boolean; onHoldStatAllowed: Boolean)
    var
        RepairStatus: Record "Repair Status";
        Exists: Boolean;
    begin
        if RepairStatus.Get(RepairStatusCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RepairStatus.Validate(Code, RepairStatusCode);
        RepairStatus.Validate(Description, RepairStatusDesc);
        RepairStatus.Validate("Service Order Status", OrderStatus);
        RepairStatus.Validate(Initial, Initial);
        RepairStatus.Validate("In Process", InProcess);
        RepairStatus.Validate(Finished, Finished);
        RepairStatus.Validate("Partly Serviced", PartlyServiced);
        RepairStatus.Validate(Referred, Referred);
        RepairStatus.Validate("Spare Part Ordered", SpOrdered);
        RepairStatus.Validate("Spare Part Received", SpReceieved);
        RepairStatus.Validate("Waiting for Customer", Wait);
        RepairStatus.Validate("Quote Finished", Quote);
        RepairStatus.Validate("Posting Allowed", PostAllowed);
        RepairStatus.Validate("Pending Status Allowed", PendStatAllowed);
        RepairStatus.Validate("In Process Status Allowed", InProcStatAllowed);
        RepairStatus.Validate("Finished Status Allowed", FinishedStatAllowed);
        RepairStatus.Validate("On Hold Status Allowed", onHoldStatAllowed);

        if Exists then
            RepairStatus.Modify(true)
        else
            RepairStatus.Insert(true);
    end;

    procedure InsertFaultResolutionRelation(FaultAreaCode: Code[10]; SymptomCode: Code[10]; FaultCode: Code[10]; ResolutionCode: Code[10]; ServiceItemGroupCode: Code[10])
    var
        FaultResolutionRelation: Record "Fault/Resol. Cod. Relationship";
        Exists: Boolean;
    begin
        if FaultResolutionRelation.Get(FaultCode, FaultAreaCode, SymptomCode, ResolutionCode, ServiceItemGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FaultResolutionRelation.Validate("Fault Area Code", FaultAreaCode);
        FaultResolutionRelation.Validate("Symptom Code", SymptomCode);
        FaultResolutionRelation.Validate("Fault Code", FaultCode);
        FaultResolutionRelation.Validate("Resolution Code", ResolutionCode);
        FaultResolutionRelation.Validate("Service Item Group Code", ServiceItemGroupCode);

        if Exists then
            FaultResolutionRelation.Modify(true)
        else
            FaultResolutionRelation.Insert(true);
    end;
}