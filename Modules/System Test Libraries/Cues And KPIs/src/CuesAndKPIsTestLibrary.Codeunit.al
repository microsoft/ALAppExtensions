codeunit 135058 "Cues And KPIs Test Library"
{
    procedure DeleteAllSetup()
    var
        CueSetup: Record "Cue Setup";
    begin
        CueSetup.DeleteAll();
    end;
}