namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Setup;

/// <summary>
/// Table Shpfy Metafield (ID 30101).
/// </summary>
table 30101 "Shpfy Metafield"
{
    Caption = 'Shopify Metafield';
    DataClassification = CustomerContent;
    DrillDownPageId = "Shpfy Metafields";
    LookupPageId = "Shpfy Metafields";

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
#pragma warning disable AS0086 // false positive on extending the field length on internal table
        field(2; Namespace; Text[255])
        {
            Caption = 'Namespace';
            DataClassification = SystemMetadata;
        }
#pragma warning restore AS0086

        field(3; "Owner Resource"; Text[50])
        {
            Caption = 'Owner Resource';
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteReason = 'Owner Resource is obsolete. Use Owner Type instead.';
            ObsoleteTag = '25.0';

            trigger OnValidate()
            begin
                case "Owner Resource" of
                    'Customer':
                        Validate("Owner Type", "Owner Type"::Customer);
                    'Product':
                        Validate("Owner Type", "Owner Type"::Product);
                    'Variant':
                        Validate("Owner Type", "Owner Type"::ProductVariant);
                end;
            end;
        }

        field(4; "Owner Id"; BigInteger)
        {
            Caption = 'Owner Id';
            DataClassification = SystemMetadata;
        }

#pragma warning disable AS0086 // false positive on extending the field length on internal table
        field(5; Name; Text[64])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
#pragma warning restore AS0086

        field(6; "Value Type"; Enum "Shpfy Metafield Value Type")
        {
            Caption = 'Value Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Value Type is obsolete in Shopify API. Use Type instead.';
            ObsoleteTag = '25.0';
        }

#pragma warning disable AS0086 // false positive on extending the field length on internal table
        field(7; Value; Text[2048])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ValueNotValidErr: Label 'The value is not valid for the type. Example value: ';
                IMetafieldType: Interface "Shpfy IMetafield Type";
            begin
                IMetafieldType := Rec.Type;
                if not IMetafieldType.IsValidValue(Value) then
                    Error(ErrorInfo.Create(ValueNotValidErr + IMetafieldType.GetExampleValue()));

                if Rec.Type = Rec.Type::money then
                    CheckShopCurrency(Value);
            end;
        }
#pragma warning restore AS0086
        field(8; Type; Enum "Shpfy Metafield Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

#if not CLEAN26
            trigger OnValidate()
            begin
                if Type = Type::string then
                    Error(StringTypeErr, Format(Type), Format(Type::single_line_text_field));
                if Type = Type::integer then
                    Error(StringTypeErr, Format(Type), Format(Type::number_integer));
            end;
#endif
        }
        field(9; "Last Updated by BC"; DateTime)
        {
            Caption = 'Last Updated by BC';
            DataClassification = SystemMetadata;
        }
        field(10; "Owner Type"; Enum "Shpfy Metafield Owner Type")
        {
            Caption = 'Owner Type';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                IMetafieldOwnerType: Interface "Shpfy IMetafield Owner Type";
            begin
                IMetafieldOwnerType := Rec."Owner Type";
                "Parent Table No." := IMetafieldOwnerType.GetTableId();
            end;
        }

        field(101; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Owner Type" := GetOwnerType("Parent Table No.");
            end;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Idx1; "Parent Table No.", "Owner Id")
        {
        }
    }

    trigger OnInsert()
    var
        Metafield: Record "Shpfy Metafield";
    begin
        if Namespace = '' then
            Namespace := 'Microsoft.Dynamics365.BusinessCentral';
        if Id = 0 then
            if Metafield.FindFirst() and (Metafield.Id < 0) then
                Id := Metafield.Id - 1
            else
                Id := -1;
    end;

    trigger OnModify()
    begin
        "Last Updated by BC" := CurrentDateTime;
    end;

#if not CLEAN26
    var
        StringTypeErr: Label 'The type %1 is obsolete. Use %2 instead.', Comment = '%1 - Type, %2 - Type';
#endif

    /// <summary>
    /// Get the owner type based on the resources's owner table number.
    /// </summary>
    /// <param name="ParentTableNo">The owning resource table number.</param>
    internal procedure GetOwnerType(ParentTableNo: Integer): Enum "Shpfy Metafield Owner Type"
    begin
        case ParentTableNo of
            Database::"Shpfy Customer":
                exit("Owner Type"::Customer);
            Database::"Shpfy Product":
                exit("Owner Type"::Product);
            Database::"Shpfy Variant":
                exit("Owner Type"::ProductVariant);
        end;
    end;

    /// <summary>
    /// Returns the name of the enum value for the owner type. Used when the full owner resource id needs to be built.
    /// </summary>
    /// <returns>The name of the owner type.</returns>
    internal procedure GetOwnerTypeName(): Text
    begin
        exit("Owner Type".Names().Get("Owner Type".Ordinals().IndexOf("Owner Type".AsInteger())));
    end;

    local procedure CheckShopCurrency(MetafieldValue: Text[2048])
    var
        ShpfyMtfldTypeMoney: Codeunit "Shpfy Mtfld Type Money";
        CurrencyCode: Code[10];
        ShopCurrencyCode: Code[10];
        Amount: Decimal;
        CurrencyCodeMismatchErr: Label 'The currency code must match the shop currency code. Shop currency code: %1', Comment = '%1 - Shop currency code';
    begin
        ShopCurrencyCode := GetShopCurrencyCode();

        ShpfyMtfldTypeMoney.TryExtractValues(MetafieldValue, Amount, CurrencyCode);
        if CurrencyCode <> ShopCurrencyCode then
            Error(ErrorInfo.Create(StrSubstNo(CurrencyCodeMismatchErr, ShopCurrencyCode)));
    end;

    local procedure GetShopCurrencyCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Shop: Record "Shpfy Shop";
        IMetafieldOwnerType: Interface "Shpfy IMetafield Owner Type";
    begin
        IMetafieldOwnerType := Rec."Owner Type";
        Shop.Get(IMetafieldOwnerType.GetShopCode(Rec."Owner Id"));

        if Shop."Currency Code" <> '' then
            exit(Shop."Currency Code")
        else begin
            GeneralLedgerSetup.Get();
            exit(GeneralLedgerSetup."LCY Code");
        end;
    end;
}