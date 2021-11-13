enumextension 89100 "Guest User Connector" extends "Email Connector"
{
    /// <summary>
    /// The Guest User connector.
    /// </summary>
    value(89100; "Guest User")
    {
        Caption = 'Guest User';
        Implementation = "Email Connector" = "Guest User Connector";
    }
}