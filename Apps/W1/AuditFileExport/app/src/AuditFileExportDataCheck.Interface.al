interface "Audit File Export Data Check"
{
    /// <summary>
    /// Checks all records and fields that will be used for exporting of the selected audit file export document to the corresponding audit file export format.
    /// </summary>
    /// <param name="AuditFileExportHeader">Audit file export document.</param>
    /// <returns>The status of the data check - Passed or Failed.</returns>
    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"

    /// <summary>
    /// Checks if the selected audit file export document is ready for exporting, for example if all required fields are filled.
    /// </summary>
    /// <param name="AuditFileExportHeader">Audit file export document.</param>
    /// <returns>The status of the data check - Passed or Failed.</returns>
    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
}