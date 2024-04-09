#if not CLEAN24
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Install Mgt. (ID 30105).
/// </summary>
codeunit 30105 "Shpfy Install Mgt."
{
    Access = Internal;
    Subtype = Install;
    ObsoleteReason = 'This codeunit is obsolete. Use Shpfy Installer instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    trigger OnInstallAppPerDatabase()
    begin
    end;
}
#endif