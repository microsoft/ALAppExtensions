// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 139634 "Shpfy Mock Bulk ProductCreate" implements "Shpfy IBulk Operation"
{
    Access = Internal;

    var
        NameLbl: Label 'Product create';

    procedure GetGraphQL(): Text
    begin
        exit('mutation call($input: ProductInput!) { productCreate(input: $input) { product {id title variants(first: 10) {edges {node {id title inventoryQuantity }}}} userErrors { message field }}}');
    end;

    procedure GetInput(): Text
    begin
        exit('{ "input": { "title": "%1", "productType": "%2", "vendor": "%3" } }');
    end;

    procedure GetName(): Text[250]
    begin
        exit(NameLbl);
    end;

    procedure GetType(): Text
    begin
        exit('mutation');
    end;

    procedure RevertFailedRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    begin
        exit;
    end;

    procedure RevertAllRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    begin
        exit;
    end;
}