report 27030 "Create DIOT Report"
{
    UsageCategory = Administration;
    Caption = 'Create DIOT Report';
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Report Dates")
                {
                    field(StartingDate; StartingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Starting Date for the report';
                    }
                    field(EndingDate; EndingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Ending Date for the report';

                        trigger OnValidate()
                        begin
                            if EndingDate < StartingDate then
                                Error(EndingDateBeforeStartinDateErr);
                        end;
                    }
                }
            }
        }
    }

    var
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        StartingDate: Date;
        EndingDate: Date;
        BlankStartingDateErr: Label 'Please provide a starting date.';
        BlankEndingDateErr: Label 'Please provide an ending date.';
        EndingDateBeforeStartinDateErr: Label 'Ending date cannot be before starting date.';
        RunAssistedSetupMsg: Label 'You must complete Assisted Setup for DIOT before running this report. \\ Do you want to open assisted setup now?';

    trigger OnInitReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not DIOTDataMgmt.GetAssistedSetupComplete() then begin
            if ConfirmManagement.GetResponseOrDefault(RunAssistedSetupMsg, true) then
                Page.Run(Page::"DIOT Setup Wizard");
            CurrReport.Quit();
        end;
    end;

    trigger OnPreReport()
    begin
        if StartingDate = 0D then
            Error(BlankStartingDateErr);
        if EndingDate = 0D then
            Error(BlankEndingDateErr);
    end;

    trigger OnPostReport()
    begin
        DIOTDataMgmt.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, StartingDate, EndingDate);
        if TempErrorMessage.HasErrors(false) then
            TempErrorMessage.ShowErrors()
        else
            DIOTDataMgmt.WriteDIOTFile(TempDIOTReportBuffer, TempDIOTReportVendorBuffer);
    end;

}