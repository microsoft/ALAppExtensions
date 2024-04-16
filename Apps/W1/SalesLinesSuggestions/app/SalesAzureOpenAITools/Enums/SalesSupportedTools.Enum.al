// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

enum 7278 "Sales Supported Tools" implements SalesAzureOpenAITools
{
    Access = Internal;
    Extensible = false;

    value(0; magic_function)
    {
        Implementation = SalesAzureOpenAITools = "Magic Function";
    }
    value(1; search_items)
    {
        Implementation = SalesAzureOpenAITools = "Search Items Function";
    }
    value(2; lookup_from_document)
    {
        Implementation = SalesAzureOpenAITools = "Document Lookup Function";
    }
}