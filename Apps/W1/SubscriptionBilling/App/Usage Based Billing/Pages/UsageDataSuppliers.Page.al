namespace Microsoft.SubscriptionBilling;

page 8044 "Usage Data Suppliers"
{
    ApplicationArea = All;
    SourceTable = "Usage Data Supplier";
    Caption = 'Usage Data Suppliers';
    UsageCategory = Lists;
    PageType = List;
    LinksAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the unique number of the usage data supplier.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a short description of the supplier of the usage data.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ToolTip = 'Specifies the vendor that belongs to the usage data supplier.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies how to process usage data and synchronize subscriptions.';
                }
                field("Unit Price from Import"; Rec."Unit Price from Import")
                {
                    ToolTip = 'Defines whether the sales price from the usage data should be used. If yes, the pricing is overridden on the basis of the service.';
                }
                field("Vendor Invoice per"; Rec."Vendor Invoice per")
                {
                    ToolTip = 'Specifies how vendor invoices are generated. You can choose between the generation of a collective invoice per import or an invoice per end customer.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Settings)
            {
                Caption = 'Settings';
                ToolTip = 'Opens the supplier settings relevant for Usage Data Import.';
                Image = Setup;
                Scope = repeater;
                trigger OnAction()
                begin
                    Rec.OpenSupplierSettings();
                end;
            }
            action(UsageDataImport)
            {
                Caption = 'Usage Data Imports';
                ToolTip = 'Opens the "Usage data imports" related to the supplier.';
                Image = PutawayLines;
                Scope = repeater;
                RunObject = page "Usage Data Imports";
                RunPageLink = "Supplier No." = field("No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Settings_Promoted; Settings)
                {
                }
                actionref(UsageDataImport_Promoted; UsageDataImport)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report';
            }
            group(Category_Category4)
            {
                Caption = 'Connectors';
            }
            group(Category_Category5)
            {
                Caption = 'API';
            }
        }
    }
}
