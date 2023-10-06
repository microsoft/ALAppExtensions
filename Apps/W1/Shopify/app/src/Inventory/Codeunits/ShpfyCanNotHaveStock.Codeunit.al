namespace Microsoft.Integration.Shopify;

codeunit 30275 "Shpfy Can Not Have Stock" implements "Shpfy IStock Available"
{
    procedure CanHaveStock(): Boolean
    begin
        exit(false);
    end;
}