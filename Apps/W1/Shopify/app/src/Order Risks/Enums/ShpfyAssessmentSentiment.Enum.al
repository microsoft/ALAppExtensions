// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Assessment Sentiment (ID 30164).
/// </summary>
enum 30164 "Shpfy Assessment Sentiment"
{
    Caption = 'Shopify Assessment Sentiment';
    Extensible = false;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Negative)
    {
        Caption = 'Negative';
    }
    value(2; Neutral)
    {
        Caption = 'Neutral';
    }
    value(3; Positive)
    {
        Caption = 'Positive';
    }
}
