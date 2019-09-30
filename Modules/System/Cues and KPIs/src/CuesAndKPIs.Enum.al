// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
enum 9701 "Cues And KPIs Style"
{
    Extensible = true;
    // The values are matching the original option field on the Cue Setup table
    // Values 1 to 6 were blank options so they could be extended
    value(0; None) { }
    value(7; Favorable) { }
    value(8; Unfavorable) { }
    value(9; Ambiguous) { }
    value(10; Subordinate) { }
}
