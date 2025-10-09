interface "ZUGFeRD Report Integration"
{
    Access = Public;
    /// <summary>
    /// Binds the event subscriber for the ZUGFeRD report integration.
    /// </summary>
    procedure BindSubscriptionForReportIntegration()

    /// <summary>
    /// Unbinds the event subscriber for the ZUGFeRD report integration.
    /// </summary>
    procedure UnbindSubscriptionForReportIntegration()
}