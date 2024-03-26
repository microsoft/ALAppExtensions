namespace Microsoft.Integration.Shopify;

codeunit 30333 "Shpfy Metafield Owner Customer" implements "Shpfy IMetafield Owner Type"
{
    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Customer");
    end;

    procedure RetrieveMetafieldIdsFromShopify(OwnerId: BigInteger): Dictionary of [BigInteger, DateTime]
    begin
        Error('Not implemented');
    end;

    procedure GetShopCode(OwnerId: BigInteger): Code[20]
    begin
        exit('Not implemented');
    end;
}