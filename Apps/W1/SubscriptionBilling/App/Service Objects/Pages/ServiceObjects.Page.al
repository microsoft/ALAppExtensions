namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item.Attribute;

page 8059 "Service Objects"
{
    ApplicationArea = All;
    Caption = 'Subscriptions';
    PageType = List;
    SourceTable = "Subscription Header";
    UsageCategory = Lists;
    Editable = false;
    QueryCategory = 'Subscriptions';
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
                    ToolTip = 'Specifies the number of Subscription.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the Subscription.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the No. of the Item or G/L Account of the Subscription.';
                }
                field("Created in Contract line"; Rec."Created in Contract line")
                {
                    ToolTip = 'Specifies whether the Subscription was created by creating a Contract line manually.';
                    Visible = false;
                }
#if not CLEAN26
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. of the Subscription.';
                    ObsoleteReason = 'Replaced by field Source No.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                    Visible = false;
                }
#endif
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of Subscription.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the Serial No. assigned to the Subscription.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the Variant Code of the Subscription.';
                    Visible = false;
                }
                field("End-User Customer Name"; Rec."End-User Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer to whom the Subscription Line was sold.';
                }
                field("Customer Reference"; Rec."Customer Reference")
                {
                    ToolTip = 'Specifies the reference by which the customer identifies the Subscription.';
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
                Visible = Rec.Type = Rec.Type::Item;
            }
            part(ItemAttributesFactbox; "Item Attributes Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = Rec.Type = Rec.Type::Item;
            }
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Subscription Header"),
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
                ToolTip = 'Displays the attributes of the Subscription that describe it in more detail.';
                Enabled = Rec.Type = Rec.Type::Item;

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
        if Rec.IsItem() then begin
            CurrPage.ServiceObjectAttrFactbox.Page.LoadServiceObjectAttributesData(Rec."No.");
            CurrPage.ItemAttributesFactbox.Page.LoadItemAttributesData(Rec."Source No.");
        end;
    end;
}
