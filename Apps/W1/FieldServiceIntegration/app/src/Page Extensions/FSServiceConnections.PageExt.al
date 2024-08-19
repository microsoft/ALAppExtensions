// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Utilities;

pageextension 6622 "FS Service Connections" extends "Service Connections"
{
    trigger OnOpenPage()
    var
        FSAssistedSetupSubscriber: Codeunit "FS Assisted Setup Subscriber";
    begin
        FSAssistedSetupSubscriber.RegisterAssistedSetup();
    end;
}