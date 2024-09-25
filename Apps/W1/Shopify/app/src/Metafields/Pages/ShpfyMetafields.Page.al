namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Metafields (ID 30163).
/// </summary>
page 30163 "Shpfy Metafields"
{
    Caption = 'Shopify Metafields';
    Extensible = false;
    PageType = List;
    SourceTable = "Shpfy Metafield";
    UsageCategory = None;
    ApplicationArea = All;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Metafields)
            {
                Editable = IsPageEditable;

                field(Namespace; Rec.Namespace)
                {
                    ToolTip = 'Specifies the namespace of the metafield.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of value for the metafield.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the key of the metafield.';
                }
                field(Value; Rec.Value)
                {
                    ToolTip = 'Specifies the value of the metafield.';
                    Editable = IsValueEditable;

                    trigger OnAssistEdit()
                    var
                        IMetafieldType: Interface "Shpfy IMetafield Type";
                    begin
                        IMetafieldType := Rec.Type;

                        if IMetafieldType.HasAssistEdit() then
                            if IMetafieldType.AssistEdit(Rec.Value) then
                                Rec.Validate(Value);
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Evaluate(Rec."Parent Table No.", Rec.GetFilter("Parent Table No."));
        Rec.Validate("Parent Table No.");
        Evaluate(Rec."Owner Id", Rec.GetFilter("Owner Id"));
        Rec.Validate(Type, Rec.Type::single_line_text_field);
    end;

    trigger OnAfterGetCurrRecord()
    var
        IMetafieldType: Interface "Shpfy IMetafield Type";
    begin
        IMetafieldType := Rec.Type;
        IsValueEditable := not IMetafieldType.HasAssistEdit();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField(Namespace);
        Rec.TestField(Name);
        Rec.Validate(Value);

        Rec.Id := SendMetafieldToShopify();
    end;

    var
        Shop: Record "Shpfy Shop";
        IsPageEditable: Boolean;
        IsValueEditable: Boolean;

    /// <summary>
    /// Opens the page displaying metafields for the specified resource.
    /// </summary>
    /// <param name="ParentTableId">Table id of the resource.</param>
    /// <param name="OwnerId">System Id of the resource.</param>
    internal procedure RunForResource(ParentTableId: Integer; OwnerId: BigInteger; ShopCode: Code[20])
    var
        Metafield: Record "Shpfy Metafield";
    begin
        Shop.Get(ShopCode);
        IsPageEditable := (Shop."Sync Item" = Shop."Sync Item"::"To Shopify") and (Shop."Can Update Shopify Products");

        Metafield.SetRange("Parent Table No.", ParentTableId);
        Metafield.SetRange("Owner Id", OwnerId);

        CurrPage.SetTableView(Metafield);
        CurrPage.RunModal();
    end;

    local procedure SendMetafieldToShopify(): BigInteger
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        UserErrorOnShopifyErr: Label 'Something went wrong while sending the metafield to Shopify. Check Shopify Log Entries for more details.';
        GraphQuery: TextBuilder;
        JResponse: JsonToken;
        JMetafields: JsonArray;
        JUserErrors: JsonArray;
        JItem: JsonToken;
    begin
        ShpfyCommunicationMgt.SetShop(Shop);

        MetafieldAPI.CreateMetafieldQuery(Rec, GraphQuery);
        JResponse := MetafieldAPI.UpdateMetafields(GraphQuery.ToText());

        JsonHelper.GetJsonArray(JResponse, JUserErrors, 'data.metafieldsSet.userErrors');

        if JUserErrors.Count() = 0 then begin
            JsonHelper.GetJsonArray(JResponse, JMetafields, 'data.metafieldsSet.metafields');
            JMetafields.Get(0, JItem);
            exit(JsonHelper.GetValueAsBigInteger(JItem, 'legacyResourceId'));
        end else
            Error(UserErrorOnShopifyErr);
    end;
}