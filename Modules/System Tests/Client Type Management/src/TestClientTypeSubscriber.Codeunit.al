// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130018 "Test Client Type Subscriber"
{
    EventSubscriberInstance = Manual;

    var
        TestClientType: ClientType;

    [Scope('OnPrem')]
    procedure SetClientType(NewClientType: ClientType)
    begin
        TestClientType := NewClientType;
    end;

    [EventSubscriber(ObjectType::Codeunit, 4030, 'OnAfterGetCurrentClientType', '', false, false)]
    local procedure SetClientOnAfterGetCurrClientType(var CurrClientType: ClientType)
    begin
        CurrClientType := TestClientType;
    end;
}

