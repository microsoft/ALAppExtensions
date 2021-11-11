page 20107 "AMC Bank Webcall Log"
{
    Caption = 'AMC Banking 365 Webservice Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Activity Log";
    SourceTableView = sorting(ID, "Activity Date") order(descending);
    UsageCategory = History;
    ApplicationArea = Basic, Suite;
    ContextSensitiveHelpPage = '302';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Context; Context)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the context in which the activity occurred.';
                }
                field("Activity Date"; "Activity Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the activity occurred.';
                }
                field(Status; "AMC Bank WebLog Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the activity.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SOAP Call';
                    ToolTip = 'Specifies the activity.';
                }
                field("Activity Message"; "Activity Message")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Message/Status';
                    ToolTip = 'Specifies the status or error message for the activity.';
                }
                field(HintTextFld; HintText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Hint text';
                    ToolTip = 'Specifies the hint text for the activity.';
                }
                field(SupportURLFld; SupportURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Support URL';
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the support URL for the activity.';

                    trigger OnDrillDown();
                    begin
                        HYPERLINK(SupportURL);
                    end;
                }
                field(HasDetailedInfoFld; HasDetailedInfo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detailed Info Available';
                    ToolTip = 'Specifies if detailed activity log details exist. If so, choose the View Details action.';

                    trigger OnDrillDown()
                    begin
                        AMCBankingMgt.ShowDetailedLogInfo(rec, Description + '.xml', TRUE);
                    end;

                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Delete7days)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete Entries Older Than 7 Days';
                Image = ClearLog;
                ToolTip = 'Clear the list of log entries that are older than 7 days.';

                trigger OnAction();
                begin
                    DeleteEntriesAMC(7);
                end;
            }
            action(Delete0days)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete All Entries';
                Image = ClearLog;
                ToolTip = 'Clear the list of all log entries.';

                trigger OnAction();
                begin
                    DeleteEntriesAMC(0);
                end;
            }
        }
    }

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";

    trigger OnOpenPage()
    begin
        if (FindFirst()) then;
    end;

    trigger OnAfterGetRecord();
    begin
        HasDetailedInfo := "Detailed Info".HASVALUE();
        GetSubActivity();
    end;

    var
        SubActivityLog: Record "Activity Log";
        HasDetailedInfo: Boolean;
        HintText: Text;
        SupportURL: Text;

    local procedure GetSubActivity();
    begin
        SubActivityLog.RESET();
        SubActivityLog.SETFILTER("Record ID", '%1', Rec.RECORDID());
        IF (SubActivityLog.FINDFIRST()) THEN BEGIN
            HintText := SubActivityLog.Description;
            SupportURL := SubActivityLog."Activity Message";
        END
        ELSE BEGIN
            HintText := '';
            SupportURL := '';
        END;
    end;

    procedure DeleteEntriesAMC(DaysOld: Integer);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ClearActivityLog: Record "Activity Log";
        ClearSubActivityLog: Record "Activity Log";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        SubRecordRef: RecordRef;
        DeleteLbl: Label 'Are you sure that you want to delete log activity entries?';
    begin
        IF NOT CONFIRM(DeleteLbl) THEN
            EXIT;

        AMCBankingSetup.GET();
        IF DataTypeManagement.GetRecordRef(AMCBankingSetup, RecordRef) THEN BEGIN
            ClearActivityLog.RESET();
            ClearActivityLog.SETRANGE(ClearActivityLog."Record ID", RecordRef.RECORDID());
            ClearActivityLog.SETFILTER(ClearActivityLog."Activity Date", '<=%1', CREATEDATETIME(TODAY() - DaysOld, TIME()));
            IF (ClearActivityLog.FINDSET()) THEN
                REPEAT
                    IF DataTypeManagement.GetRecordRef(ClearActivityLog, SubRecordRef) THEN BEGIN
                        ClearSubActivityLog.SETRANGE(ClearSubActivityLog."Record ID", SubRecordRef.RECORDID());
                        IF (ClearSubActivityLog.FINDSET()) THEN
                            REPEAT
                                ClearSubActivityLog.DELETE();
                            UNTIL ClearSubActivityLog.NEXT() = 0;
                    END;
                    ClearActivityLog.DELETE();
                UNTIL ClearActivityLog.NEXT() = 0;
        END;
        CurrPage.UPDATE();
    end;
}

