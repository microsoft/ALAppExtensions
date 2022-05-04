/// <summary>
/// Codeunit Shpfy Base64 (ID 30155).
/// </summary>
codeunit 30155 "Shpfy Base64"
{
    Access = Internal;

    internal procedure IsBase64String(Data: Text): Boolean
    var
        RegEx: Codeunit Regex;
    begin
        exit(RegEx.IsMatch(Data, '^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$'));
    end;
}