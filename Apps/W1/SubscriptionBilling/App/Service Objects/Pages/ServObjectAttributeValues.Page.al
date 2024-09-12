namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Attribute;

page 8011 "Serv. Object Attribute Values"
{
    Caption = 'Service Object Attribute Values';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Item Attribute Value Selection";
    SourceTableTemporary = true;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = Basic, Suite;
                    AssistEdit = false;
                    Caption = 'Attribute';
                    TableRelation = "Item Attribute".Name where(Blocked = const(false));
                    ToolTip = 'Specifies the service object attribute.';

                    trigger OnValidate()
                    var
                        ItemAttributeValue: Record "Item Attribute Value";
                        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                        ItemAttribute: Record "Item Attribute";
                    begin
                        OnBeforeCheckAttributeName(Rec, RelatedRecordCode);
                        if xRec."Attribute Name" <> '' then begin
                            xRec.FindItemAttributeByName(ItemAttribute);
                            DeleteItemAttributeValueMapping(ItemAttribute.ID);
                        end;

                        if not Rec.FindAttributeValue(ItemAttributeValue) then
                            Rec.InsertItemAttributeValue(ItemAttributeValue, Rec);

                        if ItemAttributeValue.Get(ItemAttributeValue."Attribute ID", ItemAttributeValue.ID) then begin
                            ItemAttributeValueMapping.Reset();
                            ItemAttributeValueMapping.Init();
                            ItemAttributeValueMapping."Table ID" := Database::"Service Object";
                            ItemAttributeValueMapping."No." := RelatedRecordCode;
                            ItemAttributeValueMapping."Item Attribute ID" := ItemAttributeValue."Attribute ID";
                            ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                            OnBeforeItemAttributeValueMappingInsert(ItemAttributeValueMapping, ItemAttributeValue, Rec);
                            ItemAttributeValueMapping.Insert(false);
                        end;
                    end;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Value';
                    TableRelation = if ("Attribute Type" = const(Option)) "Item Attribute Value".Value where("Attribute ID" = field("Attribute ID"),
                                                                                                            Blocked = const(false));
                    ToolTip = 'Specifies the value of the service object attribute.';

                    trigger OnValidate()
                    var
                        ItemAttributeValue: Record "Item Attribute Value";
                        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                        ItemAttribute: Record "Item Attribute";
                    begin
                        if not Rec.FindAttributeValue(ItemAttributeValue) then
                            Rec.InsertItemAttributeValue(ItemAttributeValue, Rec);

                        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
                        ItemAttributeValueMapping.SetRange("No.", RelatedRecordCode);
                        ItemAttributeValueMapping.SetRange("Item Attribute ID", ItemAttributeValue."Attribute ID");
                        if ItemAttributeValueMapping.FindFirst() then begin
                            ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
                            OnBeforeItemAttributeValueMappingModify(ItemAttributeValueMapping, ItemAttributeValue, RelatedRecordCode);
                            ItemAttributeValueMapping.Modify(false);
                            OnAfterItemAttributeValueMappingModify(ItemAttributeValueMapping, Rec);
                        end;

                        ItemAttribute.Get(Rec."Attribute ID");
                        if ItemAttribute.Type <> ItemAttribute.Type::Option then
                            if Rec.FindAttributeValueFromRecord(ItemAttributeValue, xRec) then
                                if not ItemAttributeValue.HasBeenUsed() then
                                    ItemAttributeValue.Delete(false);
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                }
                field(Primary; Rec.Primary)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the primary attribute. Only one attribute can be marked per Service Object.';

                    trigger OnValidate()
                    var
                        ItemAttributeValue: Record "Item Attribute Value";
                        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                    begin
                        CheckForDuplicatePrimary();

                        if not Rec.FindAttributeValue(ItemAttributeValue) then
                            Rec.InsertItemAttributeValue(ItemAttributeValue, Rec);

                        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
                        ItemAttributeValueMapping.SetRange("No.", RelatedRecordCode);
                        ItemAttributeValueMapping.SetRange("Item Attribute ID", ItemAttributeValue."Attribute ID");
                        if ItemAttributeValueMapping.FindFirst() then begin
                            ItemAttributeValueMapping.Primary := Rec.Primary;
                            ItemAttributeValueMapping.Modify(false);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        DeleteItemAttributeValueMapping(Rec."Attribute ID");
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable(true);
    end;

    var
        PrimaryAttributeAlreadySpecifiedErr: Label 'You have already specified ''%1'' as a Primary item attribute .', Comment = '%1 - attribute name';

    protected var
        RelatedRecordCode: Code[20];

    procedure LoadAttributes(ServiceObjectNo: Code[20])
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        TempItemAttributeValue: Record "Item Attribute Value" temporary;
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        RelatedRecordCode := ServiceObjectNo;
        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
        ItemAttributeValueMapping.SetRange("No.", ServiceObjectNo);
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                TempItemAttributeValue.TransferFields(ItemAttributeValue);
                TempItemAttributeValue.Primary := ItemAttributeValueMapping.Primary;
                OnLoadAttributesOnBeforeTempItemAttributeValueInsert(TempItemAttributeValue, ItemAttributeValueMapping, RelatedRecordCode);
                TempItemAttributeValue.Insert(false);
            until ItemAttributeValueMapping.Next() = 0;

        Rec.PopulateItemAttributeValueSelection(TempItemAttributeValue, Database::"Service Object", ServiceObjectNo);
    end;

    local procedure DeleteItemAttributeValueMapping(AttributeToDeleteID: Integer)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
    begin
        ItemAttributeValueMapping.SetRange("Table ID", Database::"Service Object");
        ItemAttributeValueMapping.SetRange("No.", RelatedRecordCode);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", AttributeToDeleteID);
        if ItemAttributeValueMapping.FindFirst() then begin
            ItemAttributeValueMapping.Delete(false);
            OnAfterItemAttributeValueMappingDelete(AttributeToDeleteID, RelatedRecordCode, Rec);
        end;

        ItemAttribute.Get(AttributeToDeleteID);
        ItemAttribute.RemoveUnusedArbitraryValues();
    end;

    local procedure CheckForDuplicatePrimary()
    var
        TempItemAttributeValueSelection: Record "Item Attribute Value Selection" temporary;
        ItemAttribute: Record "Item Attribute";
        AttributeName: Text[250];
    begin
        if Rec.IsEmpty() then
            exit;
        if not Rec.Primary then
            exit;

        AttributeName := LowerCase(Rec."Attribute Name");
        TempItemAttributeValueSelection.Copy(Rec, true);
        TempItemAttributeValueSelection.SetFilter("Attribute Name", '<>%1', Rec."Attribute Name");
        TempItemAttributeValueSelection.SetRange(Primary, true);
        if not TempItemAttributeValueSelection.IsEmpty() then begin
            TempItemAttributeValueSelection.FindFirst();
            ItemAttribute.Get(TempItemAttributeValueSelection."Attribute ID");
            Error(PrimaryAttributeAlreadySpecifiedErr, ItemAttribute.GetNameInCurrentLanguage());
        end;
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterItemAttributeValueMappingDelete(AttributeToDeleteID: Integer; RelatedRecordCode: Code[20]; ItemAttributeValueSelection: Record "Item Attribute Value Selection")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterItemAttributeValueMappingModify(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ItemAttributeValueSelection: Record "Item Attribute Value Selection")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeItemAttributeValueMappingInsert(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ItemAttributeValue: Record "Item Attribute Value"; ItemAttributeValueSelection: Record "Item Attribute Value Selection")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeItemAttributeValueMappingModify(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ItemAttributeValue: Record "Item Attribute Value"; RelatedRecordCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnLoadAttributesOnBeforeTempItemAttributeValueInsert(var TempItemAttributeValue: Record "Item Attribute Value" temporary; ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; RelatedRecordCode: Code[20])
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCheckAttributeName(var ItemAttributeValueSelection: Record "Item Attribute Value Selection"; RelatedRecordCode: Code[20])
    begin
    end;
}

