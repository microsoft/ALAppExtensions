// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 13735 "Create Deferral Template DK"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Deferral Template", OnDefineDeferralAccountNo, '', false, false)]
    local procedure OnDefineDeferralAccountNo(var DeferralAccountNo: Code[20])
    var
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        DeferralAccountNo := CreateGLAccDK.Deferrals();
    end;
}