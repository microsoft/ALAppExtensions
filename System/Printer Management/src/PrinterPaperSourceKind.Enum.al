// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Standard paper sources.
/// </summary>
enum 2617 "Printer Paper Source Kind"
{
    Extensible = false;

    /// <summary>
    /// Automatically fed paper.
    /// </summary>
    value(7; "AutomaticFeed")
    {
        Caption = 'Automatically fed paper.';
    }

    /// <summary>
    /// A paper cassette.
    /// </summary>
    value(14; "Cassette")
    {
        Caption = 'A paper cassette.';
    }

    /// <summary>
    /// A printer-specific paper source.
    /// </summary>
    value(257; "Custom")
    {
        Caption = 'A printer-specific paper source.';
    }

    /// <summary>
    /// An envelope.
    /// </summary>
    value(5; "Envelope")
    {
        Caption = 'An envelope.';
    }

    /// <summary>
    /// The default input bin of printer.
    /// </summary>
    value(15; "FormSource")
    {
        Caption = 'The default input bin of printer.';
    }

    /// <summary>
    /// The large-capacity bin of printer.
    /// </summary>
    value(11; "LargeCapacity")
    {
        Caption = 'The large-capacity bin of printer.';
    }

    /// <summary>
    /// Large-format paper.
    /// </summary>
    value(10; "LargeFormat")
    {
        Caption = 'Large-format paper.';
    }

    /// <summary>
    /// The lower bin of a printer.
    /// </summary>
    value(2; "Lower")
    {
        Caption = 'The lower bin of a printer.';
    }

    /// <summary>
    /// Manually fed paper.
    /// </summary>
    value(4; "Manual")
    {
        Caption = 'Manually fed paper.';
    }

    /// <summary>
    /// Manually fed envelope.
    /// </summary>
    value(6; "ManualFeed")
    {
        Caption = 'Manually fed envelope.';
    }

    /// <summary>
    /// The middle bin of a printer.
    /// </summary>
    value(3; "Middle")
    {
        Caption = 'The middle bin of a printer.';
    }

    /// <summary>
    /// Small-format paper.
    /// </summary>
    value(9; "SmallFormat")
    {
        Caption = 'Small-format paper.';
    }

    /// <summary>
    /// A tractor feed.
    /// </summary>
    value(8; "TractorFeed")
    {
        Caption = 'A tractor feed.';
    }

    /// <summary>
    /// The upper bin of a printer.
    /// </summary>
    value(1; "Upper")
    {
        Caption = 'The upper bin of a printer.';
    }
}
