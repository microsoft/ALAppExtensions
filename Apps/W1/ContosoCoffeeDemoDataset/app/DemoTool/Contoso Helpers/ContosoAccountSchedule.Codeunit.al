codeunit 5239 "Contoso Account Schedule"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Account Schedules Chart Setup" = rim,
                tabledata "Acc. Sched. Chart Setup Line" = rim,
                tabledata "Acc. Schedule Name" = rim,
                tabledata "Acc. Schedule Line" = ri,
                tabledata "Column Layout Name" = rim,
                tabledata "Column Layout" = ri,
                tabledata "Financial Report" = rim,
                tabledata "Acc. Sched. KPI Web Srv. Line" = rim,
                tabledata "Acc. Sched. KPI Web Srv. Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAccountSchedulesChartSetup(UserID: Text[132]; Name: Text[30]; Description: Text[250]; AccountScheduleName: Code[10]; ColumnLayoutName: Code[10]; StartDate: Date; PeriodLength: Integer; NoOfPeriods: Integer; "Look Ahead": Boolean)
    var
        AccountSchedulesChartSetup: Record "Account Schedules Chart Setup";
        Exists: Boolean;
    begin
        if AccountSchedulesChartSetup.Get(UserID, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccountSchedulesChartSetup.Validate("User ID", UserID);
        AccountSchedulesChartSetup.Validate(Name, Name);
        AccountSchedulesChartSetup.Validate(Description, Description);
        AccountSchedulesChartSetup.Validate("Account Schedule Name", AccountScheduleName);
        AccountSchedulesChartSetup.Validate("Column Layout Name", ColumnLayoutName);
        AccountSchedulesChartSetup.Validate("Start Date", StartDate);
        AccountSchedulesChartSetup.Validate("Period Length", PeriodLength);
        AccountSchedulesChartSetup.Validate("No. of Periods", NoOfPeriods);
        AccountSchedulesChartSetup.Validate("Look Ahead", "Look Ahead");

        if Exists then
            AccountSchedulesChartSetup.Modify(true)
        else
            AccountSchedulesChartSetup.Insert(true);
    end;

    procedure InsertAccScheduleLine(ScheduleName: Code[10]; LineNo: Integer; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Show: Enum "Acc. Schedule Line Show"; Dimension1Totaling: Text[250]; Bold: Boolean; Italic: Boolean; Underline: Boolean; ShowOppositeSign: Boolean; RowType: Integer)
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        Exists: Boolean;
    begin
        if AccScheduleLine.Get(ScheduleName, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccScheduleLine.Validate("Schedule Name", ScheduleName);
        AccScheduleLine.Validate("Line No.", LineNo);
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate("Totaling Type", TotalingType);

        // For Localization, condition added as GL Account filters are blank
        if (Totaling = '..') then
            AccScheduleLine.Validate(Totaling)
        else
            AccScheduleLine.Validate(Totaling, Totaling);

        AccScheduleLine.Validate(Show, Show);
        AccScheduleLine.Validate("Dimension 1 Totaling", Dimension1Totaling);
        AccScheduleLine.Validate(Bold, Bold);
        AccScheduleLine.Validate(Italic, Italic);
        AccScheduleLine.Validate(Underline, Underline);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
        AccScheduleLine.Validate("Row Type", RowType);

        if Exists then
            AccScheduleLine.Modify(true)
        else
            AccScheduleLine.Insert(true);
    end;

    procedure InsertAccScheduleName(Name: Code[10]; Description: Text[80]; AnalysisViewName: Code[10])
    var
        AccScheduleName: Record "Acc. Schedule Name";
        Exists: Boolean;
    begin
        if AccScheduleName.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccScheduleName.Validate(Name, Name);
        AccScheduleName.Validate(Description, Description);
        AccScheduleName.Validate("Analysis View Name", AnalysisViewName);

        if Exists then
            AccScheduleName.Modify(true)
        else
            AccScheduleName.Insert(true);
    end;

    procedure InsertColumnLayoutName(Name: Code[10]; Description: Text[80])
    var
        ColumnLayoutName: Record "Column Layout Name";
        Exists: Boolean;
    begin
        if ColumnLayoutName.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ColumnLayoutName.Validate(Name, Name);
        ColumnLayoutName.Validate(Description, Description);

        if Exists then
            ColumnLayoutName.Modify(true)
        else
            ColumnLayoutName.Insert(true);
    end;

    procedure InsertAccSchedKPIWebSrvLine(AccScheduleName: Code[10])
    var
        AccSchedKPIWebSrvLine: Record "Acc. Sched. KPI Web Srv. Line";
        Exists: Boolean;
    begin
        if AccSchedKPIWebSrvLine.Get(AccScheduleName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccSchedKPIWebSrvLine.Validate("Acc. Schedule Name", AccScheduleName);

        if Exists then
            AccSchedKPIWebSrvLine.Modify(true)
        else
            AccSchedKPIWebSrvLine.Insert(true);
    end;

    procedure InsertAccSchedKPIWebSrvSetup(Period: Integer; ViewBy: Integer; WebServiceName: Text[240]; DataTimeToLiveHours: Integer)
    var
        AccSchedKPIWebSrvSetup: Record "Acc. Sched. KPI Web Srv. Setup";
    begin
        if not AccSchedKPIWebSrvSetup.Get() then
            AccSchedKPIWebSrvSetup.Insert();

        AccSchedKPIWebSrvSetup.Validate(Period, Period);
        AccSchedKPIWebSrvSetup.Validate("View By", ViewBy);
        AccSchedKPIWebSrvSetup.Validate("Web Service Name", WebServiceName);
        AccSchedKPIWebSrvSetup.Validate("Data Time To Live (hours)", DataTimeToLiveHours);
        AccSchedKPIWebSrvSetup.Modify(true);
    end;

    procedure InsertAccSchedChartSetupLine(UserID: Text[132]; Name: Text[30]; AccountScheduleLineNo: Integer; ColumnLayoutLineNo: Integer; AccountScheduleName: Code[10]; ColumnLayoutName: Code[10]; MeasureName: Text[111]; ChartType: Enum "Account Schedule Chart Type")
    var
        AccSchedChartSetupLine: Record "Acc. Sched. Chart Setup Line";
        Exists: Boolean;
    begin
        if AccSchedChartSetupLine.Get(UserID, Name, AccountScheduleLineNo, ColumnLayoutLineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccSchedChartSetupLine.Validate("User ID", UserID);
        AccSchedChartSetupLine.Validate(Name, Name);
        AccSchedChartSetupLine.Validate("Account Schedule Name", AccountScheduleName);
        AccSchedChartSetupLine.Validate("Column Layout Name", ColumnLayoutName);
        AccSchedChartSetupLine.Validate("Account Schedule Line No.", AccountScheduleLineNo);
        AccSchedChartSetupLine.Validate("Column Layout Line No.", ColumnLayoutLineNo);
        AccSchedChartSetupLine.Validate("Measure Name", MeasureName);
        AccSchedChartSetupLine.Validate("Measure Value", StrSubstNo('%1 %2', AccountScheduleLineNo, ColumnLayoutLineNo));
        AccSchedChartSetupLine.Validate("Chart Type", ChartType);

        if Exists then
            AccSchedChartSetupLine.Modify(true)
        else
            AccSchedChartSetupLine.Insert(true);
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; HideCurrencySymbol: Boolean)
    begin
        InsertColumnLayout(ColumnLayoutName, LineNo, ColumnNo, ColumnHeader, ColumnType, LedgerEntryType, Enum::"Account Schedule Amount Type"::"Net Amount", Formula, ShowOppositeSign, Show, ComparisonPeriodFormula, HideCurrencySymbol, 1033);
    end;

    procedure InsertColumnLayout(ColumnLayoutName: Code[10]; LineNo: Integer; ColumnNo: Code[10]; ColumnHeader: Text[30]; ColumnType: Enum "Column Layout Type"; LedgerEntryType: Enum "Column Layout Entry Type"; AmountType: Enum "Account Schedule Amount Type"; Formula: Code[80]; ShowOppositeSign: Boolean; Show: Enum "Column Layout Show"; ComparisonPeriodFormula: Code[20]; HideCurrencySymbol: Boolean; FormulaLCID: Integer)
    var
        ColumnLayout: Record "Column Layout";
        Exists: Boolean;
    begin
        if ColumnLayout.Get(ColumnLayoutName, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Column Type", ColumnType);
        ColumnLayout.Validate("Ledger Entry Type", LedgerEntryType);
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Validate(Formula, Formula);
        ColumnLayout.Validate("Show Opposite Sign", ShowOppositeSign);
        ColumnLayout.Validate(Show, Show);
        ColumnLayout.Validate("Comparison Period Formula LCID", FormulaLCID);
        ColumnLayout."Comparison Period Formula" := ComparisonPeriodFormula;
        ColumnLayout.Validate("Hide Currency Symbol", HideCurrencySymbol);

        if Exists then
            ColumnLayout.Modify(true)
        else
            ColumnLayout.Insert(true);
    end;

    procedure InsertFinancialReport(Name: Code[10]; Description: Text[80]; FinancialReportRowGrp: Code[10]; FinancialReportColumnGrp: Code[10])
    var
        FinancialReport: Record "Financial Report";
        Exists: Boolean;
    begin
        if FinancialReport.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FinancialReport.Validate(Name, Name);
        FinancialReport.Validate(Description, Description);
        FinancialReport.Validate("Financial Report Row Group", FinancialReportRowGrp);
        FinancialReport.Validate("Financial Report Column Group", FinancialReportColumnGrp);

        if Exists then
            FinancialReport.Modify(true)
        else
            FinancialReport.Insert(true);
    end;

    procedure InsertChartDefinition(Codeunit: Integer; ChartName: Text[60]; Enabled: Boolean)
    var
        ChartDefinition: Record "Chart Definition";
    begin
        if ChartDefinition.Get(Codeunit, ChartName) then
            exit;

        ChartDefinition.Validate("Code Unit ID", Codeunit);
        ChartDefinition.Validate("Chart Name", ChartName);
        ChartDefinition.Validate(Enabled, Enabled);

        ChartDefinition.Insert(true);
    end;
}
