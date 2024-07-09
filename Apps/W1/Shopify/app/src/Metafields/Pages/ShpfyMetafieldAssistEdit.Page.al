namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.Currency;

page 30164 "Shpfy Metafield Assist Edit"
{
    Caption = 'Metafield Assist Edit';
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(MoneyGroup)
            {
                Visible = IsMoneyVisible;
                ShowCaption = false;

                field(MoneyValue; MoneyValue)
                {
                    Caption = 'Value';
                    ToolTip = 'Enter the amount.';
                }
                field(MoneyCurrency; MoneyCurrency)
                {
                    Caption = 'Currency';
                    ToolTip = 'Enter the currency code.';
                    TableRelation = Currency;
                }
            }
            group(DimensionGroup)
            {
                Visible = IsDimensionVisible;
                ShowCaption = false;

                field(DimensionValue; DimensionValue)
                {
                    Caption = 'Value';
                    ToolTip = 'Enter the value.';
                }
                field(DimensionUnit; DimensionUnit)
                {
                    Caption = 'Unit';
                    ToolTip = 'Enter the unit of measure.';
                }
            }
            group(VolumeGroup)
            {
                Visible = IsVolumeVisible;
                ShowCaption = false;

                field(VolumeValue; VolumeValue)
                {
                    Caption = 'Value';
                    ToolTip = 'Enter the value.';
                }
                field(VolumeUnit; VolumeUnit)
                {
                    Caption = 'Unit';
                    ToolTip = 'Enter the unit of measure.';
                }
            }
            group(WeightGroup)
            {
                Visible = IsWeightVisible;
                ShowCaption = false;

                field(WeightValue; WeightValue)
                {
                    Caption = 'Value';
                    ToolTip = 'Enter the value.';
                }
                field(WeightUnit; WeightUnit)
                {
                    Caption = 'Unit';
                    ToolTip = 'Enter the unit of measure.';
                }
            }
            group(MultiLineTextGroup)
            {
                Visible = IsMultiLineTextVisible;
                ShowCaption = false;

                field(MultiLineText; MultiLineText)
                {
                    Caption = 'Text';
                    ToolTip = 'Enter the text.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;

                    trigger OnValidate()
                    var
                        TextTooLongErr: Label 'The text is too long. The maximum length is 2048 characters.';
                    begin
                        if StrLen(MultiLineText) > 2048 then
                            Error(ErrorInfo.Create(TextTooLongErr));
                    end;
                }
            }
        }
    }

    #region Money
    var
        IsMoneyVisible: Boolean;
        MoneyValue: Decimal;
        MoneyCurrency: Code[10];

    /// <summary>
    /// Opens the page for assisting with input of money values.
    /// </summary>
    /// <param name="Amount">The amount to preset on the page.</param>
    /// <param name="CurrencyCode">The currency code to preset on the page.</param>
    /// <returns>True if the user clicks OK; otherwise, false.</returns>
    internal procedure OpenForMoney(Amount: Decimal; CurrencyCode: Code[10]): Boolean
    begin
        IsMoneyVisible := true;
        MoneyValue := Amount;
        MoneyCurrency := CurrencyCode;

        exit(CurrPage.RunModal() = Action::OK);
    end;

    /// <summary>
    /// Gets the money value and currency code.
    /// </summary>
    /// <param name="Amount">Return value: The money value.</param>
    /// <param name="Currency">Return value: The currency code.</param>
    internal procedure GetMoneyValue(var Amount: Decimal; var Currency: Code[10])
    begin
        Amount := MoneyValue;
        Currency := MoneyCurrency;
    end;
    #endregion

    #region Dimension
    var
        IsDimensionVisible: Boolean;
        DimensionValue: Decimal;
        DimensionUnit: Enum "Shpfy Metafield Dimension Type";

    /// <summary>
    /// Opens the page for assisting with input of dimension values.
    /// </summary>
    /// <param name="Dimension">The dimension to preset on the page.</param>
    /// <param name="Unit">The unit of measure to preset on the page.</param>
    /// <returns>True if the user clicks OK; otherwise, false.</returns>
    internal procedure OpenForDimension(Dimension: Decimal; Unit: Enum "Shpfy Metafield Dimension Type"): Boolean
    begin
        IsDimensionVisible := true;
        DimensionValue := Dimension;
        DimensionUnit := Unit;

        exit(CurrPage.RunModal() = Action::OK);
    end;

    /// <summary>
    /// Gets the dimension value and unit of measure.
    /// </summary>
    /// <param name="Value">Return value: The dimension value.</param>
    /// <param name="Unit">Return value: The unit of measure.</param>
    internal procedure GetDimensionValue(var Value: Decimal; var Unit: Enum "Shpfy Metafield Dimension Type")
    begin
        Value := DimensionValue;
        Unit := DimensionUnit;
    end;
    #endregion

    #region Volume
    var
        IsVolumeVisible: Boolean;
        VolumeValue: Decimal;
        VolumeUnit: Enum "Shpfy Metafield Volume Type";

    /// <summary>
    /// Opens the page for assisting with input of volume values.
    /// </summary>
    /// <param name="Volume">The volume to preset on the page.</param>
    /// <param name="Unit">The unit of measure to preset on the page.</param>
    /// <returns>True if the user clicks OK; otherwise, false.</returns>
    internal procedure OpenForVolume(Volume: Decimal; Unit: Enum "Shpfy Metafield Volume Type"): Boolean
    begin
        IsVolumeVisible := true;
        VolumeValue := Volume;
        VolumeUnit := Unit;

        exit(CurrPage.RunModal() = Action::OK);
    end;

    /// <summary>
    /// Gets the volume value and unit of measure.
    /// </summary>
    /// <param name="Volume">Return value: The volume value.</param>
    /// <param name="Unit">Return value: The unit of measure.</param>
    internal procedure GetVolumeValue(var Volume: Decimal; var Unit: Enum "Shpfy Metafield Volume Type")
    begin
        Volume := VolumeValue;
        Unit := VolumeUnit;
    end;
    #endregion

    #region Weight
    var
        IsWeightVisible: Boolean;
        WeightValue: Decimal;
        WeightUnit: Enum "Shpfy Metafield Weight Type";

    /// <summary>
    /// Opens the page for assisting with input of weight values.
    /// </summary>
    /// <param name="Weight">The weight to preset on the page.</param>
    /// <param name="Unit">The unit of measure to preset on the page.</param>
    /// <returns>True if the user clicks OK; otherwise, false.</returns>
    internal procedure OpenForWeight(Weight: Decimal; Unit: Enum "Shpfy Metafield Weight Type"): Boolean
    begin
        IsWeightVisible := true;
        WeightValue := Weight;
        WeightUnit := Unit;

        exit(CurrPage.RunModal() = Action::OK);
    end;

    /// <summary>
    /// Gets the weight value and unit of measure.
    /// </summary>
    /// <param name="Value">Return value: The weight value.</param>
    /// <param name="Unit">Return value: The unit of measure.</param>
    internal procedure GetWeightValue(var Value: Decimal; var Unit: Enum "Shpfy Metafield Weight Type")
    begin
        Value := WeightValue;
        Unit := WeightUnit;
    end;
    #endregion

    #region MultiLineText
    var
        IsMultiLineTextVisible: Boolean;
        MultiLineText: Text;

    /// <summary>
    /// Opens the page for assisting with input of multi-line text.
    /// </summary>
    /// <param name="Text">The text to preset on the page.</param>
    /// <returns>True if the user clicks OK; otherwise, false.</returns>
    internal procedure OpenForMultiLineText(Text: Text[2048]): Boolean
    begin
        IsMultiLineTextVisible := true;
        MultiLineText := Text;

        exit(CurrPage.RunModal() = Action::OK);
    end;

    /// <summary>
    /// Gets the multi-line text.
    /// </summary>
    /// <param name="Text">Return value: The multi-line text.</param>
    internal procedure GetMultiLineText(var Text: Text[2048])
    begin
        Text := CopyStr(MultiLineText, 1, MaxStrLen(Text));
    end;
    #endregion
}