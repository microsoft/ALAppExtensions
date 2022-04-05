/// <summary>
/// Codeunit Shpfy Math (ID 30158).
/// </summary>
codeunit 30158 "Shpfy Math"
{
    Access = Internal;
    SingleInstance = true;


    /// <summary> 
    /// Max.
    /// </summary>
    /// <param name="X">Parameter of type DateTime.</param>
    /// <param name="Y">Parameter of type DateTime.</param>
    /// <returns>Return value of type DateTime.</returns>
    internal procedure Max(X: DateTime; Y: DateTime): DateTime
    begin
        if X < Y then
            exit(Y);
        exit(X);
    end;

    /// <summary> 
    /// Min.
    /// </summary>
    /// <param name="X">Parameter of type BigInteger.</param>
    /// <param name="Y">Parameter of type BigInteger.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure Min(X: BigInteger; Y: BigInteger): BigInteger
    begin
        if X < Y then
            exit(X);
        exit(Y);
    end;
}