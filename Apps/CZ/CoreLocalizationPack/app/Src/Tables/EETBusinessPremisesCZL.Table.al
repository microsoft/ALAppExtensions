// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.Encryption;
using System.Utilities;

table 31126 "EET Business Premises CZL"
{
    Caption = 'EET Business Premises';
    LookupPageId = "EET Business Premises CZL";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(15; Identification; Code[6])
        {
            Caption = 'Identification';
            Numeric = true;
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(17; "Certificate Code"; Code[10])
        {
            Caption = 'Certificate Code';
            TableRelation = "Certificate Code CZL";
            DataClassification = OrganizationIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        EETEntryCZL: Record "EET Entry CZL";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        EntryExistsErr: Label 'You cannot delete %1 %2 because there is at least one EET entry.', Comment = '%1 = Table Caption;%2 = Primary Key';
        CashRegExistsQst: Label 'Do you really want to delete %1 %2, even if at least one cash register exists?', Comment = '%1 = Table Caption;%2 = Primary Key';
    begin
        EETEntryCZL.SetCurrentKey("Business Premises Code", "Cash Register Code");
        EETEntryCZL.SetRange("Business Premises Code", Code);
        if not EETEntryCZL.IsEmpty then
            Error(EntryExistsErr, TableCaption, Code);

        EETCashRegisterCZL.SetRange("Business Premises Code", Code);
        if not EETCashRegisterCZL.IsEmpty then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(CashRegExistsQst, TableCaption, Code), true) then
                EETCashRegisterCZL.DeleteAll(true);
    end;
}

