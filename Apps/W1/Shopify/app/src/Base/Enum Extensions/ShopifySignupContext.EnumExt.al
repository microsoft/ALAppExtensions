// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

/// <summary>
/// Extension Signup Context enum
/// </summary>
enumextension 30100 ShopifySignupContext extends "Signup Context"
{
    /// <summary>
    /// Value for the Shopify context. This value is defined in the signup URL and stored by Platform
    /// </summary>
    value(30100; Shopify)
    {
        Caption = 'Shopify';
    }
}