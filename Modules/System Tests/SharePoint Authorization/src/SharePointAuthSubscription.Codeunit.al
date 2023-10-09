// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Sharepoint;

using System.Integration.Sharepoint;
using System.TestLibraries.Utilities;

codeunit 132976 "SharePoint Auth. Subscription"
{
    EventSubscriberInstance = Manual;

    var
        Any: Codeunit Any;
        ShouldFail: Boolean;
        ExpectedError: Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SharePoint Authorization Code", 'OnBeforeGetToken', '', false, false)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
        IsHandled := true;
        IsSuccess := not ShouldFail;
        if IsSuccess then
            AccessToken := Any.AlphanumericText(250)
        else
            ErrorText := ExpectedError;
    end;

    procedure SetParameters(NewShouldFail: Boolean; NewExpectedError: Text)
    begin
        ShouldFail := NewShouldFail;
        ExpectedError := NewExpectedError;
    end;
}