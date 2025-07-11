#if not CLEAN26
namespace Microsoft.Payroll.Ceridian;

codeunit 1665 "MS Ceridian Payroll upgrade"
{
    Subtype = Upgrade;
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    ObsoleteReason = 'No upgrade code left.';

    trigger OnUpgradePerCompany()
    begin

    end;
}
#endif
