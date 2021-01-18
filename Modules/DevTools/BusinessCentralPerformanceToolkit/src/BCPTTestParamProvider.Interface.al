interface "BCPT Test Param. Provider"
{
    procedure GetDefaultParameters(): Text[1000];
    procedure GetDefaultParameters(BCPTLine: Record "BCPT Line"): Text[1000];

    procedure ValidateParameters(Params: Text[1000]);
    procedure ValidateParameters(BCPTLine: Record "BCPT Line"; Params: Text[1000]);
}