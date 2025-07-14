namespace Microsoft.Integration.Shopify;

interface "Shpfy Extended IDocument Source" extends "Shpfy IDocument Source"
{
    procedure SetErrorCallStack(SourceDocumentId: BigInteger; ErrorCallStack: Text)
}