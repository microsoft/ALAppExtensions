// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using System.Security.AccessControl;
using System.Security.User;

table 18872 "TCS Challan Register"
{
    Caption = 'TCS Challan Register';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Challan No."; Code[9])
        {
            Caption = 'Challan No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "BSR Code"; Code[20])
        {
            Caption = 'BSR Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "TCS Interest Amount"; Decimal)
        {
            Caption = 'TCS Interest Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "TCS Others"; Decimal)
        {
            Caption = 'TCS Others';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Paid By Book Entry"; Boolean)
        {
            Caption = 'Paid By Book Entry';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Pay TCS Document No."; Code[20])
        {
            Caption = 'Pay TCS Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Total TCS Amount"; Decimal)
        {
            Caption = 'Total TCS Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Total Surcharge Amount"; Decimal)
        {
            Caption = 'Total Surcharge Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Total eCess Amount"; Decimal)
        {
            Caption = 'Total eCess Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Total Invoice Amount"; Decimal)
        {
            Caption = 'Total Invoice Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Total TCS Including SHE Cess"; Decimal)
        {
            Caption = 'Total TCS Including SHE Cess';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "TCS Nature of Collection"; Code[10])
        {
            Caption = 'TCS Nature of Collection';
            TableRelation = "TCS Nature Of Collection";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "TCS Payment Date"; Date)
        {
            Caption = 'TCS Payment Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "T.C.A.N. No."; Code[20])
        {
            Caption = 'T.C.A.N. No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Check / DD No."; Code[10])
        {
            Caption = 'Check / DD No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; "Check / DD Date"; Date)
        {
            Caption = 'Check / DD Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Last Bank Challan No."; Code[9])
        {
            Caption = 'Last Bank Challan No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Last Bank-Branch Code"; Code[20])
        {
            Caption = 'Last Bank-Branch Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(22; "Last Date of Challan No."; Date)
        {
            Caption = 'Last Date of Challan No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Last TCS Others"; Decimal)
        {
            Caption = 'Last TCS Others';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(24; "Last TCS Interest"; Decimal)
        {
            Caption = 'Last TCS Interest';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(25; "Financial Year"; Code[10])
        {
            Caption = 'Financial Year';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(26; "Assessment Year"; Code[10])
        {
            Caption = 'Assessment Year';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(27; Quarter; Code[10])
        {
            Caption = 'Quarter';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(28; "Nil Challan Indicator"; Boolean)
        {
            Caption = 'Nil Challan Indicator';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(29; "Last Transfer Voucher No."; Code[9])
        {
            Caption = 'Last Transfer Voucher No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(30; "Transfer Voucher No."; Code[9])
        {
            Caption = 'Transfer Voucher No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";

            trigger OnLookup()
            begin
                LookupUserID("User ID");
            end;
        }
        field(32; "Total SHE Cess Amount"; Decimal)
        {
            Caption = 'Total SHE Cess Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(33; "Minor Head Code"; Enum "Minor Head Type")
        {
            Caption = 'Minor Head Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(34; "TCS Fee"; Decimal)
        {
            Caption = 'TCS Fee';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Quarter, "Financial Year")
        {
        }
        key(Key3; "Challan Date")
        {
        }
        key(Key4; "Financial Year")
        {
        }
    }

    procedure LookupUserID(var UserName: Code[50])
    var
        SID: Guid;
    begin
        LookupUser(UserName, SID);
    end;

    local procedure LookupUser(var UserName: Code[50]; var SID: Guid): Boolean
    var
        User: Record User;
    begin
        User.SetCurrentKey("User Name");
        User."User Name" := UserName;
        if User.Find('=><') then;
        if Page.RunModal(Page::Users, User) = Action::LookupOK then begin
            UserName := User."User Name";
            SID := User."User Security ID";
            exit(true);
        end;
        exit(false);
    end;
}
