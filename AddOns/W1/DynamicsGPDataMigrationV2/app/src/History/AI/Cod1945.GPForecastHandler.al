codeunit 1945 "GP Forecast Handler"
{
    trigger OnRun()
    begin

    end;

    var
        GPTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        GP_ForecastTemp: Record GP_ForecastTemp temporary;
        CashFlowSetup: Record "Cash Flow Setup";
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        TimeSeriesManagement: Codeunit "Time Series Management";
        SalesForecastHandler: Codeunit "Sales Forecast Handler";
        GPStatus: Option " ","Missing API","Not enough historical data","Out of limit";
        ApiUrl: Text[250];
        [NonDebuggable]
        ApiKey: Text[200];
        UsingStandardCredentials: Boolean;
        LimitValue: Decimal;
        TimeSeriesLibState: Option Uninitialized,Initialized,"Data Prepared",Done;
        XINVOICETxt: Label 'INVOICE', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Forecast Handler", 'OnAfterHasMinimumHistoricalData', '', true, true)]
    procedure OnAfterHasMinimumHistoricalData(var HasMinimumHistoryLoc: Boolean; var NumberOfPeriodsWithHistoryLoc: integer; PeriodType: Integer; ForecastStartDate: Date)
    var
        GP_SOPTrxHist: Record GP_SOPTrxHist;
        GP_RMOpen: Record GP_RMOpen;
        GP_RMHist: Record GP_RMHist;
        GP_POP_POHist: Record GP_POP_POHist;
        GP_PMHist: Record GP_PMHist;
        NumberOfPeriodsWithHistory: Integer;
    begin
        if not Initialize() then
            exit;

        GP_SOPTrxHist.SetCurrentKey(DUEDATE);
        GP_SOPTrxHist.SetFilter(SOPTYPE, '%1', GP_SOPTrxHist.SOPTYPE::Invoice);
        GP_RMOpen.SetCurrentKey(DUEDATE);
        GP_RMOpen.SetFilter(RMDTYPAL, '%1|%2', GP_RMOpen.RMDTYPAL::"Sales/Invoices", GP_RMOpen.RMDTYPAL::"Credit Memos");
        GP_RMHist.SetCurrentKey(DUEDATE);
        GP_RMHist.SetFilter(RMDTYPAL, '%1|%2', GP_RMHist.RMDTYPAL::"Sales/Invoices", GP_RMHist.RMDTYPAL::"Credit Memos");
        GP_POP_POHist.SetCurrentKey(DUEDATE);
        GP_PMHist.SetCurrentKey(DUEDATE);
        GP_PMHist.SetFilter(DOCTYPE, '%1|%2', GP_PMHist.DOCTYPE::Invoice, GP_PMHist.DOCTYPE::"Credit Memo");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GP_SOPTrxHist,
            GP_SOPTrxHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GP_RMOpen,
            GP_RMOpen.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GP_RMHist,
            GP_RMHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GP_POP_POHist,
            GP_POP_POHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            GP_PMHist,
            GP_PMHist.FieldNo(DUEDATE),
            PeriodType,
            ForecastStartDate);
        ComparePeriods(NumberOfPeriodsWithHistoryLoc, NumberOfPeriodsWithHistory);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Forecast Handler", 'OnAfterPrepareSalesHistoryData', '', true, true)]
    procedure OnAfterPrepareSalesHistoryData(var TimeSeriesBuffer: Record "Time Series Buffer"; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer)
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        GP_SOPTrxHist: Record GP_SOPTrxHist;
        GP_RMOpen: Record GP_RMOpen;
        GP_RMHist: Record GP_RMHist;
    begin
        if not Initialize() then
            exit;

        GP_RMOpen.SetCurrentKey(DUEDATE);
        GP_RMOpen.SetFilter(RMDTYPAL, '%1|%2', GP_RMOpen.RMDTYPAL::"Sales/Invoices", GP_RMOpen.RMDTYPAL::"Credit Memos");
        AddToTempTable(GP_RMOpen, GP_RMOpen.FieldNo(DOCNUMBR), GP_RMOpen.FieldNo(RMDTYPAL), GP_RMOpen.FieldNo(DUEDATE), GP_RMOpen.FieldNo(SLSAMNT));
        GP_RMHist.SetCurrentKey(DUEDATE);
        GP_RMHist.SetFilter(RMDTYPAL, '%1|%2', GP_RMHist.RMDTYPAL::"Sales/Invoices", GP_RMHist.RMDTYPAL::"Credit Memos");
        AddToTempTable(GP_RMHist, GP_RMHist.FieldNo(DOCNUMBR), GP_RMHist.FieldNo(RMDTYPAL), GP_RMHist.FieldNo(DUEDATE), GP_RMHist.FieldNo(SLSAMNT));

        GP_SOPTrxHist.SetCurrentKey(DUEDATE);
        GP_SOPTrxHist.SetFilter(SOPTYPE, '%1', GP_SOPTrxHist.SOPTYPE::Invoice);
        AddToTempTable(GP_SOPTrxHist, GP_SOPTrxHist.FieldNo(SOPNUMBE), GP_SOPTrxHist.FieldNo(SOPTYPE), GP_SOPTrxHist.FieldNo(DUEDATE), GP_SOPTrxHist.FieldNo(DOCAMNT));

        GP_ForecastTemp.Reset();
        GP_ForecastTemp.SetCurrentKey(DueDate);
        PrepareData(TempTimeSeriesBuffer,
            GP_ForecastTemp,
            GP_ForecastTemp.FieldNo(DocType),
            GP_ForecastTemp.FieldNo(DueDate),
            GP_ForecastTemp.FieldNo(Amount),
            Format(GP_ForecastTemp.DocType::Invoice),
            Format(GP_ForecastTemp.DocType::"Credit Memo"),
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
        GP_POP_POHist: Record GP_POP_POHist;
        GP_PMHist: Record GP_PMHist;
    begin
        if not Initialize() then
            exit;

        GP_PMHist.SetCurrentKey(DUEDATE);
        GP_PMHist.SetFilter(DOCTYPE, '%1|%2', GP_PMHist.DOCTYPE::Invoice, GP_PMHist.DOCTYPE::"Credit Memo");
        AddToTempTable(GP_PMHist, GP_PMHist.FieldNo(DOCNUMBR), GP_PMHist.FieldNo(DOCTYPE), GP_PMHist.FieldNo(DUEDATE), GP_PMHist.FieldNo(DOCAMNT));

        GP_POP_POHist.SetCurrentKey(DUEDATE);
        AddToTempTable(GP_POP_POHist, GP_POP_POHist.FieldNo(PONUMBER), GP_POP_POHist.FieldNo(POTYPE), GP_POP_POHist.FieldNo(DUEDATE), GP_POP_POHist.FieldNo(SUBTOTAL));

        GP_ForecastTemp.SetCurrentKey(DueDate);
        PrepareData(TempTimeSeriesBuffer,
            GP_ForecastTemp,
            GP_ForecastTemp.FieldNo(DocType),
            GP_ForecastTemp.FieldNo(DueDate),
            GP_ForecastTemp.FieldNo(Amount),
            Format(GP_ForecastTemp.DocType::Invoice),
            Format(GP_ForecastTemp.DocType::"Credit Memo"),
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
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        WorkDateTime: DateTime;
    begin
        If not InitializeSI() then begin
            Status := GPStatus;
            exit;
        end;

        WorkDateTime := CREATEDATETIME(WorkDate(), 0T);
        GP_IVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGP_IVTrxAmountsHistFilters(GP_IVTrxAmountsHist, ItemNo);
        GP_IVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', WorkDateTime);

        if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
            exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        PrepareSIData(GPTimeSeriesBuffer,
          GP_IVTrxAmountsHist,
          GP_IVTrxAmountsHist.FieldNo(ITEMNMBR),
          GP_IVTrxAmountsHist.FieldNo(DOCDATE),
          GP_IVTrxAmountsHist.FieldNo(TRXQTY),
          MSSalesForecastSetup."Period Type",
          ForecastStartDate,
          NumberOfPeriodsWithHistory);

        GPTimeSeriesBuffer.SetRange("Group ID", ItemNo);
        if GPTimeSeriesBuffer.FindSet() then
            AppendSIRecords(TempTimeSeriesBuffer, GPTimeSeriesBuffer, ItemNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Forecast Handler", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinimumSIHistData(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR Status: Option " ","Missing API","Not enough historical data","Out of limit")
    var
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        ForecastStartDateTime: DateTime;
    begin
        If not InitializeSI() then begin
            Status := GPStatus;
            exit;
        end;

        ForecastStartDateTime := CREATEDATETIME(ForecastStartDate, 0T);
        GP_IVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGP_IVTrxAmountsHistFilters(GP_IVTrxAmountsHist, ItemNo);
        GP_IVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDateTime);

        //if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
        //    exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GP_IVTrxAmountsHist,
            GP_IVTrxAmountsHist.FieldNo(DOCDATE),
            MSSalesForecastSetup."Period Type",
            ForecastStartDate);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Forecast", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinSIHistDataSF(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available")
    var
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        ForecastStartDateTime: DateTime;
    begin
        If not InitializeSI() then begin
            StatusType := StatusType::" ";
            exit;
        end;

        ForecastStartDateTime := CREATEDATETIME(ForecastStartDate, 0T);
        GP_IVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGP_IVTrxAmountsHistFilters(GP_IVTrxAmountsHist, ItemNo);
        GP_IVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDateTime);

        //if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
        //    exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GP_IVTrxAmountsHist,
            GP_IVTrxAmountsHist.FieldNo(DOCDATE),
            MSSalesForecastSetup."Period Type",
            ForecastStartDate);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Forecast No Chart", 'OnAfterHasMinimumSIHistData', '', true, true)]
    procedure OnAfterHasMinSIHistDataSFNoC(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available")
    var
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        ForecastStartDateTime: DateTime;
    begin
        If not InitializeSI() then begin
            StatusType := StatusType::" ";
            exit;
        end;

        ForecastStartDateTime := CREATEDATETIME(ForecastStartDate, 0T);
        GP_IVTrxAmountsHist.SetCurrentKey(DOCTYPE, ITEMNMBR, DOCDATE, DOCNUMBR);
        SetGP_IVTrxAmountsHistFilters(GP_IVTrxAmountsHist, ItemNo);
        GP_IVTrxAmountsHist.SetFilter(DOCDATE, '<=%1', ForecastStartDateTime);

        //if not SalesForecastHandler.InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
        //    exit;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        HasMinimumHistoryLoc := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistoryLoc,
            GP_IVTrxAmountsHist,
            GP_IVTrxAmountsHist.FieldNo(DOCDATE),
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

    local procedure AppendGPRecords(var SourceTimeSeriesBuffer: Record "Time Series Buffer" temporary; GroupId: Text[50])
    begin
        if SourceTimeSeriesBuffer.FindSet() then
            repeat
                if PeriodAlreadyExists(GroupId, SourceTimeSeriesBuffer."Period Start Date") then begin
                    GPTimeSeriesBuffer.Validate(Value, (GPTimeSeriesBuffer.Value + SourceTimeSeriesBuffer.Value));
                    GPTimeSeriesBuffer.Modify();
                end else begin
                    GPTimeSeriesBuffer.Validate(Value, SourceTimeSeriesBuffer.Value);
                    GPTimeSeriesBuffer.Validate("Period Start Date", SourceTimeSeriesBuffer."Period Start Date");
                    GPTimeSeriesBuffer.Validate("Period No.", SourceTimeSeriesBuffer."Period No.");
                    GPTimeSeriesBuffer.Validate("Group ID", GroupId);
                    GPTimeSeriesBuffer.Insert();
                end;
            until SourceTimeSeriesBuffer.Next() = 0;

        GPTimeSeriesBuffer.Reset();
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

    [NonDebuggable]
    local procedure Initialize(): Boolean
    begin
        if not CashFlowSetup.Get() then
            exit(false);

        if (TimeSeriesLibState = TimeSeriesLibState::Initialized) then
            exit(true);

        GPTimeSeriesBuffer.DeleteAll();
        GP_ForecastTemp.DeleteAll();
        CashFlowSetup.GetMLCredentials(ApiUrl, ApiKey, LimitValue, UsingStandardCredentials);
        TimeSeriesManagement.Initialize(ApiUrl, ApiKey, CashFlowSetup.TimeOut, UsingStandardCredentials);
        TimeSeriesManagement.SetMaximumHistoricalPeriods(CashFlowSetup."Historical Periods");
        TimeSeriesManagement.GetState(TimeSeriesLibState);
        if not (TimeSeriesLibState = TimeSeriesLibState::Initialized) then
            exit(false);

        exit(true);
    end;

    local procedure PeriodAlreadyExists(GroupId: Text[50]; PeriodDate: Date): Boolean
    begin
        GPTimeSeriesBuffer.SetRange("Group ID", GroupId);
        GPTimeSeriesBuffer.SetRange("Period Start Date", PeriodDate);
        if GPTimeSeriesBuffer.FindFirst() then
            exit(true);

        exit(false);
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
        GPTimeSeriesBuffer.DeleteAll();
        MSSalesForecastSetup.GetSingleInstance();
        if MSSalesForecastSetup.URIOrKeyEmpty() then begin
            GPStatus := GPStatus::"Missing API";
            exit(false);
        end;

        exit(true);
    end;

    local procedure SIPeriodAlreadyExists(GroupId: Text[50]; PeriodDate: Date): Boolean
    begin
        GPTimeSeriesBuffer.SetRange("Group ID", GroupId);
        GPTimeSeriesBuffer.SetRange("Period Start Date", PeriodDate);
        if GPTimeSeriesBuffer.FindFirst() then
            exit(true);

        exit(false);
    end;

    procedure SetGP_IVTrxAmountsHistFilters(var GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist; ItemNo: Code[20])
    begin
        GP_IVTrxAmountsHist.SetRange(DOCTYPE, GP_IVTrxAmountsHist.DOCTYPE::Sale);
        GP_IVTrxAmountsHist.SetRange(ITEMNMBR, ItemNo);
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

            GP_ForecastTemp.Init();
            GP_ForecastTemp.Validate(DocNumber, DocNumberFieldRef.Value());

            if ((Format(DocTypeFieldRef.Value()) = Format(GP_ForecastTemp.DocType::"Credit Memo")) OR (Format(DocTypeFieldRef.Value()) = Format(GP_ForecastTemp.DocType::"Credit Memos"))) then
                GP_ForecastTemp.Validate(DocType, GP_ForecastTemp.DocType::"Credit Memo")
            else
                GP_ForecastTemp.Validate(DocType, GP_ForecastTemp.DocType::Invoice);

            GP_ForecastTemp.Validate(DueDate, DateFieldRef.Value());
            GP_ForecastTemp.Validate(Amount, AmountFieldRef.Value());
            if not GP_ForecastTemp.Insert() then;
        until RecRef.Next() = 0;
    end;
}