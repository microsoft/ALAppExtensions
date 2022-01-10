// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Used to mock email address entities.
/// </summary>
codeunit 134698 "Email Address Lookup Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Address Lookup", 'OnGetSuggestedAddresses', '', true, true)]
    local procedure GetSuggestedAddresses(TableId: Integer; SystemId: Guid; var Address: Record "Email Address Lookup")
    begin
        if not Address.Get('johndoe@test.com', 'John Doe', Enum::"Email Address Entity"::User) then begin
            Address.Init();
            Address.Name := 'John Doe';
            Address."E-Mail Address" := 'johndoe@test.com';
            Address.Company := 'XYZ';
            Address."Source Table Number" := 1;
            Address."Source System Id" := CreateGuid();
            Address."Entity type" := Enum::"Email Address Entity"::User;
            Address.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Address Lookup", 'OnLookupAddressFromEntity', '', true, true)]
    local procedure GetEmailAddressEntity(Entity: Enum "Email Address Entity"; var Address: Record "Email Address Lookup"; var IsHandled: Boolean)
    begin
        if not Address.Get('john@test.com', 'John Doe', Enum::"Email Address Entity"::User) then begin
            Address.Init();
            Address.Name := 'John Doe';
            Address."E-Mail Address" := 'john@test.com';
            Address.Company := 'XYZ';
            Address."Source Table Number" := 0;
            Address."Source System Id" := CreateGuid();
            Address."Entity type" := Enum::"Email Address Entity"::User;
            Address.Insert();

            IsHandled := Entity = Enum::"Email Address Entity"::User;
        end;
    end;

}