// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Archive;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Attachment;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

pageextension 18109 "GST Sales Return Ord Arch Ext" extends "Sales Return Order Archive"
{
    layout
    {
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = SalesLinesArchive;
                SubPageLink = "Table ID Filter" = const(5108), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No."), "Version No. Filter" = field("Version No.");
                ApplicationArea = Basic, Suite;
            }
#if not CLEAN25
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(36),
                              "No." = field("No."),
                              "Document Type" = field("Document Type");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(Database::"Sales Header"),
                              "No." = field("No."),
                              "Document Type" = field("Document Type");
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Suite;
                ShowFilter = false;
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No."),
                              "Date Filter" = field("Date Filter");
                Visible = false;
            }
            part(Control1900316107; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Sell-to Customer No."),
                              "Date Filter" = field("Date Filter");
            }
            part(Control1906127307; "Sales Line FactBox")
            {
                ApplicationArea = Suite;
                Provider = SalesLinesArchive;
                SubPageLink = "Document Type" = field("Document Type"),
                              "Document No." = field("Document No."),
                              "Line No." = field("Line No.");
            }
        }
    }
}
