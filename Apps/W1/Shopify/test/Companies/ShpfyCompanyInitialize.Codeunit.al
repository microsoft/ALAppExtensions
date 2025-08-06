// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 139638 "Shpfy Company Initialize"
{
    SingleInstance = true;

    var
        Any: Codeunit Any;

    internal procedure CreateShopifyCompanyLocation() CompanyLocation: Record "Shpfy Company Location"
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        CreateShopifyCompany(ShopifyCompany);
        exit(CreateShopifyCompanyLocation(ShopifyCompany));
    end;

    internal procedure CreateShopifyCompanyLocation(ShopifyCompany: Record "Shpfy Company") CompanyLocation: Record "Shpfy Company Location"
    begin
        CompanyLocation.DeleteAll();
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(1, 99999);
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation.Name := 'Address';
        CompanyLocation.Address := 'Address';
        CompanyLocation."Address 2" := 'Address 2';
        CompanyLocation."Phone No." := '111';
        CompanyLocation.Zip := '1111';
        CompanyLocation.City := 'City';
        CompanyLocation."Country/Region Code" := 'US';
        CompanyLocation.Recipient := 'Recipient';
        CompanyLocation.Insert();
    end;

    internal procedure CreateShopifyCompany(var ShopifyCompany: Record "Shpfy Company"): BigInteger
    var
        CompanyId: BigInteger;
    begin
        ShopifyCompany.DeleteAll();
        CompanyId := Any.IntegerInRange(1000, 99999);
        ShopifyCompany.Init();
        ShopifyCompany.Id := CompanyId;
        ShopifyCompany.Name := 'Name';
        ShopifyCompany.Insert();
        exit(CompanyId);
    end;

    internal procedure ModifyFields(RecVariant: variant): Variant
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        Index: Integer;
    begin
        RecordRef.GetTable(RecVariant);
        for Index := 1 to RecordRef.FieldCount do begin
            FieldRef := RecordRef.FieldIndex(Index);
            if FieldRef.Class = FieldRef.Class::Normal then
                if FieldRef.Type = FieldRef.Type::Text then
                    if Format(FieldRef.Value) <> '' then
                        FieldRef.Value := CopyStr('!' + Format(FieldRef.Value), 1, FieldRef.Length);
        end;
        RecordRef.SetTable(RecVariant);
        exit(RecVariant);
    end;

    internal procedure CreateCompanyGraphQLResult(): Text
    var
        ResInStream: InStream;
        Body: Text;
    begin
        NavApp.GetResource('Companies/CompanyCreateRequest.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        exit(Body);
    end;

    internal procedure CreateGraphQueryUpdateCompanyResult(CompanyId: BigInteger): Text
    var
        ResInStream: InStream;
        Body: Text;
    begin
        NavApp.GetResource('Companies/CompanyUpdateRequest.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        exit(StrSubstNo(Body, CompanyId));
    end;

    internal procedure CreateGraphQueryUpdateCompanyLocationResult(CompanyLocationId: BigInteger): Text
    var
        ResInStream: InStream;
        Body: Text;
    begin
        NavApp.GetResource('Companies/CompanyLocationUpdateRequest.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        exit(StrSubstNo(Body, CompanyLocationId));
    end;

    internal procedure CompanyMainContactResponse(Id: BigInteger; FirstName: Text; LastName: Text; Email: Text; PhoneNo: Text): JsonObject
    var
        JResult: JsonObject;
        ResInStream: InStream;
        Body: Text;
    begin
        NavApp.GetResource('Companies/CompanyMainContactResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        JResult.ReadFrom(StrSubstNo(Body, Id, FirstName, LastName, Email, PhoneNo));
        exit(JResult);
    end;

    internal procedure CompanyResponse(Name: Text; ExternalId: Text; CompanyContactId: BigInteger; CustomerId: BigInteger): JsonObject
    var
        JResult: JsonObject;
        ResInStream: InStream;
        Body: Text;
    begin
        NavApp.GetResource('Companies/CompanyResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        JResult.ReadFrom(StrSubstNo(Body, Name, ExternalId, CompanyContactId, CustomerId));
        exit(JResult);
    end;

    internal procedure PaymentTermsGQLNode(): Text
    begin
        exit('buyerExperienceConfiguration: {paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/%1\"}');
    end;

    internal procedure CreateLocationResponse(LocationValues: Dictionary of [Text, Text]): Text
    var
        JObject: JsonObject;
        JCompanyLocations: JsonObject;
        JEdges: JsonArray;
        JNode: JsonObject;
        JBillingAddress: JsonObject;
        JPaymentTerms: JsonObject;
        LocationResponse: Text;
        CompanyLocationIdLbl: Label 'gid://shopify/CompanyLocation/%1', Comment = 'companyLocationId', Locked = true;
        PaymentTermsTemplateIdLbl: Label '{"paymentTermsTemplate": {id: "gid://shopify/PaymentTermsTemplate/%1"}}', Comment = 'paymentTermsTemplateId', Locked = true;
    begin
        JNode.Add('id', StrSubstNo(CompanyLocationIdLbl, LocationValues.Get('id')));
        JBillingAddress.Add('address1', LocationValues.Get('address1'));
        JBillingAddress.Add('address2', LocationValues.Get('address2'));
        JBillingAddress.Add('city', LocationValues.Get('city'));
        JBillingAddress.Add('countryCode', LocationValues.Get('countryCode'));
        JBillingAddress.Add('zip', LocationValues.Get('zip'));
        JBillingAddress.Add('phone', LocationValues.Get('phone'));
        JBillingAddress.Add('zoneCode', LocationValues.Get('zoneCode'));
        JBillingAddress.Add('province', LocationValues.Get('province'));
        JNode.Add('billingAddress', JBillingAddress);
        JNode.Add('taxRegistrationId', LocationValues.Get('taxRegistrationId'));
        JPaymentTerms.ReadFrom(StrSubstNo(PaymentTermsTemplateIdLbl, LocationValues.Get('paymentTermsTemplateId')));
        JNode.Add('buyerExperienceConfiguration', JPaymentTerms);
        JEdges.Add(JNode);
        JCompanyLocations.Add('edges', JEdges);
        JObject.Add('companyLocations', JCompanyLocations);
        JObject.WriteTo(LocationResponse);
        exit(LocationResponse);
    end;

    internal procedure TaxIdGQLNode(CompanyLocation: Record "Shpfy Company Location"): Text
    var
        CompanyLocationIdLbl: Label 'locationId: \"gid://shopify/CompanyLocation/%1\", taxId: \"%2\"', Comment = '%1 - locationId, %2 - taxId', Locked = true;
    begin
        exit(StrSubstNo(CompanyLocationIdLbl, CompanyLocation.Id, CompanyLocation."Tax Registration Id"));
    end;

    internal procedure ExternalIdGQLNode(Customer: Record Customer): Text
    var
        ExternalIdLbl: Label 'externalId: \"%1\"', Comment = 'externalId', Locked = true;
    begin
        exit(StrSubstNo(ExternalIdLbl, Customer."No."));
    end;
}