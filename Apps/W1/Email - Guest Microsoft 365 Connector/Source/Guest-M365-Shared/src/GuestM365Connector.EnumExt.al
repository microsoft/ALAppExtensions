enumextension 89200 "LGS Guest M365 Connector" extends "Email Connector"
{
    /// <summary>
    /// The Guest User connector.
    /// </summary>
    value(89200; "LGS Guest Microsoft 365")
    {
        Caption = 'Guest Microsoft 365';
        Implementation = "Email Connector" = "LGS Guest M365 Connector";
    }
}