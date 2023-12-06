// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.Encryption;

using System.Security.AccessControl;

table 31132 "Certificate Code CZL"
{
    Caption = 'Certificate Code';
    DataPerCompany = false;
    DataCaptionFields = "Code", Description;
    LookupPageId = "Certificate Code List CZL";
    Permissions = tabledata "Isolated Certificate" = r;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    procedure FindValidCertificate(var IsolatedCertificate: Record "Isolated Certificate"): Boolean
    var
        User: Record User;
    begin
        if not User.Get(UserSecurityId()) then
            User.Init();
        exit(FindValidCertificate(IsolatedCertificate, User."User Name"));
    end;

    procedure FindValidCertificate(var IsolatedCertificate: Record "Isolated Certificate"; UserName: Code[50]): Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindValidCertificate(IsolatedCertificate, UserName, IsHandled);
        if IsHandled then
            exit;

        Clear(IsolatedCertificate);
        IsolatedCertificate.SetRange("Certificate Code CZL", Code);
        IsolatedCertificate.SetFilter("Expiry Date", '%1|>=%2', 0DT, CurrentDateTime);
        if IsolatedCertificate.IsEmpty() then
            exit(false);

        IsolatedCertificate.SetRange("Company ID", CompanyName);
        if UserName = '' then
            exit(IsolatedCertificate.FindFirst());

        IsolatedCertificate.SetRange("User ID", UserName);
        if IsolatedCertificate.FindFirst() then
            exit(true);

        IsolatedCertificate.SetRange("Company ID");
        if IsolatedCertificate.FindFirst() then
            exit(true);

        IsolatedCertificate.SetRange("User ID");
        IsolatedCertificate.SetRange("Company ID", CompanyName);
        exit(IsolatedCertificate.FindFirst());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindValidCertificate(var IsolatedCertificate: Record "Isolated Certificate"; UserName: Code[50]; var IsHandled: Boolean)
    begin
    end;
}
