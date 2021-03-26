tableextension 31033 "FA Setup CZL" extends "FA Setup"
{
    procedure IsFAAcquisitionAsCustom2CZL(): Boolean
    var
        FAAcquisitionAsCustom2: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnIsFAAcquisitionAsCustom2CZL(FAAcquisitionAsCustom2, IsHandled);
        if IsHandled then
            exit(FAAcquisitionAsCustom2);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsFAAcquisitionAsCustom2CZL(var FAAcquisitionAsCustom2: Boolean; var IsHandled: Boolean)
    begin
    end;
}