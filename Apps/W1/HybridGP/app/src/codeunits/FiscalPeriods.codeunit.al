codeunit 40107 FiscalPeriods
{

    procedure MoveStagingData()
    var
        GPSY40101: Record "GP SY40101";
    begin
        if not GPSY40101.FindSet() then
            exit;

        repeat
            CreateFiscalPeriods(GPSY40101);
        until GPSY40101.Next() = 0;
    end;


    local procedure CreateFiscalPeriods(GPSY40101: Record "GP SY40101")
    var
        GPSY40100: Record "GP SY40100";
        AccountingPeriod: Record "Accounting Period";
        InventorySetup: Record "Inventory Setup";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        I: Integer;
    begin
        GPSY40100.Reset();
        GPSY40100.SetFilter(YEAR1, Format(GPSY40101.YEAR1));
        GPSY40100.SetFilter(SERIES, '2');
        if not GPSY40100.FindSet() then
            exit;

        for I := 1 to GPSY40101.NUMOFPER do begin
            GPSY40100.SetFilter(PERIODID, Format(I));
            if GPSY40100.FindFirst() then begin
                Clear(AccountingPeriod);
                AccountingPeriod.Validate("Starting Date", DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPSY40100.PERIODDT)));

                if not AccountingPeriod.Get() then begin
                    AccountingPeriod.Validate(Name, CopyStr(GPSY40100.PERNAME.TrimEnd(), 1, 10));
                    if I = 1 then begin
                        AccountingPeriod."New Fiscal Year" := true;
                        InventorySetup.Get();
                        AccountingPeriod."Average Cost Calc. Type" := InventorySetup."Average Cost Calc. Type";
                        AccountingPeriod."Average Cost Period" := InventorySetup."Average Cost Period";
                    end;
                    AccountingPeriod.Insert();

                    AccountingPeriod.UpdateAvgItems();
                end;
            end;
        end;
    end;
}