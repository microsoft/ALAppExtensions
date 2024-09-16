namespace Microsoft.SubscriptionBilling;

using System.Reflection;
using Microsoft.Inventory.Item;

codeunit 8018 TableAndFieldManagement
{
    Access = Internal;
    internal procedure FieldExists(SearchTableNo: Integer; SearchFieldNo: Integer): Boolean
    var
        AllFields: Record Field;
    begin
        AllFields.SetRange(TableNo, SearchTableNo);
        AllFields.SetRange("No.", SearchFieldNo);
        exit(not AllFields.IsEmpty());
    end;

    internal procedure FieldBooleanValue(RecVariant: Variant; FieldNo: Integer) FieldValue: Boolean
    begin
        RRef.GetTable(RecVariant);
        FRef := RRef.Field(FieldNo);
        FieldValue := FRef.Value;
    end;

    internal procedure ValidateItemFieldInItemTemplate(var ItemTemplate: Record "Item Templ."; FieldId: Integer)
    var
        ItemRecRef: RecordRef;
        ItemTemplRecRef: RecordRef;
        ItemFieldRef: FieldRef;
        ItemTemplFieldRef: FieldRef;
    begin
        ItemTemplRecRef.GetTable(ItemTemplate);
        ItemRecRef.Open(Database::Item, true);
        TransferFieldValues(ItemTemplRecRef, ItemRecRef, false, 3, ItemTemplRecRef.FieldCount());
        ItemRecRef.Insert(false);

        ItemFieldRef := ItemRecRef.Field(FieldId);
        ItemTemplFieldRef := ItemTemplRecRef.Field(FieldId);
        ItemFieldRef.Validate(ItemTemplFieldRef.Value);

        TransferFieldValues(ItemTemplRecRef, ItemRecRef, true, 3, ItemTemplRecRef.FieldCount());

        ItemTemplRecRef.SetTable(ItemTemplate);
        ItemTemplate.Modify(false);
    end;

    internal procedure TransferFieldValues(var SrcRecRef: RecordRef; var DestRecRef: RecordRef; Reverse: Boolean; StartFieldIndex: Integer; FieldCount: Integer)
    var
        SrcFieldRef: FieldRef;
        DestFieldRef: FieldRef;
        i: Integer;
    begin
        for i := StartFieldIndex to FieldCount do begin
            SrcFieldRef := SrcRecRef.FieldIndex(i);
            DestFieldRef := DestRecRef.Field(SrcFieldRef.Number);
            if not Reverse then
                DestFieldRef.Value := SrcFieldRef.Value
            else
                SrcFieldRef.Value := DestFieldRef.Value;
        end;
    end;

    var
        RRef: RecordRef;
        FRef: FieldRef;
}