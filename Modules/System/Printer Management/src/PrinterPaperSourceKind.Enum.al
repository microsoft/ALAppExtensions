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
    value(7; "AutomaticFeed")
    {
        Caption = 'Automatically fed paper.';
    }
    value(14; "Cassette")
    {
        Caption = 'A paper cassette.';
    }
    value(257; "Custom")
    {
        Caption = 'A printer-specific paper source.';
    }
    value(5; "Envelope")
    {
        Caption = 'An envelope.';
    }
    value(15; "FormSource")
    {
        Caption = 'The default input bin of printer.';
    }
    value(11; "LargeCapacity")
    {
        Caption = 'The large-capacity bin of printer.';
    }
    value(10; "LargeFormat")
    {
        Caption = 'Large-format paper.';
    }
    value(2; "Lower")
    {
        Caption = 'The lower bin of a printer.';
    }
    value(4; "Manual")
    {
        Caption = 'Manually fed paper.';
    }
    value(6; "ManualFeed")
    {
        Caption = 'Manually fed envelope.';
    }
    value(3; "Middle")
    {
        Caption = 'The middle bin of a printer.';
    }
    value(9; "SmallFormat")
    {
        Caption = 'Small-format paper.';
    }
    value(8; "TractorFeed")
    {
        Caption = 'A tractor feed.';
    }
    value(1; "Upper")
    {
        Caption = 'The upper bin of a printer.';
    }
}
