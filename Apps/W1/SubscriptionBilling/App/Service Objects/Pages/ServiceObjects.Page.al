namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item.Attribute;

page 8059 "Service Objects"
{
    ApplicationArea = All;
    Caption = 'Service Objects';
    PageType = List;
    SourceTable = "Service Object";
    UsageCategory = Lists;
    Editable = false;
    QueryCategory = 'Service Object List';
    RefreshOnActivate = true;
    CardPageId = "Service Object";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the service object.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the service object.';
                }
                field(Quantity; Rec."Quantity Decimal")
                {
                    ToolTip = 'Number of units of service object.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the Serial No. assigned to the service object.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the Variant Code of the service object.';
                    Visible = false;
                }
                field("End-User Customer Name"; Rec."End-User Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer to whom the service was sold.';
                }
                field("Customer Reference"; Rec."Customer Reference")
                {
                    ToolTip = 'Specifies the reference by which the customer identifies the service object.';
                    Visible = false;
                    Editable = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(ServiceObjectAttrFactbox; "Service Object Attr. Factbox")
            {
                ApplicationArea = Basic, Suite;
            }
            part(ItemAttributesFactbox; "Item Attributes Factbox")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Service Object"),
                              "No." = field("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Attributes)
            {
                AccessByPermission = tabledata "Item Attribute" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Attributes';
                Image = Category;
                Scope = Repeater;
                ToolTip = 'Displays the attributes of the Service Object that describe it in more detail.';

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Serv. Object Attr. Values", Rec);
                    CurrPage.SaveRecord();
                    CurrPage.ServiceObjectAttrFactbox.Page.LoadServiceObjectAttributesData(Rec."No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.ServiceObjectAttrFactbox.Page.LoadServiceObjectAttributesData(Rec."No.");
        CurrPage.ItemAttributesFactbox.Page.LoadItemAttributesData(Rec."Item No.");
    end;
}
