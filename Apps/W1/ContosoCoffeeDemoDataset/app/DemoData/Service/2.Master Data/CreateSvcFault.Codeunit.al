codeunit 4794 "Create Svc Fault"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSymptoms();
        CreateResolution();
        CreateFaultCodes();
        CreateTroubleshooting();
        CreateFaultResolutionRelations();
    end;

    local procedure CreateSymptoms()
    begin
        ContosoService.InsertSymptom(ErrorSymptom(), AlarmLightMessageLbl);
        ContosoService.InsertSymptom(LeakingSymptom(), LeakingLbl);
        ContosoService.InsertSymptom(NoiseSymptom(), LoudNoiseLbl);
    end;

    local procedure CreateResolution()
    begin
        ContosoService.InsertResolution(RTok + '1', R1DescTok);
        ContosoService.InsertResolution(RTok + '2', R2DescTok);
        ContosoService.InsertResolution(RTok + '3', R3DescTok);
        ContosoService.InsertResolution(RTok + '4', R4DescTok);
        ContosoService.InsertResolution(RTok + '5', R5DescTok);
        ContosoService.InsertResolution(RTok + '6', R6DescTok);
    end;

    local procedure CreateFaultCodes()
    begin
        ContosoService.InsertFaultCode('', ErrorSymptom(), '1-1', FaultCode11DescTok);
        ContosoService.InsertFaultCode('', ErrorSymptom(), '1-2', FaultCode12DescTok);
        ContosoService.InsertFaultCode('', ErrorSymptom(), '1-3', FaultCode13DescTok);
        ContosoService.InsertFaultCode('', ErrorSymptom(), '1-9', FaultCode19DescTok);
        ContosoService.InsertFaultCode('', LeakingSymptom(), '3-1', FaultCode31DescTok);
        ContosoService.InsertFaultCode('', LeakingSymptom(), '3-2', FaultCode32DescTok);
        ContosoService.InsertFaultCode('', NoiseSymptom(), '5-1', FaultCode51DescTok);
        ContosoService.InsertFaultCode('', NoiseSymptom(), '5-2', FaultCode52DescTok);
    end;

    local procedure CreateFaultResolutionRelations()
    var
        SvcSetup: Codeunit "Create Svc Setup";
    begin
        ContosoService.InsertFaultResolutionRelation('', ErrorSymptom(), '1-1', RTok + '1', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', ErrorSymptom(), '1-2', RTok + '2', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', ErrorSymptom(), '1-3', RTok + '4', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', ErrorSymptom(), '1-9', '', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', LeakingSymptom(), '3-1', RTok + '5', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', LeakingSymptom(), '3-2', RTok + '6', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', NoiseSymptom(), '5-1', RTok + '1', SvcSetup.DefaultServiceItemGroup());
        ContosoService.InsertFaultResolutionRelation('', NoiseSymptom(), '5-2', RTok + '2', SvcSetup.DefaultServiceItemGroup());
    end;

    local procedure CreateTroubleshooting()
    var
        SvcSetup: Codeunit "Create Svc Setup";
    begin
        ContosoService.InsertTroubleshootingHeader(DefaultTroubleShootingCode(), TroubleshootingDescTok);
        ContosoService.InsertTroubleshootingLine(DefaultTroubleShootingCode(), TroubleshootingDescTok);
        ContosoService.InsertTroubleshootingSetup(SvcSetup.DefaultServiceItemGroup(), Enum::"Troubleshooting Item Type"::"Service Item Group", DefaultTroubleShootingCode());
    end;

    var
        ContosoService: Codeunit "Contoso Service";
        ErrorCodeTok: Label 'ERROR', MaxLength = 10;
        AlarmLightMessageLbl: Label 'Alarm light/message', MaxLength = 100;
        LeakingCodeTok: Label 'LEAKING', MaxLength = 10;
        LeakingLbl: Label 'Leaking', MaxLength = 100;
        NoiseCodeTok: Label 'NOISE', MaxLength = 10;
        LoudNoiseLbl: Label 'Loud noise', MaxLength = 100;
        RTok: Label 'R', MaxLength = 1, Comment = 'R - [R]esolution';
        R1DescTok: Label 'Clean the coffee funnel clean the coffee funnel in Maintenance manual', MaxLength = 80;
        R2DescTok: Label 'Clean and great the brew group as described in Maintenance manual', MaxLength = 80;
        R3DescTok: Label 'Remove any beans/bean particles located in the water tank compartment area', MaxLength = 80;
        R4DescTok: Label 'Turn off the machine and wait for 60 minutes', MaxLength = 80;
        R5DescTok: Label 'Clean out waste box and waste pipe as described in Maintenance manual', MaxLength = 80;
        R6DescTok: Label 'Filter basket needs replacement', MaxLength = 80;
        FaultCode11DescTok: Label 'The coffee funnel is blocked by ground coffee', MaxLength = 80;
        FaultCode12DescTok: Label 'The brew unit is clogged or has not been properly greased', MaxLength = 80;
        FaultCode13DescTok: Label 'The machine is overheated', MaxLength = 80;
        FaultCode19DescTok: Label 'Contact service center for assistance', MaxLength = 80;
        FaultCode31DescTok: Label 'The machine leaking underneath', MaxLength = 80;
        FaultCode32DescTok: Label 'The coffee leaking from filter holder', MaxLength = 80;
        FaultCode51DescTok: Label 'Loud noise during grinding', MaxLength = 80;
        FaultCode52DescTok: Label 'Loud noise during brewing', MaxLength = 80;
        DefaultTroubleshootingTok: Label 'Default', MaxLength = 20;
        TroubleshootingDescTok: Label 'Have you tried turning it off and on again?', MaxLength = 80;


    procedure ErrorSymptom(): Code[10]
    begin
        exit(ErrorCodeTok);
    end;

    procedure LeakingSymptom(): Code[10]
    begin
        exit(LeakingCodeTok);
    end;

    procedure NoiseSymptom(): Code[10]
    begin
        exit(NoiseCodeTok);
    end;

    procedure DefaultTroubleShootingCode(): Code[20]
    begin
        exit(DefaultTroubleshootingTok);
    end;
}