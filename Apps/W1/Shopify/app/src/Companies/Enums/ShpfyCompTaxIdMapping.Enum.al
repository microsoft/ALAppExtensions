// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shopify Company Tax Id Mapping (ID 30166) implements Interface Shpfy Tax Registration Id Mapping.
/// </summary>
enum 30166 "Shpfy Comp. Tax Id Mapping" implements "Shpfy Tax Registration Id Mapping"
{
    Caption = 'Shopify Company Tax Id Mapping';
    Extensible = true;

    value(0; "Registration No.")
    {
        Caption = 'Registration No.';
        Implementation = "Shpfy Tax Registration Id Mapping" = "Shpfy Tax Registration No.";
    }
    value(1; "VAT Registration No.")
    {
        Caption = 'VAT Registration No.';
        Implementation = "Shpfy Tax Registration Id Mapping" = "Shpfy VAT Registration No.";
    }
}