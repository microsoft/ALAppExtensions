#if not CLEAN26
namespace Microsoft.DataMigration.GP;

codeunit 4034 "GPForecastHandler"
{
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    ObsoleteReason = 'Forecast functionality is not used in this migration app.';

    [Obsolete('Forecast functionality is not used in this migration app.', '26.0')]
    procedure SetGPIVTrxAmountsHistFilters(var GPIVTrxAmountsHist: Record GPIVTrxAmountsHist; ItemNo: Code[20])
    begin
    end;
}
#endif