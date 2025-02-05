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
                        if not IsPageEditable then
                            exit;

                        IMetafieldType := Rec.Type;

                        if IMetafieldType.HasAssistEdit() then
                            if IMetafieldType.AssistEdit(Rec.Value) then
                                Rec.Validate(Value);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetMetafieldDefinitions)
            {
                ApplicationArea = All;
                Caption = 'Get Metafield Definitions';
                Image = Import;
                ToolTip = 'Retrieve metafield definitions from Shopify.';
                Visible = IsPageEditable;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MetafieldAPI: Codeunit "Shpfy Metafield API";
                    ParentTableNo: Integer;
                    OwnerId: BigInteger;
                begin
                    Evaluate(ParentTableNo, Rec.GetFilter("Parent Table No."));
                    Evaluate(OwnerId, Rec.GetFilter("Owner Id"));
                    MetafieldAPI.SetShop(Shop);
                    MetafieldAPI.GetMetafieldDefinitions(ParentTableNo, OwnerId);
                end;
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

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Id < 0 then
            if xRec.Value <> Rec.Value then
                Rec.Rename(SendMetafieldToShopify());
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
        IMetafieldOwnerType: Interface "Shpfy IMetafield Owner Type";
    begin
        Shop.Get(ShopCode);

        IMetafieldOwnerType := Metafield.GetOwnerType(ParentTableId);
        IsPageEditable := IMetafieldOwnerType.CanEditMetafields(Shop);

        Metafield.SetRange("Parent Table No.", ParentTableId);
        Metafield.SetRange("Owner Id", OwnerId);

        CurrPage.SetTableView(Metafield);
        CurrPage.RunModal();
    end;

    local procedure SendMetafieldToShopify(): BigInteger
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        UserErrorOnShopifyErr: Label 'Something went wrong while sending the metafield to Shopify. Check Shopify Log Entries for more details.';
        GraphQuery: TextBuilder;
        JResponse: JsonToken;
        JMetafields: JsonArray;
        JUserErrors: JsonArray;
        JItem: JsonToken;
    begin
        MetafieldAPI.SetShop(Shop);
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