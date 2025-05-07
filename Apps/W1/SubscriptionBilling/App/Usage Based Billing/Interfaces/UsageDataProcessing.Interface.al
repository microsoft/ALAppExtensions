namespace Microsoft.SubscriptionBilling;

interface "Usage Data Processing"
{
    Access = internal;
    /// <summary>
    /// Use it to specify how to import usage data into connector specific staging table whether by using Data Exchange Definition or by using APIs.
    /// </summary>
    /// <param name="UsageDataImport">Usage Data Import for which the import is executed</param>
    procedure ImportUsageData(var UsageDataImport: Record "Usage Data Import")

    /// <summary>
    /// Use it in order to process the records in connector specific staging table. Processing includes:
    /// 1. Checking if the quantity in the staging table is 0.
    /// 2. Creating Usage Data Customers if they do not exist.
    /// 3. Creating Usage Data Subscriptions if they do not exist.
    /// 4. Checking if Subscription Lines exist and if yes, check the dates.
    /// 5. If possible assigns the Subscription to the record in the staging table.
    /// </summary>
    /// <param name="UsageDataImport">Usage Data Import for which the process is executed</param>
    procedure ProcessUsageData(var UsageDataImport: Record "Usage Data Import")

    /// <summary>
    /// Use it to prevent the creation of Usage Data Billing records from the records in staging table that are marked with in an error.
    /// </summary>
    /// <param name="UsageDataImport">Usage Data Import for which the creation is executed</param>
    procedure TestUsageDataImport(var UsageDataImport: Record "Usage Data Import");

    /// <summary>
    /// Use it in order to find and process the records in connector specific staging table and create Usage Data Billing records.
    /// </summary>
    /// <param name="UsageDataImport">Usage Data Import for which the creation is executed</param>
    procedure FindAndProcessUsageDataImport(var UsageDataImport: Record "Usage Data Import");

    /// <summary>
    /// Use it to set an error for for import if the errors happened during the processing of the records in the staging table.
    /// </summary>
    /// <param name="UsageDataImport">Usage Data Import for which the creation is executed</param>
    procedure SetUsageDataImportError(var UsageDataImport: Record "Usage Data Import");
}
