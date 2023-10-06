// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Azure.ActiveDirectory;

using System.TestLibraries.Mocking;
using System;
using System.Azure.Identity;

codeunit 132922 "Azure AD Graph Test Library"
{
    EventSubscriberInstance = Manual;

    var
        MockGraphQuery: DotNet MockGraphQuery;

    procedure SetMockGraphQuery(MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library")
    begin
        MockGraphQueryTestLibrary.GetMockGraphQuery(MockGraphQuery);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph Impl.", 'OnInitialize', '', false, false)]
    local procedure OnGraphInitialization(var GraphQuery: DotNet GraphQuery; var Handled: Boolean)
    begin
        GraphQuery := GraphQuery.GraphQuery(MockGraphQuery);
        Handled := true;
    end;
}