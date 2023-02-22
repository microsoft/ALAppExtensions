interface "BCPT Test Param. Provider"
{
    procedure GetDefaultParameters(): Text[1000];

    procedure ValidateParameters(Params: Text[1000]);
}