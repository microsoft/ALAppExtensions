codeunit 4034 "GPForecastHandler"
{
    trigger OnRun()
    begin

    end;

    var
        TempGPTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        TempGPForecastTemp: Record "GPForecastTemp" temporary;
        CashFlowSetup: Record "Cash Flow Setup";
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        TimeSeriesManagement: Codeunit "Time Series Management";
        SalesForecastHandler: Codeunit "Sales Forecast Handler";
        GPStatus: Option " ","Missing API","Not enough historical data","Out of limit";
        ApiUrl: Text[250];
        ApiKey: Text[200];
        UsingStandardCredentials: Boolean;
        LimitValue: Decimal;
        TimeSeriesLibState: Option Uninitialized,Initialized,"Data Prepared",Done;
        XINVOICETxt: Label 'INVOICE', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Forecast Handler", 'OnAfterHasMinimumHistoricalData', '', true, true)]
    procedure OnAfterHasMinimumHistoricalData(var HasMinimumHistoryLoc: Boolean; var NumberOfPeriodsWithHistoryLoc: integer; PeriodType: Integer; ForecastStartDate: Date)
    var
        GPSOPTrxHist: Record GPSOPTrxHist;
        GPRMOpen: Record GPRMOpen;
        GPRMHist: Record GPRMHist;
        GPPOPPOHist: Record GPPOPPOHist;
        GPPMHist: Record GPPMHist;
        NumberOfPeriodsWithHistory: Integer;
    begin
        if not Initialize() then
            exit;

        GPSOPTrxHist.SetCurrentKey(DUEDATE);
        GPSOPTrxHist.SetFilter(SOPTYPE, '%1', GPSOPTrxHist.SOPTYPE::Invoice);
        GPRMOpen.SetCurrentKey(DUEDATE);
        GPRMOpen.SetFilter(RMDTYPAL, '%1|%2', GPRMOpen.RMDTYPAL::"Sales/Invoices", GPRMOpen.RMDTYPAL::"Credit Memos");
        GPRMHist.SetCurrentKey(DUEDATE);
        GPRMHist.SetFilter(RMDTYPAL, '%1|%2', GPRMHist.RMDTYPAL::"Sales/Invoices", GPRMHist.RMDTYPAL::"Credit Memos");
        GPPOPPOHist.SetCurrentKey(DUEDATE);
        GPPMHist.SetCurrentKey(DUEDATE);
        GPPMHist.SetFilter(DOCTYPE, '%1|%2', GPPMHist.DOCTYPE::Invoice, GPPMHist.DOCTYPE::"Credit Memo");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GPSOPTrxHist,
            GPSOPTrxHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GPRMOpen,
            GPRMOpen.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GPRMHist,
            GPRMHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GPPOPPOHist,
            GPPOPPOHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GPPMHist,
            GPPMHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Forecast Handler", 'OnAfterPrepareSalesHistoryData', '', true, true)]
    procedure OnAfterPrepareSalesHistoryData(var TimeSeriesBuffer: Record "Time Series Buffer"; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer)
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        GPSOPTrxHist: Record GPSOPTrxHist;
        GPRMOpen: Record GPRMOpen;
        GPRMHist: Record GPRMHist;
    begin
        if not Initialize() then
            exit;

        GPRMOpen.SetCurrentKey(DUEDATE);
        GPRMOpen.SetFilter(RMDTYPAL, '%1|%2', GPRMOpen.RMDTYPAL::"Sales/Invoices", GPRMOpen.RMDTYPAL::"Credit Memos");
        AddToTempTable(GPRMOpen, GPRMOpen.FieldNo(DOCNUMBR), GPRMOpen.FieldNo(RMDTYPAL), GPRMOpen.FieldNo(DUEDATE), GPRMOpen.FieldNo(SLSAMNT));
        GPRMHist.SetCurrentKey(DUEDATE);
        GPRMHist.SetFilter(RMDTYPAL, '%1|%2', GPRMHist.RMDTYPAL::"Sales/Invoices", GPRMHist.RMDTYPAL::"Credit Memos");
        AddToTempTable(GPRMHist, GPRMHist.FieldNo(DOCNUMBR), GPRMHist.FieldNo(RMDTYPAL), GPRMHist.FieldNo(DUEDATE), GPRMHist.FieldNo(SLSAMNT));

        GPSOPTrxHist.SetCurrentKey(DUEDATE);
        GPSOPTrxHist.SetFilter(SOPTYPE, '%1', GPSOPTrxHist.SOPTYPE::Invoice);
        AddToTempTable(GPSOPTrxHist, GPSOPTrxHist.FieldNo(SOPNUMBE), GPSOPTrxHist.FieldNo(SOPTYPE), GPSOPTrxHist.FieldNo(DUEDATE), GPSOPTrxHist.FieldNo(DOCAMNT));

        TempGPForecastTemp.Reset();
        TempGPForecastTemp.SetCurrentKey(DueDate);
        PrepareData(TempTimeSeriesBuffer,
            TempGPForecastTemp,
            TempGPForecastTemp.FieldNo(DocType),
            TempGPForecastTemp.FieldNo(DueDate),
            TempGPForecastTemp.FieldNo(Amount),
            Format(TempGPForecastTemp.DocType::Invoice),
            Format(TempGPForecastTemp.DocType::"Credit Memo"),
            PeriodType,
            ForecastStartDate,
            NumberOfPeriodsWithHistory);

        if TempTimeSeriesBuffer.FindSet() then
            AppendRecords(TimeSeriesBuffer, TempTimeSeriesBuffer, XINVOICETxt);
        TempTimeSeriesBuffer.DeleteAll();

        TimeSeriesBuffer.Reset();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Forecast Handler", 'OnAfterPreparePurchHistoryData', '', true, true)]
    procedure OnAfterPreparePurchHistoryData(var TimeSeriesBuffer: Record "Time Series Buffer"; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer)
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        GPPOPPOHist: Record GPPOPPOHist;
        GPPMHist: Record GPPMHist;
    begin
        if not Initialize() then
            exit;

        GPPMHist.SetCurrentKey(DUEDATE);
        GPPMHist.SetFilter(DOCTYPE, '%1|%2', GPPMHist.DOCTYPE::Invoice, GPPMHist.DOCTYPE::"Credit Memo");
        AddToTempTable(GPPMHist, GPPMHist.FieldNo(DOCNUMBR), GPPMHist.FieldNo(DOCTYPE), GPPMHist.FieldNo(DUEDATE), GPPMHist.FieldNo(DOCAMNT));

        GPPOPPOHist.SetCurrentKey(DUEDATE);
        AddToTempTable(GPPOPPOHist, GPPOPPOHist.FieldNo(PONUMBER), GPPOPPOHist.FieldNo(POTYPE), GPPOPPOHist.FieldNo(DUEDATE), GPPOPPOHist.FieldNo(SUBTOTAL));

        TempGPForecastTemp.SetCurrentKey(DueDate);
        PrepareData(TempTimeSeriesBuffer,
            TempGPForecastTemp,
            TempGPForecastTemp.FieldNo(DocType),
            TempGPForecastTemp.FieldNo(DueDate),
            TempGPForecastTemp.FieldNo(Amount),
            Format(TempGPForecastTemp.DocType::Invoice),
            Format(TempGPForecastTemp.DocType::"Credit Memo"),
            PeriodType,
            ForecastStartDate,
            NumberOfPeriodsWithHistory);

        if TempTimeSeriesBuffer.FindSet() then
            AppendRecords(TimeSeriesBuffer, TempTimeSeriesBuffer, XINVOICETxt);
        TempTimeSeriesBuffer.DeleteAll();

        TimeSeriesBuffer.Reset();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Forecast Handler", 'OnAfterPrepareSalesInvData', '', true, true)]
    procedure OnAfterPrepareSalesInvData(ItemNo: Code[20]; VAR TempTimeSeriesBuffer: Record "Time Series Buffer"; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer; VAR Status: Option " ","Missing API","Not enough historical data","Out of limit");
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
    begin
        If not InitializeSI() then begin
            Status := GPStatus;
            exit;
        end;

        GPIVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGPIVTrxAmountsHistFilters(GPIVTrxAmountsHist, ItemNo);
        GPIVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', WorkDate());

        if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
            exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        PrepareSIData(TempGPTimeSeriesBuffer,
          GPIVTrxAmountsHist,
          GPIVTrxAmountsHist.FieldNo(ITEMNMBR),
          GPIVTrxAmountsHist.FieldNo(DOCDATE),
          GPIVTrxAmountsHist.FieldNo(TRXQTY),
          MSSalesForecastSetup."Period Type",
          ForecastStartDate,
          NumberOfPeriodsWithHistory);

        TempGPTimeSeriesBuffer.SetRange("Group ID", ItemNo);
        if TempGPTimeSeriesBuffer.FindSet() then
            AppendSIRecords(TempTimeSeriesBuffer, TempGPTimeSeriesBuffer, ItemNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Forecast Handler", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinimumSIHistData(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR Status: Option " ","Missing API","Not enough historical data","Out of limit")
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
    begin
        If not InitializeSI() then begin
            Status := GPStatus;
            exit;
        end;

        GPIVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGPIVTrxAmountsHistFilters(GPIVTrxAmountsHist, ItemNo);
        GPIVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDate);

        //if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
        //    exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GPIVTrxAmountsHist,
            GPIVTrxAmountsHist.FieldNo(DOCDATE),
            MSSalesForecastSetup."Period Type",
            ForecastStartDate);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Forecast", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinSIHistDataSF(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available")
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
    begin
        If not InitializeSI() then begin
            StatusType := StatusType::" ";
            exit;
        end;

        GPIVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGPIVTrxAmountsHistFilters(GPIVTrxAmountsHist, ItemNo);
        GPIVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDate);

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GPIVTrxAmountsHist,
            GPIVTrxAmountsHist.FieldNo(DOCDATE),
            MSSalesForecastSetup."Period Type",
            ForecastStartDate);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Forecast No Chart", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinSIHistDataSFNoC(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available")
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
    begin
        If not InitializeSI() then begin
            StatusType := StatusType::" ";
            exit;
        end;

        GPIVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGPIVTrxAmountsHistFilters(GPIVTrxAmountsHist, ItemNo);
        GPIVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDate);

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GPIVTrxAmountsHist,
            GPIVTrxAmountsHist.FieldNo(DOCDATE),
            MSSalesForecastSetup."Period Type",
            ForecastStartDate);
    end;

    local procedure PrepareData(var TempTimeSeriesBuffer: Record "Time Series Buffer" temporary; RecordVariant: Variant; GroupIdFieldNo: Integer; DateFieldNo: Integer; ValueFieldNo: Integer; InvoiceOption: Text; CreditMemoOption: Text; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer)
    var
        TempCreditMemoTimeSeriesBuffer: Record "Time Series Buffer" temporary;
    begin
        TimeSeriesManagement.PrepareData(RecordVariant, GroupIdFieldNo, DateFieldNo, ValueFieldNo, PeriodType, ForecastStartDate, NumberOfPeriodsWithHistory);
        TimeSeriesManagement.GetPreparedData(TempTimeSeriesBuffer);
        TempCreditMemoTimeSeriesBuffer.Copy(TempTimeSeriesBuffer, true);
        TempCreditMemoTimeSeriesBuffer.SetRange("Group ID", CreditMemoOption);

        TempTimeSeriesBuffer.SetRange("Group ID", InvoiceOption);

        if TempTimeSeriesBuffer.FindSet() and TempCreditMemoTimeSeriesBuffer.FindSet() then
            repeat
                TempTimeSeriesBuffer.Value := TempTimeSeriesBuffer.Value - TempCreditMemoTimeSeriesBuffer.Value;
                TempTimeSeriesBuffer.Modify();
            until (TempTimeSeriesBuffer.Next() = 0) and (TempCreditMemoTimeSeriesBuffer.Next() = 0);
    end;

    local procedure AppendRecords(var TargetTimeSeriesBuffer: Record "Time Series Buffer"; var SourceTimeSeriesBuffer: Record "Time Series Buffer" temporary; GroupId: Text[50])
    begin
        if SourceTimeSeriesBuffer.FindSet() then
            repeat
                if TargetTimeSeriesBuffer.Get(GroupId, SourceTimeSeriesBuffer."Period No.") then begin
                    TargetTimeSeriesBuffer.Validate(Value, (TargetTimeSeriesBuffer.Value + SourceTimeSeriesBuffer.Value));
                    TargetTimeSeriesBuffer.Modify();
                end else begin
                    TargetTimeSeriesBuffer.Validate(Value, SourceTimeSeriesBuffer.Value);
                    TargetTimeSeriesBuffer.Validate("Period Start Date", SourceTimeSeriesBuffer."Period Start Date");
                    TargetTimeSeriesBuffer.Validate("Period No.", SourceTimeSeriesBuffer."Period No.");
                    TargetTimeSeriesBuffer.Validate("Group ID", GroupId);
                    TargetTimeSeriesBuffer.Insert();
                end;
            until SourceTimeSeriesBuffer.Next() = 0;
    end;

    local procedure Initialize(): Boolean
    begin
        if not CashFlowSetup.Get() then
            exit(false);

        if (TimeSeriesLibState = TimeSeriesLibState::Initialized) then
            exit(true);

        TempGPTimeSeriesBuffer.DeleteAll();
        TempGPForecastTemp.DeleteAll();
        CashFlowSetup.GetMLCredentials(ApiUrl, ApiKey, LimitValue, UsingStandardCredentials);
        TimeSeriesManagement.Initialize(ApiUrl, ApiKey, CashFlowSetup.TimeOut, UsingStandardCredentials);
        TimeSeriesManagement.SetMaximumHistoricalPeriods(CashFlowSetup."Historical Periods");
        TimeSeriesManagement.GetState(TimeSeriesLibState);
        if not (TimeSeriesLibState = TimeSeriesLibState::Initialized) then
            exit(false);

        exit(true);
    end;

    local procedure ComparePeriods(var NumberOfPeriodsWithHistoryLoc: integer; NumberOfPeriodsWithHistory: integer)
    begin
        if NumberOfPeriodsWithHistory > NumberOfPeriodsWithHistoryLoc then
            NumberOfPeriodsWithHistoryLoc := NumberOfPeriodsWithHistory;
    end;

    local procedure PrepareSIData(var TempTimeSeriesBuffer: Record "Time Series Buffer";
                                    RecordVariant: Variant;
                                    GroupIdFieldNo: Integer;
                                    DateFieldNo: Integer;
                                    ValueFieldNo: Integer;
                                    PeriodType: Integer;
                                    ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer)
    begin
        TimeSeriesManagement.PrepareData(RecordVariant, GroupIdFieldNo, DateFieldNo, ValueFieldNo, PeriodType, ForecastStartDate, NumberOfPeriodsWithHistory);
        TimeSeriesManagement.GetPreparedData(TempTimeSeriesBuffer);
    end;

    local procedure AppendSIRecords(var TargetTimeSeriesBuffer: Record "Time Series Buffer"; var SourceTimeSeriesBuffer: Record "Time Series Buffer" temporary; GroupId: Text[50])
    begin
        if SourceTimeSeriesBuffer.FindSet() then
            repeat
                if TargetTimeSeriesBuffer.Get(GroupId, SourceTimeSeriesBuffer."Period No.") then begin
                    // Already exists, so must merge source and dest...
                    TargetTimeSeriesBuffer.Validate(Value, (TargetTimeSeriesBuffer.Value + SourceTimeSeriesBuffer.Value));
                    TargetTimeSeriesBuffer.Modify();
                end else begin
                    TargetTimeSeriesBuffer.Validate("Group ID", GroupId);
                    TargetTimeSeriesBuffer.Validate("Period No.", SourceTimeSeriesBuffer."Period No.");
                    TargetTimeSeriesBuffer.Validate("Period Start Date", SourceTimeSeriesBuffer."Period Start Date");
                    TargetTimeSeriesBuffer.Validate(Value, SourceTimeSeriesBuffer.Value);
                    TargetTimeSeriesBuffer.Insert();
                end;
            until SourceTimeSeriesBuffer.Next() = 0;
    end;

    local procedure InitializeSI(): Boolean
    begin
        Clear(GPStatus);
        TempGPTimeSeriesBuffer.DeleteAll();
        MSSalesForecastSetup.GetSingleInstance();
        if MSSalesForecastSetup.URIOrKeyEmpty() then begin
            GPStatus := GPStatus::"Missing API";
            exit(false);
        end;

        exit(true);
    end;

    procedure SetGPIVTrxAmountsHistFilters(var GPIVTrxAmountsHist: Record GPIVTrxAmountsHist; ItemNo: Code[20])
    begin
        GPIVTrxAmountsHist.SetRange(DOCTYPE, GPIVTrxAmountsHist.DOCTYPE::Sale);
        GPIVTrxAmountsHist.SetRange(ITEMNMBR, ItemNo);
    end;

    local procedure AddToTempTable(RecordVariant: Variant; DocNumberFieldNo: Integer; DocTypeFieldNo: Integer; DateFieldNo: Integer; AmountFieldNo: Integer)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        DocNumberFieldRef: FieldRef;
        DocTypeFieldRef: FieldRef;
        DateFieldRef: FieldRef;
        AmountFieldRef: FieldRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        if RecRef.IsEmpty() then
            exit;

        repeat
            DocNumberFieldRef := RecRef.Field(DocNumberFieldNo);
            DocTypeFieldRef := RecRef.Field(DocTypeFieldNo);
            DateFieldRef := RecRef.Field(DateFieldNo);
            AmountFieldRef := RecRef.Field(AmountFieldNo);

            TempGPForecastTemp.Init();
            TempGPForecastTemp.Validate(DocNumber, DocNumberFieldRef.Value());

            if ((Format(DocTypeFieldRef.Value()) = Format(TempGPForecastTemp.DocType::"Credit Memo")) OR (Format(DocTypeFieldRef.Value()) = Format(TempGPForecastTemp.DocType::"Credit Memos"))) then
                TempGPForecastTemp.Validate(DocType, TempGPForecastTemp.DocType::"Credit Memo")
            else
                TempGPForecastTemp.Validate(DocType, TempGPForecastTemp.DocType::Invoice);

            TempGPForecastTemp.Validate(DueDate, DateFieldRef.Value());
            TempGPForecastTemp.Validate(Amount, AmountFieldRef.Value());
            if not TempGPForecastTemp.Insert() then;
        until RecRef.Next() = 0;
    end;
}