// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

tableextension 6441 "SignUp E-Doc. Svc. Type Ext" extends "E-Doc. Service Supported Type"
{
    fields
    {
        field(6440; "Profile Id"; Integer)
        {
            Caption = 'Profile Id';
            ToolTip = 'Specifies the unique identifier for the metadata profile.';
            DataClassification = CustomerContent;
            TableRelation = "SignUp Metadata Profile";
            BlankZero = true;

            trigger OnValidate()
            begin
                Rec.CalcFields("Profile Name");
            end;
        }
        field(6441; "Profile Name"; Text[250])
        {
            Caption = 'Profile Name';
            ToolTip = 'Specifies the common name of the metadata profile.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("SignUp Metadata Profile"."Profile Name" where("Profile ID" = field("Profile Id")));
        }
    }
}