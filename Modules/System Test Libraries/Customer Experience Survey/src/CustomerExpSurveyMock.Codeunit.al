// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Feedback;

using System.Feedback;

codeunit 132100 "Customer Exp. Survey Mock"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Exp. Survey Impl.", 'OnTryGetIsEurope', '', false, false)]
    local procedure HandleOnTryGetIsEurope(var Result: Boolean; var IsHandled: Boolean)
    begin
        Result := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Exp. Survey Impl.", 'OnIsSaas', '', false, false)]
    local procedure HandleOnIsSaas(var Result: Boolean; var IsHandled: Boolean)
    begin
        Result := true;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Exp. Survey Impl.", 'OnIsPPE', '', false, false)]
    local procedure HandlOnIsPPE(var Result: Boolean; var IsHandled: Boolean)
    begin
        Result := true;
        IsHandled := true;
    end;
}