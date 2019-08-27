// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130018 "Test Client Type Subscriber"
{
    EventSubscriberInstance = Manual;

    var
        TestClientType: ClientType;

    /// <summary>
    /// Sets the client type that will be returned from the GetCurrentClientType function when the subscription is bound.
    /// Uses <see cref="OnAfterGetCurrentClientType"/> event.
    /// </summary>
    /// <param name="NewClientType">The client type that will be returned from GetCurrentClientType.</param>
    [Scope('OnPrem')]
    procedure SetClientType(NewClientType: ClientType)
    begin
        TestClientType := NewClientType;
    end;

    /// <summary>
    /// Overwrite the current client type.
    /// </summary>
    /// <param name="CurrClientType">Current client type as returned from CurrentClientType platform function.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Client Type Mgt. Impl.", 'OnAfterGetCurrentClientType', '', false, false)]
    local procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
        CurrClientType := TestClientType;
    end;
}

