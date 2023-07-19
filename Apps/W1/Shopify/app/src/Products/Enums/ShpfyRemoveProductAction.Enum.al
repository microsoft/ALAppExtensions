/// <summary>
/// Enum Shpfy Remove Product Action (ID 30131) implements Interface Shpfy IRemoveProductAction.
/// </summary>
enum 30131 "Shpfy Remove Product Action" implements "Shpfy IRemoveProductAction"
{
    Caption = 'Shopify Remove Product Action';
    Extensible = false;

    value(0; DoNothing)
    {
        Caption = ' ';
        Implementation = "Shpfy IRemoveProductAction" = "Shpfy RemoveProductDoNothing";
    }
    value(1; StatusToArchived)
    {
        Caption = 'Status to Archived';
        Implementation = "Shpfy IRemoveProductAction" = "Shpfy ToArchivedProduct";
    }
    value(2; StatusToDraft)
    {
        Caption = 'Status to Draft';
        Implementation = "Shpfy IRemoveProductAction" = "Shpfy ToDraftProduct";
    }

}
