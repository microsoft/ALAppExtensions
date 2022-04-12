/// <summary>
/// Enum Shpfy Remove Product Action (ID 30131) implements Interface Shpfy IRemoveProductAction.
/// </summary>
enum 30131 "Shpfy Remove Product Action" implements "Shpfy IRemoveProductAction"
{
    Access = Internal;
    Caption = 'Shopify Remove Product Action';
    Extensible = true;
    DefaultImplementation = "Shpfy IRemoveProductAction" = "Shpfy RemoveProductDoNothing";

    value(0; DoNothing)
    {
        Caption = ' ';
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
