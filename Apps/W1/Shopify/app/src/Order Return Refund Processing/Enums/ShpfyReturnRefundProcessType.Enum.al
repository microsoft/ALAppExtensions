namespace Microsoft.Integration.Shopify;

enum 30139 "Shpfy ReturnRefund ProcessType" implements "Shpfy IReturnRefund Process"
{
    Extensible = true;
    DefaultImplementation = "Shpfy IReturnRefund Process" = "Shpfy RetRefProc Default";

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Import Only")
    {
        Caption = 'Import Only';
        Implementation = "Shpfy IReturnRefund Process" = "Shpfy RetRefProc ImportOnly";
    }
    value(3; "Auto Create Credit Memo")
    {
        Caption = 'Auto Create Credit Memo';
        Implementation = "Shpfy IReturnRefund Process" = "Shpfy RetRefProc Cr.Memo";
    }
}