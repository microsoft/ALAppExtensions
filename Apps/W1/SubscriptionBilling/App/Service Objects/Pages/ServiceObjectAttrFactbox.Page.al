namespace Microsoft.SubscriptionBilling;

using System.Environment;
using Microsoft.Inventory.Item.Attribute;

page 8012 "Service Object Attr. Factbox"
{
    Caption = 'Service Object Attributes';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Item Attribute Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Attribute; Rec.GetAttributeNameInCurrentLanguage())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attribute';
                    ToolTip = 'Specifies the name of the service object attribute.';
                    Visible = TranslatedValuesVisible;
                }
                field(Value; Rec.GetValueInCurrentLanguage())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of the service object attribute.';
                    Visible = TranslatedValuesVisible;
                }
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attribute';
                    ToolTip = 'Specifies the name of the service object attribute.';
                    Visible = not TranslatedValuesVisible;
                }
                field(RawValue; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of the service object attribute.';
                    Visible = not TranslatedValuesVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Edit)
            {
                AccessByPermission = tabledata "Item Attribute" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Edit';
                Image = Edit;
                ToolTip = 'Edit the Service Object''s attributes that describe it in more detail.';

                trigger OnAction()
                var
                    ServiceObject: Record "Service Object";
                begin
                    if not ServiceObject.Get(ServiceObjectNo) then
                        exit;
                    Page.RunModal(Page::"Serv. Object Attr. Values", ServiceObject);
                    CurrPage.SaveRecord();
                    LoadServiceObjectAttributesData(ServiceObjectNo);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Attribute Name");
        TranslatedValuesVisible := ClientTypeManagement.GetCurrentClientType() <> ClientType::Phone;
        if ServiceObjectNo <> '' then
            LoadServiceObjectAttributesData(ServiceObjectNo);
    end;

    var
        ClientTypeManagement: Codeunit "Client Type Management";
        ServiceObjectNo: Code[20];

    protected var
        TranslatedValuesVisible: Boolean;

    procedure LoadServiceObjectAttributesData(KeyValue: Code[20])
    begin
        ServiceObjectNo := KeyValue;
        LoadServiceObjectAttributesFactBoxData(KeyValue);
        CurrPage.Update(false);
    end;

    procedure LoadServiceObjectAttributesFactBoxData(KeyValue: Code[20])
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
        ItemAttributeValueMapping.SetRange("No.", KeyValue);
        if ItemAttributeValueMapping.FindSet() then
            repeat
                if ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID") then begin
                    Rec.TransferFields(ItemAttributeValue);
                    OnLoadItemAttributesFactBoxDataOnBeforeInsert(ItemAttributeValueMapping, Rec);
                    Rec.Insert(false);
                end
            until ItemAttributeValueMapping.Next() = 0;
    end;

    [InternalEvent(false, false)]
    local procedure OnLoadItemAttributesFactBoxDataOnBeforeInsert(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; var ItemAttributeValue: Record "Item Attribute Value")
    begin
    end;
}

