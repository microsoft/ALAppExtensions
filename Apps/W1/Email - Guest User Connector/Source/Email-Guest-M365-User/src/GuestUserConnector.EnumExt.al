enumextension 89100 "LGS Guest User Connector" extends "Email Connector"
{
    /// <summary>
    /// The Guest User connector.
    /// </summary>
    value(89100; "LGS Guest User")
    {
        Caption = 'Guest User';
        Implementation = "Email Connector" = "LGS Guest User Connector";
    }
}