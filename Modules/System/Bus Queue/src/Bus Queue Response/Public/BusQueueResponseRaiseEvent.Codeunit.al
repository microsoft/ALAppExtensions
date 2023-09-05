/// <summary>
/// Codeunit that allows to handle the response of a Bus Queue Response
/// </summary>
codeunit 51753 "Bus Queue Response Raise Event"
{
    Access = Public;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Allows to read the response of a Bus Queue Response
    /// </summary>
    [BusinessEvent(false, false)]
    internal procedure OnAfterInsertBusQueueResponse(BusQueueResponse: Codeunit "Bus Queue Response")
    begin
    end;
}