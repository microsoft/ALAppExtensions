// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to format the appearance of decimal data types in fields of a table, report, or page.
/// </summary>
codeunit 45 "Auto Format"
{
    Access = Public;
    SingleInstance = true;

    var
        AutoFormatImpl: Codeunit "Auto Format Impl.";

    /// <summary>
    /// Formats the appearance of decimal data types.
    /// Use this method if you need to format decimals for text message in the same way how system formats decimals in fields.
    /// </summary>
    /// <param name="AutoFormatType">
    /// A value that determines how data is formatted.
    /// The values that are available are "0" and "11". 
    /// Use "0" to ignore the value that AutoFormatExpr passes and use the standard format for decimals instead.
    /// Use "11" to apply a specific format in AutoFormatExpr without additional transformation.
    /// </param>
    /// <seealso cref="OnResolveAutoFormat"/>
    /// <param name="AutoFormatExpr">An expression that specifies how to format data.</param>
    /// <returns>The resolved expression that defines data formatting</returns>
    procedure ResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]): Text[80]
    begin
        exit(AutoFormatImpl.ResolveAutoFormat(AutoFormatType, AutoFormatExpr));
    end;

    /// <summary>
    /// Gets the default rounding precision.
    /// </summary>
    /// <returns>Returns the rounding precision.</returns>
    procedure ReadRounding(): Decimal
    begin
        exit(AutoFormatImpl.ReadRounding());
    end;

    /// <summary>
    /// Integration event to resolve the ResolveAutoFormat procedure.
    /// </summary>
    /// <param name="AutoFormatType">A value that determines how data is formatted.</param>
    /// <param name="AutoFormatExpr">An expression that specifies how to format data.</param>
    /// <param name="Result">A resolved expression that defines how to format data.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnAfterResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; var Result: Text[80])
    begin
    end;

    /// <summary>
    /// Event that is called to resolve cases for AutoFormatTypes other that "0" and "11". 
    /// Subscribe to this event if you want to introduce new AutoFormatTypes.
    /// </summary>
    /// <param name="AutoFormatType">A value that determines how data is formatted.</param>
    /// <param name="AutoFormatExpr">An expression that specifies how to format data.</param>
    /// <param name="Result">
    /// The resolved expression that defines data formatting.
    /// For example '&lt;Precision,4:4&gt;&lt;Standard Format,2&gt; suffix' that depending on your regional settings 
    /// will format decimal into "-12345.6789 suffix" or "-12345,6789 suffix".
    /// </param>
    /// <param name="Resolved">A value that describes whether the data formatting expression is correct.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; var Result: Text[80]; var Resolved: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event to resolve the ReadRounding procedure.
    /// </summary>
    /// <param name="AmountRoundingPrecision">The decimal value precision.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnReadRounding(var AmountRoundingPrecision: Decimal)
    begin
    end;
}