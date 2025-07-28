// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Assembly.Document;

/// <summary>
/// Codeunit Shpfy Suppress ASM Warning (ID 30210).
/// </summary>
codeunit 30220 "Shpfy Suppress Asm Warning"
{
    Access = Internal;
    //Set the event subscribers to manual binding;
    EventSubscriberInstance = Manual;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnBeforeShowAvailability', '', false, false)]
    local procedure BeforeShowAvailability(var TempAssemblyHeader: Record "Assembly Header" temporary; var TempAssemblyLine: Record "Assembly Line" temporary; ShowPageEvenIfEnoughComponentsAvailable: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}