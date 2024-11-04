// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10062 "IRS 1099 Documents API"
{
    APIPublisher = 'microsoft';
    APIGroup = 'irsForms';
    APIVersion = 'v1.0';
    EntityCaption = 'IRS 1099 Document';
    EntitySetCaption = 'IRS 1099 Documents';
    PageType = API;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    EntityName = 'irs1099document';
    EntitySetName = 'irs1099documents';
    ODataKeyFields = SystemId;
    SourceTable = "IRS 1099 Form Doc. Header";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field(vendorName; Rec."Vendor Name")
                {
                    Caption = 'Vendor Name';
                }
                field(docId; Rec.Id)
                {
                    Caption = 'Id';
                }
                field(formNo; Rec."Form No.")
                {
                    Caption = 'Form No.';
                }
                field(receivingConsent; Rec."Receiving 1099 E-Form Consent")
                {
                    Caption = 'Receiving 1099 E-Form Consent';
                }
                field(vendorEmail; Rec."Vendor E-Mail")
                {
                    Caption = 'Vendor E-Mail';
                }
                part(irs1099documentlines; "IRS 1099 Doc. Line API")
                {
                    SubPageLink = "Document ID" = field(ID), "Period No." = field("Period No."), "Vendor No." = field("Vendor No."), "Form No." = field("Form No.");
                    EntityName = 'irs1099documentline';
                    EntitySetName = 'irs1099documentlines';
                    Caption = 'IRS 1099 Document Lines';
                }
                part(irs1099formreports; "IRS 1099 Form Reports API")
                {
                    SubPageLink = "Document ID" = field(ID), "Report Type" = filter('Copy B');
                    EntityName = 'irs1099formreport';
                    EntitySetName = 'irs1099formreports';
                    Caption = 'IRS 1099 Form Reports';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
    end;
}