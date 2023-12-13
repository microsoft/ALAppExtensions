// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Navigate;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 31107 "VAT Ctrl. Report Line CZL"
{
    Caption = 'VAT Control Report Line';
    LookupPageId = "VAT Ctrl. Report Lines CZL";
    DrillDownPageId = "VAT Ctrl. Report Lines CZL";

    fields
    {
        field(1; "VAT Ctrl. Report No."; Code[20])
        {
            Caption = 'Control Report No.';
            TableRelation = "VAT Ctrl. Report Header CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "VAT Ctrl. Report Section Code"; Code[20])
        {
            Caption = 'VAT Control Report Section Code';
            TableRelation = "VAT Ctrl. Report Section CZL";
            DataClassification = CustomerContent;
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; "Original Document VAT Date"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
        field(15; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
            TableRelation = if (Type = const(Purchase)) Vendor else
            if (Type = const(Sale)) Customer;
            DataClassification = CustomerContent;
        }
        field(16; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(17; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(18; "Tax Registration No."; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(20; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(30; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
            DataClassification = CustomerContent;
        }
        field(31; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Editable = false;
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(32; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Editable = false;
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(35; Base; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(36; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "VAT Rate"; Option)
        {
            Caption = 'VAT Rate';
            OptionCaption = ' ,Base,Reduced,Reduced 2';
            OptionMembers = " ",Base,Reduced,"Reduced 2";
            DataClassification = CustomerContent;
        }
        field(41; "Commodity Code"; Code[10])
        {
            Caption = 'Commodity Code';
            TableRelation = "Commodity CZL";
            DataClassification = CustomerContent;
        }
        field(42; "Supplies Mode Code"; Option)
        {
            Caption = 'Supplies Mode Code';
            OptionCaption = ' ,par. 89,par. 90';
            OptionMembers = " ","par. 89","par. 90";
            DataClassification = CustomerContent;
        }
        field(43; "Corrections for Bad Receivable"; Enum "VAT Ctrl. Report Corect. CZL")
        {
            Caption = 'Corrections for Bad Receivable';
            DataClassification = CustomerContent;
        }
        field(45; "Ratio Use"; Boolean)
        {
            Caption = 'Ratio Use';
            DataClassification = CustomerContent;
        }
        field(46; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(47; "Birth Date"; Date)
        {
            Caption = 'Birth Date';
            DataClassification = CustomerContent;
        }
        field(48; "Place of Stay"; Text[50])
        {
            Caption = 'Place of Stay';
            DataClassification = CustomerContent;
        }
        field(50; "Exclude from Export"; Boolean)
        {
            Caption = 'Exclude from Export';
            DataClassification = CustomerContent;
        }
        field(60; "Closed by Document No."; Code[20])
        {
            Caption = 'Closed by Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "Closed Date"; Date)
        {
            Caption = 'Closed Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "VAT Ctrl. Report No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "VAT Ctrl. Report No.", "Posting Date")
        {
        }
        key(Key3; "VAT Ctrl. Report No.", "VAT Date")
        {
        }
        key(Key4; "Closed by Document No.")
        {
        }
    }
    trigger OnDelete()
    var
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
    begin
        TestStatusOpen();

        VATCtrlReportEntLinkCZL.SetRange("VAT Ctrl. Report No.", "VAT Ctrl. Report No.");
        VATCtrlReportEntLinkCZL.SetRange("Line No.", "Line No.");
        VATCtrlReportEntLinkCZL.DeleteAll();
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
    end;

    trigger OnModify()
    begin
        TestStatusOpen();
    end;

    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";

    local procedure TestStatusOpen()
    begin
        VATCtrlReportHeaderCZL.Get("VAT Ctrl. Report No.");
        VATCtrlReportHeaderCZL.TestField(Status, VATCtrlReportHeaderCZL.Status::Open);
    end;

    procedure Navigate()
    var
        PageNavigate: Page Navigate;
    begin
        PageNavigate.SetDoc("Posting Date", "Document No.");
        PageNavigate.Run();
    end;

    procedure ChangeVATControlRepSection()
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        VATCtrlReportSectionsCZL: Page "VAT Ctrl. Report Sections CZL";
    begin
        VATCtrlReportSectionsCZL.LookupMode := true;
        if VATCtrlReportSectionsCZL.RunModal() <> Action::LookupOK then
            exit;
        VATCtrlReportSectionCZL.Init();
        VATCtrlReportSectionsCZL.GetRecord(VATCtrlReportSectionCZL);
        ChangeVATControlRepSectionCode(VATCtrlReportSectionCZL.Code);
    end;

    procedure ChangeVATControlRepSectionCode(VATCtrlRptSectionCode: Code[20])
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        VATCtrlReportLineCZL.Copy(Rec);
        VATCtrlReportLineCZL.ModifyAll("VAT Ctrl. Report Section Code", VATCtrlRptSectionCode);
    end;
}
