// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20374 "Sales Invoice Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Sales Invoice Header" = r;

    procedure IsOnboarded(): Boolean
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 5;

        exit(PostedSalesInvoice.Count() >= OnboardingThreshold);
    end;
}
