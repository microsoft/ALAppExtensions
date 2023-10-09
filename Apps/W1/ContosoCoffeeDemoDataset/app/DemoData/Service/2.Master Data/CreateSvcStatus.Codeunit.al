codeunit 5137 "Create Svc Status"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSvcOrderStatusSetup();
        CreateRepairStatusSetup();
    end;

    local procedure CreateSvcOrderStatusSetup()
    begin
        //0 - high, 1 - medium high, 2 - medium low, 3 - low
        ContosoService.InsertServiceStatusPrioritySetup(Enum::"Service Document Status"::Pending, 1);
        ContosoService.InsertServiceStatusPrioritySetup(Enum::"Service Document Status"::"In Process", 0);
        ContosoService.InsertServiceStatusPrioritySetup(Enum::"Service Document Status"::Finished, 3);
        ContosoService.InsertServiceStatusPrioritySetup(Enum::"Service Document Status"::"On Hold", 2);
    end;

    local procedure CreateRepairStatusSetup()
    begin
        ContosoService.InsertRepairStatusSetup(StatusFinishedTok, StatusFinishedDescTok, Enum::"Service Document Status"::Finished, false, false, true, false, false, false, false, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusINPROCTok, StatusINPROCDescTok, Enum::"Service Document Status"::"In Process", false, true, false, false, false, false, false, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusINITTok, StatusINITDescTok, Enum::"Service Document Status"::Pending, true, false, false, false, false, false, false, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusPARTLYTok, StatusPARTLYDescTok, Enum::"Service Document Status"::Pending, false, false, false, true, false, false, false, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusQUOTETok, StatusQUOTEDescTok, Enum::"Service Document Status"::"On Hold", false, false, false, false, false, false, false, false, true, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusREFTok, StatusREFDescTok, Enum::"Service Document Status"::Pending, false, false, false, false, true, false, false, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusSPORDERTok, StatusSPORDERDescTok, Enum::"Service Document Status"::"On Hold", false, false, false, false, false, true, false, false, false, false, false, false, false, true);
        ContosoService.InsertRepairStatusSetup(StatusSPRCVDTok, StatusSPRCVDDescTok, Enum::"Service Document Status"::Pending, false, false, false, false, false, false, true, false, false, true, true, true, true, true);
        ContosoService.InsertRepairStatusSetup(StatusWAITTok, StatusWAITDescTok, Enum::"Service Document Status"::"On Hold", false, false, false, false, false, false, false, true, false, true, true, true, true, true);
    end;

    var
        ContosoService: Codeunit "Contoso Service";
        StatusFinishedTok: Label 'FINISHED', MaxLength = 10;
        StatusFinishedDescTok: Label 'Service is finished', MaxLength = 100;
        StatusINPROCTok: Label 'IN PROCESS', MaxLength = 10;
        StatusINPROCDescTok: Label 'Service in process', MaxLength = 100;
        StatusINITTok: Label 'INITIAL', MaxLength = 10;
        StatusINITDescTok: Label 'Initial Repair Status', MaxLength = 100;
        StatusPARTLYTok: Label 'PARTLYSERV', MaxLength = 10;
        StatusPARTLYDescTok: Label 'Partly Serviced', MaxLength = 100;
        StatusQUOTETok: Label 'QUOTEFIN', MaxLength = 10;
        StatusQUOTEDescTok: Label 'Quotation Finished', MaxLength = 100;
        StatusREFTok: Label 'REFERRED', MaxLength = 10;
        StatusREFDescTok: Label 'Referred', MaxLength = 100;
        StatusSPORDERTok: Label 'SP ORDERED', MaxLength = 10;
        StatusSPORDERDescTok: Label 'Spare Part ordered', MaxLength = 100;
        StatusSPRCVDTok: Label 'SP RCVD', MaxLength = 10;
        StatusSPRCVDDescTok: Label 'Spare part received', MaxLength = 100;
        StatusWAITTok: Label 'WAITCUST', MaxLength = 10;
        StatusWAITDescTok: Label 'Waiting for Customer', MaxLength = 100;
}