// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.EMail;

tableextension 10042 "IRS 1099 Vendor" extends Vendor
{

    fields
    {
        field(10030; "Receiving 1099 E-Form Consent"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IRS1099VendorEmail.CheckEmailForIRS(Rec);
                IRS1099VendorEmail.PropagateReceiving1099EFormConsentToFormDocuments(Rec);
            end;
        }
        field(10031; "FATCA Requirement"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10032; "E-Mail For IRS"; Text[80])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                IRS1099VendorEmail.ClearConsentForEmptyEmail(Rec);
                if "E-Mail For IRS" <> '' then
                    MailManagement.CheckValidEmailAddresses("E-Mail For IRS");
                IRS1099VendorEmail.PropagateEmailToFormDocuments(Rec);
            end;
        }
#pragma warning disable AA0232
        field(10033; "IRS Reporting Period"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = max("IRS 1099 Vendor Form Box Setup"."Period No." where("Vendor No." = field("No.")));
            Editable = false;
        }
#pragma warning restore AA0232
        field(10034; "IRS 1099 Form No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = max("IRS 1099 Vendor Form Box Setup"."Form No." where("Vendor No." = field("No.")));
            Editable = false;
        }
        field(10035; "IRS 1099 Form Box No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = max("IRS 1099 Vendor Form Box Setup"."Form Box No." where("Vendor No." = field("No.")));
            Editable = false;
        }
        modify("E-Mail")
        {
            trigger OnAfterValidate()
            begin
                IRS1099VendorEmail.ClearConsentForEmptyEmail(Rec);
                IRS1099VendorEmail.PropagateEmailToFormDocuments(Rec);
            end;
        }
    }

    var
        IRS1099VendorEmail: Codeunit "IRS 1099 Vendor Email";

}
