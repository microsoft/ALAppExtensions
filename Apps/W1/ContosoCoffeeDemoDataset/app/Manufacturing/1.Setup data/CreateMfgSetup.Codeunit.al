codeunit 4766 "Create Mfg Setup"
{

    trigger OnRun()
    begin
        if not ManufacturingSetup.Get() then
            ManufacturingSetup.Insert();

        ManufacturingSetup.Validate("Normal Starting Time", 080000T);
        ManufacturingSetup.Validate("Normal Ending Time", 230000T);
        ManufacturingSetup.Validate("Doc. No. Is Prod. Order No.", true);

        ManufacturingSetup.Validate("Cost Incl. Setup", true);
        ManufacturingSetup.Validate("Planning Warning", true);
        ManufacturingSetup.Validate("Dynamic Low-Level Code", true);

        ManufacturingSetup.Validate("Show Capacity In", XMINUTESTok);

        InitBaseSeries(ManufacturingSetup."Work Center Nos.", XWORKCTRTok, XWorkCentersTok, XW10Tok, XW99990Tok, '', '', 10, true);
        InitBaseSeries(ManufacturingSetup."Machine Center Nos.", XMACHCTRTok, XMachineCentersTok, XM10Tok, XM99990Tok, '', '', 10, true);
        InitBaseSeries(ManufacturingSetup."Production BOM Nos.", XPRODBOMTok, XProductionBOMsTok, XP10Tok, XP99990Tok, '', '', 10, true);
        InitBaseSeries(ManufacturingSetup."Routing Nos.", XROUTINGTok, XRoutingslcTok, XR10Tok, XR99990Tok, '', '', 10, true);
        InitTempSeries(ManufacturingSetup."Simulated Order Nos.", XMSIMTok, XSimulatedOrdersTok);
        InitFinalSeries(ManufacturingSetup."Planned Order Nos.", XMPLANTok, XPlannedordersTok, 1);
        InitFinalSeries(ManufacturingSetup."Firm Planned Order Nos.", XMFIRMPTok, XFirmPlannedordersTok, 1);
        InitFinalSeries(ManufacturingSetup."Released Order Nos.", XMRELTok, XReleasedordersTok, 1);

        ManufacturingSetup."Simulated Order Nos." := XMSIMTok;
        ManufacturingSetup."Planned Order Nos." := XMPLANTok;
        ManufacturingSetup."Firm Planned Order Nos." := XMFIRMPTok;
        ManufacturingSetup."Released Order Nos." := XMRELTok;
        ManufacturingSetup."Combined MPS/MRP Calculation" := true;
        Evaluate(ManufacturingSetup."Default Safety Lead Time", '<1D>');

        OnBeforeManufacturingSetupModify(ManufacturingSetup);

        ManufacturingSetup.Modify();
    end;

    local procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningAtNo: Code[20]; "IncrementByNo": Integer; AllowGaps: Boolean)
    begin
        OnBeforeInitSeries(SeriesCode, "Code");
        CreateMfgNoSeries.InitBaseSeries(SeriesCode, "Code", Description, StartingNo, EndingNo, LastNumberUsed, WarningAtNo, IncrementByNo, AllowGaps);
        OnAfterInitSeries(SeriesCode, "Code");
    end;

    local procedure InitTempSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100])
    begin
        OnBeforeInitSeries(SeriesCode, "Code");
        CreateMfgNoSeries.InitTempSeries(SeriesCode, "Code", Description);
        OnAfterInitSeries(SeriesCode, "Code");
    end;

    local procedure InitFinalSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; No: Integer)
    begin
        OnBeforeInitSeries(SeriesCode, "Code");
        CreateMfgNoSeries.InitFinalSeries(SeriesCode, "Code", Description, No);
        OnAfterInitSeries(SeriesCode, "Code");
    end;

    var
        ManufacturingSetup: Record "Manufacturing Setup";
        CreateMfgNoSeries: Codeunit "Create Mfg No. Series";
        XWORKCTRTok: Label 'WORKCTR', MaxLength = 20;
        XWorkCentersTok: Label 'Work Centers', MaxLength = 100;
        XW10Tok: Label 'W10', MaxLength = 20;
        XW99990Tok: Label 'W99990', MaxLength = 20;
        XMACHCTRTok: Label 'MACHCTR', MaxLength = 20;
        XMachineCentersTok: Label 'Machine Centers', MaxLength = 100;
        XM10Tok: Label 'M10', MaxLength = 20;
        XM99990Tok: Label 'M99990', MaxLength = 20;
        XPRODBOMTok: Label 'PRODBOM', MaxLength = 20;
        XProductionBOMsTok: Label 'Production BOMs', MaxLength = 100;
        XP10Tok: Label 'P10', MaxLength = 20;
        XP99990Tok: Label 'P99990', MaxLength = 20;
        XROUTINGTok: Label 'ROUTING', MaxLength = 20;
        XRoutingslcTok: Label 'Routings', MaxLength = 100;
        XR10Tok: Label 'R10', MaxLength = 20;
        XR99990Tok: Label 'R99990', MaxLength = 20;
        XMSIMTok: Label 'M-SIM', MaxLength = 20;
        XSimulatedOrdersTok: Label 'Simulated orders', MaxLength = 100;
        XMPLANTok: Label 'M-PLAN', MaxLength = 20;
        XPlannedordersTok: Label 'Planned orders', MaxLength = 100;
        XMFIRMPTok: Label 'M-FIRMP', MaxLength = 20;
        XFirmPlannedordersTok: Label 'Firm Planned orders', MaxLength = 100;
        XMRELTok: Label 'M-REL', MaxLength = 20;
        XReleasedordersTok: Label 'Released orders', MaxLength = 100;
        XMINUTESTok: Label 'MINUTES', MaxLength = 10;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSeries(var SeriesCode: Code[20]; var "Code": Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSeries(var SeriesCode: Code[20]; var "Code": Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManufacturingSetupModify(var ManufacturingSetup: Record "Manufacturing Setup")
    begin
    end;
}