namespace Microsoft.Integration.Shopify;

codeunit 30313 "Shpfy Metafield Owner Company" implements "Shpfy IMetafield Owner Type"
{

    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Company");
    end;

    procedure RetrieveMetafieldIdsFromShopify(OwnerId: BigInteger): Dictionary of [BigInteger, DateTime]
    begin
        //not implemented yet
    end;

    procedure GetShopCode(OwnerId: BigInteger): Code[20]
    var
        Company: Record "Shpfy Company";
    begin
        Company.Get(OwnerId);
        exit(Company."Shop Code");
    end;

}
