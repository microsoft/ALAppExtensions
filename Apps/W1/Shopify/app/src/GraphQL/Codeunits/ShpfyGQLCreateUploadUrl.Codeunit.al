namespace Microsoft.Integration.Shopify;

codeunit 30218 "Shpfy GQL CreateUploadUrl" implements "Shpfy IGraphQL"
{
    Access = Internal;

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetGraphQL(): Text
    begin
        exit('{"query": "mutation { stagedUploadsCreate(input: {filename: \"{{Filename}}\", mimeType: \"{{MimeType}}\", resource: {{Resource}}, httpMethod: {{HttpMethod}}}) { stagedTargets { url resourceUrl parameters { name value } }}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetExpectedCost(): Integer
    begin
        exit(11);
    end;
}