#if not CLEAN21
Codeunit 31085 "Feature Advance Payments CZZ" implements "Feature Data Update"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteReason = 'AdvancePaymentsLocalizationForCzech removed from Feature Management.';
    ObsoleteTag = '21.0';

    procedure IsDataUpdateRequired(): Boolean;
    begin
        exit(false);
    end;

    procedure ReviewData();
    begin
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
    end;
}
#endif
