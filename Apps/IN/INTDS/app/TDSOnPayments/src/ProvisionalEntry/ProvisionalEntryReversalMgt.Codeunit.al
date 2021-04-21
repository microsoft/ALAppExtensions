codeunit 18772 "Provisional Entry Reversal Mgt"
{
    SingleInstance = true;
    Access = Internal;
    procedure SetReverseProvEntWithoutTDS(ReverseProvEntWOTDS: Boolean)
    begin
        ReverseProvEntWithoutTDS := ReverseProvEntWOTDS;
    end;

    procedure GetReverseProvEntWithoutTDS(): Boolean
    begin
        exit(ReverseProvEntWithoutTDS);
    end;

    var
        ReverseProvEntWithoutTDS: Boolean;
}