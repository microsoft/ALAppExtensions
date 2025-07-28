// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30359 "Shpfy GQL TranslationsRegister" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { translationsRegister(resourceId: \"gid://shopify/{{ResourceType}}/{{ResourceId}}\", translations: [{{Translations}}]) { userErrors {field, message}}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(50);
    end;
}