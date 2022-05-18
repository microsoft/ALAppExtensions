table 40107 MSFTSY40100
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; CLOSED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(2; SERIES; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; ODESCTN; Text[51])
        {
            DataClassification = CustomerContent;
        }
        field(4; FORIGIN; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; PERIODID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; PERIODDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(7; PERNAME; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(8; PSERIES_1; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; PSERIES_2; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; PSERIES_3; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(11; PSERIES_4; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(12; PSERIES_5; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(13; PSERIES_6; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; YEAR1; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; PERDENDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(16; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(17; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; FORIGIN, YEAR1, PERIODID, SERIES, ODESCTN)
        {
            Clustered = true;
        }
    }

    procedure MoveStagingData(MSFTSY40101: Record MSFTSY40101)
    var
        AccountingPeriod: Record "Accounting Period";
        InventorySetup: Record "Inventory Setup";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        i: Integer;
    begin
        Rec.Reset();
        Rec.SetFilter(YEAR1, Format(MSFTSY40101.YEAR1));
        Rec.SetFilter(SERIES, '2');
        if FindSet() then
            for i := 1 to MSFTSY40101.NUMOFPER do begin
                Rec.SetFilter(PERIODID, Format(i));
                if FindFirst() then begin
                    AccountingPeriod.Init();
                    AccountingPeriod.Validate("Starting Date", DT2Date(OutlookSynchTypeConv.LocalDT2UTC(Rec.PERIODDT)));
                    AccountingPeriod.Validate(Name, CopyStr(Rec.PERNAME.TrimEnd(), 1, 10));
                    if i = 1 then begin
                        AccountingPeriod."New Fiscal Year" := true;
                        InventorySetup.Get();
                        AccountingPeriod."Average Cost Calc. Type" := InventorySetup."Average Cost Calc. Type";
                        AccountingPeriod."Average Cost Period" := InventorySetup."Average Cost Period";
                    end;

                    if not AccountingPeriod.Find('=') then
                        AccountingPeriod.Insert();

                    AccountingPeriod.UpdateAvgItems();
                end;
            end;
    end;
}