tableextension 1959 "LPP Sales Header" extends "Sales Header"
{
    var
        PredictionDisabledErr: Label 'There must be an amount to make a prediction for.';

    procedure CheckAmountMoreThanZero();
    begin
        CalcFields(Amount);
        if Amount <= 0 then
            Error(PredictionDisabledErr);
    end;
}