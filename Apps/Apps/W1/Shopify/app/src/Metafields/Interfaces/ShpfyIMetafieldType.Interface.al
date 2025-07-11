namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface used for validating and editing values of a Shopify Metafield.
/// </summary>
interface "Shpfy IMetafield Type"
{
    Access = Internal;

    /// <summary>
    /// Determines if Type defines an Assist Edit dialog.
    /// </summary>
    /// <returns>True if Type defines an Assist Edit dialog, otherwise false.</returns>
    procedure HasAssistEdit(): Boolean

    /// <summary>
    /// Determines if provided value is valid for Type.
    /// </summary>
    /// <param name="Value">Value to validate.</param>
    /// <returns>True if value is valid, otherwise False.</returns>
    procedure IsValidValue(Value: Text): Boolean

    /// <summary>
    /// Opens a dialog to assist in editing the value.
    /// </summary>
    /// <param name="Value">Value to edit. Value may be modified.</param>
    /// <returns>True if value was edited, otherwise False.</returns>
    procedure AssistEdit(var Value: Text[2048]): Boolean

    /// <summary>
    /// Returns an example value for the Type.
    /// </summary>
    /// <returns>Example value.</returns>
    procedure GetExampleValue(): Text
}