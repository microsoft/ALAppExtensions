page 40100 "GP Migration Progress"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GP Configuration";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(LastErrorMessage; "Last Error Message") { ApplicationArea = All; Tooltip = 'Last Error Message'; }
                field(PreMigrationCleanupCompleted; "PreMigration Cleanup Completed") { ApplicationArea = All; Tooltip = 'PreMigration Cleanup Completed'; }
                field(DimensionsCreated; "Dimensions Created") { ApplicationArea = All; Tooltip = 'Dimensions Created'; }
                field(PaymentTermsCreated; "Payment Terms Created") { ApplicationArea = All; Tooltip = 'Payment Terms Created'; }
                field(ItemTrackingCodesCreated; "Item Tracking Codes Created") { ApplicationArea = All; Tooltip = 'Item Tracking Codes Created'; }
                field(LocationsCreated; "Locations Created") { ApplicationArea = All; Tooltip = 'Locations Created'; }
                field(CheckBooksCreated; "CheckBooks Created") { ApplicationArea = All; Tooltip = 'CheckBooks Created'; }
                field(OpenPurchaseOrdersCreated; "Open Purchase Orders Created") { ApplicationArea = All; Tooltip = 'Open Purchase Orders Created'; }
            }
        }
    }
}