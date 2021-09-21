// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Used to mock email address entities.
/// </summary>
codeunit 134698 "Address Book Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Address Book", 'OnGetSuggestedAddresses', '', true, true)]
    local procedure GetSuggestedAddresses(SourceTableNo: Integer; SourceSystemID: Guid; var Address: Record Address)
    begin
        Address.Init();
        Address.Name := 'John Doe';
        Address."E-Mail Address" := 'johndoe@test.com';
        Address.Company := 'Cronos';
        Address."Source Name" := 'Customer';
        Address.SourceTable := 0;
        Address.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Address Book", 'OnGetEmailAddressEntity', '', true, true)]
    local procedure GetEmailAddressEntity(var AddressEntity: Record "Address Entity")
    begin
        AddressEntity.Init();
        AddressEntity."Source Name" := 'Contact';
        AddressEntity.SourceTable := 42;
        AddressEntity.Insert();
    end;

}